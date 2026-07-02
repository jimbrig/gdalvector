#  ------------------------------------------------------------------------
#
# Title : GDAL Known Configuration Options
#    By : Jimmy Briggs
#  Date : 2026-07-02
#
#  ------------------------------------------------------------------------

# parses GDAL's compile-time known-configuration-option registry from the version-pinned source
# header `port/cpl_known_config_options.h` (generated upstream by GDAL's
# collect_config_options.py). that header is the exact array `CPLGetKnownConfigOptions()`
# (GDAL >= 3.11) returns - gdalraster does not bind that function, so parsing the header yields
# identical data with no compiled code. a copy of the header is also bundled under inst/schemas/
# for transparency (see inst/schemas/schemas.R). build-specific drift from the pinned version is
# covered at runtime by gdal_config_option_known().

gdal_known_config_opts_tbl <- local({
  gdal_version <- "3.13.0"
  url <- sprintf(
    "https://raw.githubusercontent.com/OSGeo/gdal/v%s/port/cpl_known_config_options.h",
    gdal_version
  )

  entries <- readLines(url, warn = FALSE) |>
    stringr::str_match("^\\s*\"([^\"]+)\",\\s*(?://\\s*from\\s+(.*))?$")

  tbl <- tibble::tibble(
    name = entries[, 2],
    source = stringr::str_trim(entries[, 3])
  ) |>
    dplyr::filter(!is.na(.data$name)) |>
    dplyr::distinct(.data$name, .keep_all = TRUE) |>
    dplyr::arrange(.data$name)

  attr(tbl, "gdal_version") <- gdal_version
  cli::cli_alert_success("Parsed {nrow(tbl)} known configuration option{?s} (GDAL {gdal_version})")
  tbl
})
