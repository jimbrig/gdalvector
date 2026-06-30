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
#' Reusable semantic styling for the package's cli output. Defines a small set of custom inline span classes and
#' nudges two builtin ones to colors that stay legible on dark terminal backgrounds:
#'
#' - `{.drv}`: a GDAL driver short name.
#' - `{.flag}`: a CLI flag (e.g. `--open-option`).
#' - `{.optname}`: an option name.
#' - `{.optval}`: an option value.
#' - `{.val}`, `{.cls}`: brightened to cyan (the builtin blue is too dim on dark backgrounds).
#'
#' Applied once on load (see `zzz.R`) by layering onto the active cli theme; unknown classes degrade gracefully to
#' unstyled text.
#'
#' @returns A named list suitable for the `theme` argument of [cli::cli_div()] or the `cli.theme` option.
#'
#' @keywords internal
#' @noRd
gdalvector_cli_theme <- function() {
  list(
    "span.drv" = list(color = "cyan"),
    "span.flag" = list(color = "grey"),
    "span.optname" = list(color = "blue"),
    "span.optval" = list(color = "green"),
    "span.val" = list(color = "cyan"),
    "span.cls" = list(color = "cyan")
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
