#  ------------------------------------------------------------------------
#
# Title : Test GeoParquet Metadata
#    By : Jimmy Briggs
#  Date : 2026-06-30
#
#  ------------------------------------------------------------------------

# `geo.parquet`     : a real GDAL-written GeoParquet 1.1 (poly_multipoly sample) under tests/testthat/data/.
# `plain.parquet`   : a plain, non-geo Parquet file under tests/testthat/data/.
# `atlanta.parquet` : a real DuckDB-written GeoParquet 2.0 shipped in inst/extdata/ (primary column "geom").

# gpq_file_info ---------------------------------------------------------------------------------------------------

test_that("gpq_file_info summarises footer-level facts", {
  info <- gpq_file_info(test_data("geo.parquet"))

  expect_s3_class(info, "gpq_file_info")
  expect_equal(info$num_rows, 4)
  expect_equal(info$num_cols, 5)
  expect_equal(info$num_row_groups, 1)
  expect_identical(info$geoparquet_version, "1.1.0")
  expect_true(all(c("geo", "gdal:schema", "gdal:creation-options") %in% info$kv_keys))
})

test_that("gpq_file_info reports NA GeoParquet version for plain parquet", {
  info <- gpq_file_info(test_data("plain.parquet"))

  expect_identical(info$geoparquet_version, NA_character_)
  expect_false("geo" %in% info$kv_keys)
})

test_that("gpq_file_info errors on missing files and non-parquet extensions", {
  expect_error(gpq_file_info("does-not-exist.parquet"))

  txt <- withr::local_tempfile(fileext = ".txt")
  file.create(txt)
  expect_error(gpq_file_info(txt))
})


# gpq_schema_info -------------------------------------------------------------------------------------------------

test_that("gpq_schema_info separates leaves from struct nodes and annotates geometry", {
  sch <- gpq_schema_info(test_data("geo.parquet"))

  expect_s3_class(sch, "gpq_schema_info")
  expect_equal(sch$n_leaf, 8)
  expect_equal(sch$n_struct, 1)
  expect_true("geometry_bbox" %in% sch$struct_nodes$name)
  expect_identical(nrow(sch$columns), 8L)
  expect_match(sch$columns$info[sch$columns$name == "geometry"], "^WKB")
  expect_true(all(is.na(sch$columns$info[sch$columns$name != "geometry"])))
})

test_that("gpq_schema_info has no struct nodes for a flat, non-geo file", {
  sch <- gpq_schema_info(test_data("plain.parquet"))

  expect_equal(sch$n_struct, 0)
  expect_setequal(sch$columns$name, c("id", "label", "value"))
  expect_true(all(is.na(sch$columns$info)))
})


# gpq_row_groups --------------------------------------------------------------------------------------------------

test_that("gpq_row_groups aggregates chunks and decodes numeric and character statistics", {
  rg <- gpq_row_groups(test_data("geo.parquet"))

  expect_s3_class(rg, "gpq_row_groups")
  expect_equal(nrow(rg$row_groups), 1)
  expect_equal(nrow(rg$col_summary), 8)
  expect_true("geometry_bbox.xmin" %in% rg$col_summary$col_name)

  # nested bbox floats carry numeric statistics
  xmin <- rg$col_summary[rg$col_summary$col_name == "geometry_bbox.xmin", ]
  expect_false(identical(xmin$min, "-"))

  # character columns decode to lexical min/max
  ev <- rg$col_summary[rg$col_summary$col_name == "Event_ID", ]
  expect_type(ev$min, "character")
  expect_true(ev$min <= ev$max)
})

test_that("gpq_row_groups reports '-' min/max for the WKB geometry column", {
  rg <- gpq_row_groups(test_data("geo.parquet"))
  geom <- rg$col_summary[rg$col_summary$col_name == "geometry", ]
  expect_identical(geom$min, "-")
  expect_identical(geom$max, "-")
})


# gpq_geo_metadata ------------------------------------------------------------------------------------------------

test_that("gpq_geo_metadata parses the geo spec and PROJJSON crs (GeoParquet 1.1)", {
  geo <- gpq_geo_metadata(test_data("geo.parquet"))

  expect_true(geo$is_geoparquet)
  expect_identical(geo$version, "1.1.0")
  expect_identical(geo$primary_column, "geometry")
  expect_identical(geo$encoding, "WKB")
  expect_setequal(geo$geometry_types, c("Polygon", "MultiPolygon"))
  expect_identical(geo$crs_type, "PROJJSON")
  expect_identical(geo$crs_authority, "EPSG:4269")
  expect_true(all(c("COMPRESSION", "WRITE_COVERING_BBOX") %in% names(geo$gdal_creation_opts)))
})

test_that("gpq_geo_metadata handles a non-'geometry' primary column (GeoParquet 2.0)", {
  geo <- gpq_geo_metadata(pkg_sys_extdata("atlanta/atlanta.parquet"))

  expect_true(geo$is_geoparquet)
  expect_identical(geo$version, "2.0.0")
  expect_identical(geo$primary_column, "geom")
  expect_identical(geo$crs_type, "PROJJSON")
  expect_identical(geo$crs_authority, "EPSG:4326")
})

test_that("gpq_geo_metadata warns and flags non-geoparquet files", {
  expect_warning(
    geo <- gpq_geo_metadata(test_data("plain.parquet")),
    class = "gpq_not_geoparquet_warning"
  )
  expect_false(geo$is_geoparquet)
})


# gpq_arrow_schema ------------------------------------------------------------------------------------------------

test_that("gpq_arrow_schema reads arrow fields when arrow is available", {
  skip_if_not_installed("arrow")
  schema <- gpq_arrow_schema(test_data("geo.parquet"))

  expect_s3_class(schema, "gpq_arrow_schema")
  expect_true("geometry" %in% schema$fields$name)
  expect_true(all(c("index", "name", "arrow_type", "nullable", "extension") %in% names(schema$fields)))
})

test_that("gpq_arrow_schema aborts with a typed condition when arrow is unavailable", {
  local_mocked_bindings(requireNamespace = function(...) FALSE, .package = "base")
  expect_error(
    gpq_arrow_schema(test_data("geo.parquet")),
    class = "gpq_arrow_unavailable_error"
  )
})


# gpq_inspect -----------------------------------------------------------------------------------------------------

test_that("gpq_inspect assembles all panels and omits arrow by default", {
  res <- gpq_inspect(test_data("geo.parquet"))

  expect_s3_class(res, "gpq_inspect")
  expect_s3_class(res$file_info, "gpq_file_info")
  expect_s3_class(res$schema, "gpq_schema_info")
  expect_s3_class(res$row_groups, "gpq_row_groups")
  expect_s3_class(res$geo_metadata, "gpq_geo_metadata")
  expect_null(res$arrow_schema)
})


# format & print --------------------------------------------------------------------------------------------------

test_that("format methods return character vectors and print without error", {
  f <- test_data("geo.parquet")

  for (obj in list(
    gpq_file_info(f),
    gpq_schema_info(f),
    gpq_row_groups(f),
    gpq_geo_metadata(f),
    gpq_inspect(f)
  )) {
    out <- format(obj)
    expect_type(out, "character")
    expect_match(cli::ansi_strip(paste(out, collapse = "\n")), class(obj)[[1]], fixed = TRUE)
    expect_no_error(print(obj))
  }
})

test_that("format includes decoded values and a class header", {
  txt <- cli::ansi_strip(paste(format(gpq_file_info(test_data("geo.parquet"))), collapse = "\n"))

  expect_match(txt, "gpq_file_info/list", fixed = TRUE)
  expect_match(txt, "GeoParquet version")
  expect_match(txt, "1.1.0", fixed = TRUE)
})
