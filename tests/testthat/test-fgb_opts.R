#  ------------------------------------------------------------------------
#
# Title : FlatGeobuf Options
#    By : Jimmy Briggs
#  Date : 2026-06-29
#
#  ------------------------------------------------------------------------

# config ----------------------------------------------------------------------------------------------------------

test_that("fgb_config_opts warns (no config options) and returns an empty config object", {
  expect_warning(co <- fgb_config_opts(), class = "gdal_opts_empty_warning")
  expect_length(unclass(co), 0L)
  expect_gdal_opts(co, "gdal_config_opts", driver = "FlatGeobuf")
})

# open ------------------------------------------------------------------------------------------------------------

test_that("fgb_open_opts coerces verify_buffers and tags the driver", {
  oo <- fgb_open_opts(verify_buffers = FALSE)
  expect_gdal_opts(oo, "gdal_open_opts", driver = "FlatGeobuf")
  expect_opt_value(oo, "VERIFY_BUFFERS", "NO")
})

test_that("fgb_open_opts with no args is an empty open-opts object", {
  oo <- fgb_open_opts()
  expect_gdal_opts(oo, "gdal_open_opts", driver = "FlatGeobuf")
  expect_length(unclass(oo), 0L)
})

test_that("fgb_open_opts(.set_defaults) fills the documented metadata default", {
  oo <- fgb_open_opts(.set_defaults = TRUE)
  expect_opt_value(oo, "VERIFY_BUFFERS", "YES")
  # user-supplied values always take precedence over filled defaults
  oo2 <- fgb_open_opts(verify_buffers = FALSE, .set_defaults = TRUE)
  expect_opt_value(oo2, "VERIFY_BUFFERS", "NO")
})

# creation --------------------------------------------------------------------------------------------------------

test_that("fgb_creation_opts builds a layer-level object and coerces booleans", {
  co <- fgb_creation_opts(spatial_index = TRUE, title = "Parcels", description = "test")
  expect_gdal_opts(co, "gdal_creation_opts", driver = "FlatGeobuf", level = "layer")
  expect_opt_value(co, "SPATIAL_INDEX", "YES")
  expect_opt_value(co, "TITLE", "Parcels")
  expect_opt_value(co, "DESCRIPTION", "test")
})

test_that("fgb builders forward additional options through ...", {
  oo <- fgb_open_opts(verify_buffers = FALSE, SOME_FUTURE_OPT = "x")
  expect_opt_value(oo, "VERIFY_BUFFERS", "NO")
  expect_opt_value(oo, "SOME_FUTURE_OPT", "x")
})
