\name{unittest-package}
\alias{unittest-package}
\alias{unittest}
\docType{package}

\title{TAP-compliant Unit Testing}
\description{
  Concise TAP-compliant unit testing package.
  Authored unit tests can be run using \code{R CMD check} with minimal implementation overhead.
  If you want more features there are other unit testing packages (see 'See Also').
}
\details{
  The \code{unittest} package provides two functions, \code{\link{ok}} and \code{\link{ok_group}}.
  The \code{\link{ok}} function prints \code{ok} when the expression provided evaluates to \code{TRUE}
  and prints \code{not ok} if the expression evaluates to anything else or results in a runtime error;
  this is the \code{TAP} format (\url{http://testanything.org/}) for reporting test results.
  The \code{\link{ok_group}} function is a convenience function for grouping related unit tests
  and produces \code{TAP} compliant comments in the output to separate the unit test groups.

  A unit test summary is produced at the end of a session when a set of unit tests are run in non-interactive
  mode, for example when the unit tests are run using \code{Rscript} or by \code{R CMD check}. For
  using with \code{R CMD check}, see \sQuote{I'm writing a package, how do I put tests in it?}.

  For a list of all documentation use \code{library(help="unittest")}.
}

\author{
  Maintainer: Jamie Lentin <jm@ravingmantis.com>, Anthony Hennessey <ah@ravingmantis.com>.
}

\section{Getting started}{

  You don't need to be writing a package to use unittest. Suppose you have a file \code{biggest.R}
  with the following function
  \preformatted{
    biggest <- function(x,y) {max(c(x,y))}
  }
  To test this create a file called \code{test_biggest.R} in the same directory containing
  \preformatted{
    library(unittest, quietly = TRUE)

    source('biggest.R')

    ok(biggest(3,4) == 4, "two numbers")    
    ok(biggest(c(5,3),c(3,4)) == 5, "two vectors")    
  }
  Now in an \code{R} session \code{source()} the test file
  \preformatted{
    source('test_biggest.R')
  }
  and you will see output like this
  \preformatted{
    ok - two numbers
    ok - two vectors
  }
  and that's it.
  \cr\cr
  Now each time you edit \code{biggest.R} re-sourcing \code{test_biggest.R}
  reloads your function and runs your unit tests.
}

\section{I'm writing a package, how do I put tests in it?}{
  First, add \code{unittest} to \code{Suggests:} in the package \code{DESCRIPTION} file.
  \preformatted{
    Suggests: unittest
  }

  Then create a directory called \code{tests} in your package source, alongside your \code{R} directory.
  \cr\cr
  Any \code{.R} file in the \code{tests} directory will be run by \code{R CMD check}. The \code{unittest} package
  \dQuote{knows} that it is being run by \code{CMD check} and so at the end of the tests will produce a
  summary and throw an error if any tests fail; throwing an error will in turn cause \code{CMD check} to
  report the error and fail the \code{check}.
  \cr\cr
  Assuming your package contains (and \code{exports}) the \code{biggest()} function from
  \sQuote{Getting started}, we could add a \code{tests/test_biggest.R} that contains
  \preformatted{
    library(mypackage)
    library(unittest, quietly = TRUE)

    ok(biggest(3,4) == 4, "two numbers")
    ok(biggest(c(5,3),c(3,4)) == 5, "two vectors")
  }
  and that's it. \code{R CMD check} will run the tests and fail if any of the tests fail.
}

\section{Grouping tests}{
  When dealing with many unit tests in one file it can be useful to group related unit tests.
  The \code{\link{ok_group}} function is used like this
  \preformatted{
    ok_group("Test addition", {
      ok(1 + 1 == 2, "Can add 1")
      ok(1 + 3 == 4, "Can add 3")
    })
    ok_group("Test subtraction", {
      ok(1 - 1 == 0, "Can subtract 1")
      ok(1 - 3 == -2, "Can subtract 3")
    })
  }
  which will produce output like this
  \preformatted{
    # Test addition
    ok - Can add 1
    ok - Can add 3
    # Test subtraction
    ok - Can subtract 1
    ok - Can subtract 3
  }
}

\section{Cookbook}{

  \subsection{Checking error conditions}{
    Define a helper function \code{test_for_error} that uses \code{tryCatch}. If your test
    results in an error that does not match, then the test fails and the actual error will
    be included in your test results.
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

      add_four <- function(x) {
          if( ! is.numeric(x) ) stop("x must be numeric")
          return( x+4 )
      }

      ok(test_for_error(add_four("a"), "must be numeric"), "add_four() argument not numeric correctly throws an error")
    }
    this will result in the output
    \preformatted{
      ok - add_four() argument not numeric correctly throws an error
    }
  }

  \subsection{Testing un-exported package functions}{
    If you have some unit tests which require access to un-exported functions,
    or un-exported S3 methods, you can use \code{local}.
    \preformatted{
      local({
        ok(internal_function() == 3)
        ok(another_internal_function() == 4)
        ok(final_internal_function() == 5)
      }, asNamespace('mypackage'))
    }
  }

  \subsection{Comparing multivalue results}{
    Use \code{all.equal(...)}
    \preformatted{
      a <- c(1,2,3)
      b <- 1:3
      ok(all.equal(a,b), "a and b are equal")
    }

    Alternatively, the following helper function will give coloured output showing what's different
    \preformatted{
      cmp <- function(a, b) {
        if(identical(all.equal(a,b), TRUE)) return(TRUE)

        if (file.exists(Sys.which('git'))) {
          totmp <- function(x) {
            f <- tempfile(pattern = "str.")
            capture.output(str(x,
              vec.len = 1000,
              digits.d = 5,
              nchar.max = 1000), file = f)
            return(f)
          }

          return(suppressWarnings(system2(
            Sys.which('git'),
            c("diff", "--no-index", "--color-words", totmp(a), totmp(b)),
            input = "",
            stdout = TRUE, stderr = TRUE)))
        }

        return(c(
          capture.output(str(a)),
          "... does not equal...",
          capture.output(str(b))
        ))
      }
    }
    To see the coloured output, try the following:
    \preformatted{
    ok(cmp(1:3, 1:8))
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
