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
  Good places to start are the \sQuote{\href{../doc/getting_started.html}{Getting Started}}
  and \sQuote{\href{../doc/faq.html}{FAQ}}vignettes.
  You can see these by typing \code{vignette('getting_started', package='unittest')} and
  \code{vignette('faq', package='unittest')} respectively.
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
