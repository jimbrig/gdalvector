#  ------------------------------------------------------------------------
#
# Title : GDAL Sitrep
#    By : Jimmy Briggs
#  Date : 2026-06-11
#
#  ------------------------------------------------------------------------

# sitrep ----------------------------------------------------------------------------------------------------------

gdal_sitrep <- function() {}

gdal_sitrep_versions <- function() {
  list(
    system = gdal_version_sys(),
    gdalraster = gdal_version_gdalraster(),
    sf = gdal_version_sf(),
    terra = gdal_version_terra(),
    vapour = gdal_version_vapour()
  )
}

gdal_sitrep_version_check <- function(major = 3L, minor = 11L, patch = 0L) {
  gdal_version_num() >= gdalraster::gdal_compute_version(major, minor, patch)
}

gdal_sitrep_alg_check <- function() {
  !identical(gdal_alg_names(), character(0))
}

gdal_sitrep_driver_check <- function(driver) {
  drvs <- gdalraster::gdal_formats()$short_name
  driver %in% drvs
}

# algorithmic -----------------------------------------------------------------------------------------------------

gdal_alg_names <- function() {
  gdalraster::gdal_global_reg_names()
}

# binary ----------------------------------------------------------------------------------------------------------

gdal_cmd_path <- function() {
  sys_which("gdal")
}


# version - gdal --------------------------------------------------------------------------------------------------

gdal_version <- function(backend = c("system", "gdalraster", "sf", "terra", "vapour")) {
  backend <- rlang::arg_match(backend)
  switch(
    backend,
    "system" = gdal_version_sys(),
    "gdalraster" = gdal_version_gdalraster(),
    "sf" = gdal_version_sf(),
    "terra" = gdal_version_terra(),
    "vapour" = gdal_version_vapour()
  )
}

gdal_version_num <- function() {
  gdalraster::gdal_version_num()
}

gdal_version_sys <- function(path = gdal_cmd_path()) {
  .clean_gdal_version_string(processx::run(path, c("--version"))$stdout)
}

gdal_version_gdalraster <- function() {
  gdalraster::gdal_version()[[4]]
}

gdal_version_sf <- function() {
  sf::sf_extSoftVersion()[["GDAL"]]
}

gdal_version_terra <- function() {
  terra::libVersion(lib = "gdal")
}

gdal_version_vapour <- function() {
  .clean_gdal_version_string(vapour::vapour_gdal_version())
}


# versions - geos -------------------------------------------------------------------------------------------------

geos_version <- function(backend = c("gdalraster", "sf", "terra", "geos")) {
  backend <- rlang::arg_match(backend)
  switch(
    backend,
    "gdalraster" = geos_version_gdalraster(),
    "sf" = geos_version_sf(),
    "terra" = geos_version_terra(),
    "geos" = geos_version_geos()
  )
}

geos_version_gdalraster <- function() {
  gdalraster::geos_version()$name
}

geos_version_sf <- function() {
  sf::sf_extSoftVersion()[[1]]
}

geos_version_terra <- function() {
  terra::libVersion(lib = "geos")
}

geos_version_geos <- function() {
  geos::geos_version()
}


# versions - proj -------------------------------------------------------------------------------------------------

proj_version <- function(backend = c("gdalraster", "sf", "terra")) {
  backend <- rlang::arg_match(backend)
  switch(
    backend,
    "gdalraster" = proj_version_gdalraster(),
    "sf" = proj_version_sf(),
    "terra" = proj_version_terra()
  )
}

proj_version_gdalraster <- function() {
  gdalraster::proj_version()$name
}

proj_version_sf <- function() {
  sf::sf_extSoftVersion()[["PROJ"]]
}

proj_version_terra <- function() {
  terra::libVersion("PROJ")
}

# internal --------------------------------------------------------------------------------------------------------

.parse_version_string <- function(str) {
  str <- trimws(str)
  match <- regexpr("[0-9]+\\.[0-9]+\\.[0-9]+(rc[0-9]+)?", str)
  if (match == -1L) {
    return(NULL)
  }
  regmatches(str, match)
}

.clean_gdal_version_string <- function(str, call = rlang::caller_env()) {
  sub(".*GDAL ([0-9.]+).*", "\\1", str)
}

.parse_gdal_version_string <- function(str) {
  str <- trimws(str)
  match <- regexpr("[0-9]+\\.[0-9]+\\.[0-9]+(rc[0-9]+)?", str)
  if (match == -1L) {
    return(NULL)
  }
  full <- regmatches(str, match)
  parts <- strsplit(full, "\\.")[[1]]
  major <- as.integer(parts[1])
  minor <- as.integer(parts[2])
  patch <- if (length(parts) > 2L) {
    patch_str <- parts[3]
    as.integer(sub("rc[0-9]+", "", patch_str))
  } else {
    0L
  }
  rc <- if (grepl("rc[0-9]+", full)) {
    rc_match <- regexpr("rc[0-9]+", full)
    regmatches(full, rc_match)
  } else {
    NULL
  }
  list(full = full, major = major, minor = minor, patch = patch, rc = rc)
}
