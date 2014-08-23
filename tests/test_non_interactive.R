R_binary <- file.path(R.home("bin"), "R")

run_script <- function(script) {
    warn <- ""
    out <- withCallingHandlers(
        system2(
            R_binary,
            c("--vanilla", "--slave"),
            input=script,
            wait = TRUE, stdout = TRUE, stderr = TRUE),
        warning = function (w) {
            warn <<- sub('running command.* had status', 'command returned status', conditionMessage(w))
            invokeRestart("muffleWarning")
        })
    invisible( c(warn, out) )
}

compare <- function(actual, expected, description) {
    if( isTRUE(all.equal(actual, expected)) ) {
        cat("ok\n")
    } else {
        cat("\nExpected:",
            expected,
            "\nGot:",
            actual,
            sep = "\n"
        )
        stop( description )
    }
}

# one test one success
out <- run_script("library(unittest, quietly = TRUE)\nok(1==1,\"1 equals 1\")")
compare(out, c(
        "",
        "ok - 1 equals 1",
        "# Looks like you passed all 1 tests."
    ),
    "One test one success case not as expected"
) 

# two tests two sucesses
out <- run_script("library(unittest, quietly = TRUE)\nok(1==1,\"1 equals 1\")\nok(2==2,\"2 equals 2\")")
compare(out, c(
        "",
        "ok - 1 equals 1",
        "ok - 2 equals 2",
        "# Looks like you passed all 2 tests."
    ),
    "Two tests two successes case not as expected"
) 

# one test one failure 
out <- run_script("library(unittest, quietly = TRUE)\nok(1!=1,\"1 equals 1\")")
compare(out, c(
        "command returned status 10",
        "not ok - 1 equals 1",
        "# Test returned non-TRUE value:",
        "# [1] FALSE",
        "# Looks like you failed 1 of 1 tests."
    ),
    "One test one failure case not as expected"
)

# four tests two failures 
out <- run_script("library(unittest, quietly = TRUE)\nok(1==1,\"1 equals 1\")\nok(2!=2,\"2 equals 2\")\nok(3==3,\"3 equals 3\")\nok(4!=4,\"4 equals 4\")")
compare(out, c(
        "command returned status 10",
        "ok - 1 equals 1",
        "not ok - 2 equals 2",
        "# Test returned non-TRUE value:",
        "# [1] FALSE",
        "ok - 3 equals 3",
        "not ok - 4 equals 4",
        "# Test returned non-TRUE value:",
        "# [1] FALSE",
        "# Looks like you failed 2 of 4 tests."
    ),
    "Four tests two failures case not as expected"
)

# check detaching stops non_interactive_exit functionality
out <- run_script("library(unittest, quietly = TRUE)\nok(1!=1,\"1 equals 1\")\ndetach(package:unittest,unload=FALSE)")
compare(out, c(
        "",
        "not ok - 1 equals 1",
        "# Test returned non-TRUE value:",
        "# [1] FALSE"
    ),
    "detaching stops non_interactive_exit functionality"
)

# and if we re-attach it works again
out <- run_script("library(unittest, quietly = TRUE)\nok(1!=1,\"1 equals 1\")\ndetach(package:unittest,unload=FALSE)\nlibrary(unittest, quietly = TRUE)\nok(2!=2,\"2 equals 2\")")
compare(out, c(
        "command returned status 10",
        "not ok - 1 equals 1",
        "# Test returned non-TRUE value:",
        "# [1] FALSE",
        "not ok - 2 equals 2",
        "# Test returned non-TRUE value:",
        "# [1] FALSE",
        "# Looks like you failed 1 of 1 tests."
    ),
    "detaching stops non_interactive_exit functionality and then re-attaching resets and the rest still works"
)

# check detaching and unloading stops non_interactive_exit functionality
out <- run_script("library(unittest, quietly = TRUE)\nok(1!=1,\"1 equals 1\")\ndetach(package:unittest,unload=TRUE)")
compare(out, c(
        "",
        "not ok - 1 equals 1",
        "# Test returned non-TRUE value:",
        "# [1] FALSE"
    ),
    "detaching and unloading stops non_interactive_exit functionality"
)

# and if we reload and re-attach it works again
out <- run_script("library(unittest, quietly = TRUE)\nok(1!=1,\"1 equals 1\")\ndetach(package:unittest,unload=TRUE)\nlibrary(unittest, quietly = TRUE)\nok(2!=2,\"2 equals 2\")")
compare(out, c(
        "command returned status 10",
        "not ok - 1 equals 1",
        "# Test returned non-TRUE value:",
        "# [1] FALSE",
        "not ok - 2 equals 2",
        "# Test returned non-TRUE value:",
        "# [1] FALSE",
        "# Looks like you failed 1 of 1 tests."
    ),
    "detaching and unloading stops non_interactive_exit functionality and then reloading and re-attaching resets and the rest still works"
)

