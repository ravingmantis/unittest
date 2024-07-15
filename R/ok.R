ok <- function(
    test,
    description
) {
    if(missing(description)) description <- strtrim(paste0(deparse(substitute(test)), collapse = " "), 60)
    if(! is.character(description) || length(description) > 1) stop('\'description\' must be of type \'chr\' and not a vector.')

    error_stack <- c()
    capture_calls <- function (e) {
        error_stack <<- head(sys.calls(), -2)

        for (i in seq_along(error_stack)) {
            # Start of ok() call
            if ( identical(error_stack[[i]][[1]], quote(ok)) || identical(error_stack[[i]][[1]], quote(unittest::ok)) ) {
                error_stack <<- tail(error_stack, -i)
                for (i in seq_along(error_stack)) {
                    # End of ok() machinery
                    if ( identical(error_stack[[i]][[1]], quote(withCallingHandlers)) ) {
                        error_stack <<- tail(error_stack, -i)
                        break
                    }
                }
                break
            }
        }
        signalCondition(e)
    }
    result <- tryCatch(withCallingHandlers(test, error = capture_calls), error = function(e) e)

    outcome <- data.frame()
    if(identical(result, TRUE) ) {
        outcome <- data.frame(
            status = TRUE,
            description = description,
            output = "",
            stringsAsFactors = FALSE
        )
    }
    else if(inherits(result,'error')) {
        outcome <- data.frame(
            status = FALSE,
            description = description,
            output = paste(
                "# Test resulted in error:",
                paste("# ", result$message, collapse = "\n"),
                "# Whilst evaluating:",
                paste("# ", deparse(result$call), collapse = "\n"),
                "# Stacktrace:",
                paste("# ->", lapply(error_stack, function (ex) paste(deparse(ex), collapse = "\n# ")), collapse = "\n"),
                sep = "\n", collapse = "\n"
            ),
            stringsAsFactors = FALSE
        )
    }
    else if(is.character(result)) {
        outcome <- data.frame(
            status = FALSE,
            description = description,
            output = paste(
                "# Test returned non-TRUE value:",
                paste("#", unlist(strsplit_with_emptystr(result, split = "\n")), collapse = "\n"),
                sep = "\n", collapse = "\n"
            ),
            stringsAsFactors = FALSE
        )
    }
    else {
        outcome <- data.frame(
            status = FALSE,
            description = description,
            output = paste(
                "# Test returned non-TRUE value:",
                paste("#", capture.output( print(result) ), collapse = "\n"),
                sep = "\n", collapse = "\n"
            ),
            stringsAsFactors = FALSE
        )
    }
    assign_outcome(outcome)
    write_ut_lines(
        paste(
            (if (outcome[1, "status"]) "ok" else "not ok"),
            "-",
            outcome[1, "description"]),
        if (any(nzchar(outcome[1, "output"]))) outcome[1, "output"],
        NULL
    )
    if (isFALSE(outcome[1,'status'])) {
        switch(on_fail(),
            stop = stop('Test failure, not continuing'),
            # TODO: Number of failing test, as per non-interactive summary
            # TODO: How to warn that we can't print a summary, because warnings are errors? message() would be lost in noise
            summary = if (interactive() && getOption("warn") == 0) {
                warning("Failed unittest: ", description, call. = FALSE)
            },
            NULL
        )
    }
    invisible(result)
}

# strsplit doesn't preserve empty strings: strsplit("", "\\*") == list(character(0))
# so put them back. NB: this doesn't solve trailing matches, e.g.
# > strsplit("*M*A*S*H*", "\\*")[[1]]
# [1] ""  "M" "A" "S" "H"
# ... but in this case we don't care
strsplit_with_emptystr <- function (...) {
    lapply(strsplit(...), function (x) if(length(x) == 0) "" else x)
}

# Append ... lines to output_fh(), tailed with \n.
# writeLines() isn't enough, as it doesn't do append = TRUE
write_ut_lines <- function (...) {
    cat(unlist(list(...)), sep = "\n", file = output_fh(), append = TRUE)
}
