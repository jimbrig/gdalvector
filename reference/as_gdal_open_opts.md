# Coerce to GDAL Open Options

Coerce a named list, a `KEY=VALUE` character vector, a driver-metadata
tibble, or an existing `gdal_open_opts` to the
[`gdal_open_opts()`](http://docs.jimbrig.com/gdalvector/reference/gdal_open_opts.md)
class.

## Usage

``` r
as_gdal_open_opts(x, ..., driver = NULL, call = rlang::caller_env())

# Default S3 method
as_gdal_open_opts(x, ..., driver = NULL, call = rlang::caller_env())

# S3 method for class 'gdal_open_opts'
as_gdal_open_opts(x, ..., driver = NULL, call = rlang::caller_env())

# S3 method for class 'list'
as_gdal_open_opts(x, ..., driver = NULL, call = rlang::caller_env())

# S3 method for class 'character'
as_gdal_open_opts(x, ..., driver = NULL, call = rlang::caller_env())

# S3 method for class 'tbl_df'
as_gdal_open_opts(x, ..., driver = NULL, call = rlang::caller_env())
```

## Arguments

- x:

  Object to coerce.

- ...:

  Unused; for method extensibility.

- driver:

  Optional GDAL driver short name to attach.

- call:

  The execution environment of a currently running function, e.g.
  `caller_env()`. The function will be mentioned in error messages as
  the source of the error. See the `call` argument of
  [`abort()`](https://rlang.r-lib.org/reference/abort.html) for more
  information.

## Value

A
[`gdal_open_opts()`](http://docs.jimbrig.com/gdalvector/reference/gdal_open_opts.md)
object.
