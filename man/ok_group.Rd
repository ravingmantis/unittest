\name{ok_group}
\alias{ok_group}

\title{Group a set of tests}

\description{Group a set of tests together}

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
  Returns the result of the code block.
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

  }
}
