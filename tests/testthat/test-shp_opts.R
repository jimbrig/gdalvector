
#  ------------------------------------------------------------------------
#
# Title : ESRI Shapefile Options
#    By : Jimmy Briggs
#  Date : 2026-06-29
#
#  ------------------------------------------------------------------------


# config ----------------------------------------------------------------------------------------------------------

test_that("shp_config_opts coerces the SHAPE_* booleans and tags the driver", {
  cfg <- shp_config_opts(shape_restore_shx = TRUE, shape_2gb_limit = FALSE)
  expect_gdal_opts(cfg, "gdal_config_opts", driver = "ESRI Shapefile")
  expect_opt_value(cfg, "SHAPE_RESTORE_SHX", "YES")
  expect_opt_value(cfg, "SHAPE_2GB_LIMIT", "NO")
})

test_that("shp_config_opts passes the encoding override through", {
  cfg <- shp_config_opts(shape_encoding = "ISO-8859-1")
  expect_opt_value(cfg, "SHAPE_ENCODING", "ISO-8859-1")
})

# open ------------------------------------------------------------------------------------------------------------

test_that("shp_open_opts coerces booleans and accepts a valid last-update date", {
  oo <- shp_open_opts(encoding = "UTF-8", auto_repack = TRUE, dbf_date_last_update = "2026-06-29")
  expect_gdal_opts(oo, "gdal_open_opts", driver = "ESRI Shapefile")
  expect_opt_value(oo, "ENCODING", "UTF-8")
  expect_opt_value(oo, "AUTO_REPACK", "YES")
  expect_opt_value(oo, "DBF_DATE_LAST_UPDATE", "2026-06-29")
})

test_that("shp_open_opts rejects a malformed last-update date", {
  expect_error(shp_open_opts(dbf_date_last_update = "not-a-date"), class = "gdal_check_error")
})

# creation --------------------------------------------------------------------------------------------------------

test_that("shp_creation_opts maps two_gb_limit to the 2GB_LIMIT option name", {
  co <- shp_creation_opts(spatial_index = TRUE, two_gb_limit = FALSE)
  expect_gdal_opts(co, "gdal_creation_opts", driver = "ESRI Shapefile", level = "layer")
  expect_opt_value(co, "SPATIAL_INDEX", "YES")
  expect_opt_value(co, "2GB_LIMIT", "NO")
})

test_that("shp_creation_opts validates the last-update date", {
  expect_error(shp_creation_opts(dbf_date_last_update = "2026/06/29"), class = "gdal_check_error")
})

# workflow --------------------------------------------------------------------------------------------------------

test_that("shapefile read with shp open opts feeds vector info without option warnings", {
  skip_if_no_gdalalg()
  shp <- system.file("extdata/poly_multipoly.shp", package = "gdalraster")
  skip_if(!nzchar(shp), "gdalraster extdata shapefile not available")

  oo <- shp_open_opts(encoding = "UTF-8", auto_repack = TRUE, dbf_eof_char = TRUE)
  args <- c("--input", shp, as_gdal_args(oo, with_format = TRUE), "--format", "json")
  # the driver short name with a space stays a single token in-process
  expect_true("ESRI Shapefile" %in% args)

  warns <- character()
  out <- withCallingHandlers(
    gdalraster::gdal_run("vector info", args)$output(),
    warning = function(w) {
      warns <<- c(warns, conditionMessage(w))
      invokeRestart("muffleWarning")
    }
  )
  expect_true(!is.null(yyjsonr::read_json_str(out)$layers))
  expect_length(grep("unexpected value|does not support open option", warns), 0L)
})
