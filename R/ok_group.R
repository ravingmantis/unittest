# Display debug message before evaluating a code block
# tryCatch code borrows from tools:::.try_quietly (R 4.3.3)
ok_group <- function (message, tests = NULL) {
    # Break up any newlines inside message, so we just have a character vector of lines
    message <- unlist(strsplit(message, "[\r\n]+"))
    write_ut_lines(
        paste0("# ", message),
        NULL)
    tryCatch(withRestarts(withCallingHandlers(tests, error = {
        function(e) invokeRestart("grmbl", e, sys.calls())
    }), grmbl = function(e, calls) {
        n <- length(sys.calls())
        calls <- calls[-seq.int(length.out = n - 1L)]
        calls <- head(calls, -2)
        tb <- lapply(calls, deparse, width.cutoff = 200L, nlines = 1L)
        output <- paste("# Exception:", e$message)
        if(length(tb)>0) output <- paste(output, "#   Call stack:",
                                   paste("#     ", tb, collapse = "\n"), sep = "\n")
        outcome <- data.frame(
            status = FALSE,
            description = paste0("exception caught within ok_group '", message[1], "'"),
            output = output,
            stringsAsFactors = FALSE
        )
        assign_outcome(outcome)
        write_ut_lines(
            paste("not ok -", outcome[1, "description"]),
            outcome[1, "output"],
            NULL
        )
    }))
    invisible(NULL)
}
