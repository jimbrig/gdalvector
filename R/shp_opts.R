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
#' @param shape_rewind_on_write Value for `SHAPE_REWIND_ON_WRITE` (logical -> `"YES"`/`"NO"`); whether
#'   to correct the winding order of exterior/interior rings on write. Since GDAL 3.7 the default for
#'   Polygon/MultiPolygon is `"NO"`.
#' @param shape_restore_shx Value for `SHAPE_RESTORE_SHX` (logical -> `"YES"`/`"NO"`); restore a
#'   missing/broken `.shx` from the `.shp` on open. GDAL default `"NO"`.
#' @param shape_2gb_limit Value for `SHAPE_2GB_LIMIT` (logical -> `"YES"`/`"NO"`); strictly enforce
#'   the 2 GB `.shp`/`.dbf` size limit when updating.
#' @param shape_encoding Value for `SHAPE_ENCODING` (override DBF encoding with any `CPLRecode()`
#'   encoding; `""` disables recoding).
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
  ...,
  .set_defaults = FALSE
) {
  .build_gdal_opts(
    c(
      list(
        SHAPE_REWIND_ON_WRITE = shape_rewind_on_write,
        SHAPE_RESTORE_SHX = shape_restore_shx,
        SHAPE_2GB_LIMIT = shape_2gb_limit,
        SHAPE_ENCODING = shape_encoding
      ),
      rlang::list2(...)
    ),
    channel = "config",
    driver = "ESRI Shapefile",
    .set_defaults = .set_defaults
  )
}

# open ------------------------------------------------------------------------------------------------------------

#' ESRI Shapefile Open Options
#'
#' @description
#' Construct a [gdal_open_opts()] object for the `ESRI Shapefile` driver.
#'
#' @param encoding Value for `ENCODING` (override DBF encoding with any `CPLRecode()` encoding; `""`
#'   avoids recoding).
#' @param dbf_date_last_update Value for `DBF_DATE_LAST_UPDATE` (`YYYY-MM-DD`); modification date
#'   written in the DBF header. Defaults to the current date.
#' @param adjust_type Value for `ADJUST_TYPE` (logical -> `"YES"`/`"NO"`); read the whole `.dbf` to
#'   refine ambiguous `Real`/`Integer`/`Integer64` field types. GDAL default `"NO"`.
#' @param adjust_geom_type Value for `ADJUST_GEOM_TYPE`. One of `NO`/`FIRST_SHAPE`/`ALL_SHAPES`; how
#'   the layer geometry type (notably the `M` dimension) is determined. GDAL default `"FIRST_SHAPE"`.
#' @param auto_repack Value for `AUTO_REPACK` (logical -> `"YES"`/`"NO"`); auto-repack the shapefile
#'   when needed. GDAL default `"YES"`.
#' @param dbf_eof_char Value for `DBF_EOF_CHAR` (logical -> `"YES"`/`"NO"`); write the `0x1A`
#'   end-of-file character in the `.dbf`. GDAL default `"YES"`.
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
  ...,
  .set_defaults = FALSE
) {
  if (!is.null(dbf_date_last_update)) {
    check_regex(dbf_date_last_update, pattern = "^[0-9]{4}-[0-9]{2}-[0-9]{2}$")
  }
  .build_gdal_opts(
    c(
      list(
        ENCODING = encoding,
        DBF_DATE_LAST_UPDATE = dbf_date_last_update,
        ADJUST_TYPE = adjust_type,
        ADJUST_GEOM_TYPE = adjust_geom_type,
        AUTO_REPACK = auto_repack,
        DBF_EOF_CHAR = dbf_eof_char
      ),
      rlang::list2(...)
    ),
    channel = "open",
    driver = "ESRI Shapefile",
    .set_defaults = .set_defaults
  )
}

# creation --------------------------------------------------------------------------------------------------------

#' ESRI Shapefile Creation Options
#'
#' @description
#' Construct a layer-level [gdal_creation_opts()] object for the `ESRI Shapefile` driver.
#'
#' @param spatial_index Value for `SPATIAL_INDEX` (logical -> `"YES"`/`"NO"`); create a `.qix`
#'   spatial index. GDAL default `"NO"`.
#' @param encoding Value for `ENCODING` (DBF encoding written to the `.cpg`/header). GDAL default
#'   `"LDID/87"`.
#' @param resize Value for `RESIZE` (logical -> `"YES"`/`"NO"`); resize fields to their optimal size.
#'   GDAL default `"NO"`.
#' @param shpt Value for `SHPT` (shape type override): one of `NULL`/`POINT`/`ARC`/`POLYGON`/
#'   `MULTIPOINT` (2D), the `*Z`/`*M`/`*ZM` measured/3D variants, or `MULTIPATCH`.
#' @param two_gb_limit Value for `2GB_LIMIT` (logical -> `"YES"`/`"NO"`); enforce the 2 GB `.shp`/`.dbf`
#'   size limit. GDAL default `"NO"`.
#' @param auto_repack Value for `AUTO_REPACK` (logical -> `"YES"`/`"NO"`); auto-repack when needed.
#'   GDAL default `"YES"`.
#' @param dbf_date_last_update Value for `DBF_DATE_LAST_UPDATE` (`YYYY-MM-DD`); modification date
#'   written in the DBF header. Defaults to the current date.
#' @param dbf_eof_char Value for `DBF_EOF_CHAR` (logical -> `"YES"`/`"NO"`); write the `0x1A`
#'   end-of-file character in the `.dbf`. GDAL default `"YES"`.
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
  ...,
  .set_defaults = FALSE
) {
  if (!is.null(dbf_date_last_update)) {
    check_regex(dbf_date_last_update, pattern = "^[0-9]{4}-[0-9]{2}-[0-9]{2}$")
  }
  .build_gdal_opts(
    c(
      list(
        SPATIAL_INDEX = spatial_index,
        ENCODING = encoding,
        RESIZE = resize,
        SHPT = shpt,
        `2GB_LIMIT` = two_gb_limit,
        AUTO_REPACK = auto_repack,
        DBF_DATE_LAST_UPDATE = dbf_date_last_update,
        DBF_EOF_CHAR = dbf_eof_char
      ),
      rlang::list2(...)
    ),
    channel = "creation",
    driver = "ESRI Shapefile",
    level = "layer",
    .set_defaults = .set_defaults
  )
}
