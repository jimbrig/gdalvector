test_that("validate_gdal_opts returns TRUE for valid options", {
  expect_true(validate_gdal_opts(gdal_open_opts(LIST_ALL_TABLES = "NO", driver = "GPKG")))
})

test_that("validate_gdal_opts returns NA (with a warning) when no driver is known", {
  expect_warning(
    res <- validate_gdal_opts(gdal_open_opts(LIST_ALL_TABLES = "NO")),
    class = "gdal_opts_warning"
  )
  expect_true(is.na(res))
})

test_that("validate_gdal_opts warns on unknown option names", {
  expect_warning(
    res <- validate_gdal_opts(gdal_open_opts(NOT_A_REAL_OPTION = "x", driver = "GPKG")),
    class = "gdal_opts_unknown_warning"
  )
  expect_false(res)
})

test_that("validate_gdal_opts warns on invalid enumerated values", {
  expect_warning(
    res <- validate_gdal_opts(gdal_open_opts(LIST_ALL_TABLES = "MAYBE", driver = "GPKG")),
    class = "gdal_opts_value_warning"
  )
  expect_false(res)
})

test_that("free-string options (no enumerated set) are not flagged", {
  oo <- gdal_open_opts(
    LIST_ALL_TABLES = "NO",
    PRELUDE_STATEMENTS = "PRAGMA cache_size=-2000;",
    driver = "GPKG"
  )
  expect_true(validate_gdal_opts(oo))
})
