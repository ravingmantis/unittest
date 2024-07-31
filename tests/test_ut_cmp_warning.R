library(unittest)

ok(isTRUE(ut_cmp_warning(warning("Wooooo!"), "^Woo")), "Single warning caught and compared")
ok(ut_cmp_warning(2 + 2, "^Woo") == "No warnings issued", "No warning results in message")
ok(!isTRUE(ut_cmp_warning(warning("Snake!"), "^Woo")), "Single warning caught but does not match regexp")
ok(isTRUE(ut_cmp_warning({warning("Woo!"); warning("Wooooo!")}, "^Woo",  expected_count = 2L)), "expected_count > 1, single regexp that matches all warnings")
ok(!isTRUE(ut_cmp_warning({warning("Woo!"); warning("Wooooo!")}, "^Woo")), "Too many warnings caught. Single regexp matches all warnings")
ok(!isTRUE(ut_cmp_warning({warning("Woo!"); warning("Wooooo!"); warning("Woop!")}, "^Woo", expected_count = 5L)), "Too few warnings caught. Single regexp matches all warnings")

ok(isTRUE(ut_cmp_warning(warning("Wooooo!"))), "Single warning caught and no regexp specified")
ok(!isTRUE(ut_cmp_warning({warning("Woo!"); warning("Woo!")})), "Too many warnings and no regexp specified")
ok(isTRUE(ut_cmp_warning({warning("Woo!"); warning("Woo!")}, expected_count = 2L)), "expected_count > 1 and no regexp specified")
ok(isTRUE(ut_cmp_warning({warning("Woo!"); warning("Woo!")}, expected_count = NULL)), "expected_count is NULL and no regexp specified (two warnings)")

ok(isTRUE(ut_cmp_warning({warning("Woooo!"); warning("Boooo!")}, c("^Woo", "^Boo"), expected_count = 2L)), "Two regexes uniquely match two warnings")
ok(isTRUE(ut_cmp_warning({warning("Woooo!"); warning("Boooo!")}, c("^Woo", "^Boo"), expected_count = NULL)), "Two regexes uniquely match two warnings. expected_count is NULL")
ok(isTRUE(ut_cmp_warning({warning("Woooo!"); warning("Boooo!"); warning("Boo!")}, c("^Woo", "^Boo"), expected_count = 3L)), "Two regexes. 3 warnings. One regex matches two warnings and one regex matches one warning")
ok(!isTRUE(ut_cmp_warning({warning("Woooo!"); warning("Haa!"); warning("Boooo!"); warning("Boo!")}, c("^Woo", "^Boo"), expected_count = 4L)), "Two regexes. 4 warnings. One warning unmatched")
ok(!isTRUE(ut_cmp_warning({warning("Woooo!"); warning("Boooo!"); warning("Boo!")}, c("^.+oo.+$", "^Raa"), expected_count = 3L)), "Two regexes. 3 warnings. One regex matches all warnings. One regex does not match any warnings")
ok(!isTRUE(ut_cmp_warning({warning("Woooo!"); warning("Haa!"); warning("Boooo!"); warning("Boo!")}, c("^.+oo.+$", "^Raa"), expected_count = 4L)), "Two regexes. 4 warnings. One warning unmatched. One regex does not match")
ok(isTRUE(ut_cmp_warning({warning("Woooo!"); warning("Haa!"); warning("Raa!"); warning("Boooo!"); warning("Boo!")}, c("(oo|aa)", "^Boo"), expected_count = 5L)), "Two regexes. 5 warnings. Regex matches overlap")
ok(isTRUE(ut_cmp_warning({warning("Woooo!"); warning("Haa!"); warning("Raa!"); warning("Boooo!"); warning("Boo!")}, c("(oo|aa)", "^Boo"), expected_count = NULL)), "Two regexes. 5 warnings. Regex matches overlap. expected_count is NULL")

ok(isTRUE(ut_cmp_warning(warning("Erk"), "E.+k")), "Comparison is a regex")
ok(!isTRUE(ut_cmp_warning(warning("Erk"), "E.+k", fixed = TRUE)), "Regex comparison turned off with fixed")
ok(!isTRUE(ut_cmp_warning(warning("Erk"), "e.+k")), "Regex is case sensitive by default")
ok(isTRUE(ut_cmp_warning(warning("Erk"), "e.+k", ignore.case = TRUE)), "Regex case sensitivity turned off with ignore.case")

