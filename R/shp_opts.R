#  ------------------------------------------------------------------------
#
# Title : ESRI Shapefile Options
#    By : Jimmy Briggs
#  Date : 2026-06-28
#
#  ------------------------------------------------------------------------

# config ----------------------------------------------------------------------------------------------------------

#' ESRI Shapefile Configuration Options
#'
#' @description
#' Construct a [gdal_config_opts()] object for the `ESRI Shapefile` driver. These are global GDAL
#' configuration options applied to the process (via [gdalraster::set_config_option()] /
#' `--config`). Only options you supply are emitted.
#'
#' @param shape_rewind_on_write Value for `SHAPE_REWIND_ON_WRITE` (logical -> `"YES"`/`"NO"`).
#' @param shape_restore_shx Value for `SHAPE_RESTORE_SHX` (logical -> `"YES"`/`"NO"`); restore a
#'   missing/broken `.shx` from the `.shp` on open.
#' @param shape_2gb_limit Value for `SHAPE_2GB_LIMIT` (logical -> `"YES"`/`"NO"`).
#' @param shape_encoding Value for `SHAPE_ENCODING` (override DBF encoding; `""` disables recoding).
#' @inheritParams .shared_params
#'
#' @returns A [gdal_config_opts()] object for the `ESRI Shapefile` driver.
#' @export
#'
#' @seealso [shp_open_opts()], [shp_creation_opts()], [gdal_config_opts()]
#'
#' ```{r child = "man/fragments/shp_links.md"}
#' ```
#'
#' @examples
#' shp_config_opts(shape_restore_shx = TRUE)
shp_config_opts <- function(
  shape_rewind_on_write = NULL,
  shape_restore_shx = NULL,
  shape_2gb_limit = NULL,
  shape_encoding = NULL,
  .set_defaults = FALSE
) {
  opts <- .gdal_opts_normalize(list(
    SHAPE_REWIND_ON_WRITE = shape_rewind_on_write,
    SHAPE_RESTORE_SHX = shape_restore_shx,
    SHAPE_2GB_LIMIT = shape_2gb_limit,
    SHAPE_ENCODING = shape_encoding
  ))
  if (length(opts) > 0L) {
    check_gdal_opts(opts, gdal_vector_driver_config_opts_values("ESRI Shapefile"))
  }
  if (isTRUE(.set_defaults)) {
    opts <- utils::modifyList(as.list(gdal_vector_driver_config_opts_defaults("ESRI Shapefile")), opts)
  }
  new_gdal_config_opts(opts, driver = "ESRI Shapefile")
}

# open ------------------------------------------------------------------------------------------------------------

#' ESRI Shapefile Open Options
#'
#' @description
#' Construct a [gdal_open_opts()] object for the `ESRI Shapefile` driver.
#'
#' @param encoding Value for `ENCODING` (override DBF encoding).
#' @param dbf_date_last_update Value for `DBF_DATE_LAST_UPDATE` (`YYYY-MM-DD`).
#' @param adjust_type Value for `ADJUST_TYPE` (logical -> `"YES"`/`"NO"`).
#' @param adjust_geom_type Value for `ADJUST_GEOM_TYPE` (e.g. `"FIRST_SHAPE"`).
#' @param auto_repack Value for `AUTO_REPACK` (logical -> `"YES"`/`"NO"`).
#' @param dbf_eof_char Value for `DBF_EOF_CHAR` (logical -> `"YES"`/`"NO"`).
#' @inheritParams .shared_params
#'
#' @returns A [gdal_open_opts()] object for the `ESRI Shapefile` driver.
#' @export
#'
#' @seealso [shp_config_opts()], [shp_creation_opts()], [gdal_open_opts()]
#'
#' ```{r child = "man/fragments/shp_links.md"}
#' ```
#'
#' @examples
#' shp_open_opts(encoding = "UTF-8", auto_repack = TRUE)
shp_open_opts <- function(
  encoding = NULL,
  dbf_date_last_update = NULL,
  adjust_type = NULL,
  adjust_geom_type = NULL,
  auto_repack = NULL,
  dbf_eof_char = NULL,
  .set_defaults = FALSE
) {
  if (!is.null(dbf_date_last_update)) {
    check_regex(dbf_date_last_update, pattern = "^[0-9]{4}-[0-9]{2}-[0-9]{2}$")
  }
  opts <- .gdal_opts_normalize(list(
    ENCODING = encoding,
    DBF_DATE_LAST_UPDATE = dbf_date_last_update,
    ADJUST_TYPE = adjust_type,
    ADJUST_GEOM_TYPE = adjust_geom_type,
    AUTO_REPACK = auto_repack,
    DBF_EOF_CHAR = dbf_eof_char
  ))
  if (length(opts) > 0L) {
    check_gdal_opts(opts, gdal_vector_driver_open_opts_values("ESRI Shapefile"))
  }
  if (isTRUE(.set_defaults)) {
    opts <- utils::modifyList(as.list(gdal_vector_driver_open_opts_defaults("ESRI Shapefile")), opts)
  }
  new_gdal_open_opts(opts, driver = "ESRI Shapefile")
}

# creation --------------------------------------------------------------------------------------------------------

#' ESRI Shapefile Creation Options
#'
#' @description
#' Construct a layer-level [gdal_creation_opts()] object for the `ESRI Shapefile` driver.
#'
#' @param spatial_index Value for `SPATIAL_INDEX` (logical -> `"YES"`/`"NO"`).
#' @param encoding Value for `ENCODING` (DBF encoding).
#' @param resize Value for `RESIZE` (logical -> `"YES"`/`"NO"`); resize fields to optimal size.
#' @param shpt Value for `SHPT` (shape type, e.g. `"POLYGON"`).
#' @param two_gb_limit Value for `2GB_LIMIT` (logical -> `"YES"`/`"NO"`); restrict `.shp`/`.dbf` to 2 GB.
#' @param auto_repack Value for `AUTO_REPACK` (logical -> `"YES"`/`"NO"`).
#' @param dbf_date_last_update Value for `DBF_DATE_LAST_UPDATE` (`YYYY-MM-DD`).
#' @param dbf_eof_char Value for `DBF_EOF_CHAR` (logical -> `"YES"`/`"NO"`).
#' @inheritParams .shared_params
#'
#' @returns A layer-level [gdal_creation_opts()] object for the `ESRI Shapefile` driver.
#' @export
#'
#' @seealso [shp_open_opts()], [gdal_creation_opts()]
#'
#' ```{r child = "man/fragments/shp_links.md"}
#' ```
#'
#' @examples
#' shp_creation_opts(spatial_index = TRUE, encoding = "UTF-8")
shp_creation_opts <- function(
  spatial_index = NULL,
  encoding = NULL,
  resize = NULL,
  shpt = NULL,
  two_gb_limit = NULL,
  auto_repack = NULL,
  dbf_date_last_update = NULL,
  dbf_eof_char = NULL,
  .set_defaults = FALSE
) {
  if (!is.null(dbf_date_last_update)) {
    check_regex(dbf_date_last_update, pattern = "^[0-9]{4}-[0-9]{2}-[0-9]{2}$")
  }
  opts <- .gdal_opts_normalize(list(
    SPATIAL_INDEX = spatial_index,
    ENCODING = encoding,
    RESIZE = resize,
    SHPT = shpt,
    `2GB_LIMIT` = two_gb_limit,
    AUTO_REPACK = auto_repack,
    DBF_DATE_LAST_UPDATE = dbf_date_last_update,
    DBF_EOF_CHAR = dbf_eof_char
  ))
  if (length(opts) > 0L) {
    check_gdal_opts(opts, gdal_vector_driver_creation_opts_values("ESRI Shapefile", sub_type = "layer"))
  }
  if (isTRUE(.set_defaults)) {
    opts <- utils::modifyList(
      as.list(gdal_vector_driver_creation_opts_defaults("ESRI Shapefile", sub_type = "layer")),
      opts
    )
  }
  new_gdal_creation_opts(opts, driver = "ESRI Shapefile", level = "layer")
}
