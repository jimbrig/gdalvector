# Coerce to GDAL Creation Options

Coerce a named list, a `KEY=VALUE` character vector, a driver-metadata
tibble, or an existing `gdal_creation_opts` to the
[`gdal_creation_opts()`](http://docs.jimbrig.com/gdalvector/reference/gdal_creation_opts.md)
class.

## Usage

``` r
as_gdal_creation_opts(
  x,
  ...,
  driver = NULL,
  level = c("layer", "dataset"),
  call = rlang::caller_env()
)

# Default S3 method
as_gdal_creation_opts(
  x,
  ...,
  driver = NULL,
  level = c("layer", "dataset"),
  call = rlang::caller_env()
)

# S3 method for class 'gdal_creation_opts'
as_gdal_creation_opts(
  x,
  ...,
  driver = NULL,
  level = c("layer", "dataset"),
  call = rlang::caller_env()
)

# S3 method for class 'list'
as_gdal_creation_opts(
  x,
  ...,
  driver = NULL,
  level = c("layer", "dataset"),
  call = rlang::caller_env()
)

# S3 method for class 'character'
as_gdal_creation_opts(
  x,
  ...,
  driver = NULL,
  level = c("layer", "dataset"),
  call = rlang::caller_env()
)

# S3 method for class 'tbl_df'
as_gdal_creation_opts(
  x,
  ...,
  driver = NULL,
  level = c("layer", "dataset"),
  call = rlang::caller_env()
)
```

## Arguments

- x:

  Object to coerce.

- ...:

  Unused; for method extensibility.

- driver:

  Optional GDAL driver short name to attach.

- level:

  Creation-option level: `"layer"` (`--lco`) or `"dataset"` (`--co`).

- call:

  The execution environment of a currently running function, e.g.
  `caller_env()`. The function will be mentioned in error messages as
  the source of the error. See the `call` argument of
  [`abort()`](https://rlang.r-lib.org/reference/abort.html) for more
  information.

## Value

A
[`gdal_creation_opts()`](http://docs.jimbrig.com/gdalvector/reference/gdal_creation_opts.md)
object.
