#  ------------------------------------------------------------------------
#
# Title : Test Helpers
#    By : Jimmy Briggs
#  Date : 2026-06-29
#
#  ------------------------------------------------------------------------

# expectations ----------------------------------------------------------------------------------------------------

# assert a gdal_opts object's class, payload, driver, and (optional) creation level in one shot.
expect_gdal_opts <- function(object, subclass, driver = NULL, level = NULL) {
  act <- testthat::quasi_label(rlang::enquo(object), arg = "object")
  testthat::expect_s3_class(act$val, c(subclass, "gdal_opts", "list"), exact = TRUE)
  if (!is.null(driver)) {
    testthat::expect_identical(attr(act$val, "driver"), driver)
  }
  if (!is.null(level)) {
    testthat::expect_identical(attr(act$val, "level"), level)
  }
  invisible(act$val)
}

# assert a single payload entry resolves to the expected (coerced) GDAL string value.
expect_opt_value <- function(object, name, value) {
  act <- testthat::quasi_label(rlang::enquo(object), arg = "object")
  testthat::expect_identical(unclass(act$val)[[name]], value)
  invisible(act$val)
}

# assert two gdal_opts objects are equivalent regardless of payload ordering: identical class and
# driver/level/vsi_path attributes, and the same NAME = VALUE mapping. use this to prove that two
# different construction paths (typed builder vs explicit names vs generic + driver) converge.
expect_opts_equivalent <- function(object, expected) {
  act <- testthat::quasi_label(rlang::enquo(object), arg = "object")
  exp <- testthat::quasi_label(rlang::enquo(expected), arg = "expected")
  testthat::expect_identical(class(act$val), class(exp$val))
  testthat::expect_identical(attr(act$val, "driver"), attr(exp$val, "driver"))
  testthat::expect_identical(attr(act$val, "level"), attr(exp$val, "level"))
  testthat::expect_identical(attr(act$val, "vsi_path"), attr(exp$val, "vsi_path"))
  a <- as.list(act$val)
  b <- as.list(exp$val)
  testthat::expect_identical(a[order(names(a))], b[order(names(b))])
  invisible(act$val)
}


# fixtures --------------------------------------------------------------------------------------------------------

# a tiny hand-rolled GDAL option-list XML payload covering each shape the parser must handle:
# a string-select with a default, a free string, and a boolean.
sample_option_xml <- function() {
  paste0(
    "<OptionOptionList>",
    "<Option name='MODE' type='string-select' description='the mode' default='AUTO'>",
    "<Value>AUTO</Value><Value>FAST</Value><Value>SAFE</Value></Option>",
    "<Option name='LABEL' type='string' description='a free label'/>",
    "<Option name='STRICT' type='boolean' description='be strict' default='NO'/>",
    "</OptionOptionList>"
  )
}

# a minimal driver-docs HTML page exposing a configuration-options section, mirroring the structure
# parse_gdal_driver_config_opts() scrapes from gdal.org.
sample_config_html <- function() {
  paste0(
    "<html><body><section id='configuration-options'><ul>",
    "<li><strong>FOO_OPT [YES/NO]</strong>: Defaults to YES. Toggles foo.</li>",
    "<li><strong>BAR_OPT</strong>: A free-form string option with no default.</li>",
    "<li><strong>BAZ_OPT [A/B/C]</strong>: Defaults to B. Chooses a mode.</li>",
    "</ul></section></body></html>"
  )
}


# skips -----------------------------------------------------------------------------------------------------------

# skip unless the gdalraster gdal CLI algorithm API (GDAL >= 3.11.3) is usable
skip_if_no_gdalalg <- function() {
  testthat::skip_if_not_installed("gdalraster")
  ok <- gdal_sitrep_alg_check()
  testthat::skip_if_not(ok, "gdal algorithms not available")
}

# write a tiny throwaway GPKG (from gdalraster's bundled shapefile) and register cleanup.
local_tmp_gpkg <- function(env = parent.frame()) {
  skip_if_no_gdalalg()
  shp <- system.file("extdata/poly_multipoly.shp", package = "gdalraster")
  testthat::skip_if(!nzchar(shp), "gdalraster extdata shapefile not available")
  gpkg <- withr::local_tempfile(fileext = ".gpkg", .local_envir = env)
  # fixture build only; the geometry-type advisory from the sample data is irrelevant here
  suppressWarnings({
    alg <- gdalraster::gdal_run("vector convert", c("--input", shp, "--output", gpkg, "--overwrite"))
    alg$close()
  })
  gpkg
}
