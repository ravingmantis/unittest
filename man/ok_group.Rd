\name{ok_group}
\alias{ok_group}

\title{Group associated unit tests}

\description{Group associated unit tests with TAP compliant comments separating the output.}

\usage{
  ok_group( message, tests )
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
}

\examples{
  \dontrun{
  ok_group("Test addition", {
      ok( 1 + 1 == 2, "Can add 1" )
      ok( 1 + 3 == 4, "Can add 3" )
  })
  ok_group("Test subtraction", {
      ok( 1 - 1 == 0, "Can subtract 1" )
      ok( 1 - 3 == -2, "Can subtract 3" )
  })
  # # Test addition
  # ok - Can add 1
  # ok - Can add 3
  # # Test subtraction
  # ok - Can subtract 1
  # ok - Can subtract 3

  # Multiline group message 
  ok_group(c("Test multiplication", "but not division"),{
      ok( 1 * 1 == 1, "Can multiply by 1" )
      ok( 2 * 3 == 6, "Can multiply by 3" )
  })
  # # Test multiplication
  # # but not division
  # ok - Can multiply by 1
  # ok - Can multiply by 3
  }
}
