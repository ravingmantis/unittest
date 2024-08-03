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

  The \code{unittest.stop_on_fail} option tells unit test to stop on the first test failure.
  This is useful when debugging long test scripts with multiple failures.

  The \code{unittest.output} option tells unittest where output should be sent.
  This is most useful for vignettes, where sending output to
  \code{\link{stderr}} separates the unittest output from the vignette itself.
}

\examples{
\dontshow{
  # Fetch state to restore later
  old.stop_on_fail <- getOption("unittest.stop_on_fail")
  options(unittest.stop_on_fail = NULL)
  old.output <- getOption("unittest.output")
}

ok(1==1, "1 equals 1")

ok(1==1)

ok(1==2, "1 equals 2")

ok(all.equal(c(1,2),c(1,2)), "compare vectors")

fn <- function () stop("oops")
ok(fn(), "something with a coding error")

ok(c("Some diagnostic", "messages"), "A failure with diagnostic messages")

## Write a failing unit test script
test_path <- tempfile(fileext = ".R")
writeLines('
library(unittest)

ok(1==1)
ok(1==2)
ok(2==2)
ok(3==3)
', con = test_path)

# Without unittest.stop_on_fail, we see all failures:
options(unittest.stop_on_fail = NULL)
tryCatch(source(test_path), error = function (e) { print("=== error ===") })

# With, we stop at the first failing test:
options(unittest.stop_on_fail = TRUE)
tryCatch(source(test_path), error = function (e) { print("=== error ===") })
options(unittest.stop_on_fail = NULL)

## Send unittest output to stderr()
options(unittest.output = stderr())
ok(ut_cmp_equal(4, 5), "4 == 5? Probably not")

## Reset unittest output to default (stdout())
options(unittest.output = NULL)
ok(ut_cmp_equal(4, 5), "4 == 5? Probably not")

\dontshow{
  # Clear unittest result log, so our unittest failues don't fail example-building
  unittest:::clear_outcomes()
  options(unittest.stop_on_fail = old.stop_on_fail)
  options(unittest.output = old.output)
}
}
