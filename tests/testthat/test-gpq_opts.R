#  ------------------------------------------------------------------------
#
# Title : GeoParquet (Parquet) Options
#    By : Jimmy Briggs
#  Date : 2026-06-29
#
#  ------------------------------------------------------------------------

# open ------------------------------------------------------------------------------------------------------------

test_that("gpq_open_opts carries CRS and coerces lists_as_string_json", {
  oo <- gpq_open_opts(crs = "EPSG:4326", lists_as_string_json = TRUE)
  expect_gdal_opts(oo, "gdal_open_opts", driver = "Parquet")
  expect_opt_value(oo, "CRS", "EPSG:4326")
  expect_opt_value(oo, "LISTS_AS_STRING_JSON", "YES")
})

test_that("gpq_open_opts passes geom_possible_names through verbatim", {
  oo <- gpq_open_opts(geom_possible_names = "geom,geometry,wkb")
  expect_opt_value(oo, "GEOM_POSSIBLE_NAMES", "geom,geometry,wkb")
})

# creation --------------------------------------------------------------------------------------------------------

test_that("gpq_creation_opts coerces numerics/booleans and tags the driver/level", {
  co <- gpq_creation_opts(compression = "ZSTD", row_group_size = 100000, sort_by_bbox = TRUE)
  expect_gdal_opts(co, "gdal_creation_opts", driver = "Parquet", level = "layer")
  expect_opt_value(co, "COMPRESSION", "ZSTD")
  expect_opt_value(co, "ROW_GROUP_SIZE", "100000")
  expect_opt_value(co, "SORT_BY_BBOX", "YES")
})

test_that("gpq_creation_opts validates enumerated values against driver metadata", {
  expect_error(gpq_creation_opts(geometry_encoding = "NOPE"), class = "gdal_check_error")
})

test_that("gpq_creation_opts(builder) is identical to the generic gdal_creation_opts(driver/level)", {
  expect_identical(
    gpq_creation_opts(compression = "ZSTD"),
    gdal_creation_opts(COMPRESSION = "ZSTD", driver = "Parquet", level = "layer")
  )
})

test_that("numeric and string forms of row_group_size resolve to the same payload", {
  expect_identical(
    gpq_creation_opts(row_group_size = 100000),
    gpq_creation_opts(row_group_size = "100000")
  )
})

# workflow --------------------------------------------------------------------------------------------------------

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
