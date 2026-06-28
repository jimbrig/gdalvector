# skip unless the gdalraster gdal CLI algorithm API (GDAL >= 3.11.3) is usable
skip_if_no_gdalalg <- function() {
  testthat::skip_if_not_installed("gdalraster")
  ok <- tryCatch(
    {
      alg <- gdalraster::gdal_alg("vector info", parse = FALSE)
      alg$release()
      TRUE
    },
    error = function(e) FALSE
  )
  testthat::skip_if_not(ok, "gdal vector CLI algorithms not available")
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
