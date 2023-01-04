\name{ut_cmp}
\alias{ut_cmp_equal}
\alias{ut_cmp_identical}

\title{Compare variables with verbose error output}

\description{
  A wrapper for \code{\link{all.equal}} and \code{\link{identical}} that provides
  more useful diagnostics when used in a unittest \code{\link{ok}} function.
}

\usage{
  ut_cmp_equal(a, b, filter = NULL, deparse_frame = -1, ...)
  ut_cmp_identical(a, b, filter = NULL, deparse_frame = -1)
}

\arguments{
  \item{a}{First item to compare, usually the result of whatever you are testing}
  \item{b}{Second item to compare, usually the expected output of whatever you are testing}
  \item{filter}{An optional filter function, that turns either a or b into text, and prints this out}
  \item{deparse_frame}{
    Tell \code{\link{sys.call}} which frame to deparse to get original expressions.
    Set to \code{-2} when making a helper function, see examples.
  }
  \item{...}{Other arguments passed directly to \code{\link{all.equal}}}
}

\details{
  For both functions, \code{a} and \code{b} are first passed to
  \code{\link{all.equal}} (for \code{ut_cmp_equal()}) or
  \code{\link{identical}} (for \code{ut_cmp_identical()}). If they match, then
  the function returns TRUE and your test passes.

  If this fails, then we turn both \code{a} and \code{b} into text, and then
  use \code{git diff} to compare the 2 outputs. If you do not have git
  installed, then the 2 outputs will be shown side-by-side.

  When using \code{git diff}, we turn colored output on when outputting to a
  terminal. You can force this on or off using \code{options("cli.num_colors" = 1)}
  or the \code{NO_COLOR} or \code{R_CLI_NUM_COLORS} environment variable.

  The step of turning into text is done with the filter function. There are
  several of these built-in, and it will choose the one that produces the
  simplest output. This may mean that the output will be from the \code{\link{print}}
  function if the differences are obvious, or \code{\link{str}} with many
  decimal places if there are subtle differences between the 2.

  You can also provide your own filter function if there's a particular way
  you would like to see the data when comparing, for example you can use
  \code{write.table} if your data is easiest to understand in tabular output.
}

\value{
  Returns \code{TRUE} if \code{a} & \code{b} are \code{\link{all.equal}} (for \code{ut_cmp_equal()}) or \code{\link{identical}} (for \code{ut_cmp_identical()}).
  Otherwise, returns an \code{invisible()} character vector of diagnostic
  strings helping you find where the difference is.

  If called directly in an interactive R session, this output will be printed
  to the console.
}

\examples{
## A function to test:
fn <- function(x) { seq(x) }

## Get it right, and test passes:
ok(ut_cmp_equal(fn(3), c(1,2,3)))

## Get it wrong, and we get told where in the output things are different:
ok(ut_cmp_equal(fn(3), c(1,4,3)))

## Using a custom filter, we can format the output with write.table:
ok(ut_cmp_equal(fn(3), c(1,4,3), filter = write.table))

## With ut_cmp_equal, an integer 1 is the same as a numeric 1
ok(ut_cmp_equal(as.numeric(1), as.integer(1)))

## With ut_cmp_identical, they're not
ok(ut_cmp_identical(as.numeric(1), as.integer(1)))

## all.equal() takes a tolerance parameter, for example:
all.equal(0.01, 0.02, tolerance = 0.1)

## ...we can also give this to to ut_cmp_equal if we want a very
## approximate comparison
ok(ut_cmp_equal(0.01, 0.02, tolerance = 0.1))

## We can make a comparison function of our own, and use
## deparse_frame to show the right expression in diff output
cmp_noorder <- function (a, b) {
    sortlist <- function (x) if (length(x) > 0) x[order(names(x))] else x
    ut_cmp_identical(sortlist(a), sortlist(b), deparse_frame = -2)
}
ok(cmp_noorder(list(a=1, b=2), list(b=2, a=3)))

\dontshow{
  # Clear unittest result log, so our unittest failues don't fail example-building
  unittest:::clear_outcomes()
}
}
