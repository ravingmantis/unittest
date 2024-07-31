# unittest 1.6-1-999:

## New features

* Failing tests are now reported at the end of test output (ec84b0c)
* unittest.cmp_context configures number of context lines for diff output (833c9c5)
* Add ut_cmp_warning() for checking code is raising warnings (840f1f4)
* ut_cmp_error() can now check error class as well as message (27e6e2d)

# unittest 1.6-0:

## Bug fixes

* More robust stacktrace filtering in ok()

# unittest 1.5-1

## New features

* options(unittest.output = ...) to redirect unittest output.

# unittest 1.4-0

## New features

* ut_cmp_equal() and ut_cmp_identical() for comparing outputs.
* ut_cmp_error() function to simplify testing for errors.

# unittest 1.3-0

## New vignettes

* Getting Started
* FAQ

## New features

* Show stack traces when functions being tested fail

# unittest 1.1-0

## New features

* New ok_group function for grouping unit tests.
* Additional cookbook examples in the package documentation.
