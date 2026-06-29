#  ------------------------------------------------------------------------
#
# Title : GeoPackage (GPKG) Options
#    By : Jimmy Briggs
#  Date : 2026-06-29
#
#  ------------------------------------------------------------------------

# config ----------------------------------------------------------------------------------------------------------

test_that("gpkg_config_opts maps typed args to the curated OGR_SQLITE_* option names", {
  cfg <- gpkg_config_opts(sqlite_synchronous = "OFF", use_ogr_vfs = TRUE, num_threads = "ALL_CPUS")
  expect_gdal_opts(cfg, "gdal_config_opts", driver = "GPKG")
  expect_opt_value(cfg, "OGR_SQLITE_SYNCHRONOUS", "OFF")
  expect_opt_value(cfg, "SQLITE_USE_OGR_VFS", "YES")
  expect_opt_value(cfg, "OGR_GPKG_NUM_THREADS", "ALL_CPUS")
})

test_that("gpkg_config_opts validates enumerated values against curated config metadata", {
  # SQLITE_USE_OGR_VFS is a curated boolean (YES/NO); a bogus value supplied via ... is rejected
  expect_error(gpkg_config_opts(SQLITE_USE_OGR_VFS = "MAYBE"), class = "gdal_check_error")
})

# construction-path equivalence -----------------------------------------------------------------------------------

test_that("gpkg_config_opts(explicit OGR names) is identical to gdal_config_opts(..., driver = 'GPKG')", {
  via_driver_fn <- gpkg_config_opts(
    "OGR_GPKG_NUM_THREADS" = "4",
    "OGR_SQLITE_CACHE" = "4000000",
    "OGR_SQLITE_SYNCHRONOUS" = "OFF"
  )
  via_generic <- gdal_config_opts(
    "OGR_GPKG_NUM_THREADS" = "4",
    "OGR_SQLITE_CACHE" = "4000000",
    "OGR_SQLITE_SYNCHRONOUS" = "OFF",
    driver = "GPKG"
  )
  expect_identical(via_driver_fn, via_generic)
})

test_that("gpkg typed args resolve to the same NAME=VALUE pairs as explicit OGR names", {
  typed <- gpkg_config_opts(num_threads = 4L, sqlite_cache = 4000000, sqlite_synchronous = "OFF")
  explicit <- gpkg_config_opts(
    "OGR_GPKG_NUM_THREADS" = "4",
    "OGR_SQLITE_CACHE" = "4000000",
    "OGR_SQLITE_SYNCHRONOUS" = "OFF"
  )
  # numeric/integer typed values coerce to the same strings; only payload order differs
  expect_opts_equivalent(typed, explicit)
})

test_that("gpkg_open_opts(builder) is identical to the generic gdal_open_opts(driver = 'GPKG')", {
  expect_identical(
    gpkg_open_opts(list_all_tables = FALSE),
    gdal_open_opts(LIST_ALL_TABLES = "NO", driver = "GPKG")
  )
})

test_that("gpkg_open_opts accepts logical and string list_all_tables forms equivalently", {
  expect_identical(gpkg_open_opts(list_all_tables = FALSE), gpkg_open_opts(list_all_tables = "NO"))
  expect_identical(gpkg_open_opts(list_all_tables = TRUE), gpkg_open_opts(list_all_tables = "YES"))
})

test_that("sqlite_synchronous = FALSE is coerced to 'NO' (a known sharp edge; pass 'OFF' instead)", {
  # OGR_SQLITE_SYNCHRONOUS is an enum (OFF/NORMAL/FULL); a logical is blindly mapped to YES/NO, so
  # the logical form does NOT match the canonical string form. this locks in current behavior.
  expect_identical(unclass(gpkg_config_opts(sqlite_synchronous = FALSE))[["OGR_SQLITE_SYNCHRONOUS"]], "NO")
  expect_false(identical(
    gpkg_config_opts(sqlite_synchronous = FALSE),
    gpkg_config_opts(sqlite_synchronous = "OFF")
  ))
})

test_that("gpkg_config_opts(.set_defaults) only fills curated defaults that exist", {
  # GPKG curated config options declare no defaults, so .set_defaults is a no-op here
  cfg <- gpkg_config_opts(use_ogr_vfs = TRUE, .set_defaults = TRUE)
  expect_opt_value(cfg, "SQLITE_USE_OGR_VFS", "YES")
})

# open ------------------------------------------------------------------------------------------------------------

test_that("gpkg_open_opts coerces list_all_tables and tags the driver", {
  oo <- gpkg_open_opts(list_all_tables = FALSE, nolock = TRUE)
  expect_gdal_opts(oo, "gdal_open_opts", driver = "GPKG")
  expect_opt_value(oo, "LIST_ALL_TABLES", "NO")
  expect_opt_value(oo, "NOLOCK", "YES")
})

test_that("gpkg_open_opts drops an empty prelude string", {
  oo <- gpkg_open_opts(list_all_tables = FALSE, prelude_statements = "")
  expect_false("PRELUDE_STATEMENTS" %in% names(unclass(oo)))
})

test_that("gpkg_open_opts(.set_defaults) fills the documented LIST_ALL_TABLES default", {
  oo <- gpkg_open_opts(.set_defaults = TRUE)
  expect_opt_value(oo, "LIST_ALL_TABLES", "AUTO")
})

# creation --------------------------------------------------------------------------------------------------------

test_that("gpkg dataset vs layer creation level is honored", {
  ds <- gpkg_creation_opts(VERSION = "1.4", level = "dataset")
  expect_gdal_opts(ds, "gdal_creation_opts", driver = "GPKG", level = "dataset")
  lyr <- gpkg_creation_opts(spatial_index = TRUE)
  expect_gdal_opts(lyr, "gdal_creation_opts", driver = "GPKG", level = "layer")
  expect_opt_value(lyr, "SPATIAL_INDEX", "YES")
})

test_that("gpkg_creation_opts coerces booleans supplied through ... before validation", {
  ds <- gpkg_creation_opts(ADD_GPKG_OGR_CONTENTS = TRUE, level = "dataset")
  expect_opt_value(ds, "ADD_GPKG_OGR_CONTENTS", "YES")
})

# prelude pragmas -------------------------------------------------------------------------------------------------

test_that("gpkg_prelude_pragmas builds a single semicolon-joined string", {
  s <- gpkg_prelude_pragmas(cache_size = -4000000, temp_store = "MEMORY", mmap_size = 8589934592, journal_mode = "WAL")
  expect_identical(
    s,
    "PRAGMA cache_size=-4000000;PRAGMA temp_store=MEMORY;PRAGMA mmap_size=8589934592;PRAGMA journal_mode=WAL;"
  )
})

test_that("gpkg_prelude_pragmas accepts integer temp_store codes and raw extras", {
  s <- gpkg_prelude_pragmas(temp_store = 2L, journal_mode = "WAL", extra = "PRAGMA foreign_keys=ON;")
  expect_match(s, "PRAGMA temp_store=MEMORY;", fixed = TRUE)
  expect_match(s, "PRAGMA foreign_keys=ON;", fixed = TRUE)
})

test_that("gpkg_prelude_pragmas rejects unknown journal modes and is empty by default", {
  expect_error(gpkg_prelude_pragmas(journal_mode = "NOPE"))
  expect_identical(gpkg_prelude_pragmas(), "")
})

test_that("PRELUDE_STATEMENTS is carried as ONE option value and ONE --oo token", {
  prelude <- gpkg_prelude_pragmas(cache_size = -4000000, temp_store = "MEMORY")
  oo <- gpkg_open_opts(list_all_tables = FALSE, prelude_statements = prelude)
  expect_length(unclass(oo), 2L)
  expect_opt_value(oo, "PRELUDE_STATEMENTS", prelude)

  tokens <- as_gdal_args(oo)
  # exactly two --oo flags, and the prelude value (with its ';') survives as one token
  expect_identical(sum(tokens == "--oo"), 2L)
  expect_true(any(tokens == paste0("PRELUDE_STATEMENTS=", prelude)))
})

# live integration ------------------------------------------------------------------------------------------------

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
