# The connection we should send output to, by default stdout()
output_fh <- function () {
    getOption("unittest.output", stdout())
}

# Append ... lines to output_fh(), tailed with \n.
# writeLines() isn't enough, as it doesn't do append = TRUE
write_ut_lines <- function (...) {
    cat(unlist(list(...)), sep = "\n", file = output_fh(), append = TRUE)
}

# Write output in bold & colour, if turned on
write_ut_bold <- function (..., color = 0) {
    if (!output_ansi_color()) {
        write_ut_lines(...)
    } else {
        write_ut_lines(paste0(paste0("\033[", color, ";1m"), ..., "\033[0m"))
    }
}

# Should we enable colours?
output_ansi_color <- function () {
    # Honour some of the options that cli/crayon::num_ansi_colors support
    # NB: We don't use these directly so we can output color in the console
    # whilst knitr is running, e.g.
    if (!is.na(Sys.getenv("NO_COLOR", NA_character_))) {
        return(FALSE)
    }
    if (!is.null(x <- getOption("cli.num_colors"))) {
        return(as.integer(x) > 1)
    }
    if (nzchar(x <- Sys.getenv("R_CLI_NUM_COLORS", ""))) {
        return(as.integer(x) > 1)
    }

    if (!methods::is(output_fh(), 'terminal')) {
        # Not terminal-ish, don't output colour here
        return(FALSE)
    }

    if (.Platform$GUI == "Rgui" || .Platform$GUI == "R.app") {
        # The windows Rgui doesn't support ANSI colors
        return(FALSE)
    }

    if (.Platform$GUI == "Rstudio") {
        # Rstudio console is terminal-ish, but not isatty()
        return(TRUE)
    }

    if (isatty(output_fh())) {
        if (.Platform$OS.type == "windows") {
            # Running echo enables ANSI color support under windows,
            # presumably by running SetConsoleMode() for us
            system2("cmd", c("/c", "echo 1 >NUL"))
        }
        return(TRUE)
    }
    return(FALSE)
}
