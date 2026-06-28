# condition class hierarchy ---------------------------------------------------------------------------------------

test_that("opts signalers layer a specific subclass over the base hierarchy", {
  err <- rlang::catch_cnd(gdal_abort_opts("nope", cls = "gdal_opts_coerce_error"))
  expect_s3_class(err, c("gdal_opts_coerce_error", "gdal_opts_error", "gdal_error", "gdal_condition"))

  warn <- rlang::catch_cnd(gdal_warn_opts("careful", cls = "gdal_opts_value_warning"))
  expect_s3_class(warn, c("gdal_opts_value_warning", "gdal_opts_warning", "gdal_warning", "gdal_condition"))

  msg <- rlang::catch_cnd(gdal_inform_opts("fyi"))
  expect_s3_class(msg, c("gdal_opts_message", "gdal_message", "gdal_condition"))
})

test_that("gdal_abort_opts without an extra class still carries the opts + base error classes", {
  err <- rlang::catch_cnd(gdal_abort_opts("nope"))
  expect_s3_class(err, c("gdal_opts_error", "gdal_error", "gdal_condition"))
})
