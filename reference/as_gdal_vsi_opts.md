# Coerce to GDAL VSI Options

Coerce a named list, a `KEY=VALUE` character vector, or an existing
`gdal_vsi_opts` to the
[`gdal_vsi_opts()`](http://docs.jimbrig.com/gdalvector/reference/gdal_vsi_opts.md)
class. VSI options are path-scoped, config-like settings applied via
[`gdalraster::vsi_set_path_option()`](https://firelab.github.io/gdalraster/reference/vsi_set_path_option.html).

## Usage

``` r
as_gdal_vsi_opts(x, ..., vsi_path = NULL, call = rlang::caller_env())

# Default S3 method
as_gdal_vsi_opts(x, ..., vsi_path = NULL, call = rlang::caller_env())

# S3 method for class 'gdal_vsi_opts'
as_gdal_vsi_opts(x, ..., vsi_path = NULL, call = rlang::caller_env())

# S3 method for class 'list'
as_gdal_vsi_opts(x, ..., vsi_path = NULL, call = rlang::caller_env())

# S3 method for class 'character'
as_gdal_vsi_opts(x, ..., vsi_path = NULL, call = rlang::caller_env())
```

## Arguments

- x:

  Object to coerce.

- ...:

  Unused; for method extensibility.

- vsi_path:

  Optional VSI path prefix the options apply to (e.g.
  `"/vsis3/bucket"`).

- call:

  The execution environment of a currently running function, e.g.
  `caller_env()`. The function will be mentioned in error messages as
  the source of the error. See the `call` argument of
  [`abort()`](https://rlang.r-lib.org/reference/abort.html) for more
  information.

## Value

A
[`gdal_vsi_opts()`](http://docs.jimbrig.com/gdalvector/reference/gdal_vsi_opts.md)
object.
