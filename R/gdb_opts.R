#  ------------------------------------------------------------------------
#
# Title : OpenFileGDB Options
#    By : Jimmy Briggs
#  Date : 2026-06-28
#
#  ------------------------------------------------------------------------

# config ----------------------------------------------------------------------------------------------------------

#' OpenFileGDB Configuration Options
#'
#' @description
#' Construct a [gdal_config_opts()] object for the `OpenFileGDB` driver. Only options you supply are
#' emitted; boolean values are validated against the driver metadata.
#'
#' @param default_string_width Value for `OPENFILEGDB_DEFAULT_STRING_WIDTH` (integer). Width for
#'   string fields created when the requested width is the unspecified value `0`. GDAL default `65536`.
#' @param in_memory_spi Value for `OPENFILEGDB_IN_MEMORY_SPI`. Logical `TRUE`/`FALSE` (coerced to
#'   `"YES"`/`"NO"`); build an in-memory spatial index instead of using the native one.
#' @param ... Additional `NAME = value` configuration options passed through after coercion.
#' @inheritParams .shared_params
#'
#' @returns A [gdal_config_opts()] object for the `OpenFileGDB` driver.
#' @export
#'
#' @seealso [gdb_open_opts()], [gdb_creation_opts()], [gdal_config_opts()]
#'
#' @examples
#' gdb_config_opts(default_string_width = 1024L, in_memory_spi = TRUE)
gdb_config_opts <- function(default_string_width = NULL, in_memory_spi = NULL, ..., .set_defaults = FALSE) {
  .build_gdal_opts(
    c(
      list(
        OPENFILEGDB_DEFAULT_STRING_WIDTH = default_string_width,
        OPENFILEGDB_IN_MEMORY_SPI = in_memory_spi
      ),
      rlang::list2(...)
    ),
    channel = "config",
    driver = "OpenFileGDB",
    .set_defaults = .set_defaults
  )
}

# open ------------------------------------------------------------------------------------------------------------

#' OpenFileGDB Open Options
#'
#' @description
#' Construct a [gdal_open_opts()] object for the `OpenFileGDB` driver.
#'
#' @param list_all_tables Value for `LIST_ALL_TABLES` (`"YES"`/`"NO"`; logical coerced). Whether to
#'   list all tables, including system/internal `GDB_*` tables. GDAL default `"NO"`.
#' @inheritParams .shared_params
#'
#' @returns A [gdal_open_opts()] object for the `OpenFileGDB` driver.
#' @export
#'
#' @seealso [gdb_creation_opts()], [gdal_open_opts()]
#'
#' @examples
#' gdb_open_opts(list_all_tables = TRUE)
gdb_open_opts <- function(list_all_tables = NULL, .set_defaults = FALSE) {
  .build_gdal_opts(
    list(LIST_ALL_TABLES = list_all_tables),
    channel = "open",
    driver = "OpenFileGDB",
    .set_defaults = .set_defaults
  )
}

# creation --------------------------------------------------------------------------------------------------------

#' OpenFileGDB Creation Options
#'
#' @description
#' Construct a layer-level [gdal_creation_opts()] object for the `OpenFileGDB` driver. Typed
#' arguments cover the common layer options; advanced coordinate-precision grid options
#' (`XORIGIN`, `XYSCALE`, `XYTOLERANCE`, `Z*`/`M*`) may be supplied through `...`.
#'
#' @param fid Name of the OID column (`FID`). GDAL default `"OBJECTID"`.
#' @param geometry_name Name of the geometry column (`GEOMETRY_NAME`). GDAL default `"SHAPE"`.
#' @param geometry_nullable Value for `GEOMETRY_NULLABLE` (logical -> `"YES"`/`"NO"`).
#' @param configuration_keyword Value for `CONFIGURATION_KEYWORD` (storage configuration).
#' @param target_arcgis_version Value for `TARGET_ARCGIS_VERSION`.
#' @param create_multipatch Value for `CREATE_MULTIPATCH` (logical -> `"YES"`/`"NO"`).
#' @param create_shape_area_and_length_fields Value for `CREATE_SHAPE_AREA_AND_LENGTH_FIELDS`
#'   (logical -> `"YES"`/`"NO"`).
#' @param time_in_utc Value for `TIME_IN_UTC` (logical -> `"YES"`/`"NO"`).
#' @param column_types Value for `COLUMN_TYPES` (e.g. `"field=fgdb_type,..."`).
#' @param feature_dataset Value for `FEATURE_DATASET`.
#' @param layer_alias Value for `LAYER_ALIAS`.
#' @param documentation Value for `DOCUMENTATION` (XML documentation string).
#' @param ... Additional `NAME = value` layer-creation options (e.g. coordinate-grid options).
#' @inheritParams .shared_params
#'
#' @returns A layer-level [gdal_creation_opts()] object for the `OpenFileGDB` driver.
#' @export
#'
#' @seealso [gdb_open_opts()], [gdal_creation_opts()]
#'
#' @examples
#' gdb_creation_opts(geometry_name = "SHAPE", target_arcgis_version = "ALL")
gdb_creation_opts <- function(
  fid = NULL,
  geometry_name = NULL,
  geometry_nullable = NULL,
  configuration_keyword = NULL,
  target_arcgis_version = NULL,
  create_multipatch = NULL,
  create_shape_area_and_length_fields = NULL,
  time_in_utc = NULL,
  column_types = NULL,
  feature_dataset = NULL,
  layer_alias = NULL,
  documentation = NULL,
  ...,
  .set_defaults = FALSE
) {
  .build_gdal_opts(
    c(
      list(
        FID = fid,
        GEOMETRY_NAME = geometry_name,
        GEOMETRY_NULLABLE = geometry_nullable,
        CONFIGURATION_KEYWORD = configuration_keyword,
        TARGET_ARCGIS_VERSION = target_arcgis_version,
        CREATE_MULTIPATCH = create_multipatch,
        CREATE_SHAPE_AREA_AND_LENGTH_FIELDS = create_shape_area_and_length_fields,
        TIME_IN_UTC = time_in_utc,
        COLUMN_TYPES = column_types,
        FEATURE_DATASET = feature_dataset,
        LAYER_ALIAS = layer_alias,
        DOCUMENTATION = documentation
      ),
      rlang::list2(...)
    ),
    channel = "creation",
    driver = "OpenFileGDB",
    level = "layer",
    .set_defaults = .set_defaults
  )
}
