#  ------------------------------------------------------------------------
#
# Title : GDAL Drivers/Formats
#    By : Jimmy Briggs
#  Date : 2026-06-05
#
#  ------------------------------------------------------------------------

# relevant gdalraster functions:
# ------------------------------
# gdalraster::identifyDriver()
# gdalraster::gdal_formats()
# gdalraster::ogr_ds_format()
# gdalraster::gdal_get_driver_md()
# gdalraster::getCreationOptions()

# constants -------------------------------------------------------------------------------------------------------

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

gdal_vector_drivers <- function() {
  # TODO
}

# metadata --------------------------------------------------------------------------------------------------------

gdal_vector_driver_get_meta <- function(driver) {
  # check_gdal_driver_name(driver)
  driver_meta_tbl <- tibble::as_tibble(gdalraster::gdal_formats(format = driver))
  driver_md <- gdalraster::gdal_get_driver_md(driver)
  driver_caps_tbl <- driver_md[startsWith(names(driver_md), "DCAP_")] |>
    tibble::enframe(name = "name", value = "value") |>
    tidyr::unnest("value")
  filt_str <- "OPENOPTION|OPEN_OPTION|CREATIONOPTION|CREATION_OPTION|CREATIONFIELD|CREATION_FIELD|CREATIONDATATYPES"
  driver_dmds_tbl <- driver_md[startsWith(names(driver_md), "DMD_")] |>
    tibble::enframe(name = "name", value = "value") |>
    dplyr::filter(!stringr::str_detect(.data$name, .env$filt_str)) |>
    tidyr::unnest("value")
  # TODO - figure out what exactly is "metadata" here?
  list(
    short_name = driver_meta_tbl$short_name,
    long_name = driver_meta_tbl$long_name,
    aliases = c(driver_meta_tbl$short_name, driver_meta_tbl$long_name),
    is_vector = driver_meta_tbl$vector,
    is_raster = driver_meta_tbl$raster,
    extensions = driver_meta_tbl$extensions |> stringr::str_split(" ") |> purrr::pluck(1L) |> stringr::str_trim(),
    sql_dialects = driver_meta_tbl$sql_dialects |> stringr::str_split(" ") |> purrr::pluck(1L) |> stringr::str_trim(),
    supports_vsi = driver_meta_tbl$virtual_io,
    capabilities = driver_caps_tbl,
    dataset_metadata = driver_dmds_tbl
  )
}


# opts ------------------------------------------------------------------------------------------------------------

gdal_vector_driver_get_opts <- function(driver) {
  # check_gdal_driver_name(driver)
  config_opts_tbl <- gdal_vector_driver_get_config_opts(driver)
  open_opts_tbl <- gdal_vector_driver_get_open_opts(driver)
  creation_opts_tbl <- gdal_vector_driver_get_creation_opts(driver)
  dplyr::bind_rows(config_opts_tbl, open_opts_tbl, creation_opts_tbl)
}

# config opts -----------------------------------------------------------------------------------------------------

gdal_vector_driver_get_config_opts <- function(driver) {
  # check_gdal_driver_name(driver)
  gdal_vector_driver_config_opts_tbl |> dplyr::filter(.data$driver == .env$driver)
}

gdal_vector_driver_get_config_opts_defaults <- function(driver, opt_name = NULL) {
  # check_gdal_driver_name(driver)
  hold <- gdal_vector_driver_get_config_opts(driver = driver)
  if (is.null(opt_name)) {
    return(
      hold |> dplyr::select("name", "default") |> dplyr::filter(!is.na(.data$default)) |> tibble::deframe()
    )
  }
  opt_name <- rlang::arg_match(opt_name, hold$name)
  hold |> dplyr::filter(.data$name == .env$opt_name) |> dplyr::pull(.data$default)
}

gdal_vector_driver_get_config_opts_values <- function(driver, opt_name = NULL) {
  # check_gdal_driver_name(driver)
  hold <- gdal_vector_driver_get_config_opts(driver = driver)
  if (is.null(opt_name)) {
    return(
      hold |> dplyr::select("name", "values") |> dplyr::filter(!is.na(.data$values)) |> tibble::deframe()
    )
  }
  opt_name <- rlang::arg_match(opt_name, hold$name)
  hold |> dplyr::filter(.data$name == .env$opt_name) |> dplyr::pull(.data$values) |> purrr::pluck(1L)
}

# open opts -------------------------------------------------------------------------------------------------------

gdal_vector_driver_get_open_opts <- function(driver) {
  # check_gdal_driver_name(driver)
  rlang::try_fetch(
    {
      .pkg_env$gdal$vector_drivers_open_opts_tbl |> dplyr::filter(.data$driver == .env$driver)
    },
    error = function(err) {
      open_opts_xml <- gdalraster::gdal_get_driver_md(driver, mdi_name = "DMD_OPENOPTIONLIST")
      xml_parse_gdal_options(open_opts_xml, scope = "vector", driver = driver, opt_type = "open")
    }
  )
}

gdal_vector_driver_get_open_opts_defaults <- function(driver, opt_name = NULL) {
  # check_gdal_driver_name(driver)
  hold <- gdal_vector_driver_get_open_opts(driver = driver)
  if (is.null(opt_name)) {
    return(
      hold |> dplyr::select("name", "default") |> dplyr::filter(!is.na(.data$default)) |> tibble::deframe()
    )
  }
  opt_name <- rlang::arg_match(opt_name, hold$name)
  hold |> dplyr::filter(.data$name == .env$opt_name) |> dplyr::pull(.data$default)
}

gdal_vector_driver_get_open_opts_values <- function(driver, opt_name = NULL) {
  # check_gdal_driver_name(driver)
  hold <- gdal_vector_driver_get_open_opts(driver = driver)
  if (is.null(opt_name)) {
    return(
      hold |> dplyr::select("name", "values") |> dplyr::filter(!is.na(.data$values)) |> tibble::deframe()
    )
  }
  opt_name <- rlang::arg_match(opt_name, hold$name)
  hold |> dplyr::filter(.data$name == .env$opt_name) |> dplyr::pull(.data$values) |> purrr::pluck(1L)
}

# creation opts ---------------------------------------------------------------------------------------------------

gdal_vector_driver_get_creation_opts <- function(driver) {
  # check_gdal_driver_name(driver)
  rlang::try_fetch(
    {
      .pkg_env$gdal$vector_drivers_creation_opts_tbl |> dplyr::filter(.data$driver == .env$driver)
    },
    error = function(err) {
      dplyr::bind_rows(
        gdal_vector_driver_get_layer_creation_opts(driver = driver),
        gdal_vector_driver_get_dataset_creation_opts(driver = driver)
      )
    }
  )
}

gdal_vector_driver_get_layer_creation_opts <- function(driver) {
  # check_gdal_driver_name(driver)
  gdalraster::gdal_get_driver_md(driver, mdi_name = "DS_LAYER_CREATIONOPTIONLIST") |>
    xml_parse_gdal_options(scope = "vector", driver = driver, opt_type = "layer")
}

gdal_vector_driver_get_dataset_creation_opts <- function(driver) {
  # check_gdal_driver_name(driver)
  gdalraster::gdal_get_driver_md(driver, mdi_name = "DMD_CREATIONOPTIONLIST") |>
    xml_parse_gdal_options(scope = "vector", driver = driver, opt_type = "dataset")
}

gdal_vector_driver_get_creation_opts_defaults <- function(driver, opt_name = NULL) {
  # check_gdal_driver_name(driver)
  hold <- gdal_vector_driver_get_creation_opts(driver = driver)
  if (is.null(opt_name)) {
    return(
      hold |> dplyr::select("name", "default") |> dplyr::filter(!is.na(.data$default)) |> tibble::deframe()
    )
  }
  opt_name <- rlang::arg_match(opt_name, hold$name)
  hold |> dplyr::filter(.data$name == .env$opt_name) |> dplyr::pull(.data$default)
}

gdal_vector_driver_get_creation_opts_values <- function(driver, opt_name = NULL) {
  # check_gdal_driver_name(driver)
  hold <- gdal_vector_driver_get_creation_opts(driver = driver)
  if (is.null(opt_name)) {
    return(
      hold |> dplyr::select("name", "values") |> dplyr::filter(!is.na(.data$values)) |> tibble::deframe()
    )
  }
  opt_name <- rlang::arg_match(opt_name, hold$name)
  hold |> dplyr::filter(.data$name == .env$opt_name) |> dplyr::pull(.data$values) |> purrr::pluck(1L)
}


# initialization --------------------------------------------------------------------------------------------------

gdal_vector_drivers_init <- function() {
  if (!exists(".pkg_env")) {
    return()
  }
  # vector drivers
  .pkg_env$gdal$vector_drivers <- GDAL_VECTOR_DRIVERS
  # config_opts_tbl
  config_opts_tbl <- gdal_vector_driver_config_opts_tbl
  # open_opts_tbl
  open_opts_tbl <- purrr::map_dfr(GDAL_VECTOR_DRIVERS, function(drv) {
    gdalraster::gdal_get_driver_md(format = drv, mdi_name = "DMD_OPENOPTIONLIST") |>
      xml_parse_gdal_options(scope = "vector", driver = drv, opt_type = "open")
  })
  # creation_opts_tbl
  creation_opts_tbl <- purrr::map_dfr(GDAL_VECTOR_DRIVERS, function(drv) {
    dplyr::bind_rows(
      gdalraster::gdal_get_driver_md(format = drv, mdi_name = "DMD_CREATIONOPTIONLIST") |>
        xml_parse_gdal_options(scope = "vector", driver = drv, opt_type = "dataset"),
      gdalraster::gdal_get_driver_md(format = drv, mdi_name = "DS_LAYER_CREATIONOPTIONLIST") |>
        xml_parse_gdal_options(scope = "vector", driver = drv, opt_type = "layer")
    )
  })
  # merged opts
  opts_tbl <- dplyr::bind_rows(config_opts_tbl, open_opts_tbl, creation_opts_tbl)
  # store in pkg env
  .pkg_env$gdal$vector_drivers_config_opts_tbl <- config_opts_tbl
  .pkg_env$gdal$vector_drivers_open_opts_tbl <- open_opts_tbl
  .pkg_env$gdal$vector_drivers_creation_opts_tbl <- creation_opts_tbl
  .pkg_env$gdal$vector_drivers_opts_tbl <- opts_tbl
}

# internal --------------------------------------------------------------------------------------------------------
