[![CRAN version badge](https://img.shields.io/cran/v/unittest.svg)](https://cran.r-project.org/package=unittest)
[![CRAN Checks](https://cranchecks.info/badges/summary/unittest)](https://cran.r-project.org/web/checks/check_results_unittest.html)
[![CRAN RStudio mirror total downloads badge](https://cranlogs.r-pkg.org/badges/grand-total/unittest?color=001577)](https://cran.r-project.org/package=unittest)
[![CRAN RStudio mirror monthly downloads badge](https://cranlogs.r-pkg.org/badges/unittest?color=001577)](https://cran.r-project.org/package=unittest)
[![R-CMD-check](https://github.com/ravingmantis/unittest/workflows/R-CMD-check/badge.svg)](https://github.com/ravingmantis/unittest/actions)
[![DOI](https://zenodo.org/badge/23253323.svg)](https://zenodo.org/badge/latestdoi/23253323)

# unittest: Concise, [TAP](http://testanything.org/)-compliant, R package for writing unit tests

Given a simple function you'd like to test in the file `myfunction.R`:

    biggest <- function(x,y) { max(c(x,y)) }
       
A test script for this function `test_myfunction.R` would be:

    library(unittest)
    
    source('myfunction.R')  # Or library(mypackage) if part of a package
    
    ok(biggest(3,4) == 4, "two numbers")
    ok(biggest(c(5,3),c(3,4)) == 5, "two vectors")

You can then run this test in several ways:

* ``source('test_myfunction.R')`` from R
* ``Rscript --vanilla test_myfunction.R`` from the command prompt
* ``R CMD check``, if `test_myfunction.R` is inside the `tests` directory of `mypackage` being tested. `unittest` doesn't require any further setup in your package.

If writing tests as part of a package, see the ["Adding Tests to Packages" vignette](https://cran.r-project.org/package=unittest/vignettes/testing_packages.html) for more information.

The workhorse of the `unittest` package is the `ok` function which prints "ok" when the expression provided evaluates to `TRUE` and "not ok" if the expression evaluates to anything else or results in an error.
There are several ``ut_cmp_*`` helpers designed to work with `ok`:

* ``ok(ut_cmp_equal( biggest(1/3, 2/6), 2/6), "two floating point numbers")``: Uses [all.equal](https://stat.ethz.ch/R-manual/R-devel/library/base/html/all.equal.html) to compare within a tolerance.
* ``ok(ut_cmp_identical( biggest("c", "d") ), "two strings")``: Uses [identical](https://stat.ethz.ch/R-manual/R-devel/library/base/html/identical.html) to make sure outputs are identical.
* ``ok(ut_cmp_error(biggest(3), '"y".*missing'), "single argument is an error")``: Make sure the code produces an error matching the regular expression.

In all cases you get detailed, colourised output on what the difference is, for example:

![Output of `ok(ut_cmp_identical(list(1,3,3,4), list(1,2,3,4)))`](man/figures/ut_cmp_identical_example.svg)

The package was inspired by Perl's [Test::Simple](https://metacpan.org/pod/Test::Simple).

If you want more features there are other unit testing packages out there; see [testthat](https://CRAN.R-project.org/package=testthat), [RUnit](https://CRAN.R-project.org/package=RUnit), [svUnit](https://CRAN.R-project.org/package=svUnit).

## Installing from CRAN

In an R session type

    install.packages('unittest')

Or add ``Suggests: unittest`` to your package's ``DESCRIPTION`` file.

## Installing the latest development version directly from GitHub

To install the latest development version, use [remotes](https://CRAN.R-project.org/package=remotes):

    # install.packages("remotes")
    remotes::install_github("ravingmantis/unittest")
