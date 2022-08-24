# The connection we should send output to, by default stdout()
output_fh <- function () {
    getOption("unittest.output", stdout())
}

# Should we enable colours? Condensed version of crayon::num_ansi_colors
output_ansi_color <- function () {
    if (!is.na(Sys.getenv("NO_COLOR", NA_character_))) {
        return(FALSE)
    }

    if (!is.null(getOption("cli.num_colors"))) {
        return(getOption("cli.num_colors") > 1)
    }

    if (.Platform$GUI == "Rgui") {
        # The windows Rgui doesn't support ANSI colors
        return(FALSE)
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
