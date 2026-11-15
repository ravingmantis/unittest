# Start recording now, rather than the first test, so errors before then get summarised
.onAttach <- function(libname, pkgname) {
    record_outcomes()
}

# "Note that when an R session is finished, packages are not detached and namespaces are not unloaded, so the corresponding hooks will not be run." ?getHook
# so we can assume that if this is called then the package is being detached (and maybe also unloaded)
# the assumption is that if the package is also unloaded that any reg.finalizers would be run some time later when garbage collection happens
# So the onDetach event allows us to clear out the pkg_vars environment so that when the finalizer is called the non_interactive_exit will no-op
.onDetach <- function(libpath) {
    if (interactive()) return()

    clear_outcomes()
}
