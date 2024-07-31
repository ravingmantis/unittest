pkg_vars <- new.env(parent = emptyenv())

# Clear out pkg_vars so any test failures aren't reported
clear_outcomes <- function () {
    if (exists('outcomes', where = pkg_vars)) rm('outcomes', pos = pkg_vars)
}

assign_outcome <- function(outcome) {
    if (interactive()) return()
    # as per assign() invoked for side effect
    if( ! exists('outcomes', where = pkg_vars) ) {
        assign(
            'outcomes',
             data.frame(status = logical(0), description = character(0), output = character(0), stringsAsFactors = FALSE),
             pos = pkg_vars
        )
    }
    assign('outcomes', rbind(get('outcomes', pos = pkg_vars), outcome), pos = pkg_vars)
}

# Output human-readable version of summary contents, return number of failing tests, or -1 if an error occured
outcome_summary <- function (error = NULL) {
    outcomes <- if (exists('outcomes', where = pkg_vars)) get('outcomes', pos = pkg_vars) else data.frame(status = logical(0))
    tests.total <- nrow(outcomes)
    tests.failed <- sum(!outcomes$status)

    if( tests.total == 0 ) {
        # No tests run, or package detached
    } else if ( !is.null(error) ) {
        write_ut_lines(
            paste("Bail out! Looks like", tests.total, "tests ran, but script ended prematurely", collapse = " "),
            paste("#", error$message),
            "# Traceback:",
            paste("#", error$traceback),
            NULL)
        tests.failed <- -1
    } else if (tests.failed) {
        write_ut_lines(
            paste("# Looks like you failed", tests.failed, "of", tests.total, "tests.", collapse = " "),
            if (tests.failed != tests.total && tests.failed < 20) {
                paste0("# ", which(!outcomes$status), ": ", outcomes[!outcomes$status, "description"])
            },
            NULL)
    } else {
        write_ut_lines(
            paste("# Looks like you passed all", tests.total, "tests.", collapse = " "),
            NULL)
    }

    return(invisible(tests.failed))
}
