# Display debug message before evaluating a code block
# tryCatch code borrows from tools:::.try_quietly (R 4.3.3)
ok_group <- function (message, tests = NULL) {
    # Break up any newlines inside message, so we just have a character vector of lines
    message <- unlist(strsplit(message, "[\r\n]+"))
    write_ut_lines(
        paste0("# ", message),
        NULL)
    result <- try_catch_traceback(tests)

    if (inherits(result,'error')) {
        output <- paste("# Exception:", result$message)

        output <- paste(output,
                  "# Traceback:",
                  paste0("# ", format_traceback(attr(result, 'traceback')), collapse = "\n"),
                  sep = "\n", collapse = "\n")
        outcome <- data.frame(
            status = FALSE,
            description = paste0("exception caught within ok_group '", message[1], "'"),
            output = output,
            stringsAsFactors = FALSE
        )
        assign_outcome(outcome)
    }

    invisible(NULL)
}
