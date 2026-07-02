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


# VSI Prefixes ----------------------------------------------------------------------------------------------------

#' @keywords internal
#' @noRd
GDAL_VSI_PREFIXES <- c(
  "/vsistdin/",
  "/vsistdout/",
  "/vsimem/",
  "/vsicurl/",
  "/vsizip/",
  "/vsitar/",
  "/vsigzip/",
  "/vsicache/",
  "/vsis3/",
  "/vsigs/",
  "/vsiaz/",
  "/vsiadls/",
  "/vsicrypt/"
)

# core config options ---------------------------------------------------------------------------------------------

# curated names of *core* (non-driver, non-VSI) GDAL configuration options, drawn from
# https://gdal.org/en/stable/user/configoptions.html (GDAL 3.13). this is the only known-option
# source that cannot be derived from the running GDAL build: VSI/network/credential options are
# enumerated at runtime via vsi_get_fs_options(), and per-driver config options come from the
# curated driver metadata table. used only for advisory typo checking and the gdal_config()
# snapshot probe - never blocking. keep small; when in doubt, leave a name out (a key that GDAL
# already resolves to a value is never flagged).
#' @keywords internal
#' @noRd
GDAL_CORE_CONFIG_OPTS <- c(
  # performance / general
  "GDAL_NUM_THREADS",
  "GDAL_CACHEMAX",
  "GDAL_FORCE_CACHING",
  "GDAL_BAND_BLOCK_CACHE",
  "GDAL_MAX_DATASET_POOL_SIZE",
  "GDAL_MAX_DATASET_POOL_RAM_USAGE",
  "GDAL_SWATH_SIZE",
  "GDAL_DISABLE_READDIR_ON_OPEN",
  "GDAL_READDIR_LIMIT_ON_OPEN",
  "GDAL_DATA",
  "GDAL_DRIVER_PATH",
  "GDAL_SKIP",
  "OGR_SKIP",
  "GDAL_CONFIG_FILE",
  "GDAL_RASTERIO_RESAMPLING",
  "GDAL_XML_VALIDATION",
  "GDAL_FILENAME_IS_UTF8",
  "GDAL_PAM_ENABLED",
  "GDAL_PAM_PROXY_DIR",
  # cpl / logging
  "CPL_DEBUG",
  "CPL_LOG",
  "CPL_LOG_ERRORS",
  "CPL_TIMESTAMP",
  "CPL_MAX_ERROR_REPORTS",
  "CPL_ACCUM_ERROR_MSG",
  "CPL_CURL_VERBOSE",
  "CPL_CURL_GZIP",
  "CPL_TMPDIR",
  # vsi general
  "VSI_CACHE",
  "VSI_CACHE_SIZE",
  # http core (not reliably part of the runtime vsi option metadata on all builds)
  "GDAL_HTTP_TIMEOUT",
  "GDAL_HTTP_CONNECTTIMEOUT",
  "GDAL_HTTP_MAX_RETRY",
  "GDAL_HTTP_RETRY_DELAY",
  "GDAL_HTTP_RETRY_CODES",
  "GDAL_HTTP_VERSION",
  "GDAL_HTTP_USERAGENT",
  "GDAL_HTTP_PROXY",
  "GDAL_HTTPS_PROXY",
  "GDAL_HTTP_PROXYUSERPWD",
  "GDAL_HTTP_NETRC",
  "GDAL_HTTP_SSL_VERIFYPEER",
  "GDAL_HTTP_UNSAFESSL",
  "GDAL_HTTP_TCP_KEEPALIVE",
  # cloud extras not consistently enumerated by vsi_get_fs_options()
  "AWS_REGION",
  # proj / srs
  "PROJ_LIB",
  "PROJ_DATA",
  "PROJ_NETWORK",
  "PROJ_NETWORK_ENDPOINT",
  "OSR_DEFAULT_AXIS_MAPPING_STRATEGY",
  "OSR_WKT_FORMAT",
  "CHECK_WITH_INVERT_PROJ",
  "CENTER_LONG",
  # ogr general
  "OGR_INTERLEAVED_READING",
  "OGR_ARC_STEPSIZE",
  "OGR_ARC_MAX_GAP",
  "OGR_WKT_PRECISION",
  "OGR_ORGANIZE_POLYGONS",
  "OGR_ENABLE_PARTIAL_REPROJECTION",
  "OGR_SQL_LIKE_AS_ILIKE",
  "OGR_FORCE_ASCII",
  "OGR_CURRENT_DATE"
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
#' This example should run first and set an option for the process that builds the example. By default, `pkgdown` builds
#' examples in a separate process.
#'
#' This also produces a help page that is not linked from anywhere.
#'
#' @keywords internal
#'
#' @examples
#' options(rlang_backtrace_on_error = "none")
NULL
