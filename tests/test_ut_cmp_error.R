library(unittest)

ok_group("ut_cmp_error regex", {
    ok(isTRUE(ut_cmp_error(stop("Erk"), "Erk")), "Error caught and compared")
    ok(ut_cmp_error(2 + 2, "error") == "No error returned", "No error results in a message (even though we would have matched message with regex)")

    ok(isTRUE(ut_cmp_error(stop("Erk"), "E.+k")), "Comparison is a regex")
    ok(!isTRUE(ut_cmp_error(stop("Erk"), "E.+k", fixed = TRUE)), "... turned off with fixed")

    ok(!isTRUE(ut_cmp_error(stop("Erk"), "e.+k")), "Case sensitive by default")
    ok(isTRUE(ut_cmp_error(stop("Erk"), "e.+k", ignore.case = TRUE)), "... turned off with ignore.case")
})

ok_group("ut_cmp_error class", {
    ok(isTRUE(ut_cmp_error(stop(errorCondition("Ahhh!", class = "scream")), expected_class = "scream")), "Error caught and class tested")
    ok(isTRUE(ut_cmp_error(stop(errorCondition("Ahhh!", class = c("scream", "exclaim", "shout"))), expected_class = c("scream", "shout"))), "Error caught and multiple classes tested")
    ok(!isTRUE(ut_cmp_error(stop(errorCondition("Ahhh!", class = c("scream", "exclaim", "shout"))), expected_class = c("scream", "cry"))), "Error where classes do not match")
})

ok_group("ut_cmp_error regex and class", {
    ok(isTRUE(ut_cmp_error(stop(errorCondition("Ahhh!", class = "scream")), expected_regex = "^Ah", expected_class = "scream")), "Error caught with regex and class tested")
    ok(!isTRUE(ut_cmp_error(stop(errorCondition("Ahhh!", class = "scream")), expected_regex = "^Ah", expected_class = "cry")), "Error caught regex matches, class does not match")
    ok(!isTRUE(ut_cmp_error(stop(errorCondition("Ahhh!", class = "scream")), expected_regex = "^Oops", expected_class = "scream")), "Error caught regex does not match, class matches")
    ok(!isTRUE(ut_cmp_error(stop(errorCondition("Ahhh!", class = "scream")), expected_regex = "^Oops", expected_class = "cry")), "Error caught regex does not match, class doen not match")
})
