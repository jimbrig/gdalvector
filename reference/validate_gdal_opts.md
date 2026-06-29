# Validate GDAL Options Against Driver Metadata

Check a
[`gdal_opts()`](http://docs.jimbrig.com/gdalvector/reference/gdal_opts.md)
object against its driver's registered metadata: unknown option names,
invalid enumerated (`string-select`) values, and invalid boolean values.
Validation is advisory and non-blocking - it warns (with classed
conditions) and returns a logical, leaving the decision to act at the
call site.

## Usage

``` r
validate_gdal_opts(x, driver = attr(x, "driver"), call = rlang::caller_env())
```

## Arguments

- x:

  A
  [`gdal_open_opts()`](http://docs.jimbrig.com/gdalvector/reference/gdal_open_opts.md),
  [`gdal_creation_opts()`](http://docs.jimbrig.com/gdalvector/reference/gdal_creation_opts.md),
  or
  [`gdal_config_opts()`](http://docs.jimbrig.com/gdalvector/reference/gdal_config_opts.md)
  object.

- driver:

  GDAL driver short name; defaults to the object's `driver` attribute.

- call:

  The execution environment of a currently running function, e.g.
  `caller_env()`. The function will be mentioned in error messages as
  the source of the error. See the `call` argument of
  [`abort()`](https://rlang.r-lib.org/reference/abort.html) for more
  information.

## Value

Invisibly, `TRUE` if valid, `FALSE` if any problems were found, or `NA`
if validation could not be performed (no driver).

## Examples

``` r
validate_gdal_opts(gdal_open_opts(LIST_ALL_TABLES = "NO", driver = "GPKG"))
```
