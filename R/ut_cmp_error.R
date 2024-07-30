# Code block (code) is assumed to throw an error, to be compared against (expected_regexp) and (expected_class)
# All other options are handed to grepl()
ut_cmp_error <- function(code, expected_regexp = NULL, expected_class = NULL, ignore.case = FALSE, perl = FALSE, fixed = FALSE) {
    tryCatch({
        code
        return("No error returned")
    }, error = function(e) {
        if(is.null(expected_regexp) && is.null(expected_class)) return(TRUE)
        fails <- c()
        if (!is.null(expected_regexp) && !grepl(expected_regexp, e$message, ignore.case = ignore.case, perl = perl, fixed = fixed))
            fails <- append(fails, c("Error message:- ", e$message, "Did not match:-", expected_regexp))
        if (!is.null(expected_class) && !all(expected_class %in% class(e)))
            fails <- append(fails, c("Error class(es):-", paste0("'", paste(class(e), collapse="', '"), "'"), "Did not match:-", paste0("'", paste(expected_class, collapse="', '"), "'")))
        if(length(fails)>0) return(fails)
        return(TRUE)
    })
}
