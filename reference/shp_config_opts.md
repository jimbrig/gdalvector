# ESRI Shapefile Configuration Options

Construct a
[`gdal_config_opts()`](http://docs.jimbrig.com/gdalvector/reference/gdal_config_opts.md)
object for the `ESRI Shapefile` driver. These are global GDAL
configuration options applied to the process (via
[`gdalraster::set_config_option()`](https://firelab.github.io/gdalraster/reference/set_config_option.html)
/ `--config`). Only options you supply are emitted.

## Usage

``` r
shp_config_opts(
  shape_rewind_on_write = NULL,
  shape_restore_shx = NULL,
  shape_2gb_limit = NULL,
  shape_encoding = NULL,
  ...,
  .set_defaults = FALSE
)
```

## Arguments

- shape_rewind_on_write:

  Value for `SHAPE_REWIND_ON_WRITE` (logical -\> `"YES"`/`"NO"`);
  whether to correct the winding order of exterior/interior rings on
  write. Since GDAL 3.7 the default for Polygon/MultiPolygon is `"NO"`.

- shape_restore_shx:

  Value for `SHAPE_RESTORE_SHX` (logical -\> `"YES"`/`"NO"`); restore a
  missing/broken `.shx` from the `.shp` on open. GDAL default `"NO"`.

- shape_2gb_limit:

  Value for `SHAPE_2GB_LIMIT` (logical -\> `"YES"`/`"NO"`); strictly
  enforce the 2 GB `.shp`/`.dbf` size limit when updating.

- shape_encoding:

  Value for `SHAPE_ENCODING` (override DBF encoding with any
  `CPLRecode()` encoding; `""` disables recoding).

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
[`gdal_config_opts()`](http://docs.jimbrig.com/gdalvector/reference/gdal_config_opts.md)
object for the `ESRI Shapefile` driver.

## See also

[`shp_open_opts()`](http://docs.jimbrig.com/gdalvector/reference/shp_open_opts.md),
[`shp_creation_opts()`](http://docs.jimbrig.com/gdalvector/reference/shp_creation_opts.md),
[`gdal_config_opts()`](http://docs.jimbrig.com/gdalvector/reference/gdal_config_opts.md)

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
shp_config_opts(shape_restore_shx = TRUE)
#> <gdal_config_opts/gdal_opts>
#> ℹ Driver: ESRI Shapefile
#> ℹ Configuration Options: SHAPE_RESTORE_SHX=YES
#> ℹ Command Line: --config 'SHAPE_RESTORE_SHX=YES'
```
