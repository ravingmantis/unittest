library(unittest)

test_path <- tempfile(fileext = ".R")
writeLines(c(
    'library(unittest)',
    'ok(1==1)',
    ''), con = test_path)

ok(ut_cmp_identical(capture.output(unittest:::ut_with_report({
    source(test_path)
})), c(
    'ok - 1 == 1',
    '# Looks like you passed all 1 tests.',
    NULL)), "Printed summary after sourcing a test script")

ok(ut_cmp_identical(capture.output(unittest:::ut_with_report({
    ok(1==1)
    ok(2==1)
})), c(
    "ok - 1 == 1",
    "not ok - 2 == 1",
    "# Test returned non-TRUE value:",
    "# [1] FALSE",
    "# Looks like you failed 1 of 2 tests.",
    "# 2: 2 == 1",
    NULL)), "Printed summary with failure")

ok(ut_cmp_identical(capture.output(unittest:::ut_with_report({
    ok(1==1)
    ok(2==1)
    stop("Oh no!")
    ok(3==1)
})), c(
    "ok - 1 == 1",
    "not ok - 2 == 1",
    "# Test returned non-TRUE value:",
    "# [1] FALSE",
    "Bail out! Looks like 2 tests ran, but script ended prematurely",
    "# Oh no!",
    "# Traceback:",
    "#   1: stop(\"Oh no!\")",
    NULL)), "Printed summary with error")
