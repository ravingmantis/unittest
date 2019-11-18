# Return TRUE if all.equal(a, b), otherwise show the difference with str().
# like all.equal but with more diagnostic output
ut_cmp_equal <- function(a, b, filter = NULL, ...) {
    cmp_inner(a, b, comparison_fn = function (x, y) all.equal(x, y, ...), filter = filter)
}

# Same as ut_cmp_equal(), but uses identical instead
ut_cmp_identical <- function(a, b, filter = NULL) {
    cmp_inner(a, b, comparison_fn = identical, filter = filter)
}

cmp_inner <- function(a, b, comparison_fn = all.equal, filter = NULL) {
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
            function (x) utils::str(x, vec.len = 1000, digits.d = 5, nchar.max = 1000),
            NULL)) {
        if (is.function(f)) {
            diff_lines <- output_diff(f(a), f(b))
            if (length(diff_lines) > 0) {
                break
            }
        }
    }
    diff_lines <- c(ae_output, diff_lines)

    if (interactive() && sys.nframe() == 2) {
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
output_diff <- function (a_out, b_out) {
    path_join <- function(letter, path) {
        # On UNIX a diff path will look like a/tmp/Rtmp...
        out <- paste0(letter, if (substring(path, 1, 1) == '/') '' else '/', path)
        if (grepl("\\", out, fixed = TRUE)) {
            # On Windows a diff path will look like "a/D:\\temp\\Rtmp..."
            out <- paste0('"', gsub("\\", "\\\\", out, fixed = TRUE), '"')
        }
        out
    }

    # Write 2 tempfiles, use git to compare
    if (file.exists(git_binary())) {
        a_path <- tempfile(pattern = "a.")
        utils::capture.output(a_out, file = a_path)
        on.exit(unlink(a_path))

        b_path <- tempfile(pattern = "b.")
        utils::capture.output(b_out, file = b_path)
        on.exit(unlink(b_path))

        out <- suppressWarnings(system2(Sys.which('git'), c(
            "diff",
            "--no-index",
            "--color",
            "--word-diff=plain",
            "--minimal",
            "-U100000000",  # Lines of context, assuming output is no longer than this
            a_path,
            b_path,
            NULL), input = "", stdout = TRUE, stderr = TRUE))

        # Remove useless git preamble
        out <- grep("^(\033\\[.*?m)?(index|diff|@@) ", out, value = TRUE, invert = TRUE, perl = TRUE)

        # Replace temp filenames with the expression cmp was called with
        out <- gsub(path_join("a", a_path), deparse(sys.call(-2)[[2]], nlines = 1), out, fixed = TRUE)
        out <- gsub(path_join("b", b_path), deparse(sys.call(-2)[[3]], nlines = 1), out, fixed = TRUE)

        # Remove any trailing newline
        if (length(out) > 0 && out[length(out)] == "") {
            out <- head(out, -1)
        }
        return(out)
    }

    # Fallback: Capture the strings and compare that
    a_repr <- utils::capture.output(a_out)
    b_repr <- utils::capture.output(b_out)
    if (identical(a_repr, b_repr)) {
        return(c())
    } else {
        return(c(
            paste0("--- ", deparse(sys.call(-2)[[2]], nlines = 1)), a_repr,
            paste0("+++ ", deparse(sys.call(-2)[[3]], nlines = 1)), b_repr))
    }
}
