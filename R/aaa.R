#  ------------------------------------------------------------------------
#
# Title : aaa.R - shared pacakge resources
#    By : Jimmy Briggs
#  Date : 2026-05-31
#
#  ------------------------------------------------------------------------

# core drivers ----------------------------------------------------------------------------------------------------

#' @keywords internal
#' @noRd
GDAL_VECTOR_DRIVERS <- c(
  "GeoJSON",
  "GPKG",
  "OpenFileGDB",
  "SQLite",
  "ESRI Shapefile",
  "FlatGeobuf",
  "Parquet",
  "PMTiles",
  "Arrow",
  "MEM",
  "GDALG",
  "OGR_VRT"
)

# magic bytes -----------------------------------------------------------------------------------------------------

#' @keywords internal
#' @noRd
SQLITE_MAGIC_BYTES <- charToRaw("SQLite format 3")

#' @keywords internal
#' @noRd
FGB_MAGIC_BYTES <- as.raw(c(0x66, 0x67, 0x62, 0x03, 0x66, 0x67, 0x62, 0x01))

#' @keywords internal
#' @noRd
GPKG_APPLICATION_IDS <- c(
  "GPKG" = readBin(charToRaw("GPKG"), what = "integer"),
  "GP10" = readBin(charToRaw("GP10"), what = "integer"),
  "GP11" = readBin(charToRaw("GP11"), what = "integer")
)

# json options ----------------------------------------------------------------------------------------------------

#' @keywords internal
#' @noRd
#' @importFrom yyjsonr opts_read_json
JSON_READ_OPTS <- yyjsonr::opts_read_json(
  obj_of_arrs_to_df = FALSE,
  arr_of_objs_to_df = FALSE,
  arr_of_arrs_to_matrix = FALSE
)

#' @keywords internal
#' @noRd
#' @importFrom yyjsonr opts_write_json
JSON_WRITE_OPTS <- yyjsonr::opts_write_json(
  pretty = TRUE,
  auto_unbox = TRUE
)

# shared parameters ------------------------------------------------------------------------------------------------

#' Shared Package Parameters
#'
#' @name .shared_params
#'
#' @description
#' Use `@inheritParams .shared_params` in a function's roxygen2 block to import these parameter descriptions.
#'
#' @description
#' Common, shared parameters that can be inherited by other functions in the package.
#'
#' @param .set_defaults Logical. If `TRUE`, options left unset (`NULL`) are filled with the driver's
#'   documented GDAL metadata defaults (via the relevant `gdal_vector_driver_*_opts_defaults()`);
#'   user-supplied values always take precedence. Defaults to `FALSE`.
#' @param ... Additional `NAME = value` options passed through verbatim alongside the typed
#'   arguments. They are coerced and validated against the driver metadata in the same way, and
#'   take precedence over a typed argument that sets the same option.
#'
#' @keywords internal
NULL

# shared returns --------------------------------------------------------------------------------------------------

#' Check Returns
#'
#' @name .shared_returns_check
#'
#' @description
#' Returns for check_*() functions.
#'
#' @returns
#' If checks pass, invisibly returns to initially provided object `x`, otherwise a condition of class `check_error`
#' is thrown.
#'
#' @keywords internal
NULL

# shared docs -----------------------------------------------------------------------------------------------------

#' GDAL Configuration Links
#'
#' @name gdal_config_links
#'
#' @description
#' Links to the official GDAL Configuration Documentation.
#'
#' ```{r child = "man/fragments/gdal_config_links.md"}
#' ```
#'
#' @seealso [gdal_config_opts()]
NULL

# avoid backtraces ------------------------------------------------------------------------------------------------

# TODO: confirm whether this provides any actual benefit in the pkgdown build process, and if not, remove it.

#' Avoid backtraces in examples
#'
#' @name avoid_backtraces
#'
#' @description
#' This example should run first and set an option for the process that builds the example. By default, {pkgdown} builds
#' examples in a separate process.
#'
#' This also produces a help page that is not linked from anywhere.
#'
#' @keywords internal
#'
#' @examples
#' options(rlang_backtrace_on_error = "none")
NULL
