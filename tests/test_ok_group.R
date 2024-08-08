library(unittest)

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

expect_equal <- function (expr, expected) {
    actual <- capture.output(expr)
    if (!identical(all.equal(actual, expected), TRUE)) {
        stop("ok_group output didn't match: ", actual)
    }
}

# Expression printed
expect_equal(ok_group("camels", TRUE), c(
    "# camels"))

# Can have multiple lines in a vector
expect_equal(ok_group(c("camels", "ostriches"), TRUE), c(
    "# camels",
    "# ostriches"))

# Can divide lines with newlines too
expect_equal(ok_group(c("camels\nbadgers\r\nhoney badgers", "ostriches"), FALSE), c(
    "# camels",
    "# badgers",
    "# honey badgers",
    "# ostriches"))

# Expression evaluated after printing section message
expect_equal(ok_group("camels", print("moo")), c(
    "# camels",
    '[1] "moo"'))

# Return NULL
expect_equal({
    if (!is.null(ok_group("camels", 6))) stop("Didn't return NULL")
}, c("# camels"))

run_script('
    library(unittest)
    options(unittest.stop_on_fail = FALSE)
    ok_group("snake", {
        ok(1==1)
        ok(1==2)
        stop("hiss!")
        ok(1==3)
    })
    print("badger")
', 10, c(
    "# snake",
    "ok - 1 == 1",
    "not ok - 1 == 2",
    "# Test returned non-TRUE value:",
    "# [1] FALSE",
    "not ok - ok_group 'snake'",
    "# Exception: hiss!",
    "# Traceback:",
    '#  1: stop("hiss!")',
    '[1] "badger"',
    "1..3",
    "# Looks like you failed 1 of 2 tests.",
    "# 2: 1 == 2",
    "# Looks like 1 groups raised an exception.",
    "# 1: ok_group 'snake'",
    NULL ), "Execution continues after an exception, if stop_on_fail FALSE")

run_script('
    library(unittest)
    options(unittest.stop_on_fail = TRUE)
    ok_group("snake", stop("hiss!"))
    print("badger")
', 11, c(
    "# snake",
    "not ok - ok_group 'snake'",
    "# Exception: hiss!",
    "# Traceback:",
    '#  1: stop("hiss!")',
    "Bail out! Looks like 0 tests ran, but a group failed and unittest.stop_on_fail is set",
    NULL ), "Execution stops after an exception, if stop_on_fail TRUE")

run_script('
    library(unittest)
    options(unittest.stop_on_fail = FALSE)
    ok_group("snake", reptile <- snake)
', 10, c(
    "# snake",
    "not ok - ok_group 'snake'",
    "# Exception: object 'snake' not found",
    "# Traceback:",
    '#  (none)',
    "1..1",
    "# Looks like 1 groups raised an exception.",
    "# 1: ok_group 'snake'",
    NULL ), "Don't output an empty call stack")
