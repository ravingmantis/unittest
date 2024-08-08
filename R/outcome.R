pkg_vars <- new.env(parent = emptyenv())

MSG_STOP_ON_FAIL <- "Test failure and unittest.stop_on_fail is set"

# Start recording outcomes, so a summary will be generated. Return TRUE iff not previously recording
record_outcomes <- function () {
    if (exists('outcomes', where = pkg_vars)) return(FALSE)
    assign('outcomes', data.frame(
        status = logical(0),
        description = character(0),
        output = character(0),
        stringsAsFactors = FALSE), pos = pkg_vars )
    return(TRUE)
}

# Clear out previous outcomes, stop recording outcomes
clear_outcomes <- function () {
    if (exists('outcomes', where = pkg_vars)) rm('outcomes', pos = pkg_vars)
}

assign_outcome <- function(...) {
    outcome <- as.data.frame(list(...))

    # Only bother assigning if we're recording at this point
    if (exists('outcomes', where = pkg_vars)) {
        assign('outcomes', rbind(get('outcomes', pos = pkg_vars), outcome), pos = pkg_vars)
    }

    write_ut_lines(
        paste(
            (if (outcome[1, "status"]) "ok" else "not ok"),
            "-",
            outcome[1, "description"]),
        if (any(nzchar(outcome[1, "output"]))) outcome[1, "output"],
        NULL)

    if (!outcome[1, "status"] && isTRUE(getOption("unittest.stop_on_fail", FALSE))) {
        stop(MSG_STOP_ON_FAIL)
    }
}

# Output human-readable version of summary contents, return number of failing tests, or -1 if an error occured
outcome_summary <- function (error = NULL) {
    # If not recording, print nothing
    if (!exists('outcomes', where = pkg_vars)) return(invisible(0))

    outcomes <- get('outcomes', pos = pkg_vars)
    tests.total <- nrow(outcomes)
    tests.failed <- sum(!outcomes$status)

    if ( !is.null(error) && any(grepl(MSG_STOP_ON_FAIL, error$message, fixed = TRUE)) ) {
        # NB: We can't use an errorClass since the message may have come from options(error) / geterrmessage()
        write_ut_lines(
            paste("Bail out! Looks like", tests.total, "tests ran, but a test failed and unittest.stop_on_fail is set", collapse = " "),
            NULL )
        tests.failed <- -1
    } else if ( !is.null(error) ) {
        write_ut_lines(
            paste("Bail out! Looks like", tests.total, "tests ran, but script ended prematurely", collapse = " "),
            paste("#", error$message),
            "# Traceback:",
            paste("#", format_traceback(error$traceback)),
            NULL)
        tests.failed <- -1
    } else if( tests.total == 0 ) {
        # No tests run
        # NB: We could report this, but we need to fix the examples/tests first
    } else if (tests.failed) {
        write_ut_lines(
            paste0(1, "..", tests.total),
            paste("# Looks like you failed", tests.failed, "of", tests.total, "tests.", collapse = " "),
            if (tests.failed != tests.total && tests.failed < 20) {
                paste0("# ", which(!outcomes$status), ": ", outcomes[!outcomes$status, "description"])
            },
            NULL)
    } else {
        write_ut_lines(
            paste0(1, "..", tests.total),
            paste("# Looks like you passed all", tests.total, "tests.", collapse = " "),
            NULL)
    }

    return(invisible(tests.failed))
}
