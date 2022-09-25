options(useFancyQuotes = FALSE)  # Force to stabilise all.equal output

library(unittest)

# Compare character output of a (failing) cmp function, ignoring colors
cmp_lines <- function (actual, ...) {
    # Remove color escape codes
    no_color <- gsub('\033\\[.*?m', '', actual, perl = TRUE)
    if(identical(no_color, c(...)[!is.null(c(...))])) {
        return(TRUE)
    }
    # utils::str(no_color, vec.len = 1000, digits.d = 5, nchar.max = 1000)
    return(c(c(...)[!is.null(c(...))], '----', actual))
}

# Mock (fn) in namespace with (replacement) whilst (block) is being evaluated
mock <- function (fn, replacement, block) {
    # Get the name of the function from the unevaluated argument,
    # assuming it's of the form package::name
    fn_name <- as.character(as.list(sys.call()[[2]])[[3]])
    ns <- environment(fn)

    orig_fn <- get(fn_name, env = ns)
    unlockBinding(fn_name, env = ns)
    assign(fn_name, replacement, envir = ns)
    on.exit(assign(fn_name, orig_fn, envir = ns), add = TRUE)

    block
}

ok_group("ut_cmp_equal", (function () {
    ok(isTRUE(ut_cmp_equal(4, 4)), "Identical objects return true")
    ok(isTRUE(ut_cmp_equal(as.integer(4), 4)), "Equivalent objects return true (i.e. integer vs. number)")
    ok(isTRUE(ut_cmp_equal(0.01, 0.02, tolerance = 0.1)), "Additional arguments passed through to all.equal")

    if (!file.exists(unittest:::git_binary())) {
        ok(TRUE, "# skip git not available")
        return()
    }

    ok(cmp_lines(ut_cmp_equal(c(2,4,2,8), c(5,4,2,1)),
        'Mean relative difference: 1',
        '--- c(2, 4, 2, 8)',
        '+++ c(5, 4, 2, 1)',
        '[1] [-2-]{+5+} 4 2 [-8-]{+1+}',
        NULL), "Vectors filtered by str, individual differences highlighted")

    ok(!withVisible(ut_cmp_equal("apples", "oranges"))$visible,
        "Output of comparision isn't visible (we should print it at a real console though)")

    do_a_thing <- function (x) seq(x)
    ok(cmp_lines(ut_cmp_equal(do_a_thing(4), do_a_thing(1 + 2)),
        'Numeric: lengths (4, 3) differ',
        '--- do_a_thing(4)',
        '+++ do_a_thing(1 + 2)',
        '[1] 1 2 3[-4-]',
        NULL), "The ---/+++ lines show expressions handed to ut_cmp_equal()")

    ok(cmp_lines(ut_cmp_equal(list(c(1, 2, 8), c(2, 3, 2), 10, 11, 12, 13), list(c(1, 2, 3), c(2, 3, 2), 10, 11, 12, 13)),
        "Component 1: Mean relative difference: 0.625",
        "--- list(c(1, 2, 8), c(2, 3, 2), 10, 11, 12, 13)",
        "+++ list(c(1, 2, 3), c(2, 3, 2), 10, 11, 12, 13)",
        "[[1]]",
        "[1] 1 2 [-8-]{+3+}",
        "",
        "[[2]]",
        "[1] 2 3 2",
        "",
        "[[3]]",
        "[1] 10",
        "",
        "[[4]]",
        "[1] 11",
        "",
        "[[5]]",
        "[1] 12",
        "",
        "[[6]]",
        "[1] 13",
        NULL), "We return the whole file as context, not just the usual 3 lines")
    
    ok(cmp_lines(ut_cmp_equal(c("'Ouch!' he said,", "it was an iron bar."), c("Ooops!", "it was an accident.")),
        '2 string mismatches',
        '--- c("\'Ouch!\' he said,", "it was an iron bar.")',
        '+++ c("Ooops!", "it was an accident.")',
        "[-'Ouch!' he said,-]{+Ooops!+}",
        'it was an [-iron bar.-]{+accident.+}',
        NULL), "Character vectors get compared one per line")

    ok(cmp_lines(ut_cmp_equal(as.environment(list(a=3, b=4)), as.environment(list(a=5, b=4, c=9))),
        'Length mismatch: comparison on first 2 components',
        'Component "a": Mean relative difference: 0.6666667',
        '--- as.environment(list(a = 3, b = 4))',
        '+++ as.environment(list(a = 5, b = 4, c = 9))',
        '{+$c+}',
        '{+[1] 9+}',
        '',
        '$b',
        '[1] 4',
        '',
        '$a',
        '[1] [-3-]{+5+}',
        NULL), "Environments get converted to lists")

    cmp_helper <- function (a, b) ut_cmp_equal(a, b, deparse_frame = -2)
    ok(cmp_lines(cmp_helper(2, 8),
        'Mean relative difference: 3',
        '--- 2',
        '+++ 8',
        '[1] [-2-]{+8+}',
        NULL), "A helper function can up deparse_frame to improve output")
})())

# Mock git_binary(), so we don't find git even if it is available
ok_group("ut_cmp_equal:nogit", mock(unittest:::git_binary, function () "/not-here", {
    ok(cmp_lines(ut_cmp_equal(c(2,4,2,8), c(5,4,2,1)),
        'Mean relative difference: 1',
        '--- c(2, 4, 2, 8)',
        '[1] 2 4 2 8',
        '+++ c(5, 4, 2, 1)',
        '[1] 5 4 2 1',
        NULL), "No git available, so show outputs side by side")

    ok(cmp_lines(ut_cmp_equal(as.environment(list(a=3, b=4)), as.environment(list(a=5, b=4, c=9))),
        'Length mismatch: comparison on first 2 components',
        'Component "a": Mean relative difference: 0.6666667',
        '--- as.environment(list(a = 3, b = 4))',
        '$b',
        '[1] 4',
        '',
        '$a',
        '[1] 3',
        '',
        '+++ as.environment(list(a = 5, b = 4, c = 9))',
        '$c',
        '[1] 9',
        '',
        '$b',
        '[1] 4',
        '',
        '$a',
        '[1] 5',
        '',
        NULL), "Environments get converted to lists")
}))

ok_group("ut_cmp_identical", (function () {
    if (!file.exists(unittest:::git_binary())) {
        ok(TRUE, "# skip git not available")
        return()
    }

    ok(isTRUE(ut_cmp_identical(4, 4)), "Identical objects return true")
    ok(cmp_lines(ut_cmp_identical(as.integer(4), 4),
        '--- as.integer(4)',
        '+++ 4',
        ' [-int-]{+num+} 4',
        NULL), "Equivalent objects do not, unlike ut_cmp_equal(). We also fall back to using str(), as print() will produce identical output")

    # NB: On r-oldrel-windows-ix86+x86_64 this produces 1.0000000001,
    #     not 1.000000000100000008274, regardless expecting this much
    #     numerical consistency is a bit enthusiastic.
    ok(cmp_lines(gsub("1.0000000001[0-9]+", "1.0000000001", ut_cmp_identical(1, 1 + 1e-10)),
        '--- 1',
        '+++ 1 + 1e-10',
        ' num [-1-]{+1.0000000001+}',
        NULL), "Increase str() digits to 22 show a difference")

    ok(cmp_lines(ut_cmp_identical(1 + 1e-10, 1 + 1e-7),
        '--- 1 + 1e-10',
        '+++ 1 + 1e-07',
        ' num [-1-]{+1.0000001+}',
        NULL), "Increase str() digits (7 is enough) show a difference")

    cmp_helper <- function (a, b) ut_cmp_identical(a, b, deparse_frame = -2)
    ok(cmp_lines(cmp_helper(2, 8),
        '--- 2',
        '+++ 8',
        '[1] [-2-]{+8+}',
        NULL), "A helper function can up deparse_frame to improve output")
})())

ok_group("output_diff", (function () {
    if (!file.exists(unittest:::git_binary())) {
        ok(TRUE, "# skip git not available")
        return()
    }

    options("cli.num_colors" = 256)
    ok(any(grepl('\033\\[.*?m', ut_cmp_identical(1L, 2L), perl = TRUE)), "cli.num_colors honoured (escape code in output)")

    options("cli.num_colors" = 1)
    ok(!all(grepl('\033\\[.*?m', ut_cmp_identical(1L, 2L), perl = TRUE)), "cli.num_colors honoured (no escape code in output)")
})())

ok_group("ut_cmp_identical:nogit", mock(unittest:::git_binary, function () "/not-here", {
    ok(isTRUE(ut_cmp_identical(4, 4)), "Identical objects return true")
    ok(cmp_lines(ut_cmp_identical(as.integer(4), 4),
        '--- as.integer(4)',
        ' int 4',
        '+++ 4',
        ' num 4',
        NULL), "Equivalent objects do not, unlike ut_cmp_equal(). We also fall back to using str(), as print() will produce identical output")
}))
