#  ------------------------------------------------------------------------
#
# Title : cli Utilities
#    By : Jimmy Briggs
#  Date : 2026-06-28
#
#  ------------------------------------------------------------------------

# theme -----------------------------------------------------------------------------------------------------------

#' Package cli Theme
#'
#' @description
#' Reusable semantic styling for the package's cli output (GDAL option rendering, and future
#' driver/validation/sitrep views). Defines a small set of custom inline span classes:
#'
#' - `{.drv}`: a GDAL driver short name.
#' - `{.flag}`: a CLI flag (e.g. `--open-option`).
#' - `{.optname}`: an option name.
#' - `{.optval}`: an option value.
#'
#' The theme is applied locally where output is produced (via [cli::cli_div()]), not registered
#' globally on package load, so the package never mutates the user's session-wide cli styling.
#' Unknown classes degrade gracefully to unstyled text when the theme is not active.
#'
#' @returns A named list suitable for the `theme` argument of [cli::cli_div()].
#'
#' @keywords internal
#' @noRd
gdalvector_cli_theme <- function() {
  list(
    "span.drv" = list(color = "cyan"),
    "span.flag" = list(color = "grey"),
    "span.optname" = list(color = "blue"),
    "span.optval" = list(color = "green")
  )
}
