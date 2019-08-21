library(unittest)

# Compare character output of a (failing) cmp function, ignoring colors
cmp_lines <- function (actual, ...) {
    # Remove color escape codes
    no_color <- gsub('\033\\[.*?m', '', actual, perl = TRUE)
    if(identical(no_color, c(...)[!is.null(c(...))])) {
        return(TRUE)
    }
    # utils::str(no_color, vec.len = 1000, digits.d = 5, nchar.max = 1000)
    return(actual)
}

ok_group("cmp_equal", {
    ok(isTRUE(cmp_equal(4, 4)), "Identical objects return true")
    ok(isTRUE(cmp_equal(as.integer(4), 4)), "Equivalent objects return true (i.e. integer vs. number)")

    ok(cmp_lines(cmp_equal(c(2,4,2,8), c(5,4,2,1)),
        'Mean relative difference: 1',
        '--- c(2, 4, 2, 8)',
        '+++ c(5, 4, 2, 1)',
        '[1] [-2-]{+5+} 4 2 [-8-]{+1+}',
        NULL), "Vectors filtered by str, individual differences highlighted")

    do_a_thing <- function (x) seq(x)
    ok(cmp_lines(cmp_equal(do_a_thing(4), do_a_thing(1 + 2)),
        'Numeric: lengths (4, 3) differ',
        '--- do_a_thing(4)',
        '+++ do_a_thing(1 + 2)',
        '[1] 1 2 3[-4-]',
        NULL), "The ---/+++ lines show expressions handed to cmp_equal()")

    ok(cmp_lines(cmp_equal(list(c(1, 2, 8), c(2, 3, 2), 10, 11, 12, 13), list(c(1, 2, 3), c(2, 3, 2), 10, 11, 12, 13)),
        "Component 1: Mean relative difference: 0.625",
        "--- list(c(1, 2, 8), c(2, 3, 2), 10, 11, 12, 13)",
        "+++ list(c(1, 2, 3), c(2, 3, 2), 10, 11, 12, 13)",
        "[[1]]",
        "[1] 1 2 [-8-]{+3+}",
        "",  # TODO: The empty lines are getting lost in actual ok() output, which feels like a bug
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
        "",
        NULL), "We return the whole file as context, not just the usual 3 lines")
    
    ok(cmp_lines(cmp_equal(c("'Ouch!' he said,", "it was an iron bar."), c("Ooops!", "it was an accident.")),
        '2 string mismatches',
        '--- c("\'Ouch!\' he said,", "it was an iron bar.")',
        '+++ c("Ooops!", "it was an accident.")',
        "[-'Ouch!' he said,-]{+Ooops!+}",
        'it was an [-iron bar.-]{+accident.+}',
        NULL), "Character vectors get compared one per line")
})

ok_group("cmp_identical", {
    ok(isTRUE(cmp_identical(4, 4)), "Identical objects return true")
    ok(cmp_lines(cmp_identical(as.integer(4), 4),
        '--- as.integer(4)',
        '+++ 4',
        ' [-int-]{+num+} 4',
        NULL), "Equivalent objects do not, unlike cmp_equal(). We also fall back to using str(), as print() will produce identical output")
})
