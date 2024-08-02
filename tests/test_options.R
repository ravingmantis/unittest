library(unittest)

expect_equal <- function (expr, expected) {
    actual <- capture.output(expr)
    if (!identical(all.equal(actual, as.character(expected)), TRUE)) {
        str(actual, vec.len = 10000)
        stop("output didn't match: ", actual)
    }
}

# NB: In an interactive session, the state of unittest isn't guaranteed
if (!interactive()) {
    # By default, output in stdout
    expect_equal({
        ok_group("Some tests", {
            ok(ut_cmp_equal(4, 5), "4 == 5? Probably not")
        })
    }, c(
        "# Some tests",
        "not ok - 4 == 5? Probably not",
        "# Test returned non-TRUE value:",
        "# Mean relative difference: 0.25",
        "# --- 4",
        "# +++ 5",
        "# [1] [-4-]{+5+}"))
}

# Redirect to tempfile, output ended up there
tf <- tempfile()
options(unittest.output = tf)
expect_equal({
    ok_group("Some tests", {
        ok(ut_cmp_equal(5, 6), "5 == 6? Probably not")
    })
}, c())
expect_equal(writeLines(readLines(tf)), c(
    "# Some tests",
    "not ok - 5 == 6? Probably not",
    "# Test returned non-TRUE value:",
    "# Mean relative difference: 0.2",
    "# --- 5",
    "# +++ 6",
    "# [1] [-5-]{+6+}"))

# Send back to stdout
options(unittest.output = NULL)
expect_equal({
    ok_group("Some tests", {
        ok(ut_cmp_equal(8, 9), "8 == 9? Probably not")
    })
}, c(
    "# Some tests",
    "not ok - 8 == 9? Probably not",
    "# Test returned non-TRUE value:",
    "# Mean relative difference: 0.125",
    "# --- 8",
    "# +++ 9",
    "# [1] [-8-]{+9+}"))

test_output_ansi_color <- function (x) {
    old_env <- c("NO_COLOR", "R_CLI_NUM_COLORS") ; names(old_env) <- old_env
    old_env <- lapply(old_env, Sys.getenv)
    on.exit(do.call(Sys.setenv, old_env))

    old_opts <- c("cli.num_colors") ; names(old_opts) <- old_opts
    old_opts <- lapply(old_opts, getOption)
    on.exit(do.call(options, old_opts))

    Sys.unsetenv(c("NO_COLOR", "R_CLI_NUM_COLORS"))
    options("cli.num_colors" = NULL)

    x
}

test_output_ansi_color({
    Sys.setenv(NO_COLOR=1)
    stopifnot(isFALSE(unittest:::output_ansi_color()))
})

test_output_ansi_color({
    Sys.setenv(R_CLI_NUM_COLORS=8)
    stopifnot(isTRUE(unittest:::output_ansi_color()))
})
test_output_ansi_color({
    Sys.setenv(R_CLI_NUM_COLORS=1)
    stopifnot(isFALSE(unittest:::output_ansi_color()))
})

test_output_ansi_color({
    options("cli.num_colors" = 8)
    stopifnot(isTRUE(unittest:::output_ansi_color()))
})
test_output_ansi_color({
    options("cli.num_colors" = 1)
    stopifnot(isFALSE(unittest:::output_ansi_color()))
})

# Clear results of expected test failures
if (!interactive()) rm('outcomes', pos = unittest:::pkg_vars)
