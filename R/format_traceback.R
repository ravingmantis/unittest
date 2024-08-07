# Generate a traceback string
format_traceback <- function (stack, start = 1, end = length(stack)) {
    stack <- as.list(stack)
    stack_calls <- vapply(stack, function (c) if (is.call(c)) deparse1(c[[1]]) else "", character(1))
    if (is.character(start)) {
        start <- min(max(which(stack_calls == start) + 1, 1), length(stack_calls))
    }
    if (is.character(end)) {
        end <- min(max(which(stack_calls == end) - 1, 1), length(stack_calls))
    } else if (end < 0) {
        end <- length(stack) + end
    }
    stack <- stack[start:end]

    tb <- lapply(seq_along(stack), function (i) {
        lines <- deparse(stack[[i]], width.cutoff = 60L, nlines = 3L)
        prefix <- rep("  ", length(lines))
        prefix[[1]] <- paste0(format(i, width = 2), ": ")
        paste0(prefix, lines)
    })

    unlist(tb)
}
