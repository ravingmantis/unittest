ut_cmp_warning <- function(code, expected_regexp = NULL, expected_count = 1L, ignore.case = FALSE, perl = FALSE, fixed = FALSE) {
    # NULL becomes integer(0)
    expected_count <- as.integer(expected_count)
    if(length(expected_count) > 1 || (length(expected_count) == 1 && expected_count < 1)) stop("'expected_count' must either be a single none zero positive integer or NULL")
    ww <- NULL
    wh <- function(w) {
        ww <<- append(ww, w$message)
        invokeRestart("muffleWarning")
    }
    got <- withCallingHandlers(code, warning=wh)
    if(length(ww) == 0) return("No warnings issued")
    fails <- c()
    if(length(expected_count) != 0 && length(ww) != expected_count)
        fails <- append(fails, paste("Warning count", length(ww), "does not match expected count", expected_count))
    if(!is.null(expected_regexp)) {
        # list of integer vectors. list element name is regex. vectors are the warings indexes that match 
        matches <- sapply(expected_regexp, grep, x = ww, ignore.case = ignore.case, perl = perl, fixed = fixed)
        # regexes that do not match warning
        no_match_regex <- names(which(sapply(matches, length) == 0))
        if(length(no_match_regex) > 0)
            fails <- append(fails, c("Regex(es):-", paste0("'", paste(no_match_regex, collapse="', '"), "'"), "did not match any warnings."))
        # warnings not matched by regex
        no_match_warnings <- which(! 1:length(ww) %in% sort(unique(unlist(matches))))
        if(length(no_match_warnings) > 0)
            fails <- append(fails, c("Warning(s);-", paste0("  ", paste(ww[no_match_warnings])),"did not match any regex(es)."))
    }
    if(length(fails)>0) return(fails)
    return(TRUE)
}
