#
# Note:
#    None of these tests produce any output on success
#


library(unittest)


# -----
# setup
# -----

expect_success <- function( ok_call ) {
    output <- paste(capture.output(ok_call), collapse = " ")
    if(! grepl(x = output, pattern='^ok -', perl=TRUE)) {
        stop(paste('expected success, got: ', output)) 
    }
    invisible(TRUE)
}

expect_failure <- function(ok_call, exp_fail_regex = NULL) {
    output <- paste(capture.output(ok_call), collapse = "\n")
    if(! grepl(x = output, pattern='^not ok -', perl=TRUE)) {
        stop(paste('expected failure, got: ', output)) 
    }
    if(! is.null(exp_fail_regex)) {
        if(! grepl(x = output, pattern = exp_fail_regex, perl=TRUE)) {
            stop(paste('\'exp_fail_regex\' did not match. Got: ', output, sep = ""))
        }
    }
    invisible(TRUE)
}

expect_error <- function(ok_call, exp_err_regex = NULL) {
    msg <- tryCatch({ok_call ; "No error returned"}, error = function(e) e$message)
    if(!grepl(exp_err_regex, msg)) {
        stop("'", msg, "' should contain '", exp_err_regex, "'")
    }
}

regex_escape <- function (x) {
    gsub("([.|()\\^{}+$*?]|\\[|\\])", "\\\\\\1", x)
}

# -----------------
# test invalid uses
# -----------------

expect_error(
    ok(TRUE, 5),
    '\'description\' must be of type \'chr\''
)

expect_error(
    ok(TRUE, c("Lots", "of", "string")),
    '\'description\' must be of type \'chr\''
)

# ------------
# test success
# ------------

expect_success(
    ok(TRUE, "true")
)
expect_success(
    ok(1==1, "one equals one")
)

expect_success(
    ok(all.equal(c(1,2), c(1,2)), "one and two are the same")
)

expect_success(
    ok(all(1==1, 2==2), "one and two are still the same")
)


# ------------
# test failure
# ------------

expect_failure(
    ok(1==2, "one equals two"),
    '# \\[1\\] FALSE'
)

# all.equal(...) works and sees past the first element
expect_failure(
    ok(all.equal(c(1,2), c(1,4)), "one equals one, and two equals four"),
    '# Mean relative difference: 1'
)

# on an error, we display the error and the failing call
fn <- function(x) {
    stop("Oh no")
}
complex_call <- function(...) {
    fn(badgers)
}
expect_failure(
    ok(fn(5), "Function that returns error"),
    'Oh no(.|\n)*fn\\(5\\)'
)
expect_failure(
    ok(complex_call(badgers = "yes", locations = c("Bungay", "Milton Keynes", "Hearne Bay", "Wigan", "Hereford", "Timperley", "Cardiff", "Hexham", "Bangor")), "Multi-line stacktrace"),
    paste(
        regex_escape('# Traceback:'),
        regex_escape('#  1: complex_call(badgers = "yes", locations = c("Bungay", "Milton Keynes", '),
        regex_escape('#       "Hearne Bay", "Wigan", "Hereford", "Timperley", "Cardiff", '),
        regex_escape('#       "Hexham", "Bangor"))'),
        regex_escape('#  2: fn(badgers)'),
        regex_escape('#  3: stop("Oh no")'),
        sep = '\\n', collapse = '\\n'
    )
)

# Stacktrace not thwarted by closure
expect_failure(
    do.call(function (x) {ok(stop("erk"), "Test fails")}, list(1)),
    paste(
        regex_escape('# Traceback:'),
        regex_escape('#  1: stop("erk")'),
        sep = '\\n', collapse = '\\n'
    )
)

# Stacktrace not thwarted by unittest::ok
expect_failure(
    unittest::ok(complex_call(badgers = "yes"), "Calling unittest::ok"),
    paste(
        regex_escape('# Traceback:'),
        regex_escape('#  1: complex_call(badgers = "yes")'),
        regex_escape('#  2: fn(badgers)'),
        regex_escape('#  3: stop("Oh no")'),
        sep = '\\n', collapse = '\\n'
    )
)

# ------------------------
# Only TRUE counts as true
# ------------------------

expect_failure(
    ok(c(1,2)==c(1,3), "directly compare vector"),
    '# Test returned non-TRUE value:\n# \\[1\\]  TRUE FALSE'
)

expect_success(
    ok(TRUE, "truth")
)

expect_failure(
    ok(c(TRUE, TRUE), "too much truth"),
    "# Test returned non-TRUE value:\n# \\[1\\] TRUE TRUE"
)

expect_failure(
    ok(1, "he may be the one but he is not truth"),
    '# Test returned non-TRUE value:\n# \\[1\\] 1'
)

expect_failure(
    ok("1", "quoted one"),
    '# Test returned non-TRUE value:\n# 1'
)

expect_failure(
    ok("TRUE", "quoted truth"),
    '# Test returned non-TRUE value:\n# TRUE'
)

# -------------------
# default description
# -------------------

printed <- capture.output( ok( 3==3 ) )
if(! grepl(x = printed, pattern = '3\\s*==\\s*3', perl=TRUE)) {
    stop("ok() without description looks broken")
}

# ---------------------------------
# Character vectors are shown as-is
# ---------------------------------

expect_failure(
    ok(c("Site is silent, yes", "No voices can be heard now", "The cows roll their eyes."), "haiku"),
    '# Test returned non-TRUE value:\n# Site is silent, yes\n# No voices can be heard now\n# The cows roll their eyes.'
)

expect_failure(
    ok(c("Login incorrect.\nOnly perfect spellers may", "Enter this system."), "some newlines"),
    '# Test returned non-TRUE value:\n# Login incorrect.\n# Only perfect spellers may\n# Enter this system.'
)

expect_failure(
    ok("A file that big?\nIt might be very useful\nBut now it is gone.", "all newlines"),
    '# Test returned non-TRUE value:\n# A file that big\\?\n# It might be very useful\n# But now it is gone.'
)

expect_failure(
    ok(c("A file that big?\n\nIt might be very useful", "", "But now it is gone."), "empty lines inbetween"),
    '# Test returned non-TRUE value:\n# A file that big\\?\n# \n# It might be very useful\n# \n# But now it is gone.'
)

# ------------
# return value
# ------------

dev_null <- capture.output(rv <- ok(2==2, "two equals two"))  # nothing else prints so neither should this
if( ! identical(rv, TRUE) ) {
    stop("ok() return value looks wrong")
}

# ---------------------
# unittest.stop_on_fail
# ---------------------
test_path <- tempfile(fileext = ".R")
writeLines('
library(unittest)

finished <- FALSE
ok(1==1)
ok(1==2)
ok(1==1)
finished <- TRUE
', con = test_path)

# Without unittest.stop_on_fail, we see all failures
options(unittest.stop_on_fail = NULL)
success <- tryCatch({source(test_path) ; TRUE}, error = function (e) { FALSE })
stopifnot(success)
stopifnot(finished)

# With, we stop at the first failing test:
options(unittest.stop_on_fail = TRUE)
success <- tryCatch({source(test_path) ; TRUE}, error = function (e) { FALSE })
stopifnot(!success)
stopifnot(!finished)

# Tests shouldn't be reported as unittest failures
unittest:::clear_outcomes()
options(unittest.stop_on_fail = NULL)
