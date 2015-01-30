\name{ok}
\alias{ok}

\title{The unittest package's workhorse function}

\description{Report the test of an expression in TAP format.}

\usage{
  ok(test, description)
}

\arguments{
  \item{test}{
    Expression to be tested. Evaluating to \code{TRUE} is treated as success,
    anything else as failure.
  }
  \item{description}{
    Character string describing the test. If a description is not given a 
    character representation of the test expression will be used.
  }
}

\value{
  \code{ok()} returns whatever was returned when \code{test} is evaluated.
  More importantly it has the side effect of printing the result of the
  test in \code{TAP} format.
}

\details{
  See \code{\link{unittest}} package documentation.
}

\examples{
  \dontrun{
  ok(1==1, "1 equals 1")
  # ok - 1 equals 1

  ok(1==1)
  # ok - 1 == 1

  ok(1==2, "1 equals 2")
  # not ok - 1 equals 2
  # # Test returned non-TRUE value:
  # # [1] FALSE

  ok(all.equal(c(1,2),c(1,2)), "compare vectors")
  # ok - compare vectors

  ok(stop("oops"), "something with a coding error")
  # not ok - something with a coding error
  # # Test resulted in error: oops
  # #  -> doTryCatch
  # #  -> return(expr)
  # #  -> name
  # #  -> parentenv
  # #  -> handler

  ok(c("Some diagnostic", "messages"), "A failure with diagnostic messages")
  # not ok - A failure with diagnostic messages
  # # Test returned non-TRUE value:
  # # Some diagnostic
  # # messages
  }
}
