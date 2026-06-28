# metadata accessors -----------------------------------------------------------------------------------------------

test_that("open opts _values returns a named list with booleans expanded", {
  vals <- gdal_vector_driver_open_opts_values("GPKG")
  expect_type(vals, "list")
  expect_true("LIST_ALL_TABLES" %in% names(vals))
  expect_setequal(vals[["NOLOCK"]], c("YES", "NO"))
  # free-string options (no allowed set) are absent
  expect_false("PRELUDE_STATEMENTS" %in% names(vals))
})

test_that("_values with an opt_name returns a single allowed-value vector", {
  expect_setequal(
    gdal_vector_driver_open_opts_values("GPKG", "LIST_ALL_TABLES"),
    c("AUTO", "YES", "NO")
  )
})

test_that("_defaults returns a named character vector", {
  defs <- gdal_vector_driver_open_opts_defaults("GPKG")
  expect_type(defs, "character")
  expect_identical(defs[["LIST_ALL_TABLES"]], "AUTO")
})

test_that("config opts accessors no longer error on the NULL opt_name path (bug fix)", {
  expect_no_error(gdal_vector_driver_config_opts_values("GPKG"))
  expect_no_error(gdal_vector_driver_config_opts_defaults("GPKG"))
  vals <- gdal_vector_driver_config_opts_values("GPKG")
  expect_true("SQLITE_USE_OGR_VFS" %in% names(vals))
})

test_that("_types accessors expose the data_type per option", {
  types <- gdal_vector_driver_open_opts_types("GPKG")
  expect_type(types, "character")
  expect_identical(unname(types[["LIST_ALL_TABLES"]]), "string-select")
})

test_that("renamed _defaults accessor exists (typo fixed)", {
  expect_true(is.function(gdal_vector_driver_opt_defaults))
})
