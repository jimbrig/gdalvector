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

# emit a named list as a cli definition list (`key: value`), the package-wide way to render a small set of
# scalar fields in a `format`/`print` method. values are styled with `{.val}` (so strings are quoted, numbers and
# `rlang::as_bytes()` sizes are not); `NULL`/`NA`/empty values render as an em dash. intended to be wrapped in a
# `cli::cli_fmt()` block by the calling formatter.
#' @keywords internal
#' @noRd
#' @importFrom cli cli_dl col_grey format_inline
cli_kv <- function(x) {
  if (length(x) == 0L) {
    return(invisible(NULL))
  }
  values <- vapply(
    x,
    function(value) {
      if (is.null(value) || length(value) == 0L || all(is.na(value))) {
        cli::col_grey("\u2014")
      } else {
        cli::format_inline("{.val {value}}")
      }
    },
    character(1L)
  )
  cli::cli_dl(values)
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
