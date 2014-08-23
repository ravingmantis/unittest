unittest
========

This is a concise, [TAP](http://testanything.org/)-compliant, R package for writing unit tests. Authored tests that can be run with `R CMD check` with minimal implementation overhead.

The `unittest` package provides a single function, `ok`, that prints "ok" when the expression provided evaluates to `TRUE` and "not ok" if the expression evaluates to anything else or results in an error.

If you are writing a package see the "I'm writing a package, how do I put tests in it?" section in the package documentation.

The package was inspired by Perl's [Test::Simple](http://search.cpan.org/perldoc?Test::Simple).

If you want more features there are other unit testing packages out there; see [testthat](http://CRAN.R-project.org/package=testthat), [RUnit](http://CRAN.R-project.org/package=RUnit), [svUnit](http://CRAN.R-project.org/package=svUnit).

A very simple example of usage
------------------------------

You have a simple function in the file `myfunction.R` that looks something like this

    biggest <- function(x,y) { max(c(x,y)) }
       
To test this create a file called `test_myfunction.R` in the same directory containing

    library(unittest, quietly = TRUE)
    
    source('myfunction.R')
    
    ok( biggest(3,4) == 4, "two numbers" )    
    ok( biggest(c(5,3),c(3,4)) == 5, "two vectors" )    

Now in an `R` session `source()` the test file

    source('test_myfunction.R')

and you will see the test results. That's it.  Now each time you edit `myfunction.R` re-sourcing `test_myfunction.R` reloads your function and runs your unit tests.

Installing from CRAN
====================

In an R session type

    install.packages('unittest')

Installing the latest version directly from GitHub
==================================================

Linux
-----

In an R session type

    pkg_file <- tempfile()
    download.file(url = 'https://github.com/ravingmantis/unittest/archive/master.tar.gz', mode = 'wb', method = 'wget', destfile = pkg_file)
    install.packages(pkg_file, repos = NULL, type = 'source')

Mac OSX / Windows
-----------------

Assumes that the CRAN package [downloader](http://CRAN.R-project.org/package=downloader) is installed.

In an R session type

    library(downloader)
    pkg_file <- tempfile()
    download(url = 'https://github.com/ravingmantis/unittest/archive/master.tar.gz', mode = 'wb', destfile = pkg_file)
    install.packages(pkg_file, repos = NULL, type = 'source')
