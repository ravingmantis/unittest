[![CRAN version badge](https://img.shields.io/cran/v/unittest.svg)](https://cran.r-project.org/package=unittest)
[![CRAN Checks](https://cranchecks.info/badges/summary/unittest)](https://cran.r-project.org/web/checks/check_results_unittest.html)
[![CRAN RStudio mirror total downloads badge](https://cranlogs.r-pkg.org/badges/grand-total/unittest?color=001577)](https://cran.r-project.org/package=unittest)
[![CRAN RStudio mirror monthly downloads badge](https://cranlogs.r-pkg.org/badges/unittest?color=001577)](https://cran.r-project.org/package=unittest)
[![R-CMD-check](https://github.com/ravingmantis/unittest/workflows/R-CMD-check/badge.svg)](https://github.com/ravingmantis/unittest/actions)
[![DOI](https://zenodo.org/badge/23253323.svg)](https://zenodo.org/badge/latestdoi/23253323)

unittest
========

This is a concise, [TAP](http://testanything.org/)-compliant, R package for writing unit tests. Authored tests can be run with `R CMD check` with minimal implementation overhead.

The workhorse of the `unittest` package is the `ok` function which prints "ok" when the expression provided evaluates to `TRUE` and "not ok" if the expression evaluates to anything else or results in an error.

If you are writing a package see the "I'm writing a package, how do I put tests in it?" section in the package documentation.

The package was inspired by Perl's [Test::Simple](https://metacpan.org/pod/Test::Simple).

If you want more features there are other unit testing packages out there; see [testthat](https://CRAN.R-project.org/package=testthat), [RUnit](https://CRAN.R-project.org/package=RUnit), [svUnit](https://CRAN.R-project.org/package=svUnit).

A very simple example of usage
------------------------------

You have a simple function in the file `myfunction.R` that looks something like this

    biggest <- function(x,y) { max(c(x,y)) }
       
To test this create a file called `test_myfunction.R` in the same directory containing

    library(unittest, quietly = TRUE)
    
    source('myfunction.R')
    
    ok(biggest(3,4) == 4, "two numbers")    
    ok(biggest(c(5,3),c(3,4)) == 5, "two vectors")    

Now in an `R` session `source()` the test file

    source('test_myfunction.R')

and you will see the test results. That's it.  Now each time you edit `myfunction.R` re-sourcing `test_myfunction.R` reloads your function and runs your unit tests.

Installing from CRAN
====================

In an R session type

    install.packages('unittest')

Installing the latest development version directly from GitHub
==============================================================

Linux
-----

In an R session type:

    pkg_file <- tempfile()
    download.file(url = 'https://github.com/ravingmantis/unittest/archive/master.tar.gz', mode = 'wb', method = 'wget', destfile = pkg_file)
    install.packages(pkg_file, repos = NULL, type = 'source')

Mac OSX / Windows
-----------------

``download.file`` may not support fetching ``https`` URLs. Alternatively, you
can use the the CRAN package [downloader](https://CRAN.R-project.org/package=downloader)
to fetch the archive instead:

    # install.packages("downloader")
    pkg_file <- tempfile()
    downloader::download(url = 'https://github.com/ravingmantis/unittest/archive/master.tar.gz', mode = 'wb', destfile = pkg_file)
    install.packages(pkg_file, repos = NULL, type = 'source')

Alternatively use the `devtools` CRAN package
---------------------------------------------

If you have the CRAN package [devtools](https://CRAN.R-project.org/package=devtools)
you can use this to install directly from github:

    # install.packages("devtools")
    devtools::install_github("ravingmantis/unittest")

