# GDAL Open Options

Construct a `gdal_open_opts()` object from `NAME = value` pairs (the
GDAL `--oo` / `GDALOpenEx()` open-option channel).

## Usage

``` r
gdal_open_opts(..., driver = NULL, .set_defaults = FALSE)
```

## Arguments

- ...:

  Named open options (`NAME = value`). Logical values are coerced to
  `"YES"`/`"NO"`.

- driver:

  Optional GDAL driver short name to associate.

- .set_defaults:

  Logical. If `TRUE`, options left unset (`NULL`) are filled with the
  driver's documented GDAL metadata defaults (via the relevant
  `gdal_vector_driver_*_opts_defaults()`); user-supplied values always
  take precedence. Defaults to `FALSE`.

## Value

A `gdal_open_opts()` object.

## Examples

``` r
gdal_open_opts(LIST_ALL_TABLES = FALSE, driver = "GPKG")
#> <gdal_open_opts/gdal_opts>
#> ℹ Driver: GPKG
#> ℹ Open Options: LIST_ALL_TABLES=NO
#> ℹ Command Line: --input-format 'GPKG' --open-option 'LIST_ALL_TABLES=NO'
```
