# ESRI Shapefile Open Options

Construct a
[`gdal_open_opts()`](http://docs.jimbrig.com/gdalvector/reference/gdal_open_opts.md)
object for the `ESRI Shapefile` driver.

## Usage

``` r
shp_open_opts(
  encoding = NULL,
  dbf_date_last_update = NULL,
  adjust_type = NULL,
  adjust_geom_type = NULL,
  auto_repack = NULL,
  dbf_eof_char = NULL,
  ...,
  .set_defaults = FALSE
)
```

## Arguments

- encoding:

  Value for `ENCODING` (override DBF encoding with any `CPLRecode()`
  encoding; `""` avoids recoding).

- dbf_date_last_update:

  Value for `DBF_DATE_LAST_UPDATE` (`YYYY-MM-DD`); modification date
  written in the DBF header. Defaults to the current date.

- adjust_type:

  Value for `ADJUST_TYPE` (logical -\> `"YES"`/`"NO"`); read the whole
  `.dbf` to refine ambiguous `Real`/`Integer`/`Integer64` field types.
  GDAL default `"NO"`.

- adjust_geom_type:

  Value for `ADJUST_GEOM_TYPE`. One of `NO`/`FIRST_SHAPE`/`ALL_SHAPES`;
  how the layer geometry type (notably the `M` dimension) is determined.
  GDAL default `"FIRST_SHAPE"`.

- auto_repack:

  Value for `AUTO_REPACK` (logical -\> `"YES"`/`"NO"`); auto-repack the
  shapefile when needed. GDAL default `"YES"`.

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

A
[`gdal_open_opts()`](http://docs.jimbrig.com/gdalvector/reference/gdal_open_opts.md)
object for the `ESRI Shapefile` driver.

## See also

[`shp_config_opts()`](http://docs.jimbrig.com/gdalvector/reference/shp_config_opts.md),
[`shp_creation_opts()`](http://docs.jimbrig.com/gdalvector/reference/shp_creation_opts.md),
[`gdal_open_opts()`](http://docs.jimbrig.com/gdalvector/reference/gdal_open_opts.md)

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
shp_open_opts(encoding = "UTF-8", auto_repack = TRUE)
#> <gdal_open_opts/gdal_opts>
#> ℹ Driver: ESRI Shapefile
#> ℹ Open Options: ENCODING=UTF-8, AUTO_REPACK=YES
#> ℹ Command Line: --input-format 'ESRI Shapefile' --open-option 'ENCODING=UTF-8' --open-option 'AUTO_REPACK=YES'
```
