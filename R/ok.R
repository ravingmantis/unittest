ok <- function(
    test,
    description
) {
    if(missing(description)) description <- strtrim(paste0(deparse(substitute(test)), collapse = " "), 60)
    if(! is.character(description) || length(description) > 1) stop('\'description\' must be of type \'chr\' and not a vector.')

    error_stack <- c()
    capture_calls <- function (e) {
        error_stack <<- head(sys.calls(), -2)
        # Search for first withCallingHandlers in stack (i.e. the start of our machinery)
        for (i in seq_along(error_stack)) {
            if (error_stack[[i]][[1]] == as.name('withCallingHandlers')) break
        }
        error_stack <<- tail(error_stack, -i)
        signalCondition(e)
    }
    result <- tryCatch(withCallingHandlers(test, error = capture_calls), error = function(e) e)

    outcome <- data.frame()
    if(identical(result, TRUE) ) {
        outcome <- data.frame(
            status = TRUE,
            output = paste('ok -', description, collapse = " "),
            stringsAsFactors = FALSE
        )
    }
    else if(inherits(result,'error')) {
        outcome <- data.frame(
            status = FALSE,
            output = paste(
                paste('not ok -', description, collapse = " "),
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
            output = paste(
                paste('not ok -', description, collapse = " "),
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
            output = paste(
                paste('not ok -', description, collapse = " "),
                "# Test returned non-TRUE value:",
                paste("#", capture.output( print(result) ), collapse = "\n"),
                sep = "\n", collapse = "\n"
            ),
            stringsAsFactors = FALSE
        )
    }
    assign_outcome(outcome)
    rv <- paste0(outcome['output'], "\n")
    cat(rv)
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
