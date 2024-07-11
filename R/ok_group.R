# Display debug message before evaluating a code block
ok_group <- function (message, tests = NULL) {
    # Break up any newlines inside message, so we just have a character vector of lines
    message <- unlist(strsplit(message, "[\r\n]+"))
    write_ut_lines(
        paste0("# ", message),
        NULL)
    tests
    invisible(NULL)
}
