# construction invariants -----------------------------------------------------------------------------------------

test_that("constructors build named-list payloads with the right class and attributes", {
  oo <- gdal_open_opts(LIST_ALL_TABLES = FALSE, driver = "GPKG")
  expect_s3_class(oo, c("gdal_open_opts", "gdal_opts", "list"), exact = TRUE)
  expect_identical(unclass(oo)[["LIST_ALL_TABLES"]], "NO")
  expect_identical(attr(oo, "driver"), "GPKG")
  expect_true(is_gdal_open_opts(oo))
  expect_true(is_gdal_opts(oo))

  co <- gdal_creation_opts(COMPRESSION = "ZSTD", driver = "Parquet", level = "dataset")
  expect_s3_class(co, "gdal_creation_opts")
  expect_identical(attr(co, "level"), "dataset")

  cfg <- gdal_config_opts(CPL_DEBUG = "ON")
  expect_true(is_gdal_config_opts(cfg))

  vsi <- gdal_vsi_opts(AWS_REGION = "us-east-1", vsi_path = "/vsis3/bucket")
  expect_true(is_gdal_vsi_opts(vsi))
  expect_identical(attr(vsi, "vsi_path"), "/vsis3/bucket")
})

test_that("normalization uppercases names, coerces values, and drops NULL/NA", {
  x <- .gdal_opts_normalize(list(verify_buffers = TRUE, temporary_dir = NULL, title = NA, n = 100000))
  expect_named(x, c("VERIFY_BUFFERS", "N"))
  expect_identical(x[["VERIFY_BUFFERS"]], "YES")
  # numeric values must not become scientific notation
  expect_identical(x[["N"]], "100000")
})

test_that("duplicate names keep the last value", {
  x <- .gdal_opts_normalize(list(A = "1", a = "2"))
  expect_identical(x, list(A = "2"))
})

test_that("empty constructors yield an empty named list payload", {
  oo <- gdal_open_opts()
  expect_length(unclass(oo), 0L)
  expect_identical(as.list(oo), stats::setNames(list(), character()))
})

# coercion ---------------------------------------------------------------------------------------------------------

test_that("as_gdal_*_opts coerces lists, KEY=VALUE characters, and self", {
  from_list <- as_gdal_open_opts(list(LIST_ALL_TABLES = "NO"))
  from_chr <- as_gdal_open_opts("LIST_ALL_TABLES=NO")
  expect_identical(unclass(from_list)[["LIST_ALL_TABLES"]], "NO")
  expect_identical(unclass(from_chr)[["LIST_ALL_TABLES"]], "NO")

  # self-coercion can re-tag the driver
  retagged <- as_gdal_open_opts(from_list, driver = "GPKG")
  expect_identical(attr(retagged, "driver"), "GPKG")
})

test_that("coercion of unsupported input or bad KEY=VALUE errors with a classed condition", {
  expect_error(as_gdal_open_opts(42), class = "gdal_opts_coerce_error")
  expect_error(as_gdal_open_opts("LIST_ALL_TABLES"), class = "gdal_opts_coerce_error")
})

# methods ----------------------------------------------------------------------------------------------------------

test_that("as.character and as.list round-trip the payload", {
  oo <- gdal_open_opts(LIST_ALL_TABLES = "NO", NOLOCK = TRUE, driver = "GPKG")
  expect_identical(as.character(oo), c("LIST_ALL_TABLES=NO", "NOLOCK=YES"))
  expect_identical(as.list(oo), list(LIST_ALL_TABLES = "NO", NOLOCK = "YES"))
})

test_that("c() merges payloads with later values winning", {
  a <- gdal_open_opts(LIST_ALL_TABLES = "NO", driver = "GPKG")
  b <- gdal_open_opts(LIST_ALL_TABLES = "YES", NOLOCK = TRUE, driver = "GPKG")
  merged <- c(a, b)
  expect_identical(unclass(merged)[["LIST_ALL_TABLES"]], "YES")
  expect_named(unclass(merged), c("LIST_ALL_TABLES", "NOLOCK"))
})

test_that("c() warns when combining multiple drivers", {
  a <- gdal_open_opts(LIST_ALL_TABLES = "NO", driver = "GPKG")
  b <- gdal_open_opts(VERIFY_BUFFERS = "NO", driver = "FlatGeobuf")
  expect_warning(c(a, b), class = "gdal_opts_merge_warning")
})

test_that("format()/print() render the expected cli lines", {
  withr::local_options(cli.num_colors = 1, cli.width = 200)
  oo <- gdal_open_opts(LIST_ALL_TABLES = FALSE, driver = "GPKG")
  expect_snapshot(print(oo))
})

# edge cases -------------------------------------------------------------------------------------------------------

test_that("empty opts print, render, and convert without error", {
  withr::local_options(cli.num_colors = 1, cli.width = 200)
  empty <- gdal_open_opts(driver = "GPKG")
  expect_snapshot(print(empty))
  expect_identical(as_gdal_args(empty), character())
  expect_identical(as_gdal_args(empty, cli = FALSE), character())
  expect_identical(gdal_render(empty), "")
})

test_that("c() drops NULL arguments and returns NULL when everything is NULL", {
  a <- gdal_open_opts(LIST_ALL_TABLES = "NO", driver = "GPKG")
  expect_identical(unclass(c(a, NULL))[["LIST_ALL_TABLES"]], "NO")
  expect_null(c(NULL, NULL))
})

test_that("as_gdal_args passes through character vectors and flattens lists", {
  expect_identical(as_gdal_args(c("--oo", "A=1")), c("--oo", "A=1"))
  opts_list <- list(
    gdal_open_opts(LIST_ALL_TABLES = "NO", driver = "GPKG"),
    gdal_creation_opts(COMPRESSION = "ZSTD", driver = "Parquet")
  )
  expect_identical(
    as_gdal_args(opts_list),
    c("--oo", "LIST_ALL_TABLES=NO", "--lco", "COMPRESSION=ZSTD")
  )
})

test_that("as_config_option on empty config opts yields an empty named vector", {
  out <- as_config_option(gdal_config_opts())
  expect_length(out, 0L)
  expect_type(out, "character")
})
