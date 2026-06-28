test_that("gdal_vsi_opts carries a vsi_path attribute and is config-like", {
  vsi <- gdal_vsi_opts(AWS_REGION = "us-east-1", AWS_S3_ENDPOINT = "s3.amazonaws.com", vsi_path = "/vsis3/bucket")
  expect_s3_class(vsi, c("gdal_vsi_opts", "gdal_opts", "list"), exact = TRUE)
  expect_identical(attr(vsi, "vsi_path"), "/vsis3/bucket")
  expect_true(is_gdal_vsi_opts(vsi))
})

test_that("vsi opts render as --config tokens and a config-option vector", {
  vsi <- gdal_vsi_opts(AWS_REGION = "us-east-1")
  expect_identical(as_gdal_args(vsi), c("--config", "AWS_REGION=us-east-1"))
  expect_identical(as_config_option(vsi), c(AWS_REGION = "us-east-1"))
})

test_that("coercion to vsi opts errors on unsupported input", {
  expect_error(as_gdal_vsi_opts(42), class = "gdal_opts_coerce_error")
})
