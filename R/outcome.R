pkg_vars <- new.env(parent = emptyenv())

MSG_STOP_ON_FAIL <- "Test failure and unittest.stop_on_fail is set"

# Start recording outcomes, so a summary will be generated. Return TRUE iff not previously recording
record_outcomes <- function () {
    if (exists('outcomes', where = pkg_vars)) return(FALSE)
    assign('outcomes', data.frame(
        type = factor(levels = c("test", "group")),
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
    outcome$type <- factor(outcome$type, levels = c("test", "group"))

    # Only bother assigning if we're recording at this point
    if (exists('outcomes', where = pkg_vars)) {
        assign('outcomes', rbind(get('outcomes', pos = pkg_vars), outcome), pos = pkg_vars)
    }

    write_ut_bold(
        paste(
            (if (outcome[1, "status"]) "ok" else "not ok"),
            "-",
            outcome[1, "description"]),
        color = if (outcome[1, "status"]) 0L else 31L )
    if (any(nzchar(outcome[1, "output"]))) write_ut_lines(outcome[1, "output"])

    if (!outcome[1, "status"] && isTRUE(getOption("unittest.stop_on_fail", FALSE))) {
        stop(MSG_STOP_ON_FAIL)
    }
}

# Output human-readable version of summary contents, return number of failing tests, or -1 if an error occured
outcome_summary <- function (error = NULL) {
    # If not recording, print nothing
    if (!exists('outcomes', where = pkg_vars)) return(invisible(0))

    outcomes <- get('outcomes', pos = pkg_vars)
    fail.types <- outcomes[!outcomes$status, 'type']
    tests.total <- nrow(outcomes[outcomes$type == "test",])
    # NB: No such thing as groups.total, as we only log failures

    if ( !is.null(error) && any(grepl(MSG_STOP_ON_FAIL, error$message, fixed = TRUE)) ) {
        # NB: We can't use an errorClass since the message may have come from options(error) / geterrmessage()
        write_ut_lines(
            paste("Bail out! Looks like", tests.total, "tests ran, but a", fail.types[[1]], "failed and unittest.stop_on_fail is set", collapse = " "),
            NULL )
        return(invisible(-1))
    } else if ( !is.null(error) ) {
        write_ut_lines(
            paste("Bail out! Looks like", tests.total, "tests ran, but script ended prematurely", collapse = " "),
            paste("#", error$message),
            "# Traceback:",
            paste("#", format_traceback(error$traceback)),
            NULL)
        return(invisible(-1))
    } else if (length(fail.types) > 0) {
        write_ut_lines(paste0(1, "..", nrow(outcomes)))
        tests.failed <- sum(fail.types == "test")
        groups.failed <- sum(fail.types == "group")
        oc_split <- split(outcomes, outcomes$type)
        if (tests.failed > 0) write_ut_lines(
            paste("# Looks like you failed", tests.failed, "of", tests.total, "tests.", collapse = " "),
            if (tests.failed != tests.total && tests.failed < 20) {
                paste0("# ", which(!oc_split$test$status), ": ", oc_split$test[!oc_split$test$status, "description"])
            },
            NULL)
        if (groups.failed > 0) write_ut_lines(
            paste("# Looks like", groups.failed, "groups raised an exception.", collapse = " "),
            if (groups.failed < 20) {
                paste0("# ", which(!oc_split$group$status), ": ", oc_split$group[!oc_split$group$status, "description"])
            },
            NULL)
        return(invisible(length(fail.types)))
    } else if( tests.total == 0 ) {
        # No tests run
        # NB: We could report this, but we need to fix the examples/tests first
        return(invisible(0))
    } else {
        write_ut_lines(
            paste0(1, "..", nrow(outcomes)),
            paste("# Looks like you passed all", tests.total, "tests.", collapse = " "),
            NULL)
        return(invisible(0))
    }
}
