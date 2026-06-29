# Convert GDAL Configuration Options to a Config-Option Vector

Render a
[`gdal_config_opts()`](http://docs.jimbrig.com/gdalvector/reference/gdal_config_opts.md)
or
[`gdal_vsi_opts()`](http://docs.jimbrig.com/gdalvector/reference/gdal_vsi_opts.md)
object to a named character vector `c(NAME = "VALUE")`, the form
consumed by
[`gdalraster::set_config_option()`](https://firelab.github.io/gdalraster/reference/set_config_option.html).
Configuration options are ignored by the GDAL algorithm API and must be
applied to the process/session this way (or via the CLI `--config` flag,
see
[`as_gdal_args()`](http://docs.jimbrig.com/gdalvector/reference/as_gdal_args.md)).

## Usage

``` r
as_config_option(x, ...)

# S3 method for class 'gdal_config_opts'
as_config_option(x, ...)

# S3 method for class 'gdal_vsi_opts'
as_config_option(x, ...)

# Default S3 method
as_config_option(x, ...)
```

## Arguments

- x:

  A
  [`gdal_config_opts()`](http://docs.jimbrig.com/gdalvector/reference/gdal_config_opts.md)
  or
  [`gdal_vsi_opts()`](http://docs.jimbrig.com/gdalvector/reference/gdal_vsi_opts.md)
  object.

- ...:

  Passed to methods.

## Value

A named character vector.

## Examples

``` r
as_config_option(gdal_config_opts(CPL_DEBUG = "ON"))
#> CPL_DEBUG 
#>      "ON" 
```
