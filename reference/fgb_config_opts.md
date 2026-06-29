# FlatGeobuf Configuration Options

The `FlatGeobuf` driver exposes no documented configuration options.
This constructor exists for interface symmetry with the other driver
option families; it warns and returns an empty
[`gdal_config_opts()`](http://docs.jimbrig.com/gdalvector/reference/gdal_config_opts.md)
object.

## Usage

``` r
fgb_config_opts(...)
```

## Arguments

- ...:

  Ignored (no configuration options are available for this driver).

## Value

An (empty)
[`gdal_config_opts()`](http://docs.jimbrig.com/gdalvector/reference/gdal_config_opts.md)
object for the `FlatGeobuf` driver.

## See also

[`fgb_open_opts()`](http://docs.jimbrig.com/gdalvector/reference/fgb_open_opts.md),
[`fgb_creation_opts()`](http://docs.jimbrig.com/gdalvector/reference/fgb_creation_opts.md)

## Examples

``` r
fgb_config_opts()
#> Warning: The FlatGeobuf driver has no documented configuration options.
#> <gdal_config_opts/gdal_opts>
#> ℹ Driver: FlatGeobuf
#> ℹ No configuration options set.
```
