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

examples: install
	Rscript -e 'devtools::run_examples(run_donttest = FALSE, run_dontrun = FALSE, document = FALSE)'

vignettes: install
	Rscript -e 'tools::buildVignettes(dir=".")'

test: install
	for f in tests/test*.R; do echo "=== $$f ============="; Rscript $$f || exit 1; done

check: build
	R CMD check "$(TARBALL)"

check-as-cran: build
	R CMD check --as-cran "$(TARBALL)"

wincheck: build
	# See https://win-builder.r-project.org/ for more information
	curl --no-epsv -# -T "$(TARBALL)" ftp://win-builder.r-project.org/R-devel/

serve-vignettes: vignettes
	 # NB: Requires servr to be installed
	 Rscript -e 'servr::vign(host = "0.0.0.0", port = 8123)'

release:
	[ -n "$(NEW_VERSION)" ]  # NEW_VERSION variable should be set
	sed -i 's/^Version: .*/Version: $(NEW_VERSION)/' DESCRIPTION
	sed -i "s/^Date: .*/Date: $$(date +%Y-%m-%d)/" DESCRIPTION
	#
	mv ChangeLog ChangeLog.o
	echo "$$(date +%Y-%m-%d) $$(git config user.name)  <$$(git config user.email)>" > ChangeLog
	echo "" >> ChangeLog
	echo "    Version $(NEW_VERSION)" >> ChangeLog
	echo "" >> ChangeLog
	cat ChangeLog.o >> ChangeLog
	rm ChangeLog.o
	#
	mv NEWS NEWS.o
	[ "$$(head -c 7 NEWS.o)" = "CHANGES" ] || /bin/echo -e "CHANGES IN VERSION $(NEW_VERSION):\n" > NEWS
	cat NEWS.o >> NEWS
	rm NEWS.o
	#
	git commit -m "Release version $(NEW_VERSION)" DESCRIPTION ChangeLog NEWS
	git tag -am "Release version $(NEW_VERSION)" v$(NEW_VERSION)
	#
	R CMD build .
	#
	sed -i 's/^Version: .*/Version: '"$(NEW_VERSION)-999"'/' DESCRIPTION
	git commit -m "Development version $(NEW_VERSION)-999" DESCRIPTION

# Release steps
#  make release NEW_VERSION=1.3-0
#  Upload to CRAN
#  git push && git push --tags

.PHONY: all install full-install examples vignettes test build check check-as-cran serve-vignettes release
