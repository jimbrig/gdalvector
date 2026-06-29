#  ------------------------------------------------------------------------
#
# Title : GDAL Drivers Tests
#    By : Jimmy Briggs
#  Date : 2026-06-29
#
#  ------------------------------------------------------------------------

# driver table ----------------------------------------------------------------------------------------------------

test_that("gdal_drivers() returns the normalized driver schema", {
  d <- gdal_drivers()
  expect_s3_class(d, "tbl_df")
  expect_true(all(
    c(
      "driver",
      "short_name",
      "long_name",
      "extensions",
      "is_vector",
      "is_raster",
      "read_write",
      "supports_vsi",
      "supports_multiple_layers",
      "sql_dialects"
    ) %in%
      names(d)
  ))
  # extensions / sql_dialects are split into list-columns of character vectors
  expect_type(d$extensions, "list")
  expect_type(d$sql_dialects, "list")
  # the core vector drivers are present
  expect_true(all(c("GPKG", "Parquet", "FlatGeobuf") %in% d$driver))
})

test_that("gdal_drivers(pattern) filters on short and long name, case-insensitively", {
  hits <- gdal_drivers("gpkg")
  expect_true(all(grepl("gpkg", hits$driver, ignore.case = TRUE) | grepl("gpkg", hits$long_name, ignore.case = TRUE)))
  expect_true("GPKG" %in% hits$driver)
  # multiple patterns are OR-combined
  multi <- gdal_drivers(c("gpkg", "parquet"))
  expect_true(all(c("GPKG", "Parquet") %in% multi$driver))
})

test_that("gdal_driver_names() returns a character vector of short names", {
  nms <- gdal_driver_names()
  expect_type(nms, "character")
  expect_true("GPKG" %in% nms)
  expect_identical(gdal_driver_names("gpkg"), gdal_drivers("gpkg")$driver)
})

# option table ----------------------------------------------------------------------------------------------------

test_that("gdal_vector_driver_opts() filters by type, sub_type, and scope", {
  open_tbl <- gdal_vector_driver_opts("GPKG", type = "open")
  expect_true(all(open_tbl$type == "open"))

  lco_tbl <- gdal_vector_driver_opts("GPKG", sub_type = "layer")
  expect_true(all(lco_tbl$type == "creation" & lco_tbl$sub_type == "layer"))

  expect_true(nrow(gdal_vector_driver_opts("GPKG")) >= nrow(open_tbl))
})

test_that("gdal_vector_driver_opts(NULL) returns rows for all core vector drivers", {
  all_tbl <- gdal_vector_driver_opts()
  expect_s3_class(all_tbl, "tbl_df")
  expect_true(all(c("GPKG", "Parquet", "FlatGeobuf", "OpenFileGDB") %in% unique(all_tbl$driver)))
})

test_that("gdal_vector_driver_opts() rejects an unknown driver name", {
  expect_error(gdal_vector_driver_opts("DEFINITELY_NOT_A_DRIVER"), class = "gdal_check_error")
})

# curated config-option data path ---------------------------------------------------------------------------------

# config options are NOT exposed by GDAL driver metadata: they are scraped from the driver docs by
# data-raw/scripts/gdal_drivers_metadata.R into the internal `gdal_vector_driver_config_opts_tbl`,
# which is merged into the session option table at load by .init_driver_opts_tbl(). These tests
# guard that whole pipeline end to end.

test_that("the curated config-option table is shipped as internal package data", {
  tbl <- gdal_vector_driver_config_opts_tbl
  expect_s3_class(tbl, "tbl_df")
  expect_identical(
    names(tbl),
    c("driver", "type", "sub_type", "name", "description", "scope", "default", "values", "data_type")
  )
  expect_true(all(tbl$type == "config"))
  # the core driver families that document config options are present
  expect_true(all(c("GPKG", "OpenFileGDB", "ESRI Shapefile") %in% tbl$driver))
})

test_that(".init_driver_opts_tbl merges curated config rows with parsed open/creation rows", {
  opts_tbl <- .pkg_env$gdal$drivers$opts_tbl
  expect_s3_class(opts_tbl, "tbl_df")
  expect_setequal(unique(opts_tbl$type), c("config", "open", "creation"))
  # the curated GPKG config rows survive the merge into the session table
  gpkg_cfg <- opts_tbl[opts_tbl$driver == "GPKG" & opts_tbl$type == "config", ]
  expect_true(nrow(gpkg_cfg) > 0L)
  expect_true("SQLITE_USE_OGR_VFS" %in% gpkg_cfg$name)
})

test_that("config-option accessors surface the curated values with booleans expanded", {
  cfg <- gdal_vector_driver_config_opts("GPKG")
  expect_true(all(cfg$type == "config"))
  expect_true(all(c("OGR_SQLITE_CACHE", "OGR_SQLITE_SYNCHRONOUS", "SQLITE_USE_OGR_VFS") %in% cfg$name))

  vals <- gdal_vector_driver_config_opts_values("GPKG")
  # SQLITE_USE_OGR_VFS is curated as a boolean and expanded to YES/NO
  expect_setequal(vals[["SQLITE_USE_OGR_VFS"]], c("YES", "NO"))
})

test_that("config-option single-option lookups and types reflect curated metadata", {
  expect_setequal(
    gdal_vector_driver_config_opts_values("GPKG", "SQLITE_USE_OGR_VFS"),
    c("YES", "NO")
  )
  types <- gdal_vector_driver_config_opts_types("OpenFileGDB")
  expect_type(types, "character")
  expect_identical(unname(types[["OPENFILEGDB_IN_MEMORY_SPI"]]), "boolean")
})

# open-option accessors -------------------------------------------------------------------------------------------

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
  # single-option lookup
  expect_identical(unname(gdal_vector_driver_open_opts_defaults("GPKG", "LIST_ALL_TABLES")), "AUTO")
})

test_that("_types accessors expose the data_type per option", {
  types <- gdal_vector_driver_open_opts_types("GPKG")
  expect_type(types, "character")
  expect_identical(unname(types[["LIST_ALL_TABLES"]]), "string-select")
})

# config-option accessors -----------------------------------------------------------------------------------------

test_that("config opts accessors no longer error on the NULL opt_name path (bug fix)", {
  expect_no_error(gdal_vector_driver_config_opts_values("GPKG"))
  expect_no_error(gdal_vector_driver_config_opts_defaults("GPKG"))
  vals <- gdal_vector_driver_config_opts_values("GPKG")
  expect_true("SQLITE_USE_OGR_VFS" %in% names(vals))
})

# creation-option accessors ---------------------------------------------------------------------------------------

test_that("creation opts accessors respect sub_type and single-option lookups", {
  lco <- gdal_vector_driver_creation_opts("Parquet", sub_type = "layer")
  expect_true(all(lco$sub_type == "layer"))

  vals <- gdal_vector_driver_creation_opts_values("Parquet", sub_type = "layer", opt_name = "COMPRESSION")
  expect_type(vals, "character")
  expect_true(length(vals) > 0L)

  # opt_name is the 2nd positional arg, consistent with the open/config accessors
  expect_setequal(
    gdal_vector_driver_creation_opts_values("Parquet", "WRITE_COVERING_BBOX"),
    c("AUTO", "YES", "NO")
  )
  expect_identical(
    unname(gdal_vector_driver_creation_opts_defaults("GPKG", "SPATIAL_INDEX")),
    "YES"
  )

  types <- gdal_vector_driver_creation_opts_types("GPKG", sub_type = "layer")
  expect_type(types, "character")
})

# capabilities ----------------------------------------------------------------------------------------------------

test_that("gdal_vector_driver_capabilities() returns a named logical vector of DCAP_ flags", {
  caps <- gdal_vector_driver_capabilities("GPKG")
  expect_type(caps, "logical")
  expect_true(all(grepl("^DCAP_", names(caps))))
  expect_true(caps[["DCAP_CREATE"]])
  # names come back sorted
  expect_identical(names(caps), sort(names(caps)))
})

# internal helpers ------------------------------------------------------------------------------------------------

test_that(".split_words splits whitespace and handles the empty string", {
  expect_identical(.split_words("a b   c"), c("a", "b", "c"))
  expect_identical(.split_words(""), character())
  expect_identical(.split_words("  "), character())
})

test_that(".normalize_gdal_formats_tbl renames raw gdal_formats() columns to the package schema", {
  raw <- gdalraster::gdal_formats()
  norm <- .normalize_gdal_formats_tbl(raw)
  expect_s3_class(norm, "tbl_df")
  expect_identical(
    names(norm),
    c(
      "driver",
      "short_name",
      "long_name",
      "extensions",
      "is_vector",
      "is_raster",
      "is_multidim_raster",
      "is_geography_network",
      "read_write",
      "supports_vsi",
      "supports_subdatasets",
      "supports_multiple_layers",
      "supports_field_domains",
      "sql_dialects"
    )
  )
})

test_that("renamed _defaults accessor exists (typo fixed)", {
  expect_true(is.function(gdal_vector_driver_opt_defaults))
})
