# supported core drivers ------------------------------------------------------------------------------------------

#' GDAL_VECTOR_DRIVERS
#'
#' @description
#' Internal character vector of the official names for the supported core GDAL/OGR vector drivers.
#'
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

# gdal_vector_driver <- function() {}
# new_gdal_vector_driver <- function() {}
# validate_gdal_vector_driver <- function() {}
# as_gdal_vector_driver <- function() {}
# format.gdal_vector_driver <- function() {}
# print.gdal_vector_driver <- function() {}

# is_gdal_vector_driver <- function() {}
# check_gdal_vector_driver <- function() {}

# gdal_vector_drivers <- function() {}
# gdal_vector_driver_formats <- function() {}
# gdal_vector_driver_info <- function() {}
# gdal_vector_driver_capabilities <- function() {}
# gdal_vector_driver_metadata <- function() {}

gdal_vector_driver_options <- function(driver) {
  dplyr::bind_rows(
    gdal_vector_driver_config_options(driver),
    gdal_vector_driver_open_options(driver),
    gdal_vector_driver_creation_options(driver)
  )
}
gdal_vector_driver_option_defaults <- function() {}
gdal_vector_driver_option_values <- function() {}

gdal_vector_driver_config_options <- function(driver) {
  gdal_vector_driver_config_opts_tbl |> dplyr::filter(.data$driver == .env$driver)
}

gdal_vector_driver_config_option_defaults <- function(driver, option = NULL) {
  hold <- gdal_vector_driver_config_options(driver = driver) |>
    dplyr::select("name", "default") |>
    dplyr::filter(!is.na(.data$default))
  if (is.null(option)) {
    return(tibble::deframe(hold))
  }
  opt_names <- rlang::arg_match(option, hold$name, multiple = TRUE)
  hold |> dplyr::filter(.data$name %in% .env$opt_names) |> tibble::deframe()
}

gdal_vector_driver_config_option_values <- function() {}

gdal_vector_driver_open_options <- function() {}
gdal_vector_driver_open_option_defaults <- function() {}
gdal_vector_driver_open_option_values <- function() {}

gdal_vector_driver_creation_options <- function() {}
gdal_vector_driver_creation_option_defaults <- function() {}
gdal_vector_driver_creation_option_values <- function() {}

gdal_vector_driver_creation_options_dataset <- function() {}
gdal_vector_driver_creation_options_layer <- function() {}


# driver metadata -------------------------------------------------------------------------------------------------

gdal_vector_driver_metadata(driver)
{
  check_gdal_vector_driver_name(driver)

  driver_meta_tbl <- gdalraster::gdal_formats(format = driver) |> tibble::as_tibble()
  driver_meta_md <- gdalraster::gdal_get_driver_md(driver)

  driver_dcap_tbl <- driver_meta_md[startsWith(names(driver_meta_md), "DCAP_")] |>
    tibble::enframe(name = "name", value = "value") |>
    tidyr::unnest("value")

  filt_str <- "OPENOPTION|OPEN_OPTION|CREATIONOPTION|CREATION_OPTION|CREATIONFIELD|CREATION_FIELD|CREATIONDATATYPES"

  driver_dmd_tbl <- driver_meta_md[startsWith(names(driver_meta_md), "DMD_")] |>
    tibble::enframe(name = "name", value = "value") |>
    dplyr::filter(!stringr::str_detect(.data$name, .env$filt_str)) |>
    tidyr::unnest("value")
}


# driver options (merged) -----------------------------------------------------------------------------------------

# driver options (open) -------------------------------------------------------------------------------------------

# driver options (creation) ---------------------------------------------------------------------------------------

# internal drivers initialization ---------------------------------------------------------------------------------

.gdal_vector_drivers_init <- function() {
  if (!exists(".pkg_env")) {
    return()
  }

  # setup main drivers environment store/registry/cache:
  .pkg_env$gdal$drivers <- rlang::new_environment()

  # vector drivers
  # .pkg_env$gdal$drivers
}
