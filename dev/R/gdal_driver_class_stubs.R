#  ------------------------------------------------------------------------
#
# Title : GDAL Vector Drivers
#    By : Jimmy Briggs
#  Date : 2026-06-10
#
#  ------------------------------------------------------------------------

# relevant gdalraster functions:
# ------------------------------
# gdalraster::identifyDriver()
# gdalraster::gdal_formats()
# gdalraster::ogr_ds_format()
# gdalraster::gdal_get_driver_md()
# gdalraster::getCreationOptions()

# gdal_vector_driver ----------------------------------------------------------------------------------------------

gdal_vector_driver <- function(name, ...) {}

# constructor -----------------------------------------------------------------------------------------------------

new_gdal_vector_driver <- function(name, ...) {
  structure(
    list(
      name = name
    ),
    class = c("gdal_vector_driver", "gdal_driver", "list")
  )
}

# as_gdal_vector_driver -------------------------------------------------------------------------------------------

as_gdal_vector_driver <- function(x, ...) {
  UseMethod("as_gdal_vector_driver")
}

as_gdal_vector_driver.default <- function(x, ...) {}

as_gdal_vector_driver.gdal_vector_driver <- function(x, ...) {
  x
}

as_gdal_vector_driver.character <- function(x, ...) {}

as_gdal_vector_driver.list <- function(x, ...) {}

as_gdal_vector_driver.data.frame <- function(x, ...) {}

# as_tibble -------------------------------------------------------------------------------------------------------

as_tibble.gdal_vector_driver <- function(x, ...) {}

# format & print --------------------------------------------------------------------------------------------------

format.gdal_vector_driver <- function(x, ...) {}

print.gdal_vector_driver <- function(x, ...) {}
