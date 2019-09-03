PACKAGE=$(shell awk '/^Package: / { print $$2 }' DESCRIPTION)
VERSION=$(shell awk '/^Version: / { print $$2 }' DESCRIPTION)
TARBALL=$(PACKAGE)_$(VERSION).tar.gz

all: check

install:
	R CMD INSTALL --install-tests --html --example .

build:
	R CMD build .

check: build
	R CMD check "$(TARBALL)"

check-as-cran: build
	R CMD check --as-cran "$(TARBALL)"

wincheck: build
	# See https://win-builder.r-project.org/ for more information
	curl --no-epsv -# -T "$(TARBALL)" ftp://win-builder.r-project.org/R-devel/

# Release steps
#  Update DESCRIPTION & ChangeLog with new version
#  git commit -m "Release version "${VERSION} DESCRIPTION ChangeLog
#  git tag -am "Release version "${VERSION} v${VERSION}
#  Upload to CRAN
#  git push && git push --tags

.PHONY: all install build check check-as-cran
