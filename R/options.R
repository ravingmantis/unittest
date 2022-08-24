# The connection we should send output to, by default stdout()
output_fh <- function () {
    getOption("unittest.output", stdout())
}
