# Temporarily turn on record_outcomes, for summaries in interactive sessions
ut_with_report <- function (code) {
    record_outcomes()
    error <- NULL
    try(withCallingHandlers(code, error = function (e) {
        stack <- sys.calls()
        error <<- list(
            message = e$message,
            class = class(e),
            traceback = format_traceback(stack, start = "withCallingHandlers", end = ".handleSimpleError"))
    }), silent = TRUE)

    outcome_summary(error = error)
    clear_outcomes()
    invisible(NULL)
}
