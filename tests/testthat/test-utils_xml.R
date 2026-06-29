#  ------------------------------------------------------------------------
#
# Title : XML Utilities Tests
#    By : Jimmy Briggs
#  Date : 2026-06-29
#
#  ------------------------------------------------------------------------

# xml_parse_gdal_options ------------------------------------------------------------------------------------------

test_that("xml_parse_gdal_options parses name/description/default/values/type per option", {
  tbl <- xml_parse_gdal_options(sample_option_xml(), driver = "GPKG", type = "open", scope = "vector")
  expect_s3_class(tbl, "tbl_df")
  expect_identical(
    names(tbl),
    c("driver", "type", "sub_type", "name", "description", "scope", "default", "values", "data_type")
  )
  expect_setequal(tbl$name, c("MODE", "LABEL", "STRICT"))

  mode <- tbl[tbl$name == "MODE", ]
  expect_identical(mode$default, "AUTO")
  expect_identical(mode$data_type, "string-select")
  expect_setequal(mode$values[[1]], c("AUTO", "FAST", "SAFE"))
})

test_that("xml_parse_gdal_options expands boolean values to c('YES','NO')", {
  tbl <- xml_parse_gdal_options(sample_option_xml(), driver = "GPKG", type = "open")
  strict <- tbl[tbl$name == "STRICT", ]
  expect_identical(strict$data_type, "boolean")
  expect_setequal(strict$values[[1]], c("YES", "NO"))
})

test_that("free-string options carry NA values and data_type", {
  tbl <- xml_parse_gdal_options(sample_option_xml(), driver = "GPKG", type = "open")
  label <- tbl[tbl$name == "LABEL", ]
  expect_true(is.na(label$default))
  expect_true(is.na(label$values[[1]]))
})

test_that("xml_parse_gdal_options stamps driver/type/sub_type metadata", {
  tbl <- xml_parse_gdal_options(sample_option_xml(), driver = "GPKG", type = "creation", sub_type = "layer")
  expect_true(all(tbl$driver == "GPKG"))
  expect_true(all(tbl$type == "creation"))
  expect_true(all(tbl$sub_type == "layer"))
})

test_that("missing scope is normalized to 'all' when filtering for vector", {
  tbl <- xml_parse_gdal_options(sample_option_xml(), driver = "GPKG", type = "open", scope = "vector")
  expect_true(all(tbl$scope == "all"))
})

test_that("xml_parse_gdal_options accepts a parsed xml_document as well as a string", {
  doc <- xml2::read_xml(sample_option_xml())
  tbl <- xml_parse_gdal_options(doc, driver = "GPKG", type = "open")
  expect_setequal(tbl$name, c("MODE", "LABEL", "STRICT"))
})

test_that("NULL or option-less XML yields a typed empty tibble", {
  empty_null <- xml_parse_gdal_options(NULL, driver = "GPKG", type = "open")
  expect_s3_class(empty_null, "tbl_df")
  expect_identical(nrow(empty_null), 0L)

  empty_xml <- xml_parse_gdal_options("<OptionList></OptionList>", driver = "GPKG", type = "open")
  expect_identical(nrow(empty_xml), 0L)
})

test_that("xml_parse_gdal_options validates the driver, type, and scope arguments", {
  expect_error(xml_parse_gdal_options(sample_option_xml(), driver = "NOPE", type = "open"), class = "gdal_check_error")
  expect_error(xml_parse_gdal_options(sample_option_xml(), driver = "GPKG", type = "bogus"))
  expect_error(xml_parse_gdal_options("not <valid", driver = "GPKG", type = "open"), class = "gdal_check_error")
})

# round-trips against a live driver --------------------------------------------------------------------------------

test_that("xml_parse_gdal_options handles real GPKG open-option metadata", {
  skip_if_not_installed("gdalraster")
  xml <- gdalraster::gdal_get_driver_md("GPKG", mdi_name = "DMD_OPENOPTIONLIST")
  tbl <- xml_parse_gdal_options(xml, driver = "GPKG", type = "open", scope = "vector")
  expect_true("LIST_ALL_TABLES" %in% tbl$name)
  list_all <- tbl[tbl$name == "LIST_ALL_TABLES", ]
  expect_identical(list_all$default, "AUTO")
})

# xml_parse_gdal_driver_config_opts -------------------------------------------------------------------------------

test_that("config-option HTML parser extracts name, default, values, and data_type", {
  doc <- rvest::read_html(sample_config_html())
  tbl <- xml_parse_gdal_driver_config_opts(doc, scope = "vector", driver = "GPKG", type = "config")
  expect_s3_class(tbl, "tbl_df")
  expect_setequal(tbl$name, c("FOO_OPT", "BAR_OPT", "BAZ_OPT"))

  foo <- tbl[tbl$name == "FOO_OPT", ]
  expect_identical(foo$default, "YES")
  expect_identical(foo$data_type, "boolean")
  expect_setequal(foo$values[[1]], c("YES", "NO"))

  baz <- tbl[tbl$name == "BAZ_OPT", ]
  expect_identical(baz$default, "B")
  expect_identical(baz$data_type, "string-list")
})

test_that("config-option HTML parser warns and returns empty when the section is absent", {
  doc <- rvest::read_html("<html><body><p>no options here</p></body></html>")
  expect_warning(
    tbl <- xml_parse_gdal_driver_config_opts(doc, scope = "vector", driver = "GPKG", type = "config"),
    class = "gdal_warning"
  )
  expect_identical(nrow(tbl), 0L)
})

# internal helpers ------------------------------------------------------------------------------------------------

test_that(".empty_xml_opts_tbl returns the canonical 9-column schema", {
  tbl <- .empty_xml_opts_tbl(driver = "GPKG", type = "open")
  expect_identical(
    names(tbl),
    c("driver", "type", "sub_type", "name", "description", "scope", "default", "values", "data_type")
  )
  expect_identical(nrow(tbl), 0L)
})

test_that(".replace_boolean_values rewrites boolean rows to c('YES','NO') and preserves order", {
  df <- tibble::tibble(
    name = c("A", "B"),
    values = list(NA_character_, c("ON", "OFF")),
    data_type = c("boolean", "string-select")
  )
  out <- .replace_boolean_values(df)
  expect_identical(out$name, c("A", "B"))
  expect_setequal(out$values[[1]], c("YES", "NO"))
  expect_setequal(out$values[[2]], c("ON", "OFF"))
})

test_that(".opts_defaults and .opts_values summarize a metadata tibble", {
  md <- tibble::tibble(
    name = c("A", "B", "C"),
    default = c("1", NA_character_, "3"),
    values = list(c("1", "2"), NA_character_, c("3", "4")),
    data_type = c("string-select", "string", "string-select")
  )
  defs <- .opts_defaults(md)
  expect_identical(defs, c(A = "1", C = "3"))

  vals <- .opts_values(md)
  expect_named(vals, c("A", "B", "C"))
  expect_setequal(vals[["A"]], c("1", "2"))
})
