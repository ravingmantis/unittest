# tryCatch expr, returning any error, decorated with attr(e, 'traceback')
try_catch_traceback <- function (expr) {
    # See tools:::.try_quietly
    tryCatch(withRestarts(withCallingHandlers({
        expr
    }, error = {
        function(e) invokeRestart("grmbl", e, sys.calls())
    }), grmbl = function(e, calls) {
        n <- length(sys.calls())
        # Remove post-restart sys.calls() from the stacktrace sys.calls()
        calls <- calls[-seq.int(length.out = n - 1L)]
        # Chop off .handleSimpleError / h(simpleError)
        calls <- head(calls, -2)
        attr(e, 'traceback') <- calls
        e
    }))
}

# Generate a traceback string
format_traceback <- function (stack) {
    stack <- as.list(stack)
    if (length(stack) == 0) return(" (none)")

    tb <- lapply(seq_along(stack), function (i) {
        lines <- deparse(stack[[i]], width.cutoff = 60L, nlines = 3L)
        prefix <- rep("  ", length(lines))
        prefix[[1]] <- paste0(format(i, width = 2), ": ")
        paste0(prefix, lines)
    })

    unlist(tb)
}
