PACKAGE=$(shell awk '/^Package: / { print $$2 }' DESCRIPTION)
VERSION=$(shell awk '/^Version: / { print $$2 }' DESCRIPTION)
TARBALL=$(PACKAGE)_$(VERSION).tar.gz

all: check

install:
	R CMD INSTALL --install-tests --html --example .

# Some things aren't installed by "make install", vignettes for example.
# This is slower, but more accurate.
full-install: build
	R CMD INSTALL --install-tests --html --example "$(TARBALL)"

build:
	R CMD build .

check: build
	R CMD check "$(TARBALL)"

check-as-cran: build
	R CMD check --as-cran "$(TARBALL)"

wincheck: build
	# See https://win-builder.r-project.org/ for more information
	curl -# -T "$(TARBALL)" ftp://win-builder.r-project.org/R-devel/

examples: install
	Rscript -e 'devtools::run_examples(run_donttest = FALSE, run_dontrun = FALSE, document = FALSE)'

vignettes: install
	Rscript -e 'tools::buildVignettes(dir=".")'

serve-docs:
	[ -d docs ] && rm -r docs || true
	Rscript --vanilla -e "pkgdown::build_site() ; servr::httd(dir='docs', host='0.0.0.0', port='8000')"

test: install
	for f in tests/test*.R; do echo "=== $$f ============="; Rscript $$f || exit 1; done

inttest: install
	for f in inttest/*/run.R; do echo "=== $$f ============="; Rscript $$f || exit 1; done

coverage:
	R --vanilla -e 'covr::package_coverage(type = "all", line_exclusions = list())'

release: release-description release-changelog release-news
	git commit -m "Release version $(NEW_VERSION)" DESCRIPTION ChangeLog NEWS.md
	git tag -am "Release version $(NEW_VERSION)" v$(NEW_VERSION)
	#
	R CMD build .
	#
	sed -i 's/^Version: .*/Version: '"$(NEW_VERSION)-999"'/' DESCRIPTION
	git commit -m "Development version $(NEW_VERSION)-999" DESCRIPTION

release-description:
	[ -n "$(NEW_VERSION)" ]  # NEW_VERSION variable should be set
	sed -i 's/^Version: .*/Version: $(NEW_VERSION)/' DESCRIPTION
	sed -i "s/^Date: .*/Date: $$(date +%Y-%m-%d)/" DESCRIPTION

release-changelog:
	[ -n "$(NEW_VERSION)" ]  # NEW_VERSION variable should be set
	mv ChangeLog ChangeLog.o
	echo "$$(date +%Y-%m-%d) $$(git config user.name)  <$$(git config user.email)>" > ChangeLog
	echo "" >> ChangeLog
	echo "    Version $(NEW_VERSION)" >> ChangeLog
	echo "" >> ChangeLog
	cat ChangeLog.o >> ChangeLog
	rm ChangeLog.o

release-news:
	[ -n "$(NEW_VERSION)" ]  # NEW_VERSION variable should be set
	mv NEWS.md NEWS.md.o
	head -1 NEWS.md.o | grep -E '^\# $(PACKAGE) ' || /bin/echo -e "# $(PACKAGE) $(NEW_VERSION):\n" > NEWS.md
	cat NEWS.md.o >> NEWS.md
	rm NEWS.md.o

# Release steps
#  make release NEW_VERSION=1.3-0
#  Upload to CRAN
#  git push && git push --tags

.PHONY: all install full-install build check check-as-cran wincheck examples vignettes serve-docs test inttest coverage release release-description release-changelog release-news
