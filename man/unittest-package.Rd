\name{unittest-package}
\alias{unittest-package}
\alias{unittest}
\docType{package}

\title{TAP-compliant Unit Testing}
\description{
  Concise TAP-compliant unit testing package.
  Authored unit tests can be run using \code{R CMD check} with minimal implementation overhead.
}
\details{

Given a simple function you'd like to test in the file \code{myfunction.R}:

\preformatted{biggest <- function(x,y) { max(c(x,y)) }
}
       
A test script for this function \code{test_myfunction.R} would be:

\preformatted{library(unittest)
    
source('myfunction.R')  # Or library(mypackage) if part of a package
    
ok(biggest(3,4) == 4, "two numbers")
ok(biggest(c(5,3),c(3,4)) == 5, "two vectors")
}

You can then run this test in several ways:

\enumerate{
  \item{\code{source('test_myfunction.R')} from R}
  \item{\code{Rscript --vanilla test_myfunction.R} from the command prompt}
  \item{\code{R CMD check}, if \code{test_myfunction.R} is inside the \code{tests} directory of \code{mypackage} being tested. \sQuote{unittest} doesn't require any further setup in your package}
}

If writing tests as part of a package, see \code{vignette("testing_packages", package='unittest')}.

The workhorse of the \sQuote{unittest} package is the \code{\link{ok}} function which prints "ok" when the expression provided evaluates to \code{TRUE} and "not ok" if the expression evaluates to anything else or results in an error.
There are several \code{ut_cmp_*} helpers designed to work with \code{\link{ok}}:

\enumerate{
  \item{\code{ok(ut_cmp_equal( biggest(1/3, 2/6), 2/6), "two floating point numbers")}: Uses \code{\link[base]{all.equal}} to compare within a tolerance}
  \item{\code{ok(ut_cmp_identical( biggest("c", "d") ), "two strings")}: Uses \code{\link[base]{identical}} to make sure outputs are identical}
  \item{\code{ok(ut_cmp_error(biggest(3), '"y".*missing'), "single argument is an error")}: Make sure the code produces an error matching the regular expression}
}

In all cases you get detailed, colourised output on what the difference is if the test fails.

}

\author{
  Maintainer: Jamie Lentin <jm@ravingmantis.com>, Anthony Hennessey <ah@ravingmantis.com>.
}

\references{
  Inspired by Perl's Test::Simple (\url{https://metacpan.org/pod/Test::Simple}).
}

\concept{unit testing}

\seealso{
  \href{https://CRAN.R-project.org/package=testthat}{testthat},
  \href{https://CRAN.R-project.org/package=RUnit}{RUnit},
  \href{https://CRAN.R-project.org/package=svUnit}{svUnit}.
}
