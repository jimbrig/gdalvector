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
#' Per the cli theming model (see `?cli::themes`), this is applied as a scoped [cli::cli_div()] theme around the
#' package's own output (via `gpq_cli_fmt()`) rather than mutating the global `cli.theme` option, so it never
#' affects other packages' output. Unknown classes degrade gracefully to unstyled text.
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
    "span.optval" = list(color = "green"),
    "span.val" = list(color = "cyan"),
    "span.cls" = list(color = "cyan")
  )
}

# capture a cli block to a character vector under the package theme. wraps the output in a scoped `cli_div()` so the
# theme (see `gdalvector_cli_theme()`) applies only to this block, then captures it with `cli_fmt()`. `code` is
# evaluated lazily inside the themed div.
#' @keywords internal
#' @noRd
#' @importFrom cli cli_fmt cli_div cli_end
gpq_cli_fmt <- function(code) {
  cli::cli_fmt({
    cli::cli_div(theme = gdalvector_cli_theme())
    code
    cli::cli_end()
  })
}

# key-value bullets -----------------------------------------------------------------------------------------------

# emit a named list as `* key: value` bullets, optionally under a bold section title - the package-wide way to
# render a small group of scalar fields in a `format`/`print` method. values are styled with `{.val}`; blank values
# render as an em dash. meant to be wrapped in a themed `gpq_cli_fmt()` block by the calling formatter.
#' @keywords internal
#' @noRd
#' @importFrom cli cli_text cli_bullets
cli_kv <- function(x, title = NULL) {
  if (length(x) == 0L) {
    return(invisible(NULL))
  }
  if (!is.null(title)) {
    cli::cli_text("{.strong {title}:}")
  }
  for (i in seq_along(x)) {
    key <- names(x)[[i]]
    value <- x[[i]]
    if (all(is.na(value))) {
      cli::cli_bullets(c("*" = "{key}: \u2014"))
    } else {
      cli::cli_bullets(c("*" = "{key}: {.val {value}}"))
    }
  }
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
