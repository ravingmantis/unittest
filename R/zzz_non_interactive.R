# everything should no-op in interactive session

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

.onAttach <- function(libname, pkgname) {
    if (interactive()) return()

    # Start recording outcomes
    record_outcomes()

    reg.finalizer(pkg_vars, non_interactive_exit, onexit = TRUE)

    # Only register our error handler if we'd use the default otherwise
    if (is.null(getOption('error'))) {
        options(error = non_interactive_error_handler)
    }
}

# "Note that when an R session is finished, packages are not detached and namespaces are not unloaded, so the corresponding hooks will not be run." ?getHook
# so we can assume that if this is called then the package is being detached (and maybe also unloaded)
# the assumption is that if the package is also unloaded that any reg.finalizers would be run some time later when garbage collection happens
# So the onDetach event allows us to clear out the pkg_vars environment so that when the finalizer is called the non_interactive_exit will no-op
.onDetach <- function(libpath) {
    if (interactive()) return()

    clear_outcomes()
}
