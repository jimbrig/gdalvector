# OpenFileGDB Configuration Options

Construct a
[`gdal_config_opts()`](http://docs.jimbrig.com/gdalvector/reference/gdal_config_opts.md)
object for the `OpenFileGDB` driver. Only options you supply are
emitted; boolean values are validated against the driver metadata.

## Usage

``` r
gdb_config_opts(
  default_string_width = NULL,
  in_memory_spi = NULL,
  ...,
  .set_defaults = FALSE
)
```

## Arguments

- default_string_width:

  Value for `OPENFILEGDB_DEFAULT_STRING_WIDTH` (integer). Width for
  string fields created when the requested width is the unspecified
  value `0`. GDAL default `65536`.

- in_memory_spi:

  Value for `OPENFILEGDB_IN_MEMORY_SPI`. Logical `TRUE`/`FALSE` (coerced
  to `"YES"`/`"NO"`); build an in-memory spatial index instead of using
  the native one.

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
object for the `OpenFileGDB` driver.

## See also

[`gdb_open_opts()`](http://docs.jimbrig.com/gdalvector/reference/gdb_open_opts.md),
[`gdb_creation_opts()`](http://docs.jimbrig.com/gdalvector/reference/gdb_creation_opts.md),
[`gdal_config_opts()`](http://docs.jimbrig.com/gdalvector/reference/gdal_config_opts.md)

- [OpenFileGDB GDAL
  Driver](https://gdal.org/en/stable/drivers/vector/openfilegdb.html)

  - [OpenFileGDB GDAL Open
    Options](https://gdal.org/en/stable/drivers/vector/openfilegdb.html#open-options)

  - [OpenFileGDB GDAL Layer Creation
    Options](https://gdal.org/en/stable/drivers/vector/openfilegdb.html#layer-creation-options)

  - [OpenFileGDB GDAL Configuration
    Options](https://gdal.org/en/stable/drivers/vector/openfilegdb.html#configuration-options)

- [ESRI File Geodatabase (.gdb)
  Format](https://desktop.arcgis.com/en/arcmap/latest/manage-data/administer-file-gdbs/file-geodatabases.htm)

## Examples

``` r
gdb_config_opts(default_string_width = 1024L, in_memory_spi = TRUE)
#> <gdal_config_opts/gdal_opts>
#> ℹ Driver: OpenFileGDB
#> ℹ Configuration Options: OPENFILEGDB_DEFAULT_STRING_WIDTH=1024, OPENFILEGDB_IN_MEMORY_SPI=YES
#> ℹ Command Line: --config 'OPENFILEGDB_DEFAULT_STRING_WIDTH=1024' --config 'OPENFILEGDB_IN_MEMORY_SPI=YES'
```
