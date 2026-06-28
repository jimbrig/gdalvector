# as_gdal_args -----------------------------------------------------------------------------------------------------

test_that("as_gdal_args emits repeated-flag CLI tokens (never packed)", {
  oo <- gdal_open_opts(LIST_ALL_TABLES = "NO", NOLOCK = "YES", driver = "GPKG")
  expect_identical(
    as_gdal_args(oo),
    c("--oo", "LIST_ALL_TABLES=NO", "--oo", "NOLOCK=YES")
  )
  expect_identical(
    as_gdal_args(oo, long = TRUE),
    c("--open-option", "LIST_ALL_TABLES=NO", "--open-option", "NOLOCK=YES")
  )
})

test_that("as_gdal_args(cli = FALSE) yields a bare unnamed KEY=VALUE vector", {
  oo <- gdal_open_opts(LIST_ALL_TABLES = "NO", NOLOCK = "YES", driver = "GPKG")
  out <- as_gdal_args(oo, cli = FALSE)
  expect_identical(out, c("LIST_ALL_TABLES=NO", "NOLOCK=YES"))
  expect_null(names(out))
})

test_that("with_format prepends the input/output format flag and driver", {
  oo <- gdal_open_opts(LIST_ALL_TABLES = "NO", driver = "GPKG")
  expect_identical(
    as_gdal_args(oo, with_format = TRUE),
    c("--input-format", "GPKG", "--oo", "LIST_ALL_TABLES=NO")
  )
  co <- gdal_creation_opts(COMPRESSION = "ZSTD", driver = "Parquet")
  expect_identical(
    as_gdal_args(co, with_format = TRUE),
    c("--output-format", "Parquet", "--lco", "COMPRESSION=ZSTD")
  )
})

test_that("creation level selects the right flag", {
  expect_identical(gdal_opts_cli_flag(gdal_creation_opts(A = "1", level = "layer")), "--lco")
  expect_identical(gdal_opts_cli_flag(gdal_creation_opts(A = "1", level = "dataset")), "--co")
})

test_that("empty opts produce empty args", {
  expect_identical(as_gdal_args(gdal_open_opts()), character())
})

# as_config_option -------------------------------------------------------------------------------------------------

test_that("as_config_option returns a NAME=VALUE named vector for set_config_option", {
  cfg <- gdal_config_opts(CPL_DEBUG = "ON", GDAL_NUM_THREADS = "ALL_CPUS")
  expect_identical(
    as_config_option(cfg),
    c(CPL_DEBUG = "ON", GDAL_NUM_THREADS = "ALL_CPUS")
  )
  # config also renders to --config CLI tokens
  expect_identical(
    as_gdal_args(cfg),
    c("--config", "CPL_DEBUG=ON", "--config", "GDAL_NUM_THREADS=ALL_CPUS")
  )
})

test_that("config round-trips through set_config_option / get_config_option", {
  skip_if_not_installed("gdalraster")
  old <- gdalraster::get_config_option("CPL_DEBUG")
  withr::defer(gdalraster::set_config_option("CPL_DEBUG", old))
  cfg <- gdal_config_opts(CPL_DEBUG = "OFF")
  vec <- as_config_option(cfg)
  gdalraster::set_config_option(names(vec)[[1]], vec[[1]])
  expect_identical(gdalraster::get_config_option("CPL_DEBUG"), "OFF")
})

# gdal_render ------------------------------------------------------------------------------------------------------

test_that("gdal_render produces shell-specific snippets", {
  co <- gdal_creation_opts(COMPRESSION = "ZSTD", driver = "Parquet")
  bash <- gdal_render(co, shell = "bash")
  expect_match(bash, "--output-format 'Parquet'", fixed = TRUE)
  expect_match(bash, "\\\\\n", fixed = FALSE)
  pwsh <- gdal_render(co, shell = "pwsh")
  expect_match(pwsh, "`\n", fixed = TRUE)
  expect_identical(gdal_render(gdal_open_opts()), "")
})
