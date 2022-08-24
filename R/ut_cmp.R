# Return TRUE if all.equal(a, b), otherwise show the difference with str().
# like all.equal but with more diagnostic output
ut_cmp_equal <- function(a, b, filter = NULL, deparse_frame = -1, ...) {
    cmp_inner(a, b, comparison_fn = function (x, y) all.equal(x, y, ...), filter = filter, deparse_frame = deparse_frame)
}

# Same as ut_cmp_equal(), but uses identical instead
ut_cmp_identical <- function(a, b, filter = NULL, deparse_frame = -1) {
    cmp_inner(a, b, comparison_fn = identical, filter = filter, deparse_frame = deparse_frame)
}

cmp_inner <- function(a, b, comparison_fn = all.equal, filter = NULL, deparse_frame = -1) {
    stopifnot(is.numeric(deparse_frame) && deparse_frame < 0)

    # Compare inputs, if equal then we're done
    ae_output <- comparison_fn(a, b)
    if (isTRUE(ae_output)) return(TRUE)
    if (isFALSE(ae_output)) ae_output <- c()

    # Try each filter function in turn, until we find one that produces useful
    # diff output
    for (f in list(
            # Add any custom filtering function
            filter,
            # Strings can be compared directly using writeLines
            ifelse(is.character(a) && is.character(b), writeLines, 'ignore'),
            # Convert environments to list, print that
            ifelse(is.environment(a) && is.environment(b), function (x) print(as.list(x)), 'ignore'),
            # print will pick up any generics defined for custom types
            print,
            # Fall back to parsing with str
            function (x) utils::str(x),
            function (x) utils::str(x, vec.len = 1e3, digits.d = 5, nchar.max = 1e3, list.len = 1e3),
            function (x) utils::str(x, vec.len = 1e3, digits.d = 10, nchar.max = 1e3, list.len = 1e3),
            function (x) utils::str(x, vec.len = 1e3, digits.d = 22, nchar.max = 1e3, list.len = 1e3),
            NULL)) {
        if (is.function(f)) {
            diff_lines <- output_diff(
                f(a), f(b),
                a_label = deparse1(sys.call(deparse_frame)[[2]], nlines = 1),
                b_label = deparse1(sys.call(deparse_frame)[[3]], nlines = 1))
            if (length(diff_lines) > 0) {
                break
            }
        }
    }
    diff_lines <- c(ae_output, diff_lines)

    if (interactive() && sys.nframe() == 1 - deparse_frame) {
        # Interactive and called at a top-level, so print the output nicely
        writeLines(diff_lines)
    }
    invisible(diff_lines)
}

# Return location of git, separated so we can mock it
git_binary <- function() {
    Sys.which('git')
}

# Given 2 stdout-producing arguments, return human-readable word-diff lines, using git diff if available.
output_diff <- function (a_out, b_out, a_label, b_label) {
    # Write 2 tempfiles, use git to compare
    if (file.exists(git_binary())) {
        # NB: Make sure we use / under windows, since this is what git will do
        a_path <- normalizePath(tempfile(pattern = "a."), winslash = "/", mustWork = FALSE)
        utils::capture.output(a_out, file = a_path)
        on.exit(unlink(a_path))

        # NB: Make sure we use / under windows, since this is what git will do
        b_path <- normalizePath(tempfile(pattern = "b."), winslash = "/", mustWork = FALSE)
        utils::capture.output(b_out, file = b_path)
        on.exit(unlink(b_path))

        out <- suppressWarnings(system2(Sys.which('git'), c(
            "diff",
            "--no-index",
            paste0("--color=", if (output_ansi_color()) "always" else "never"),
            "--word-diff=plain",
            "--minimal",
            "-U100000000",  # Lines of context, assuming output is no longer than this
            a_path,
            b_path,
            NULL), input = "", stdout = TRUE, stderr = TRUE))

        # Remove useless git preamble
        out <- grep("^(\033\\[.*?m)?(index|diff|@@) ", out, value = TRUE, invert = TRUE, perl = TRUE)

        # Replace temp filenames with the expression cmp was called with
        out <- gsub(gsub("^/*", "a/", a_path), a_label, out, fixed = TRUE)
        out <- gsub(gsub("^/*", "b/", b_path), b_label, out, fixed = TRUE)

        # Remove any trailing newline
        if (length(out) > 0 && out[length(out)] == "") {
            out <- head(out, -1)
        }

        # Duck problems with r-devel-windows-x86_64-new-UL,
        # stray \r characters that shouldn't be there
        # See https://github.com/ravingmantis/unittest/issues/3
        if(.Platform$OS.type == "windows") out <- gsub("\r", "", out)

        return(out)
    }

    # Fallback: Capture the strings and compare that
    a_repr <- utils::capture.output(a_out)
    b_repr <- utils::capture.output(b_out)
    if (identical(a_repr, b_repr)) {
        return(c())
    } else {
        return(c(
            paste0("--- ", a_label), a_repr,
            paste0("+++ ", b_label), b_repr))
    }
}
