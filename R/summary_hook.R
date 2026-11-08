# Arrange for a summary of outcomes to be shown at the end of the test script:
# * Interactive (or unittest.source_summary set): When the source() we're inside finishes (see add_post_source_hook)
# * Non-interactive: When R exits / errors (see add_non_interactive_hooks)
# Return TRUE iff a hook was added
add_summary_hook <- function () {
    if (!is_interactive()) {
        return(add_non_interactive_hooks())
    }
    if (isTRUE(getOption("unittest.source_summary", TRUE))) {
        return(add_post_source_hook())
    }
    return(FALSE)
}

# Should a summary be shown when the source() finishes, or when R does? Separated so we can mock it
is_interactive <- function () {
    interactive()
}

# If inside source(), summarise when the (outermost) source() finishes. Return TRUE iff hook added
add_post_source_hook <- function () {
    # Stop execution with a ut_test_failure condition, after the summary has been shown
    stop_test_failure <- function (fails) {
        # Summary has said everything, so bypass any error handler (e.g. recover)
        # NB: Options are restored on unwinding, after our handler has run
        old_opts <- options(show.error.messages = FALSE, error = function () {
            cat(geterrmessage(), file = stderr())
            # A non-interactive R won't halt by itself if options(error) is set
            if (!interactive()) quit(save = "no", status = 10, runLast = FALSE)
        })
        on.exit(options(old_opts), add = TRUE)
        stop(structure(
            class = c("ut_test_failure", "error", "condition"),
            list(message = paste(fails, "test(s) failed"), call = NULL) ))
    }

    on_source_exit <- function () {
        # returnValue() gives default if source() didn't finish (error, interrupt, restart), which is already stopping execution
        # NB: ?trace calls returnValue() "experimental", but it's unchanged since R 3.2.0, other than
        #     a 2017 fix (wch/r-source 118d385) making default reliable for errors/restarts, with regression tests.
        #     If it ever broke, worst case is a misleading summary / missing or extra "test(s) failed" error
        marker <- new.env()
        if (identical(returnValue(default = marker), marker)) {
            outcomes <- get('outcomes', pos = pkg_vars)
            if (isTRUE(getOption("unittest.stop_on_fail", FALSE)) && nrow(outcomes) > 0 && !outcomes[nrow(outcomes), "status"]) {
                # Last outcome failed, so assign_outcome() stopped execution
                error <- list(message = MSG_STOP_ON_FAIL)
            } else {
                # NB: By now we can't see the error, but R will have shown it (or it was caught further up)
                error <- list()
            }
            outcome_summary(error = error)
            clear_outcomes()
            return(invisible(NULL))
        }

        fails <- outcome_summary()
        clear_outcomes()
        if (fails > 0) stop_test_failure(fails)
    }

    # NB: Look up base::source each time, Positron (ark) replaces it with a wrapper
    #     that either calls the original, or evaluates the file itself if there are breakpoints
    source_fns <- list(base::source, base::sys.source)
    if ("tools:rstudio" %in% search()) {
        # RStudio's "Source" button uses debugSource() if there are breakpoints, which doesn't call source()
        source_fns <- c(source_fns, get0("debugSource", envir = as.environment("tools:rstudio"), inherits = FALSE))
    }
    frame_no <- Find(function (i) {
        any(vapply(source_fns, identical, logical(1), sys.function(i)))
    }, seq_len(sys.nframe()))
    if (is.null(frame_no)) return(FALSE)

    # Add on.exit() to source()'s frame. Call the function object, since it won't be in scope there
    do.call(on.exit, list(as.call(list(on_source_exit)), add = TRUE), envir = sys.frame(frame_no))
    return(TRUE)
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
