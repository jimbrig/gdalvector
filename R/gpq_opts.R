#  ------------------------------------------------------------------------
#
# Title : GeoParquet (Parquet) Options
#    By : Jimmy Briggs
#  Date : 2026-06-28
#
#  ------------------------------------------------------------------------

# open ------------------------------------------------------------------------------------------------------------

#' GeoParquet Open Options
#'
#' @description
#' Construct a [gdal_open_opts()] object for the `Parquet` (GeoParquet) driver.
#'
#' @param geom_possible_names Value for `GEOM_POSSIBLE_NAMES` (GDAL >= 3.8). Comma-separated list of
#'   candidate geometry column names, used only for files without GeoParquet metadata. GDAL default
#'   `"geometry,wkb_geometry,wkt_geometry"`.
#' @param crs Value for `CRS` (GDAL >= 3.8). Set or override the CRS of geometry columns, typically
#'   `"AUTH:CODE"` (e.g. `"EPSG:4326"`), or a PROJ/WKT CRS string.
#' @param lists_as_string_json Value for `LISTS_AS_STRING_JSON` (GDAL >= 3.12.1; logical ->
#'   `"YES"`/`"NO"`). Report lists of strings/integers/reals as `String(JSON)` fields. GDAL default
#'   `"NO"`.
#' @inheritParams .shared_params
#'
#' @returns A [gdal_open_opts()] object for the `Parquet` driver.
#' @export
#'
#' @seealso [gpq_creation_opts()], [gdal_open_opts()]
#'
#' ```{r child = "man/fragments/gpq_links.md"}
#' ```
#'
#' @examples
#' gpq_open_opts(crs = "EPSG:4326")
gpq_open_opts <- function(geom_possible_names = NULL, crs = NULL, lists_as_string_json = NULL, ..., .set_defaults = FALSE) {
  .build_gdal_opts(
    c(
      list(
        GEOM_POSSIBLE_NAMES = geom_possible_names,
        CRS = crs,
        LISTS_AS_STRING_JSON = lists_as_string_json
      ),
      rlang::list2(...)
    ),
    channel = "open",
    driver = "Parquet",
    .set_defaults = .set_defaults
  )
}

# creation --------------------------------------------------------------------------------------------------------

#' GeoParquet Creation Options
#'
#' @description
#' Construct a layer-level [gdal_creation_opts()] object for the `Parquet` (GeoParquet) driver. Only
#' options you supply are emitted; enumerated values are validated against the driver metadata.
#'
#' @param compression Value for `COMPRESSION`. One of `NONE`/`SNAPPY`/`GZIP`/`BROTLI`/`ZSTD`/
#'   `LZ4_RAW`/`LZ4_HADOOP` (available values depend on how the Parquet library was built). GDAL
#'   default `"SNAPPY"` when available, otherwise `NONE`.
#' @param compression_level Value for `COMPRESSION_LEVEL` (GDAL >= 3.12). Codec-dependent integer.
#' @param geometry_encoding Value for `GEOMETRY_ENCODING`. One of `WKB`/`WKT`/`GEOARROW`/
#'   `GEOARROW_INTERLEAVED`. GDAL default `"WKB"` (recommended for interoperability).
#' @param row_group_size Value for `ROW_GROUP_SIZE` (maximum rows per group). GDAL default `65536`.
#' @param geometry_name Value for `GEOMETRY_NAME`. GDAL default `"geometry"`.
#' @param fid Value for `FID` (name of the FID column to create; if unset, no FID column is created).
#' @param polygon_orientation Value for `POLYGON_ORIENTATION`. One of `COUNTERCLOCKWISE`/
#'   `UNMODIFIED`. GDAL default `"COUNTERCLOCKWISE"`.
#' @param edges Value for `EDGES`. One of `PLANAR`/`SPHERICAL`. GDAL default `"PLANAR"`.
#' @param creator Value for `CREATOR` (name of the creating application).
#' @param write_covering_bbox Value for `WRITE_COVERING_BBOX` (GDAL >= 3.9). One of `AUTO`/`YES`/`NO`
#'   (logical coerced); write per-row `xmin/ymin/xmax/ymax` bounding-box columns for faster spatial
#'   filtering. GDAL default `"AUTO"`.
#' @param covering_bbox_name Value for `COVERING_BBOX_NAME` (GDAL >= 3.13). Defaults to the geometry
#'   column name suffixed with `_bbox`.
#' @param use_parquet_geo_types Value for `USE_PARQUET_GEO_TYPES` (GDAL >= 3.12; requires
#'   libarrow >= 21). One of `YES`/`NO`/`ONLY`. GDAL default `"NO"`.
#' @param sort_by_bbox Value for `SORT_BY_BBOX` (GDAL >= 3.9; logical -> `"YES"`/`"NO"`). Spatially
#'   order features (via a temporary GeoPackage) for faster spatial filtering. GDAL default `"NO"`.
#' @param timestamp_with_offset Value for `TIMESTAMP_WITH_OFFSET` (GDAL >= 3.13). One of
#'   `AUTO`/`YES`/`NO`. GDAL default `"AUTO"`.
#' @param coordinate_precision Value for `COORDINATE_PRECISION` (number of decimals for coordinates;
#'   only for `GEOMETRY_ENCODING=WKT`).
#' @inheritParams .shared_params
#'
#' @section Distributing GeoParquet:
#' Following the OGC *Best Practices for Distributing GeoParquet*, good defaults for distribution
#' are `ZSTD` compression at a moderate level, a row-group size around 50000-150000, the per-row
#' bounding-box covering columns enabled, and spatially ordered features:
#'
#' ```r
#' gpq_creation_opts(
#'   compression = "ZSTD",
#'   compression_level = 15,
#'   row_group_size = 100000,
#'   write_covering_bbox = TRUE,
#'   sort_by_bbox = TRUE
#' )
#' ```
#'
#' @returns A layer-level [gdal_creation_opts()] object for the `Parquet` driver.
#' @export
#'
#' @seealso [gpq_open_opts()], [gdal_creation_opts()]
#'
#' ```{r child = "man/fragments/gpq_links.md"}
#' ```
#'
#' @examples
#' gpq_creation_opts(compression = "ZSTD", geometry_encoding = "WKB")
gpq_creation_opts <- function(
  compression = NULL,
  compression_level = NULL,
  geometry_encoding = NULL,
  row_group_size = NULL,
  geometry_name = NULL,
  fid = NULL,
  polygon_orientation = NULL,
  edges = NULL,
  creator = NULL,
  write_covering_bbox = NULL,
  covering_bbox_name = NULL,
  use_parquet_geo_types = NULL,
  sort_by_bbox = NULL,
  timestamp_with_offset = NULL,
  coordinate_precision = NULL,
  ...,
  .set_defaults = FALSE
) {
  .build_gdal_opts(
    c(
      list(
        COMPRESSION = compression,
        COMPRESSION_LEVEL = compression_level,
        GEOMETRY_ENCODING = geometry_encoding,
        ROW_GROUP_SIZE = row_group_size,
        GEOMETRY_NAME = geometry_name,
        FID = fid,
        POLYGON_ORIENTATION = polygon_orientation,
        EDGES = edges,
        CREATOR = creator,
        WRITE_COVERING_BBOX = write_covering_bbox,
        COVERING_BBOX_NAME = covering_bbox_name,
        USE_PARQUET_GEO_TYPES = use_parquet_geo_types,
        SORT_BY_BBOX = sort_by_bbox,
        TIMESTAMP_WITH_OFFSET = timestamp_with_offset,
        COORDINATE_PRECISION = coordinate_precision
      ),
      rlang::list2(...)
    ),
    channel = "creation",
    driver = "Parquet",
    level = "layer",
    .set_defaults = .set_defaults
  )
}
