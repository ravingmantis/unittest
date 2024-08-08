# Temporarily turn on record_outcomes, for summaries in interactive sessions
ut_with_report <- function (code) {
    do_summary <- record_outcomes()
    error <- NULL

    result <- try_catch_traceback(code)
    error <- if (!inherits(result, 'error')) NULL else list(
            message = result$message,
            traceback = attr(result, 'traceback') )

    # If we started summary recording, we should show the outcome
    if (do_summary) {
        outcome_summary(error = error)
        clear_outcomes()
    }
    invisible(NULL)
}
