# real-world workflow scenarios mirroring the patterns in dev/ (pipelines, conversions, reads).

test_that("GPKG -> Parquet convert applies the gpq OGC distribution preset as --lco", {
  gpkg <- local_tmp_gpkg()
  out <- withr::local_tempfile(fileext = ".parquet")

  co <- gpq_creation_opts(
    compression = "ZSTD",
    compression_level = 15,
    geometry_encoding = "WKB",
    row_group_size = 1000,
    write_covering_bbox = TRUE,
    sort_by_bbox = TRUE,
    creator = "gdalvector"
  )
  # the layer-creation opts render to repeated --lco tokens in the write
  lco <- as_gdal_args(co)
  expect_true(all(c("--lco", "COMPRESSION=ZSTD", "COMPRESSION_LEVEL=15") %in% lco))

  args <- c("--input", gpkg, "--output", out, "--output-format", "Parquet", lco, "--overwrite")
  alg <- gdalraster::gdal_run("vector convert", args)
  alg$close()

  expect_true(file.exists(out))
  info <- yyjsonr::read_json_str(
    gdalraster::gdal_run("vector info", c("--input", out, "--format", "json"))$output()
  )
  expect_true(!is.null(info$layers))
})

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

test_that("a full workload separates session config from per-step open/creation args", {
  # config options are session/process state (never algorithm args)
  cfg <- gdal_config_opts(GDAL_NUM_THREADS = "ALL_CPUS", OGR_SQLITE_SYNCHRONOUS = "OFF")
  cfg_vec <- as_config_option(cfg)
  expect_identical(cfg_vec, c(GDAL_NUM_THREADS = "ALL_CPUS", OGR_SQLITE_SYNCHRONOUS = "OFF"))

  # open + creation options are per-step algorithm args
  oo <- gpkg_open_opts(
    list_all_tables = FALSE,
    prelude_statements = gpkg_prelude_pragmas(cache_size = -4000000, temp_store = "MEMORY")
  )
  co <- gpq_creation_opts(compression = "ZSTD", geometry_encoding = "WKB")

  read_args <- c("read", "--input", "parcels.gpkg", as_gdal_args(oo, with_format = TRUE))
  write_args <- c("write", "--output", "parcels.parquet", as_gdal_args(co, with_format = TRUE), "--overwrite")

  expect_true(all(c("--input-format", "GPKG") %in% read_args))
  expect_identical(sum(read_args == "--oo"), 2L)
  # the PRELUDE_STATEMENTS PRAGMA payload survives as a single token (semicolons intact)
  expect_true(any(grepl("^PRELUDE_STATEMENTS=PRAGMA cache_size=-4000000;", read_args)))
  expect_true(all(c("--output-format", "Parquet", "--lco") %in% write_args))
})

test_that("config can be applied to the session and restored", {
  skip_if_not_installed("gdalraster")
  cfg <- gdal_config_opts(GDAL_NUM_THREADS = "2")
  vec <- as_config_option(cfg)
  old <- gdalraster::get_config_option(names(vec)[[1]])
  withr::defer(gdalraster::set_config_option(names(vec)[[1]], old))
  gdalraster::set_config_option(names(vec)[[1]], vec[[1]])
  expect_identical(gdalraster::get_config_option("GDAL_NUM_THREADS"), "2")
})
