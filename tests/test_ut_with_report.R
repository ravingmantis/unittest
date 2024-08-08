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

test_path <- tempfile(fileext = ".R")
writeLines(c(
    'library(unittest)',
    'ok(1==1)',
    ''), con = test_path)

run_script(paste0('
    library("unittest")
    unittest:::clear_outcomes()  # Disable implicit summary from non-interactive script
    unittest:::ut_with_report(source(', deparse1(test_path), '))
    writeLines("It\'s over!")
'), 0, c(
    'ok - 1 == 1',
    '1..1',
    '# Looks like you passed all 1 tests.',
    "It's over!",
    NULL ), "Printed summary after sourcing a test script, script still carried on")

run_script('
    library("unittest")
    unittest:::clear_outcomes()  # Disable implicit summary from non-interactive script
    unittest:::ut_with_report({
        ok(1==1)
        ok(2==1)
    })
    writeLines("It\'s over!")
', 0, c(
    "ok - 1 == 1",
    "not ok - 2 == 1",
    "# Test returned non-TRUE value:",
    "# [1] FALSE",
    '1..2',
    "# Looks like you failed 1 of 2 tests.",
    "# 2: 2 == 1",
    "It's over!",
    NULL ), "Printed summary with failure, script still carried on")

run_script('
    library("unittest")
    unittest:::clear_outcomes()  # Disable implicit summary from non-interactive script
    unittest:::ut_with_report({
        ok(1==1)
        ok(2==1)
        stop("Oh no!")
        ok(3==1)
    })
    writeLines("It\'s over!")
', 0, c(
    "ok - 1 == 1",
    "not ok - 2 == 1",
    "# Test returned non-TRUE value:",
    "# [1] FALSE",
    "Bail out! Looks like 2 tests ran, but script ended prematurely",
    "# Oh no!",
    "# Traceback:",
    "#  1: stop(\"Oh no!\")",
    "It's over!",
    NULL ), "Printed summary with error, script still carried on")

run_script('
    library("unittest")
    unittest:::clear_outcomes()  # Disable implicit summary from non-interactive script
    options(unittest.stop_on_fail = TRUE)
    unittest:::ut_with_report({
        ok(1==1)
        ok(2==1)
        stop("Oh no!")
        ok(3==1)
    })
    writeLines("It\'s over!")
', 0, c(
    "ok - 1 == 1",
    "not ok - 2 == 1",
    "# Test returned non-TRUE value:",
    "# [1] FALSE",
    "Bail out! Looks like 2 tests ran, but a test failed and unittest.stop_on_fail is set",
    "It's over!",
    NULL ), "Stop-on-fail honoured, didn't get to the failure")

run_script('
    library(unittest)
    ok(1==1)
    unittest:::ut_with_report({
        ok(2==2)
        ok(3==3)
    })
    ok(4==4)
', 0, c(
    'ok - 1 == 1',
    'ok - 2 == 2',
    'ok - 3 == 3',
    'ok - 4 == 4',
    '1..4',
    '# Looks like you passed all 4 tests.',
NULL ), "Can nest outcome recording")
