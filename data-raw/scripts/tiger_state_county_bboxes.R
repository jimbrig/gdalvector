#  ------------------------------------------------------------------------
#
# Title : TIGER State & County bboxes
#    By : Jimmy Briggs
#  Date : 2026-04-25
#
#  ------------------------------------------------------------------------

tiger_state_county_bboxes <- local({
  non_conus_state_fips <- c("02", "15", "60", "66", "69", "72", "74", "78")
  non_conus_state_sql <- glue::glue(
    "STATEFP NOT IN ({paste(paste0(\"'\", non_conus_state_fips, \"'\"), collapse = \",\")})"
  )

  # state bbox/extent -----------------------------------------------------------------------------------------------

  tiger_states_url <- "https://www2.census.gov/geo/tiger/TIGER2025/STATE/tl_2025_us_state.zip"
  tiger_states_dsn <- gdalraster::vsi_glob(paste0(
    "/vsizip",
    gdalraster::vsi_uri_to_vsi_path(tiger_states_url),
    "/*.shp"
  ))
  tiger_states_layer <- gdalraster::ogr_ds_layer_names(tiger_states_dsn)[[1L]]

  tiger_states_vec <- gdalraster::GDALVector$new(dsn = tiger_states_dsn, layer = tiger_states_layer)
  tiger_states_vec$resetReading()
  tiger_states_vec_caps <- tiger_states_vec$testCapability()
  tiger_states_vec$setSelectedFields("")
  tiger_states_vec$setSelectedFields(c("STATEFP", "STUSPS", "NAME", "OGR_GEOMETRY"))
  tiger_states_vec$setAttributeFilter("")
  tiger_states_vec$setAttributeFilter(non_conus_state_sql)
  tiger_states_vec$returnGeomAs <- "BBOX"
  tiger_states_vec$defaultGeomColName <- "bbox"
  tiger_states_vec_crs <- tiger_states_vec$getSpatialRef() |> sf::st_crs()
  tiger_states_vec_crs_epsg <- paste0("EPSG:", tiger_states_vec_crs$epsg)
  tiger_states_vec_src <- tiger_states_vec$getName()

  tiger_states_bboxes_fetched <- tiger_states_vec$fetch(-1)
  tiger_states_vec$close()

  tiger_states_bboxes <- tiger_states_bboxes_fetched |>
    tibble::as_tibble() |>
    dplyr::transmute(
      geoid = .data$STATEFP,
      state_fips = .data$STATEFP,
      state_abbr = .data$STUSPS,
      state_name = .data$NAME,
      county_fips = NA_character_,
      county_name = NA_character_,
      bbox_vals = purrr::map(.data$bbox, stats::setNames, c("xmin", "ymin", "xmax", "ymax")),
      bbox = purrr::map(.data$bbox_vals, sf::st_bbox, crs = tiger_states_vec_crs),
      bbox_xmin = purrr::map_dbl(.data$bbox, purrr::pluck, 1L),
      bbox_ymin = purrr::map_dbl(.data$bbox, purrr::pluck, 2L),
      bbox_xmax = purrr::map_dbl(.data$bbox, purrr::pluck, 3L),
      bbox_ymax = purrr::map_dbl(.data$bbox, purrr::pluck, 4L),
      bbox_wkt = purrr::map_chr(.data$bbox, gdalraster::bbox_to_wkt),
      bbox_crs = .env$tiger_states_vec_crs_epsg,
      source = .env$tiger_states_vec_src
    ) |>
    dplyr::select(-bbox_vals) |>
    dplyr::arrange(.data$geoid)

  # counties --------------------------------------------------------------------------------------------------------

  tiger_counties_url <- "https://www2.census.gov/geo/tiger/TIGER2025/COUNTY/tl_2025_us_county.zip"
  tiger_counties_dsn <- gdalraster::vsi_glob(paste0(
    "/vsizip",
    gdalraster::vsi_uri_to_vsi_path(tiger_counties_url),
    "/*.shp"
  ))
  tiger_counties_layer <- gdalraster::ogr_ds_layer_names(tiger_counties_dsn)[[1L]]

  tiger_counties_vec <- gdalraster::GDALVector$new(dsn = tiger_counties_dsn, layer = tiger_counties_layer)

  tiger_counties_vec$resetReading()
  tiger_counties_vec_caps <- tiger_counties_vec$testCapability()
  tiger_counties_vec$setSelectedFields("")
  tiger_counties_vec$setSelectedFields(c("GEOID", "STATEFP", "COUNTYFP", "NAME", "OGR_GEOMETRY"))
  tiger_counties_vec$setAttributeFilter("")
  tiger_counties_vec$setAttributeFilter(non_conus_state_sql)
  tiger_counties_vec$returnGeomAs <- "BBOX"
  tiger_counties_vec$defaultGeomColName <- "bbox"
  tiger_counties_vec_crs <- tiger_counties_vec$getSpatialRef() |> sf::st_crs()
  tiger_counties_vec_crs_epsg <- paste0("EPSG:", tiger_counties_vec_crs$epsg)
  tiger_counties_vec_src <- tiger_counties_vec$getName()

  tiger_counties_bboxes_fetched <- tiger_counties_vec$fetch(-1)
  tiger_counties_vec$close()

  tiger_counties_bboxes <- tiger_counties_bboxes_fetched |>
    tibble::as_tibble() |>
    dplyr::left_join(
      dplyr::select(tiger_states_bboxes, state_fips, state_name, state_abbr) |>
        dplyr::distinct(),
      by = c("STATEFP" = "state_fips")
    ) |>
    dplyr::transmute(
      geoid = .data$GEOID,
      state_fips = .data$STATEFP,
      state_name = .data$state_name,
      state_abbr = .data$state_abbr,
      county_fips = .data$COUNTYFP,
      county_name = .data$NAME,
      bbox_vals = purrr::map(.data$bbox, stats::setNames, c("xmin", "ymin", "xmax", "ymax")),
      bbox = purrr::map(.data$bbox_vals, sf::st_bbox, crs = tiger_counties_vec_crs),
      bbox_xmin = purrr::map_dbl(.data$bbox, purrr::pluck, 1L),
      bbox_ymin = purrr::map_dbl(.data$bbox, purrr::pluck, 2L),
      bbox_xmax = purrr::map_dbl(.data$bbox, purrr::pluck, 3L),
      bbox_ymax = purrr::map_dbl(.data$bbox, purrr::pluck, 4L),
      bbox_wkt = purrr::map_chr(.data$bbox, gdalraster::bbox_to_wkt),
      bbox_crs = .env$tiger_counties_vec_crs_epsg,
      source = .env$tiger_counties_vec_src
    ) |>
    dplyr::select(-bbox_vals) |>
    dplyr::arrange(.data$geoid)

  # merge -----------------------------------------------------------------------------------------------------------

  dplyr::bind_rows(tiger_states_bboxes, tiger_counties_bboxes) |>
    dplyr::arrange(.data$geoid)
})
