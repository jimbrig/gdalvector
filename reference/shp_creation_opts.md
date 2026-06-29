# ESRI Shapefile Creation Options

Construct a layer-level
[`gdal_creation_opts()`](http://docs.jimbrig.com/gdalvector/reference/gdal_creation_opts.md)
object for the `ESRI Shapefile` driver.

## Usage

``` r
shp_creation_opts(
  spatial_index = NULL,
  encoding = NULL,
  resize = NULL,
  shpt = NULL,
  two_gb_limit = NULL,
  auto_repack = NULL,
  dbf_date_last_update = NULL,
  dbf_eof_char = NULL,
  .set_defaults = FALSE
)
```

## Arguments

- spatial_index:

  Value for `SPATIAL_INDEX` (logical -\> `"YES"`/`"NO"`).

- encoding:

  Value for `ENCODING` (DBF encoding).

- resize:

  Value for `RESIZE` (logical -\> `"YES"`/`"NO"`); resize fields to
  optimal size.

- shpt:

  Value for `SHPT` (shape type, e.g. `"POLYGON"`).

- two_gb_limit:

  Value for `2GB_LIMIT` (logical -\> `"YES"`/`"NO"`); restrict
  `.shp`/`.dbf` to 2 GB.

- auto_repack:

  Value for `AUTO_REPACK` (logical -\> `"YES"`/`"NO"`).

- dbf_date_last_update:

  Value for `DBF_DATE_LAST_UPDATE` (`YYYY-MM-DD`).

- dbf_eof_char:

  Value for `DBF_EOF_CHAR` (logical -\> `"YES"`/`"NO"`).

- .set_defaults:

  Logical. If `TRUE`, options left unset (`NULL`) are filled with the
  driver's documented GDAL metadata defaults (via the relevant
  `gdal_vector_driver_*_opts_defaults()`); user-supplied values always
  take precedence. Defaults to `FALSE`.

## Value

A layer-level
[`gdal_creation_opts()`](http://docs.jimbrig.com/gdalvector/reference/gdal_creation_opts.md)
object for the `ESRI Shapefile` driver.

## See also

[`shp_open_opts()`](http://docs.jimbrig.com/gdalvector/reference/shp_open_opts.md),
[`gdal_creation_opts()`](http://docs.jimbrig.com/gdalvector/reference/gdal_creation_opts.md)

- [Shapefile Home Page](http://shapelib.maptools.org/)

- [Shapefile GDAL
  Driver](https://gdal.org/en/stable/drivers/vector/shapefile.html)

  - [Shapefile GDAL
    Capabilities](https://gdal.org/en/stable/drivers/vector/shapefile.html#driver-capabilities)

  - [Shapefile GDAL Open
    Options](https://gdal.org/en/stable/drivers/vector/shapefile.html#open-options)

  - [Shapefile GDAL Layer Creation
    Options](https://gdal.org/en/stable/drivers/vector/shapefile.html#layer-creation-options)

  - [Shapefile GDAL Configuration
    Options](https://gdal.org/en/stable/drivers/vector/shapefile.html#configuration-options)

- [Shapefile C Library](http://shapelib.maptools.org/)

- [ESRI Shapefile Technical Description
  (PDF)](http://dl.maptools.org/dl/shapelib/shapefile.pdf)

- [Shapefile .SHP File API](http://shapelib.maptools.org/shp_api.md)

- [Attribute .DBF File API](http://shapelib.maptools.org/dbf_api.md)

- [Xbase File Format
  Description](https://www.clicketyclick.dk/databases/xbase/format/)

- [Shapelib Code Page](http://shapelib.maptools.org/codepage.md)

## Examples

``` r
shp_creation_opts(spatial_index = TRUE, encoding = "UTF-8")
#> <gdal_creation_opts/gdal_opts>
#> ℹ Driver: ESRI Shapefile
#> ℹ Creation Options: SPATIAL_INDEX=YES, ENCODING=UTF-8
#> ℹ Command Line: --output-format 'ESRI Shapefile' --layer-creation-option 'SPATIAL_INDEX=YES' --layer-creation-option 'ENCODING=UTF-8'
```
