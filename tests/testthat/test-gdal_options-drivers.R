# per-driver builders ----------------------------------------------------------------------------------------------

test_that("fgb builders produce the right class/driver/level", {
  oo <- fgb_open_opts(verify_buffers = FALSE)
  expect_s3_class(oo, "gdal_open_opts")
  expect_identical(attr(oo, "driver"), "FlatGeobuf")
  expect_identical(unclass(oo)[["VERIFY_BUFFERS"]], "NO")

  co <- fgb_creation_opts(spatial_index = TRUE, title = "Parcels")
  expect_identical(attr(co, "level"), "layer")
  expect_identical(unclass(co)[["SPATIAL_INDEX"]], "YES")
})

test_that("fgb_config_opts warns (no config options) and returns empty", {
  expect_warning(co <- fgb_config_opts(), class = "gdal_opts_empty_warning")
  expect_length(unclass(co), 0L)
  expect_true(is_gdal_config_opts(co))
})

test_that("gdb builders coerce types and accept advanced opts via ...", {
  cfg <- gdb_config_opts(default_string_width = 1024L, in_memory_spi = TRUE)
  expect_identical(unclass(cfg)[["OPENFILEGDB_DEFAULT_STRING_WIDTH"]], "1024")
  expect_identical(unclass(cfg)[["OPENFILEGDB_IN_MEMORY_SPI"]], "YES")

  co <- gdb_creation_opts(geometry_name = "SHAPE", XYTOLERANCE = 0.001)
  expect_identical(unclass(co)[["GEOMETRY_NAME"]], "SHAPE")
  expect_identical(unclass(co)[["XYTOLERANCE"]], "0.001")
})

test_that("boolean options passed via ... are coerced before validation", {
  # dataset-level boolean creation option supplied through `...`
  ds <- gpkg_creation_opts(ADD_GPKG_OGR_CONTENTS = TRUE, level = "dataset")
  expect_identical(unclass(ds)[["ADD_GPKG_OGR_CONTENTS"]], "YES")
  # boolean config option supplied through `...`
  cfg <- gdb_config_opts(OPENFILEGDB_IN_MEMORY_SPI = TRUE)
  expect_identical(unclass(cfg)[["OPENFILEGDB_IN_MEMORY_SPI"]], "YES")
})

test_that("gpkg dataset vs layer creation level is honored", {
  ds <- gpkg_creation_opts(VERSION = "1.4", level = "dataset")
  expect_identical(attr(ds, "level"), "dataset")
  lyr <- gpkg_creation_opts(spatial_index = TRUE)
  expect_identical(attr(lyr, "level"), "layer")
  expect_identical(unclass(lyr)[["SPATIAL_INDEX"]], "YES")
})

test_that("gpq builders validate enumerated values and coerce numerics", {
  co <- gpq_creation_opts(compression = "ZSTD", row_group_size = 100000, sort_by_bbox = TRUE)
  expect_identical(unclass(co)[["ROW_GROUP_SIZE"]], "100000")
  expect_identical(unclass(co)[["SORT_BY_BBOX"]], "YES")
  expect_error(gpq_creation_opts(geometry_encoding = "NOPE"), class = "gdal_check_error")
})

test_that("shp builders map two_gb_limit to 2GB_LIMIT and validate dates", {
  co <- shp_creation_opts(spatial_index = TRUE, two_gb_limit = FALSE)
  expect_identical(unclass(co)[["2GB_LIMIT"]], "NO")
  expect_error(shp_open_opts(dbf_date_last_update = "not-a-date"), class = "gdal_check_error")
})

test_that(".set_defaults fills documented metadata defaults", {
  co <- fgb_open_opts(.set_defaults = TRUE)
  expect_identical(unclass(co)[["VERIFY_BUFFERS"]], "YES")
})

# PRELUDE_STATEMENTS nuance -----------------------------------------------------------------------------------------

test_that("gpkg_prelude_pragmas builds a single semicolon-joined string", {
  s <- gpkg_prelude_pragmas(cache_size = -4000000, temp_store = "MEMORY", mmap_size = 8589934592, journal_mode = "WAL")
  expect_identical(
    s,
    "PRAGMA cache_size=-4000000;PRAGMA temp_store=MEMORY;PRAGMA mmap_size=8589934592;PRAGMA journal_mode=WAL;"
  )
})

test_that("PRELUDE_STATEMENTS is carried as ONE option value and ONE --oo token", {
  prelude <- gpkg_prelude_pragmas(cache_size = -4000000, temp_store = "MEMORY")
  oo <- gpkg_open_opts(list_all_tables = FALSE, prelude_statements = prelude)
  expect_length(unclass(oo), 2L)
  expect_identical(unclass(oo)[["PRELUDE_STATEMENTS"]], prelude)

  tokens <- as_gdal_args(oo)
  # exactly two --oo flags, and the prelude value (with its ';') survives as one token
  expect_identical(sum(tokens == "--oo"), 2L)
  expect_true(any(tokens == paste0("PRELUDE_STATEMENTS=", prelude)))
})

# live integration --------------------------------------------------------------------------------------------------

test_that("gpkg open opts feed a real gdal_alg run without GDAL option warnings", {
  gpkg <- local_tmp_gpkg()
  oo <- gpkg_open_opts(
    list_all_tables = FALSE,
    prelude_statements = gpkg_prelude_pragmas(cache_size = -200000, temp_store = "MEMORY")
  )
  args <- c("--input", gpkg, as_gdal_args(oo, with_format = TRUE), "--format", "json")

  warns <- character()
  out <- withCallingHandlers(
    gdalraster::gdal_run("vector info", args)$output(),
    warning = function(w) {
      warns <<- c(warns, conditionMessage(w))
      invokeRestart("muffleWarning")
    }
  )
  parsed <- yyjsonr::read_json_str(out)
  expect_true(!is.null(parsed$layers))
  expect_length(grep("unexpected value|does not support open option", warns), 0L)
})
