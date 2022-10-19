lineref <- function () {
    # This only works in source(), not Rscript
    # Workaroundable with: Rscript --vanilla -e 'source("tests/test-x.R", keep.source = T)'
    # Turning keep.source within the script on appears to help, but then you just get a line number in the ok_group()
    x <- sys.call(-1)
    if (length(getSrcFilename(x)) == 0) return("")
    paste0(" at ", getSrcFilename(x), ":", getSrcLocation(x))
}

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
        lr <- lineref()  # NB: Keep it outside paste() to avoid stacktrace size varying
        outcome <- data.frame(
            status = FALSE,
            output = paste(
                paste('not ok -', description, collapse = " "),
                paste0("# Test", lr, " resulted in error:"),
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
        lr <- lineref()  # NB: Keep it outside paste() to avoid stacktrace size varying
        outcome <- data.frame(
            status = FALSE,
            output = paste(
                paste('not ok -', description, collapse = " "),
                paste0("# Test", lr, " returned non-TRUE value:"),
                paste("#", unlist(strsplit_with_emptystr(result, split = "\n")), collapse = "\n"),
                sep = "\n", collapse = "\n"
            ),
            stringsAsFactors = FALSE
        )
    }
    else {
        lr <- lineref()  # NB: Keep it outside paste() to avoid stacktrace size varying
        outcome <- data.frame(
            status = FALSE,
            output = paste(
                paste('not ok -', description, collapse = " "),
                paste0("# Test", lr, "returned non-TRUE value:"),
                paste("#", capture.output( print(result) ), collapse = "\n"),
                sep = "\n", collapse = "\n"
            ),
            stringsAsFactors = FALSE
        )
    }
    assign_outcome(outcome)
    rv <- paste0(outcome['output'], "\n")
    cat(rv, file = output_fh(), append = TRUE)
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
