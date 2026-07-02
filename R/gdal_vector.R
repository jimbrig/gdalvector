#  ------------------------------------------------------------------------
#
# Title : GDAL Vector
#    By : Jimmy Briggs
#  Date : 2026-06-13
#
#  ------------------------------------------------------------------------

# open ------------------------------------------------------------------------------------------------------------

gdal_vector_open <- function(
  dsn,
  layer = "",
  read_only = TRUE,
  open_options = NULL,
  spatial_filter = "",
  dialect = "SQLITE"
) {
  gdalraster::GDALVector$new(
    dsn = dsn,
    layer = layer,
    read_only = read_only,
    open_options = open_options,
    spatial_filter = spatial_filter,
    dialect = dialect
  )
}

# driver ----------------------------------------------------------------------------------------------------------

gdal_vector_driver <- function(dsn, ...) {
  gdalraster::ogr_ds_format(dsn)
}

gdal_vector_identify_driver <- function(dsn, vector = TRUE, raster = FALSE, allowed_drivers = NULL, file_list = NULL) {
  gdalraster::identifyDriver(
    filename = dsn,
    raster = raster,
    vector = vector,
    allowed_drivers = allowed_drivers,
    file_list = file_list
  )
}

gdal_vector_driver_format <- function(dsn) {
  gdalraster::ogr_ds_format(dsn)
}

# driver - open opts ----------------------------------------------------------------------------------------------

gdal_vector_default_open_opts <- function(dsn, layer = gdal_vector_layer(dsn)) {
  drv <- gdal_vector_driver_format(dsn)
  gdal_vector_driver_open_opts_defaults(drv)
}

gdal_vector_show_open_opts <- function(dsn, layer = gdal_vector_layer(dsn)) {
  drv <- gdal_vector_driver_format(dsn)
  gdal_vector_driver_open_opts(drv)
}


# layers ----------------------------------------------------------------------------------------------------------

gdal_vector_layer <- function(dsn, index = 1L, filter = NULL) {
  if (gdal_vector_layer_count(dsn) == 0L) {
    return(NULL)
  }
  all_layers <- gdal_vector_layer_names(dsn)
  if (!is.null(filter)) {
    lyr <- all_layers[stringr::str_detect(all_layers, filter)]
    if (length(lyr) == 0L) {
      return(NULL)
    }
    return(lyr)
  }
  all_layers[[index]]
}

gdal_vector_layer_select <- function(
  dsn,
  prompt = "Select Layer(s):",
  type = c("select", "checkbox"),
  selected = NULL,
  return_index = FALSE
) {
  layers <- gdal_vector_layer_names(dsn)
  if (length(layers) <= 1L) {
    cli::cli_alert_warning("Not more than one available layer to choose from.")
    return(layers)
  }
  type <- rlang::arg_match(type)
  climenu::menu(choices = layers, prompt = prompt, type = type, selected = selected, return_index = return_index)
}

gdal_vector_layer_names <- function(dsn) {
  gdalraster::ogr_ds_layer_names(dsn)
}

gdal_vector_layer_count <- function(dsn) {
  gdalraster::ogr_ds_layer_count(dsn)
}


# capabilities ----------------------------------------------------------------------------------------------------

gdal_vector_capabilities <- function(dsn, layer = gdal_vector_layer(dsn), with_update = FALSE) {
  gdalraster::ogr_layer_test_cap(dsn = dsn, layer = layer, with_update = with_update)
}

gdal_vector_check_capability <- function(capability, dsn, layer = gdal_vector_layer(dsn)) {
  caps <- gdal_vector_capabilities(dsn, layer)
  if (!capability %in% names(caps)) {
    gdal_warn_check(
      "Capability provided {.field {capability}} is not a valid vector capability. Valid capabilities are: {.field {names(caps)}}"
    )
    return(FALSE)
  }
  caps[[capability]]
}


# schema & fields -------------------------------------------------------------------------------------------------

gdal_vector_layer_fields <- function(dsn, layer = gdal_vector_layer(dsn), ...) {
  gdalraster::ogr_layer_field_names(dsn = dsn, layer = layer)
}

gdal_vector_layer_definition <- function(dsn, layer = gdal_vector_layer(dsn), ...) {
  vec <- gdal_vector_open(dsn = dsn, layer = layer, ...)
  withr::defer(vec$close())
  vec$getLayerDefn()
}

gdal_vector_schema <- function(dsn, layer = gdal_vector_layer(dsn), driver = gdal_vector_driver_format(dsn), ...) {
  alg <- gdalraster::gdal_run("vector export-schema", list(input = dsn, input_format = driver, input_layer = layer))
  alg$output() |>
    yyjsonr::read_json_str(yyjsonr::opts_read_json(
      obj_of_arrs_to_df = FALSE,
      arr_of_objs_to_df = FALSE,
      arr_of_arrs_to_matrix = FALSE,
      empty_array = "NULL"
    ))
}

# fid & geom cols -------------------------------------------------------------------------------------------------

gdal_vector_layer_geom_col <- function(dsn, layer = gdal_vector_layer(dsn), ...) {
  vec <- gdal_vector_open(dsn = dsn, layer = layer, ...)
  withr::defer(vec$close())
  vec$getGeometryColumn()
}

gdal_vector_layer_geom_col_type <- function(dsn, layer = gdal_vector_layer(dsn), ...) {
  vec <- gdal_vector_open(dsn = dsn, layer = layer, ...)
  withr::defer(vec$close())
  vec$getGeomType()
}

gdal_vector_layer_fid_col <- function(dsn, layer = gdal_vector_layer(dsn), ...) {
  vec <- gdal_vector_open(dsn = dsn, layer = layer, ...)
  withr::defer(vec$close())
  fields <- vec$getFieldNames()
  gdal_fid_col <- vec$getFIDColumn()
  if (!nzchar(gdal_fid_col)) {
    gdal_fid_col <- '""'
  }
  if (!(gdal_fid_col %in% fields)) {
    gdal_inform(
      c(
        "!" = "FID column reported by GDAL ({.field {gdal_fid_col}}) is not an actual field in the layer {.field {layer}}.",
        "i" = "This is common for some drivers (e.g., GeoPackage) where the FID is a virtual column and not stored as a field.",
        "i" = "Consider using {.field 'CAST(rowid AS INTEGER) AS source_fid'} in SQL performed against the layer to get the FID used by GDAL as an attribute field"
      ),
      cls = "gdal_fid_col_inform"
    )
  }
  return(gdal_fid_col)
}

# feature count ---------------------------------------------------------------------------------------------------

gdal_vector_feature_count <- function(dsn, layer = gdal_vector_layer(dsn), ..., force = FALSE) {
  vec <- gdal_vector_open(dsn = dsn, layer = layer, ...)
  withr::defer(vec$close())
  caps <- vec$testCapability()
  has_fast_feature_cap <- caps[["FastFeatureCount"]]
  if (!has_fast_feature_cap && !force) {
    gdal_warn_check(
      "Vector layer does not support fast feature count. Use {.code force = TRUE} to force a slower count."
    )
    return(NULL)
  } else if (!has_fast_feature_cap && force) {
    gdal_warn_check(
      "Vector layer does not support fast feature count. Forcing a slower count due to {.code force = TRUE}."
    )
  }
  vec$getFeatureCount()
}

# extent ----------------------------------------------------------------------------------------------------------

gdal_vector_extent <- function(dsn, layer = gdal_vector_layer(dsn), ..., force = FALSE) {
  vec <- gdal_vector_open(dsn = dsn, layer = layer, ...)
  withr::defer(vec$close())
  caps <- vec$testCapability()
  has_fast_extent_cap <- caps[["FastGetExtent"]]
  if (!has_fast_extent_cap && !force) {
    gdal_warn_check(
      "Vector layer does not support fast extent retrieval. Use {.code force = TRUE} to force a slower retrieval."
    )
    return(NULL)
  } else if (!has_fast_extent_cap && force) {
    gdal_warn_check(
      "Vector layer does not support fast extent retrieval. Forcing a slower retrieval due to {.code force = TRUE}."
    )
  }
  vec$bbox()
}

# crs/srs ---------------------------------------------------------------------------------------------------------

gdal_vector_crs <- function(dsn, layer = gdal_vector_layer(dsn), ...) {
  vec <- gdal_vector_open(dsn = dsn, layer = layer, ...)
  withr::defer(vec$close())
  spatial_ref <- vec$getSpatialRef()
  epsg <- gdalraster::srs_find_epsg(spatial_ref)
  projjson <- gdalraster::srs_to_projjson(spatial_ref)
  wkt <- gdalraster::srs_to_wkt(spatial_ref)
  sf_crs <- sf::st_crs(spatial_ref)
  structure(
    list(
      spatial_ref = spatial_ref,
      epsg = epsg,
      projjson = projjson,
      wkt = wkt,
      sf_crs = sf_crs
    ),
    class = c("gdal_vector_crs", "list")
  )
}
