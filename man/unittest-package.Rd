\name{unittest-package}
\alias{unittest-package}
\alias{unittest}
\docType{package}

\title{TAP-compliant Unit Testing}
\description{
  Concise TAP-compliant unit testing package.
  Produces tests that can be run with CMD check with minimal implementation overhead.
  If you want more features there are other unit testing packages (see 'See Also').
}
\details{
  The \code{unittest} package provides a single function, \code{\link{ok}}, that prints \code{ok}
  when the expression provided evaluates to \code{TRUE} and \code{not ok} if the expression
  evaluates to anything else or results in an error. This is the \code{TAP} format
  (\url{http://testanything.org/}) for reporting test results.

  If you are writing a package \code{unittest} is designed to integrate with \code{R CMD check}.
  See \sQuote{I'm writing a package, how do I put tests in it?}.

  A test summary is produced at the end of a session when a set of tests are run in non-interactive mode;
  for example when the tests are run using \code{Rscript} or by \code{R CMD check}.

  For a list of all documentation use \code{library(help="unittest")}.
}

\author{
  Maintainer: Jamie Lentin <jm@ravingmantis.com>, Anthony Hennessey <ah@ravingmantis.com>.
}

\section{Getting started}{

  You have a simple function in the file \code{myfunction.R} that looks something like this
  \preformatted{
    biggest <- function(x,y) { max(c(x,y)) }
  }
  To test this create a file called \code{test_myfunction.R} in the same directory cointaining
  \preformatted{
    library(unittest, quietly = TRUE)

    source('myfunction.R')

    ok( biggest(3,4) == 4, "two numbers" )    
    ok( biggest(c(5,3),c(3,4)) == 5, "two vectors" )    
  }
  Now in an \code{R} session \code{source()} the test file
  \preformatted{
    source('test_myfunction.R')
  }
  That's it.\cr

  Now each time you edit \code{myfunction.R} re-sourcing \code{test_myfunction.R}
  reloads your function and runs your unit tests.\cr
}

\section{I'm writing a package, how do I put tests in it?}{
  First, add \code{unittest} to \code{Suggests:} in the package \code{DESCRIPTION} file.
  \preformatted{
    Suggests: unittest
  }

  Then create a directory called \code{tests} in your package source, alongside your \code{R} directory.\cr

  Any \code{.R} file in the tests directory will be run by \code{R CMD check}. The \code{unittest} package
  \dQuote{knows} that it is being run by \code{CMD check} and so at the end of the tests will produce a
  summary and throw an error if any tests fail; throwing an error will in turn cause \code{CMD check} to
  report the error and fail the \code{check}.\cr

  Assuming your package contains (and \code{exports}) the \code{biggest()} function from
  \sQuote{Getting started}, we could add a \code{tests/test_biggest.R} that contains
  \preformatted{
    library(unittest, quietly = TRUE)

    ok( biggest(3,4) == 4, "two numbers" )
    ok( biggest(c(5,3),c(3,4)) == 5, "two vectors" )
  }
  and that's it. \code{R CMD check} will run the tests and fail if any of the tests fail.

  Note that your test file MUST load \code{unittest}, but SHOULD NOT load the package being tested explicitly
  (this is done for you by \code{CMD check}).\cr

  If you want to include tests for un-exported functions you will need to refer to them directly using
  \code{:::} notation.
  For example if \code{biggest()} was not \code{exported} and my package was called \code{mypackage} then my
  first test would need to look like this
  \preformatted{
    ok( mypackage:::biggest(3,4) == 4, "two numbers" )
  }
}

\section{Cookbook}{

  \subsection{Comparing multivalue results}{
    Use \code{all.equal(...)}
    \preformatted{
      a <- c(1,2,3)
      b <- 1:3
      ok( all.equal(a,b), "a and b are equal" )
    }
  }

  \subsection{Checking an error condition happened}{
    Use \code{tryCatch}. In this example if your function returns a character vector, then
    these will be displayed as part of the diagnostics.
    \preformatted{
      test_for_error <- function(code, expected_regexp) {
          tryCatch({
                  code
                  return("No error returned")
              }, error = function(e) {
                  if(grepl(expected_regexp, e$message)) return(TRUE)
                  return(c(e$message, "Did not match:-", expected_regexp))
              }
          )
      }

      add_four <- function( x ) {
          if( ! is.numeric(x) ) stop("x must be numeric")
          return( x+4 )
      }

      ok( test_for_error(add_four("a"), "must be numeric"), "add_four() argument not numeric correctly throws an error" )
    }
    this will result in the output
    \preformatted{
      ok - add_four() argument not numeric correctly throws an error
    }
  }

}

\references{
  Inspired by Perl's Test::Simple (\url{http://search.cpan.org/perldoc?Test::Simple}).
}

\concept{unit testing}

\seealso{
  \href{http://CRAN.R-project.org/package=testthat}{testthat},
  \href{http://CRAN.R-project.org/package=RUnit}{RUnit},
  \href{http://CRAN.R-project.org/package=svUnit}{svUnit}.
}
