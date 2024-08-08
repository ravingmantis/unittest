ok <- function(
    test,
    description
) {
    if(missing(description)) description <- strtrim(paste0(deparse(substitute(test)), collapse = " "), 60)
    if(! is.character(description) || length(description) > 1) stop('\'description\' must be of type \'chr\' and not a vector.')

    result <- try_catch_traceback(test)

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
                "# Traceback:",
                paste0("# ", format_traceback(attr(result, 'traceback')), collapse = "\n"),
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
