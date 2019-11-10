\name{ut_cmp}
\alias{ut_cmp_equal}
\alias{ut_cmp_identical}

\title{Compare variables with verbose error output}

\description{
  A wrapper for \code{\link{all.equal}} and \code{\link{identical}} that provides
  more useful diagnostics when used in a unittest \code{\link{ok}} function.
}

\usage{
  ut_cmp_equal(a, b, filter = NULL, ...)
  ut_cmp_identical(a, b, filter = NULL)
}

\arguments{
  \item{a}{First item to compare, usually the result of whatever you are testing}
  \item{b}{Second item to compare, usually the expected output of whatever you are testing}
  \item{filter}{An optional filter function, taking one argument and printing a representation to stdout}
  \item{...}{Other arguments passed directly to \code{\link{all.equal}}}
}

\details{
  Both functions process the input in several steps:

  \enumerate{
    \item Run \code{a} & \code{b} through \code{\link{all.equal}} (for \code{ut_cmp_equal()})
    or \code{\link{identical}} (for \code{ut_cmp_identical()}). If they match,
    then return TRUE.

    \item \code{a} & \code{b} through a "filter function", which takes one of
    the objects and turns it into a character vector

    \item Use \code{git diff} to compare the 2 and pick out any word
    differences. If there aren't any, try another filter function.
  }

  There are a list of filter functions built-in, ordered high-level (e.g.
  \code{\link{print}}) to low-level (e.g. \code{\link{str}}). If you want to
  add your own, use the \code{filter} option, e.g.
  \code{filter = function (x) str(x, vec.len = 1000)} to use \code{\link{str}}
  but make sure your vector doesn't get truncated.
}

\value{
  Returns \code{TRUE} if \code{a} & \code{b} are \code{\link{all.equal}} (for \code{ut_cmp_equal()}) or \code{\link{identical}} (for \code{ut_cmp_identical()}).
  Otherwise, returns a character vector of diagnostic strings helping you find where the difference is.
}

\examples{
  \dontrun{
    ## A function to test:
    > fn <- function(x) { seq(x) }

    ## Get it right, and test passes:
    > ok(ut_cmp_equal(fn(3), c(1,2,3)))
    ok - ut_cmp_equal(fn(3), c(1, 2, 3))

    ## Get it wrong, and we get told where in the output things are different:
    > ok(ut_cmp_equal(fn(3), c(1,4,3)))
    not ok - ut_cmp_equal(fn(3), c(1, 4, 3))
    # Test returned non-TRUE value:
    # Mean relative difference: 1
    # --- fn(3)
    # +++ c(1, 4, 3)
    # [1] 1 [-2-]{+4+} 3

    ## Using a custom filter, we can format the output with write.table:
    > ok(ut_cmp_equal(fn(3), c(1,4,3), filter = write.table))
    not ok - ut_cmp_equal(fn(3), c(1, 4, 3), filter = write.table)
    # Test returned non-TRUE value:
    # Mean relative difference: 1
    # --- fn(3)
    # +++ c(1, 4, 3)
    # "x"
    # "1" 1
    # "2" [-2-]{+4+}
    # "3" 3

    ## With ut_cmp_equal, an integer 1 is the same as a numeric 1
    > ok(ut_cmp_equal(as.numeric(1), as.integer(1)))
    ok - ut_cmp_equal(as.numeric(1), as.integer(1))

    ## With ut_cmp_identical, they're not
    > ok(ut_cmp_identical(as.numeric(1), as.integer(1)))
    not ok - ut_cmp_identical(as.numeric(1), as.integer(1))
    # Test returned non-TRUE value:
    # --- as.numeric(1)
    # +++ as.integer(1)
    #  [-num-]{+int+} 1

    ## By passing all.equal arguments we can be very approximate
    > ok(ut_cmp_equal(0.01, 0.02, tolerance = 0.1))
    ok - ut_cmp_equal(0.01, 0.02, tolerance = 0.1)
  }
}
