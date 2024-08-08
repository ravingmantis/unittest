ok <- function(
    test,
    description
) {
    if(missing(description)) description <- strtrim(paste0(deparse(substitute(test)), collapse = " "), 60)
    if(! is.character(description) || length(description) > 1) stop('\'description\' must be of type \'chr\' and not a vector.')

    result <- try_catch_traceback(test)

    status <- FALSE
    if(identical(result, TRUE) ) {
        status <- TRUE
        output <- ""
    }
    else if(inherits(result,'error')) {
        output <- paste(
                "# Test resulted in error:",
                paste("# ", result$message, collapse = "\n"),
                "# Traceback:",
                paste0("# ", format_traceback(attr(result, 'traceback')), collapse = "\n"),
                sep = "\n", collapse = "\n" )
    }
    else if(is.character(result)) {
        output <- paste(
                "# Test returned non-TRUE value:",
                paste("#", unlist(strsplit_with_emptystr(result, split = "\n")), collapse = "\n"),
                sep = "\n", collapse = "\n" )
    }
    else {
        output <- paste(
                "# Test returned non-TRUE value:",
                paste("#", capture.output( print(result) ), collapse = "\n"),
                sep = "\n", collapse = "\n" )
    }
    assign_outcome(
        type = "test",
        status = status,
        description = description,
        output = output )
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
