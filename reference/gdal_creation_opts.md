# GDAL Creation Options

Construct a `gdal_creation_opts()` object from `NAME = value` pairs. The
`level` controls whether these are dataset-creation options (`--co`) or
layer-creation options (`--lco`, the default).

## Usage

``` r
gdal_creation_opts(
  ...,
  driver = NULL,
  level = c("layer", "dataset"),
  .set_defaults = FALSE
)
```

## Arguments

- ...:

  Named creation options (`NAME = value`). Logical values are coerced to
  `"YES"`/`"NO"`.

- driver:

  Optional GDAL driver short name to associate.

- level:

  Creation-option level, `"layer"` (default) or `"dataset"`.

- .set_defaults:

  Logical. If `TRUE`, options left unset (`NULL`) are filled with the
  driver's documented GDAL metadata defaults (via the relevant
  `gdal_vector_driver_*_opts_defaults()`); user-supplied values always
  take precedence. Defaults to `FALSE`.

## Value

A `gdal_creation_opts()` object.

## Examples

``` r
gdal_creation_opts(COMPRESSION = "ZSTD", driver = "Parquet")
#> Error in gdal_vector_driver_opts(driver, type = "creation", sub_type = sub_type): `driver` must be a valid GDAL driver. Run `gdal_drivers_list()` for
#> available options.
```
