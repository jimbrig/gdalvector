#  ------------------------------------------------------------------------
#
# Title : Predicates
#    By : Jimmy Briggs
#  Date : 2026-05-31
#
#  ------------------------------------------------------------------------

# topic -----------------------------------------------------------------------------------------------------------

#' Predicates
#'
#' @name predicates
#'
#' @description
#' A collection of predicate functions for checking various conditions, types, and properties of objects.
#' These functions return logical values (TRUE or FALSE) based on the input provided.
#'
#' @section Functions:
#'
#' ### Types
#'
#' - `is_int64(x)`: Check if `x` is of type `integer64`.
#'
#' ### Virtual File System (VSI)
#'
#' - `is_vsi_path(x)`: Check if a path is a GDAL Virtual File System (VSI) path or URL.
#'
#' @keywords internal
NULL

# types -----------------------------------------------------------------------------------------------------------

#' @importFrom bit64 is.integer64
is_int64 <- function(x) {
  bit64::is.integer64(x)
}


# vsi -------------------------------------------------------------------------------------------------------------

#' Check if Virtual File System (VSI)
#'
#' @description
#' Check if a provided path or URL uses [GDAL's Virtual File System (VSI)](https://gdal.org/en/stable/user/virtual_file_systems.html).
#'
#' Virtual File System's include prefixes such as `/vsistdin/`, `/vsistdout/`, `/vsimem/`, etc.
#'
#' @param x Character string to check. Should represent a path or URL (or in rare cases, a connection string).
#'
#' @returns
#' Logical indicating if the path starts with a valid VSI prefix.
#'
#' @examples
#' is_vsi_path("/vsizip/data.zip")      # TRUE
#' is_vsi_path("/vsicurl/data.geojson") # TRUE
#' is_vsi_path("data.geojson")          # FALSE
#'
#' @export
is_vsi_path <- function(x) {
  if (!is.character(x) || length(x) != 1L || !nzchar(x)) {
    return(FALSE)
  }
  # all(startsWith(x, "/vsi"), grepl("^/vsi[a-z0-9_]+/", x, ignore.case = TRUE))
  any(startsWith(x, GDAL_VSI_PREFIXES))
}

# remote ----------------------------------------------------------------------------------------------------------

is_remote <- function(x) {
  grepl("^https?://|^ftp://|^/vsicurl/", x)
}

is_url <- function(x) {
  grepl("^https?://|^ftp://", x)
}


# cloud -----------------------------------------------------------------------------------------------------------

is_s3_url <- function(x) {
  grepl("^s3://", x)
}

is_az_url <- function(x) {
  grepl("^az://", x)
}

is_gs_url <- function(x) {
  grepl("^gs://", x)
}

is_r2_url <- function(x) {
  grepl("^r2://", x)
}

is_tigris_url <- function(x) {
  grepl("^tigris://", x)
}

# archives --------------------------------------------------------------------------------------------------------

is_archive <- function(x) {
  grepl("\\.zip$|\\.gz$|\\.tar$", x, ignore.case = TRUE) || startsWith(x, "/vsizip/")
}

is_zip <- function(x) {
  if (!is.character(x) || length(x) != 1L || !nzchar(x)) {
    return(FALSE)
  }
  tolower(tools::file_ext(x)) == "zip"
}


# platform / os ---------------------------------------------------------------------------------------------------

is_windows <- function() {
  sys_platform() == "windows"
}

is_unix <- function() {
  sys_platform() == "unix"
}

is_linux <- function() {
  is_unix() && grepl("linux", tolower(Sys.info()[["sysname"]]))
}

is_macos <- function() {
  is_unix() && grepl("darwin", tolower(Sys.info()[["sysname"]]))
}

# json ------------------------------------------------------------------------------------------------------------

is_valid_json_str <- function(x) {
  yyjsonr::validate_json_str(x)
}

is_valid_json_file <- function(x) {
  yyjsonr::validate_json_file(x)
}


# xml -------------------------------------------------------------------------------------------------------------

is_xml_string <- function(x) {
  if (!is.character(x) || !nzchar(trimws(x))) {
    return(FALSE)
  }
  res <- rlang::try_fetch(xml2::read_xml(x), error = function(e) NULL)
  if (is.null(res)) {
    return(FALSE)
  }
  TRUE
}

is_xml_document <- function(x) {
  inherits(x, "xml_document")
}

is_xml_node <- function(x) {
  inherits(x, "xml_node")
}

is_xml_nodeset <- function(x) {
  inherits(x, "xml_nodeset")
}

is_xml_namespace <- function(x) {
  inherits(x, "xml_namespace")
}

# gdal ------------------------------------------------------------------------------------------------------------

is_gdal_vector <- function(x) {
  inherits(x, "Rcpp_GDALVector")
}

is_gdal_raster <- function(x) {
  inherits(x, "Rcpp_GDALRaster")
}

is_gdal_alg <- function(x) {
  inherits(x, "Rcpp_GDALAlg")
}

is_gdal_dsn <- function(x) {
  inherits(x, "gdal_dsn")
}

is_gdal_source <- function(x) {
  inherits(x, "gdal_source")
}

is_gdalg <- function(x) {
  inherits(x, "gdalg")
}

is_gdal_opts <- function(x) {
  inherits(x, "gdal_opts")
}

is_gdal_open_opts <- function(x) {
  inherits(x, "gdal_open_opts")
}

is_gdal_creation_opts <- function(x) {
  inherits(x, "gdal_creation_opts")
}

is_gdal_config_opts <- function(x) {
  inherits(x, "gdal_config_opts")
}

is_gdal_vsi_opts <- function(x) {
  inherits(x, "gdal_vsi_opts")
}

is_gdal_config <- function(x) {
  inherits(x, "gdal_config")
}

is_gdal_config_sitrep <- function(x) {
  inherits(x, "gdal_config_sitrep")
}

is_gdal_config_file <- function(x) {
  inherits(x, "gdal_config_file")
}

is_gdal_driver_name <- function(x) {
  toupper(x) %in% toupper(gdal_driver_names())
}

is_sqlite_driver <- function(x) {
  tolower(x) %in% c("gpkg", "sqlite", "rasterlite", "vfk", "osm", "mvt")
}

is_single_layer_driver <- function(x) {
  tolower(x) %in% c("esri shapefile", "flatgeobuf", "geojson", "csv", "kml", "arrow", "gpx")
}

is_cloud_native_driver <- function(x) {
  tolower(x) %in% c("parquet", "flatgeobuf", "pmtiles", "arrow")
}

# spatial ---------------------------------------------------------------------------------------------------------

is_sf <- function(x) {
  inherits(x, "sf")
}

is_sfc <- function(x) {
  inherits(x, "sfc")
}

is_sfg <- function(x) {
  inherits(x, "sfg")
}

is_crs <- function(x) {
  inherits(try(sf::st_crs(x), silent = TRUE), "crs")
}

is_lonlat <- function(x) {
  if (!is_crs(x)) {
    return(FALSE)
  }
  crs <- sf::st_crs(x)
  if (is.na(crs$epsg)) {
    return(FALSE)
  }
  crs$epsg == 4326L
}
