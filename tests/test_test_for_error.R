library(unittest)

ok_group("test_for_error", {
    ok(isTRUE(test_for_error(stop("Erk"), "Erk")), "Error caught and compared")
    ok(test_for_error(2 + 2, "error") == "No error returned", "No error results in a message (even though we would have matched message with regex)")
    
    ok(isTRUE(test_for_error(stop("Erk"), "E.+k")), "Comparison is a regex")
    ok(!isTRUE(test_for_error(stop("Erk"), "E.+k", fixed = TRUE)), "... turned off with fixed")

    ok(!isTRUE(test_for_error(stop("Erk"), "e.+k")), "Case sensitive by default")
    ok(isTRUE(test_for_error(stop("Erk"), "e.+k", ignore.case = TRUE)), "... turned off with ignore.case")
})
