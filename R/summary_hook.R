# Arrange for a summary of outcomes to be shown at the end of the test script:
# * Non-interactive: When R exits / errors (see add_non_interactive_hooks)
# Return TRUE iff a hook was added
add_summary_hook <- function () {
    if (!interactive()) {
        return(add_non_interactive_hooks())
    }
    return(FALSE)
}

# Summarise when R exits / errors
add_non_interactive_hooks <- function () {
    non_interactive_exit <- function( e ) {
        tests.failed <- outcome_summary()

        if (tests.failed > 0) {
            # We need to alter the status code, stop() doesn't work, not allowed to use .Last, should only happen as script is terminating anyway.
            quit(save = "no", status = 10, runLast=FALSE)
        }
    }

    non_interactive_error_handler <- function() {
        error <- list(
            message = unlist(strsplit_with_emptystr(geterrmessage(), "\n")),
            traceback = head(sys.calls(), -1) )

        tests.failed <- outcome_summary(error = error)
        clear_outcomes()  # Don't summarise again on non_interactive_exit()

        q("no", status = 11, runLast = FALSE)
    }

    # NB: We may be called again after clear_outcomes(), only add one finalizer
    if (!exists('exit_finalizer', where = pkg_vars)) {
        reg.finalizer(pkg_vars, non_interactive_exit, onexit = TRUE)
        assign('exit_finalizer', TRUE, pos = pkg_vars)
    }

    # Only register our error handler if we'd use the default otherwise
    if (is.null(getOption('error'))) {
        options(error = non_interactive_error_handler)
    }
    return(TRUE)
}
