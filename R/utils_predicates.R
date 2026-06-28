#  ------------------------------------------------------------------------
#
# Title : Predicates
#    By : Jimmy Briggs
#  Date : 2026-05-31
#
#  ------------------------------------------------------------------------

# types -----------------------------------------------------------------------------------------------------------

#' @importFrom bit64 is.integer64
is_int64 <- function(x) {
  bit64::is.integer64(x)
}


# vsi -------------------------------------------------------------------------------------------------------------

#' Is VSI Path
#'
#' @description
#' Check if a Path is a GDAL Virtual File System (VSI) Path or URL.
#'
#' @param x Character string to check.
#'
#' @returns
#' Logical indicating if the path starts with a valid VSI prefix (i.e. `/vsicurl/` or `/vsizip/`).
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
  all(startsWith(x, "/vsi"), grepl("^/vsi[a-z0-9_]+/", x, ignore.case = TRUE))
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

# fips ------------------------------------------------------------------------------------------------------------

is_state_fips <- function(x) {
  if (is.null(x) || is.na(x) || length(x) == 0L || !nzchar(x)) {
    return(FALSE)
  }
  if (nchar(x) != 2L) {
    return(FALSE)
  }
  if (!(x %in% fips_codes$state_fips)) {
    return(FALSE)
  }
  TRUE
}

is_county_fips <- function(x) {
  if (is.null(x) || is.na(x) || length(x) == 0L || !nzchar(x)) {
    return(FALSE)
  }
  if (nchar(x) != 5L) {
    return(FALSE)
  }
  state_fips <- substr(x, 1L, 2L)
  if (!is_state_fips(state_fips)) {
    return(FALSE)
  }
  state_county_fips <- .get_county_fips_codes(state_fips = state_fips)
  if (!(x %in% state_county_fips)) {
    return(FALSE)
  }
  TRUE
}

is_community_fips <- function(x) {
  if (is.null(x) || is.na(x) || length(x) == 0L || !nzchar(x)) {
    return(FALSE)
  }
  if (nchar(x) != 6L) {
    return(FALSE)
  }
  if (toupper(substr(x, 6L, 6L)) != "C") {
    return(FALSE)
  }
  county_fips <- substr(x, 1L, 5L)
  if (!is_county_fips(county_fips)) {
    return(FALSE)
  }
  TRUE
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

is_bbox <- function(x) {}

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


# srs/crs ---------------------------------------------------------------------------------------------------------

# is_crs_srs <- function(x) {
#   try(gdalraster::srs_)
# }
#
# is_crs_sf <- function(x) {
#   inherits(try(sf::st_crs(x), silent = TRUE), "crs")
# }
#
#
#
# is_crs_lonlat <- function(x) {
#   if (!is_crs(x)) return(FALSE)
#   crs <- sf::st_crs(x)
#   if (is.na(crs$epsg)) return(FALSE)
#   crs$epsg == 4326L
# }

# internal --------------------------------------------------------------------------------------------------------

.get_county_fips_codes <- function(state_fips) {
  dplyr::filter(fips_codes, .data$state_fips == .env$state_fips) |>
    dplyr::pull(.data$county_fips) |>
    sort() |>
    unique()
}
