# Code block (exp) is assumed to throw an error, to be compared against (expected_regexp)
# All other options are handed to grepl()
ut_cmp_error <- function(code, expected_regexp, ignore.case = FALSE, perl = FALSE, fixed = FALSE) {
    tryCatch({
        code
        return("No error returned")
    }, error = function(e) {
        if (grepl(expected_regexp, e$message, ignore.case = ignore.case, perl = perl, fixed = fixed)) {
            return(TRUE)
        }
        return(c(e$message, "Did not match:-", expected_regexp))
    })
}
