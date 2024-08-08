\name{ok_group}
\alias{ok_group}

\title{Group associated unit tests}

\description{Group associated unit tests with TAP compliant comments separating the output.}

\usage{
  ok_group(message, tests = NULL)
}

\arguments{
  \item{message}{
    Character vector describing this group. Will be printed as a comment
    before the tests are ran.
  }
  \item{tests}{
    A code block full of tests.
  }
}

\value{
  Returns NULL.
}

\details{
  Used to group a selection of tests together, for instance you may group
  the tests relating to a function together.

  If the code within \code{tests} throws an unexpected exception execution
  of the code block will finish and a single test failure will be reported
  referencing the \code{ok_group}.

  The functionality of an \code{ok_group} to catch unexpected errors implies
  that tests should not rely on setup from within an earlier code block.
  It can also be a useful practice to isolate the code block in a
  \link[base]{local} environment.
}

\examples{
ok_group("Test addition", {
    ok(1 + 1 == 2, "Can add 1")
    ok(1 + 3 == 4, "Can add 3")
})

ok_group("Test subtraction", {
    ok(1 - 1 == 0, "Can subtract 1")
    ok(1 - 3 == -2, "Can subtract 3")
})

# Multiline group message
ok_group(c("Test multiplication", "but not division"),{
    ok(1 * 1 == 1, "Can multiply by 1")
    ok(2 * 3 == 6, "Can multiply by 3")
})

# Keep what happens in a group local
ok_group("Test addition of integers", local({
    x <- 1L; y <- 2L
    ok(x + y == 3L, "Can add integer variables")
}))

\dontshow{
  # Clear unittest result log, so our unittest failues don't fail example-building
  unittest:::clear_outcomes()
}
}
