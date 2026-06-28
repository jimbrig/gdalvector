#  ------------------------------------------------------------------------
#
# Title : GDAL Sitrep
#    By : Jimmy Briggs
#  Date : 2026-06-11
#
#  ------------------------------------------------------------------------

# relevant functions:
# -------------------------------------------------------------------------
# gdalraster --------------------------------------------------------------
# gdalraster::lib_versions()
# gdalraster::gdal_version()
# gdalraster::gdal_version_num()
# gdalraster::gdal_compute_version()
# gdalraster::proj_version()
# gdalraster::proj_networking()
# gdalraster::proj_search_paths()
# gdalraster::geos_version()
# gdalraster::has_geos()
# gdalraster::has_spatialite()
# gdalraster::http_enabled()
# gdalraster::gdal_global_reg_names()
# gdalraster::gdal_commands()
# gdalraster::gdal_usage()
# gdalraster::gdal_formats()
# gdalraster::identifyDriver()
# gdalraster::gdal_get_driver_md()
# gdalraster::inspectDataset()
# gdalraster::get_config_option()
# gdalraster::get_cache_max()
# gdalraster::get_cache_used()
# gdalraster::get_num_cpus()
# gdalraster::get_usable_physical_ram()
# gdalraster::getCreationOptions()
# gdalraster::push_error_handler()
# gdalraster::pop_error_handler()
# gdalraster::srs_info_from_db()
# gdalraster::vsi_clear_path_options()
# gdalraster::vsi_constants
# gdalraster::vsi_curl_clear_cache()
# gdalraster::vsi_get_fs_options()
# gdalraster::vsi_set_path_option()
# gdalraster::vsi_supports_rnd_write()
# gdalraster::vsi_supports_seq_write()
# sf ---------------------------------------------------------------------
# sf:::db_drivers
# sf:::extension_map
# sf:::prefix_map
# sf::sf_extSoftVersion()
# sf::gdal_compressors()
# sf::gdal_utils()
# sf::is_driver_available()
# sf::is_driver_can()
# sf::rawToHex
# sf::sf_proj_info()
# sf::st_drivers()
# sf::proj_tools()
# sf::s2()
# sf::sf_use_s2()
# sf::proj_info()
# sf::sf_proj_search_paths()
# terra -----------------------------------------------------------------
# terra::libVersion()
# vapour ----------------------------------------------------------------
# vapour::vapour_gdal_version()
# vapour::vapour_proj_version()
# geos ------------------------------------------------------------------
# geos::geos_version()

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

gdal_sitrep_version_check <- function(major = 13L, minor = 11L, patch = 0L) {
  gdalraster::gdal_version_num() >= gdalraster::gdal_compute_version(major, minor, patch)
}

gdal_sitrep_alg_check <- function() {
  if (identical(gdal_alg_names(), character(0))) {
    FALSE
  }
  TRUE
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

proj_version <- function(backend = c("gdalraster", "sf", "terra", "proj")) {
  backend <- rlang::arg_match(backend)
  switch(
    backend,
    "gdalraster" = proj_version_gdalraster(),
    "sf" = proj_version_sf(),
    "terra" = proj_version_terra(),
    "proj" = proj_version_proj()
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
  match <- regexpr("[0-9]+\\.[0-9]+\\.[0-9]+(rc[0-9]+)?", version_str)
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
