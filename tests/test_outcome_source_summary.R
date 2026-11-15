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
        cat(paste("Expected status:", expected_status),
            paste("Got status:", exit_status),
            "=== Expected stdout: ===",
            expected_out,
            "=== Got stdout: ===",
            actual,
            "==========",
            sep = "\n"
        )
        stop( description )
    }
    invisible(c(exit_status, actual))
}

write_script <- function (...) {
    path <- tempfile(fileext = ".R")
    writeLines(c(...), con = path)
    deparse1(path)
}

# Pretend to be interactive: Disable non-interactive summary (started by library()), so source() summaries are used
preamble <- '
    library("unittest")
    assignInNamespace("is_interactive", function () TRUE, "unittest")
    unittest:::clear_outcomes()
'

passing <- write_script('ok(1==1)', 'ok(2==2)')
failing <- write_script('ok(1==1)', 'ok(2==1)')

run_script(paste0(preamble, '
    source(', passing, ')
    writeLines("It\'s over!")
'), 0, c(
    'ok - 1 == 1',
    'ok - 2 == 2',
    '1..2',
    '# Looks like you passed all 2 tests.',
    "It's over!",
    NULL ), "Summary after source(), script carries on")

run_script(paste0(preamble, '
    source(', failing, ')
    writeLines("It\'s over!")
'), 10, c(
    'ok - 1 == 1',
    'not ok - 2 == 1',
    '# Test returned non-TRUE value:',
    '# [1] FALSE',
    '1..2',
    '# Looks like you failed 1 of 2 tests.',
    '# 2: 2 == 1',
    NULL ), "Failures summarised after source(), script stopped")

run_script(paste0(preamble, '
    options(error = NULL)  # Use default (interactive-style) error handling
    source(', failing, ')
    writeLines("It\'s over!")
'), 10, c(
    'ok - 1 == 1',
    'not ok - 2 == 1',
    '# Test returned non-TRUE value:',
    '# [1] FALSE',
    '1..2',
    '# Looks like you failed 1 of 2 tests.',
    '# 2: 2 == 1',
    NULL ), "Failures stop script, regardless of error handler")

run_script(paste0(preamble, '
    x <- tryCatch(source(', failing, '), ut_test_failure = function (e) conditionMessage(e))
    writeLines(paste("Caught:", x))
'), 0, c(
    'ok - 1 == 1',
    'not ok - 2 == 1',
    '# Test returned non-TRUE value:',
    '# [1] FALSE',
    '1..2',
    '# Looks like you failed 1 of 2 tests.',
    '# 2: 2 == 1',
    'Caught: 1 test(s) failed',
    NULL ), "Failure can be caught as ut_test_failure")

run_script(paste0(preamble, '
    source(', passing, ')
    source(', failing, ')
    source(', passing, ')
'), 10, c(
    'ok - 1 == 1',
    'ok - 2 == 2',
    '1..2',
    '# Looks like you passed all 2 tests.',
    'ok - 1 == 1',
    'not ok - 2 == 1',
    '# Test returned non-TRUE value:',
    '# [1] FALSE',
    '1..2',
    '# Looks like you failed 1 of 2 tests.',
    '# 2: 2 == 1',
    NULL ), "Each source() gets a separate summary, stopped at first failing source()")

nested_fail <- write_script(paste0('source(', failing, ')'), 'ok(4==4)')
run_script(paste0(preamble, '
    source(', nested_fail, ')
'), 10, c(
    'ok - 1 == 1',
    'not ok - 2 == 1',
    '# Test returned non-TRUE value:',
    '# [1] FALSE',
    'ok - 4 == 4',
    '1..3',
    '# Looks like you failed 1 of 3 tests.',
    '# 2: 2 == 1',
    NULL ), "Failing nested source() runs rest of outer script, then stops")

nested <- write_script('ok(3==3)', paste0('source(', passing, ')'), 'ok(4==4)')
run_script(paste0(preamble, '
    source(', nested, ')
'), 0, c(
    'ok - 3 == 3',
    'ok - 1 == 1',
    'ok - 2 == 2',
    'ok - 4 == 4',
    '1..4',
    '# Looks like you passed all 4 tests.',
    NULL ), "Nested source() summarised once, at the end of the outermost")

run_script(paste0(preamble, '
    sys.source(', passing, ', envir = new.env())
'), 0, c(
    'ok - 1 == 1',
    'ok - 2 == 2',
    '1..2',
    '# Looks like you passed all 2 tests.',
    NULL ), "sys.source() also summarised")

erroring <- write_script('ok(1==1)', 'stop("Oh no!")', 'ok(2==2)')
run_script(paste0(preamble, '
    options(error = NULL)  # Use default (interactive-style) error handling
    source(', erroring, ')
    writeLines("It\'s over!")
'), 1, c(
    'ok - 1 == 1',
    'Bail out! Looks like 1 tests ran, but script ended prematurely',
    NULL ), "Summary reports script didn't finish when source() stops with an error")

fail_then_error <- write_script('ok(1==2)', 'stop("Oh no!")')
run_script(paste0(preamble, '
    options(error = NULL)  # Use default (interactive-style) error handling
    source(', fail_then_error, ')
'), 1, c(
    'not ok - 1 == 2',
    '# Test returned non-TRUE value:',
    '# [1] FALSE',
    'Bail out! Looks like 1 tests ran, but script ended prematurely',
    NULL ), "Error after failure: original error stops script, no extra test failure error")

run_script(paste0(preamble, '
    options(error = NULL, unittest.stop_on_fail = TRUE)
    source(', write_script('ok(1==1)', 'ok(2==1)', 'ok(3==3)'), ')
'), 1, c(
    'ok - 1 == 1',
    'not ok - 2 == 1',
    '# Test returned non-TRUE value:',
    '# [1] FALSE',
    'Bail out! Looks like 2 tests ran, but a test failed and unittest.stop_on_fail is set',
    NULL ), "stop_on_fail reported as the reason source() didn't finish")

run_script(paste0(preamble, '
    options(unittest.stop_on_fail = TRUE)
    x <- tryCatch(source(', erroring, '), error = function (e) conditionMessage(e))
    writeLines(paste("Caught:", x))
'), 0, c(
    'ok - 1 == 1',
    'Bail out! Looks like 1 tests ran, but script ended prematurely',
    'Caught: Oh no!',
    NULL ), "Error caught outside source() still reported as not finishing, stop_on_fail only blamed if last test failed")

run_script(paste0(preamble, '
    withRestarts(
        source(', write_script('ok(1==1)', 'invokeRestart("skip")', 'ok(2==2)'), '),
        skip = function () writeLines("Skipped"))
'), 0, c(
    'ok - 1 == 1',
    'Bail out! Looks like 1 tests ran, but script ended prematurely',
    'Skipped',
    NULL ), "Restart out of source() reported as not finishing")

grouped <- write_script('ok_group("Group", stop("Oh no!"))', 'ok(1==1)')
run_script(paste0(preamble, '
    source(', grouped, ')
'), 10, c(
    '# Group',
    "not ok - ok_group 'Group'",
    '# Exception: Oh no!',
    '# Traceback:',
    '#  1: stop("Oh no!")',
    'ok - 1 == 1',
    '1..1',
    '# Looks like 1 groups raised an exception.',
    "# 1: ok_group 'Group'",
    NULL ), "ok_group() exceptions are included in summary")

run_script(paste0(preamble, '
    ok(1==1)
    ok(2==2)
'), 0, c(
    'ok - 1 == 1',
    'ok - 2 == 2',
    NULL ), "No summary outside source()")

run_script(paste0('
    library("unittest")  # NB: Non-interactive, so already recording
    options(unittest.source_summary = TRUE)
    source(', passing, ')
    ok(3==3)
'), 0, c(
    'ok - 1 == 1',
    'ok - 2 == 2',
    'ok - 3 == 3',
    '1..3',
    '# Looks like you passed all 3 tests.',
    NULL ), "Already recording, so source() isn't summarised separately")

run_script(paste0(preamble, '
    options(unittest.source_summary = FALSE)
    source(', passing, ')
'), 0, c(
    'ok - 1 == 1',
    'ok - 2 == 2',
    NULL ), "unittest.source_summary = FALSE disables summary")

# Fake RStudio's debugSource(), which evaluates the file without calling source()
fake_debug_source <- '
    debugSource <- function (fileName) {
        for (expr in parse(fileName)) eval(expr, envir = globalenv())
        invisible(NULL)
    }
'

run_script(paste0(preamble, '
    rs_env <- new.env()
    local({', fake_debug_source, '}, envir = rs_env)
    attach(rs_env, name = "tools:rstudio")
    debugSource(', passing, ')
    writeLines("It\'s over!")
'), 0, c(
    'ok - 1 == 1',
    'ok - 2 == 2',
    '1..2',
    '# Looks like you passed all 2 tests.',
    "It's over!",
    NULL ), "RStudio's debugSource() summarised")

run_script(paste0(preamble, '
    rs_env <- new.env()
    local({', fake_debug_source, '}, envir = rs_env)
    attach(rs_env, name = "tools:rstudio")
    debugSource(', failing, ')
    writeLines("It\'s over!")
'), 10, c(
    'ok - 1 == 1',
    'not ok - 2 == 1',
    '# Test returned non-TRUE value:',
    '# [1] FALSE',
    '1..2',
    '# Looks like you failed 1 of 2 tests.',
    '# 2: 2 == 1',
    NULL ), "RStudio's debugSource() stops on failure")

run_script(paste0(preamble, fake_debug_source, '
    debugSource(', passing, ')
'), 0, c(
    'ok - 1 == 1',
    'ok - 2 == 2',
    NULL ), "debugSource() outside tools:rstudio isn't treated as source()")

# Fake Positron (ark)'s replacement base::source(), which either evaluates the file
# itself (when there are breakpoints) or falls back to the original source()
fake_ark_source <- function (eval_directly) paste0('
    local({
        original_source <- base::source
        ark_source <- function (file, ...) {
            if (', eval_directly, ') {
                for (expr in parse(file)) eval(expr, envir = globalenv())
                return(invisible(NULL))
            }
            original_source(file, ...)
        }
        for (env in list(baseenv(), .BaseNamespaceEnv)) {
            unlockBinding("source", env)
            assign("source", ark_source, envir = env)
            lockBinding("source", env)
        }
    })
')

for (eval_directly in c(FALSE, TRUE)) {
    run_script(paste0(preamble, fake_ark_source(eval_directly), '
        source(', passing, ')
        source(', failing, ')
        writeLines("It\'s over!")
    '), 10, c(
        'ok - 1 == 1',
        'ok - 2 == 2',
        '1..2',
        '# Looks like you passed all 2 tests.',
        'ok - 1 == 1',
        'not ok - 2 == 1',
        '# Test returned non-TRUE value:',
        '# [1] FALSE',
        '1..2',
        '# Looks like you failed 1 of 2 tests.',
        '# 2: 2 == 1',
        NULL ), paste0("Positron's replacement source() summarised, eval_directly = ", eval_directly))
}
