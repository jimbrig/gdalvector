#  ------------------------------------------------------------------------
#
# Title : OpenFileGDB Options
#    By : Jimmy Briggs
#  Date : 2026-06-29
#
#  ------------------------------------------------------------------------

# config ----------------------------------------------------------------------------------------------------------

test_that("gdb_config_opts coerces typed args and validates against curated config metadata", {
  cfg <- gdb_config_opts(default_string_width = 1024L, in_memory_spi = TRUE)
  expect_gdal_opts(cfg, "gdal_config_opts", driver = "OpenFileGDB")
  expect_opt_value(cfg, "OPENFILEGDB_DEFAULT_STRING_WIDTH", "1024")
  expect_opt_value(cfg, "OPENFILEGDB_IN_MEMORY_SPI", "YES")
})

test_that("gdb_config_opts coerces booleans supplied through ...", {
  cfg <- gdb_config_opts(OPENFILEGDB_IN_MEMORY_SPI = TRUE)
  expect_opt_value(cfg, "OPENFILEGDB_IN_MEMORY_SPI", "YES")
})

# open ------------------------------------------------------------------------------------------------------------

test_that("gdb_open_opts coerces list_all_tables and tags the driver", {
  oo <- gdb_open_opts(list_all_tables = TRUE)
  expect_gdal_opts(oo, "gdal_open_opts", driver = "OpenFileGDB")
  expect_opt_value(oo, "LIST_ALL_TABLES", "YES")
})

# creation --------------------------------------------------------------------------------------------------------

test_that("gdb_creation_opts maps typed args and accepts advanced opts via ...", {
  co <- gdb_creation_opts(geometry_name = "SHAPE", target_arcgis_version = "ALL", XYTOLERANCE = 0.001)
  expect_gdal_opts(co, "gdal_creation_opts", driver = "OpenFileGDB", level = "layer")
  expect_opt_value(co, "GEOMETRY_NAME", "SHAPE")
  expect_opt_value(co, "TARGET_ARCGIS_VERSION", "ALL")
  # advanced coordinate-grid options pass through `...` (numeric coercion, no scientific notation)
  expect_opt_value(co, "XYTOLERANCE", "0.001")
})

test_that("gdb_creation_opts coerces the boolean layer options", {
  co <- gdb_creation_opts(geometry_nullable = FALSE, create_multipatch = TRUE, time_in_utc = TRUE)
  expect_opt_value(co, "GEOMETRY_NULLABLE", "NO")
  expect_opt_value(co, "CREATE_MULTIPATCH", "YES")
  expect_opt_value(co, "TIME_IN_UTC", "YES")
})
