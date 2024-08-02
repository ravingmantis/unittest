library(unittest)

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


# The following tests should register failures

# Execution continues after an exception
expect_equal({ok_group("snake", stop("hiss!")); print("badger")}, c(
    "# snake",
    "not ok - exception caught within ok_group 'snake'",
    "# Exception: hiss!",
    "#   Call stack:",
    '#      stop("hiss!")',
    '[1] "badger"'))

# Don't output an empty call stack
expect_equal(ok_group("snake", reptile <- snake), c(
    "# snake",
    "not ok - exception caught within ok_group 'snake'",
    "# Exception: object 'snake' not found"))

# if we are being run by CMD check
if(! interactive()) {
    # we stored some failures
    # this will fail if 'outcomes' does not exist
    get('outcomes', pos = unittest:::pkg_vars)

    # clean up
    # Remove outcomes, so we don't try and report actual failures
    rm('outcomes', pos = unittest:::pkg_vars)
}
