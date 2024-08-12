R_binary <- file.path(R.home("bin"), "R")

run_script <- function(script, expected_status, expected_out, description) {
    # solaris does not like pipes so use tmp files as intermediaries
    tmpfiles <- tempfile(pattern = c('R_unittest_stdout_','R_unittest_stderr_'), tmpdir = tempdir())
    exit_status <- withCallingHandlers(
        system2(
            R_binary,
            c("--vanilla", "--slave"),
            input = paste0(script, collapse = "\n"),
            wait = TRUE, stdout = tmpfiles[1], stderr = tmpfiles[2]),
        warning = function (w) {
            invokeRestart("muffleWarning")
        }
    )
    actual <- readLines(tmpfiles[1])  # only interested in stdout
    if( isTRUE(all.equal(actual, expected_out)) && exit_status == expected_status) {
        cat("ok\n")
    } else {
        cat("\nExpected status",
            expected_status,
            "\nGot status",
            exit_status,
            "\nExpected stdout:",
            expected_out,
            "\nGot stdout:",
            actual,
            sep = "\n"
        )
        stop( description )
    }
    invisible(c(exit_status, actual))
}

# one test one success
run_script(
    "library(unittest)\nok(1==1,\"1 equals 1\")",
    0,
    c(
        "ok - 1 equals 1",
        "1..1",
        "# Looks like you passed all 1 tests."
    ),
    "One test one success case not as expected"
) 

# Success with a multi-line expression
run_script(
    "library(unittest)\nok(all.equal(c('This is a string', 'This is a string too', 'Exciting times'),\nc('This is a string', 'This is a string too', 'Exciting times')))",
    0,
    c(
        'ok - all.equal(c("This is a string", "This is a string too", "Exc',
        "1..1",
        "# Looks like you passed all 1 tests."
    ),
    "One test one success case not as expected"
) 

# two tests two sucesses
run_script(
    "library(unittest)\nok(1==1,\"1 equals 1\")\nok(2==2,\"2 equals 2\")",
    0,
    c(
        "ok - 1 equals 1",
        "ok - 2 equals 2",
        "1..2",
        "# Looks like you passed all 2 tests."
    ),
    "Two tests two successes case not as expected"
) 

# one test one failure 
run_script(
    "library(unittest)\nok(1!=1,\"1 equals 1\")",
    10,
    c(
        "not ok - 1 equals 1",
        "# Test returned non-TRUE value:",
        "# [1] FALSE",
        "1..1",
        "# Looks like you failed 1 of 1 tests."
    ),
    "One test one failure case not as expected"
)

# four tests two failures, not all tests failed so included which failed
run_script(
    "library(unittest)\nok(1==1,\"1 equals 1\")\nok(2!=2,\"2 equals 2\")\nok(3==3,\"3 equals 3\")\nok(4!=4,\"4 equals 4\")",
    10,
    c(
        "ok - 1 equals 1",
        "not ok - 2 equals 2",
        "# Test returned non-TRUE value:",
        "# [1] FALSE",
        "ok - 3 equals 3",
        "not ok - 4 equals 4",
        "# Test returned non-TRUE value:",
        "# [1] FALSE",
        "1..4",
        "# Looks like you failed 2 of 4 tests.",
        "# 2: 2 equals 2",
        "# 4: 4 equals 4",
        NULL
    ),
    "Four tests two failures case not as expected"
)

# check detaching stops non_interactive_exit functionality
run_script(
    "library(unittest)\nok(1!=1,\"1 equals 1\")\ndetach(package:unittest,unload=FALSE)",
    0,
    c(
        "not ok - 1 equals 1",
        "# Test returned non-TRUE value:",
        "# [1] FALSE"
    ),
    "detaching stops non_interactive_exit functionality"
)

# and if we re-attach it works again
run_script(
    "library(unittest)\nok(1!=1,\"1 equals 1\")\ndetach(package:unittest,unload=FALSE)\nlibrary(unittest)\nok(2!=2,\"2 equals 2\")",
    10,
    c(
        "not ok - 1 equals 1",
        "# Test returned non-TRUE value:",
        "# [1] FALSE",
        "not ok - 2 equals 2",
        "# Test returned non-TRUE value:",
        "# [1] FALSE",
        "1..1",
        "# Looks like you failed 1 of 1 tests."
    ),
    "detaching stops non_interactive_exit functionality and then re-attaching resets and the rest still works"
)

# check detaching and unloading stops non_interactive_exit functionality
run_script(
    "library(unittest)\nok(1!=1,\"1 equals 1\")\ndetach(package:unittest,unload=TRUE)",
    0,
    c(
        "not ok - 1 equals 1",
        "# Test returned non-TRUE value:",
        "# [1] FALSE"
    ),
    "detaching and unloading stops non_interactive_exit functionality"
)

# and if we reload and re-attach it works again
run_script(
    "library(unittest)\nok(1!=1,\"1 equals 1\")\ndetach(package:unittest,unload=TRUE)\nlibrary(unittest)\nok(2!=2,\"2 equals 2\")",
    10,
    c(
        "not ok - 1 equals 1",
        "# Test returned non-TRUE value:",
        "# [1] FALSE",
        "not ok - 2 equals 2",
        "# Test returned non-TRUE value:",
        "# [1] FALSE",
        "1..1",
        "# Looks like you failed 1 of 1 tests."
    ),
    "detaching and unloading stops non_interactive_exit functionality and then reloading and re-attaching resets and the rest still works"
)

# Too many test failures and we don't print a summary
run_script(
    paste(
        "library(unittest)",
        paste0("ok(1==", 1:30, ", '1 equals ", 1:30, "')", collapse = "\n"),
        sep = "\n" ),
    10,
    c(
        "ok - 1 equals 1",
        unlist(strsplit(paste0(
            "not ok - 1 equals ", 2:30, "\n",
            "# Test returned non-TRUE value:\n",
            "# [1] FALSE" ), "\n")),
        "1..30",
        "# Looks like you failed 29 of 30 tests.",
        NULL
    ),
    "By setting an errors variable in globalenv we managed to influence unittest output"
)

# Failure outside test
run_script(
    paste(
        "library(unittest)",
        "ok(1==1, '1 equals 1')",
        "stop('eek\nook')",
        "ok(2==2, '2 equals 2')",
        "", sep = "\n"
    ),
    11,
    c(
        "ok - 1 equals 1",
        "Bail out! Looks like 1 tests ran, but script ended prematurely",
        "# Error: eek",
        "# ook",
        "# Traceback:",
        '#  1: stop("eek\\nook")',
        NULL
    ),
    "Failure outside tests"
)

# Failure before test
run_script(
    paste(
        "library(unittest)",
        "stop('eek\nook')",
        "ok(1==1, '1 equals 1')",
        "ok(2==2, '2 equals 2')",
        "", sep = "\n"
    ),
    11,
    c(
        "Bail out! Looks like 0 tests ran, but script ended prematurely",
        "# Error: eek",
        "# ook",
        "# Traceback:",
        '#  1: stop("eek\\nook")',
        NULL
    ),
    "Failure before tests"
)

# Failure before test-failure (we count all tests, including failures)
run_script(
    paste(
        "library(unittest)",
        "ok(1==1, '1 equals 1')",
        "ok(1==2, '1 equals 2')",
        "stop('eek\nook')",
        "", sep = "\n"
    ),
    11,
    c(
        "ok - 1 equals 1",
        "not ok - 1 equals 2",
        "# Test returned non-TRUE value:",
        "# [1] FALSE",
        "Bail out! Looks like 2 tests ran, but script ended prematurely",
        "# Error: eek",
        "# ook",
        "# Traceback:",
        '#  1: stop("eek\\nook")',
        NULL
    ),
    "Failure before tests"
)

# tryCatch() doesn't count as failure
run_script(
    paste(
        "library(unittest)",
        "ok(1==1, '1 equals 1')",
        "tryCatch(stop('not fatal'), error = function (e) NULL)",
        "ok(2==2, '2 equals 2')",
        "", sep = "\n"
    ),
    0,
    c(
        "ok - 1 equals 1",
        "NULL",
        "ok - 2 equals 2",
        "1..2",
        "# Looks like you passed all 2 tests.",
        NULL
    ),
    "Caught errors outside tests"
)

# Redirection of output to tempfile
tf <- tempfile()
run_script(
    c(
        'library(unittest)',
        deparse1(substitute( options(unittest.output=tf), list(tf = tf) )),
        'ok(1==1, "1 equals 1")',
        'writeLines("Hello")',
        'stop("erk")',
        NULL
    ),
    11,
    c(
        "Hello",
        NULL
    ),
    "Failure outside tests, redirected output"
)
stopifnot(identical(readLines(tf), c(
    "ok - 1 equals 1",
    "Bail out! Looks like 1 tests ran, but script ended prematurely",
    "# Error: erk",
    "# Traceback:",
    '#  1: stop("erk")',
    NULL)))

# unittest output shouldn't be influenced by the global environment
run_script(
    paste(
        "library(unittest)",
        "errors <- 'This is not an error, just a string I made'",
        "ok(1==1, '1 equals 1')",
        sep = "\n" ),
    0,
    c(
        "ok - 1 equals 1",
        "1..1",
        "# Looks like you passed all 1 tests."
    ),
    "By setting an errors variable in globalenv we managed to influence unittest output"
)

run_script('
    library(unittest)
    options(cli.num_colors = 16)
    ok(1==1)
    ok(ut_cmp_equal(as.list(1:2), as.list(1:3)))
', 10, c(
    "\033[0;1mok - 1 == 1\033[0m",
    "\033[31;1mnot ok - ut_cmp_equal(as.list(1:2), as.list(1:3))\033[0m",
    "# Test returned non-TRUE value:",
    "# Length mismatch: comparison on first 2 components",
    "# \033[1m--- as.list(1:2)\033[m",
    "# \033[1m+++ as.list(1:3)\033[m",
    "# [[1]]\033[m",
    "# [1] 1\033[m",
    "# ",
    "# [[2]]\033[m",
    "# [1] 2\033[m",
    "# ",
    "# \033[32m{+[[3]]+}\033[m",
    "# \033[32m{+[1] 3+}\033[m",
    "1..2",
    "# Looks like you failed 1 of 2 tests.",
    "# 2: ut_cmp_equal(as.list(1:2), as.list(1:3))",
    NULL ), "Ok / not ok output colourful if turned on")

run_script('
    library(unittest)
    options(cli.num_colors = 1)
    ok(1==1)
    ok(ut_cmp_equal(as.list(1:2), as.list(1:3)))
', 10, c(
    "ok - 1 == 1",
    "not ok - ut_cmp_equal(as.list(1:2), as.list(1:3))",
    "# Test returned non-TRUE value:",
    "# Length mismatch: comparison on first 2 components",
    "# --- as.list(1:2)",
    "# +++ as.list(1:3)",
    "# [[1]]",
    "# [1] 1",
    "# ",
    "# [[2]]",
    "# [1] 2",
    "# ",
    "# {+[[3]]+}",
    "# {+[1] 3+}",
    "1..2",
    "# Looks like you failed 1 of 2 tests.",
    "# 2: ut_cmp_equal(as.list(1:2), as.list(1:3))",
    NULL ), "Ok / not ok output not colourful if turned off")
