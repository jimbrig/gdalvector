#  ------------------------------------------------------------------------
#
# Title : Internal Data
#    By : Jimmy Briggs
#  Date : 2026-05-28
#
#  ------------------------------------------------------------------------

source("data-raw/scripts/tiger_state_county_bboxes.R")
source("data-raw/scripts/gdal_drivers_metadata.R")
source("data-raw/scripts/gdal_known_config_options.R")

usethis::use_data(
  tiger_state_county_bboxes,
  gdal_vector_driver_docs_urls,
  gdal_vector_driver_config_opts_tbl,
  gdal_known_config_opts_tbl,
  internal = TRUE,
  overwrite = TRUE
)
