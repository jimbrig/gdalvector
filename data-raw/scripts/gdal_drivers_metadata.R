#  ------------------------------------------------------------------------
#
# Title : GDAL Vector Drivers Metadata
#    By : Jimmy Briggs
#  Date : 2026-06-10
#
#  ------------------------------------------------------------------------

pkgload::load_all(this.path::this.proj())

gdal_vector_driver_docs_urls <- local({
  gdal_vector_drivers_index_url <- "https://gdal.org/en/stable/drivers/vector/index.html"
  gdal_vector_drivers_index_tbl <- rvest::html_table(rvest::read_html(gdal_vector_drivers_index_url))[[1]] |>
    tibble::as_tibble() |>
    janitor::clean_names()
  rvest::read_html(gdal_vector_drivers_index_url) |>
    rvest::html_elements("table.docutils a.reference.internal") |>
    rvest::html_attr("href") |>
    purrr::map_chr(~ paste0("https://gdal.org/en/stable/drivers/vector/", .x)) |>
    stats::setNames(gdal_vector_drivers_index_tbl$short_name)
})

gdal_vector_driver_config_opts_tbl <- local({
  purrr::imap_dfr(names(gdal_vector_driver_docs_urls), parse_gdal_driver_config_opts)
})
