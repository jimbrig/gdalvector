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
  ...,
  .set_defaults = FALSE
)
```

## Arguments

- spatial_index:

  Value for `SPATIAL_INDEX` (logical -\> `"YES"`/`"NO"`); create a
  `.qix` spatial index. GDAL default `"NO"`.

- encoding:

  Value for `ENCODING` (DBF encoding written to the `.cpg`/header). GDAL
  default `"LDID/87"`.

- resize:

  Value for `RESIZE` (logical -\> `"YES"`/`"NO"`); resize fields to
  their optimal size. GDAL default `"NO"`.

- shpt:

  Value for `SHPT` (shape type override): one of
  `NULL`/`POINT`/`ARC`/`POLYGON`/ `MULTIPOINT` (2D), the `*Z`/`*M`/`*ZM`
  measured/3D variants, or `MULTIPATCH`.

- two_gb_limit:

  Value for `2GB_LIMIT` (logical -\> `"YES"`/`"NO"`); enforce the 2 GB
  `.shp`/`.dbf` size limit. GDAL default `"NO"`.

- auto_repack:

  Value for `AUTO_REPACK` (logical -\> `"YES"`/`"NO"`); auto-repack when
  needed. GDAL default `"YES"`.

- dbf_date_last_update:

  Value for `DBF_DATE_LAST_UPDATE` (`YYYY-MM-DD`); modification date
  written in the DBF header. Defaults to the current date.

- dbf_eof_char:

  Value for `DBF_EOF_CHAR` (logical -\> `"YES"`/`"NO"`); write the
  `0x1A` end-of-file character in the `.dbf`. GDAL default `"YES"`.

- ...:

  Additional `NAME = value` options passed through verbatim alongside
  the typed arguments. They are coerced and validated against the driver
  metadata in the same way, and take precedence over a typed argument
  that sets the same option.

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
