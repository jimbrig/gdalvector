#  ------------------------------------------------------------------------
#
# Title : GDAL Metadata
#    By : Jimmy Briggs
#  Date : 2026-06-10
#
#  ------------------------------------------------------------------------

# drivers ---------------------------------------------------------------------------------------------------------

gdal_vector_driver_get_metadata <- function(driver_name) {
  check_gdal_driver_name(driver_name)
  driver_format_tbl <- tibble::as_tibble(gdalraster::gdal_formats(format = driver))
  driver_md <- gdalraster::gdal_get_driver_md(driver_name)
  driver_caps_tbl <- driver_md[startsWith(names(driver_md), "DCAP_")] |>
    tibble::enframe(name = "name", value = "value") |>
    tidyr::unnest("value")
  opts_regex <- "OPENOPTION|OPEN_OPTION|CREATIONOPTION|CREATION_OPTION|CREATIONFIELD|CREATION_FIELD|CREATIONDATATYPES"
  driver_dmds_tbl <- driver_md[startsWith(names(driver_md), "DMD_")] |>
    tibble::enframe(name = "name", value = "value") |>
    dplyr::filter(!stringr::str_detect(.data$name, opts_regex)) |>
    tidyr::unnest("value")
  list()
}
