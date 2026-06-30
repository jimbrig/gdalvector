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

# key-value list --------------------------------------------------------------------------------------------------

# emit a named list as aligned `key  value` lines, the package-wide way to render a small set of scalar fields in
# a `format`/`print` method. keys are bold in the terminal's default foreground (legible on any background);
# values are styled with `{.val}` (strings quoted, numbers and `rlang::as_bytes()` sizes not); blank values render
# as an em dash. emitted via `cli::cli_verbatim()` so the column alignment survives, and meant to be wrapped in a
# `cli::cli_fmt()` block by the calling formatter.
#' @keywords internal
#' @noRd
#' @importFrom cli cli_verbatim style_bold format_inline
cli_kv <- function(x) {
  if (length(x) == 0L) {
    return(invisible(NULL))
  }
  width <- max(nchar(names(x)))
  lines <- vapply(
    seq_along(x),
    function(i) {
      value <- x[[i]]
      rendered <- if (is_blank(value)) "\u2014" else cli::format_inline("{.val {value}}")
      paste0(cli::style_bold(formatC(names(x)[[i]], width = -width)), "  ", rendered)
    },
    character(1L)
  )
  cli::cli_verbatim(lines)
  invisible(NULL)
}

# json ------------------------------------------------------------------------------------------------------------

# emit an R object as pretty-printed JSON, the package-wide way to render embedded JSON metadata (e.g. PROJJSON
# CRS, GDAL OGR schema, covering bbox mappings). uses the shared `JSON_WRITE_OPTS` (pretty, auto-unboxed).
#' @keywords internal
#' @noRd
#' @importFrom yyjsonr write_json_str
#' @importFrom cli cli_verbatim
cli_json <- function(x) {
  cli::cli_verbatim(yyjsonr::write_json_str(x, opts = JSON_WRITE_OPTS))
  invisible(x)
}
