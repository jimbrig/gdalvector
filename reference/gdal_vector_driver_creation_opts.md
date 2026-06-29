# GDAL Vector Driver Creation Options

Accessors for a driver's creation options, parsed from both the
dataset-level (`DMD_CREATIONOPTIONLIST`, `--co`) and layer-level
(`DS_LAYER_CREATIONOPTIONLIST`, `--lco`) metadata. Use `sub_type` to
restrict to one level.

- `gdal_vector_driver_creation_opts()`: the creation-option table for
  `driver`.

- `gdal_vector_driver_creation_opts_defaults()`: name to default (all,
  or one when `opt_name` given).

- `gdal_vector_driver_creation_opts_values()`: name to allowed values
  (only constrained options).

- `gdal_vector_driver_creation_opts_types()`: name to `data_type`.

## Usage

``` r
gdal_vector_driver_creation_opts(driver, sub_type = NULL)

gdal_vector_driver_creation_opts_defaults(
  driver,
  opt_name = NULL,
  sub_type = NULL
)

gdal_vector_driver_creation_opts_values(
  driver,
  opt_name = NULL,
  sub_type = NULL
)

gdal_vector_driver_creation_opts_types(driver, sub_type = NULL)
```

## Arguments

- driver:

  Character scalar GDAL driver short name.

- sub_type:

  Optional creation level to restrict to: `"dataset"` or `"layer"`.

- opt_name:

  Optional single option name. When supplied, returns the value for that
  option only; otherwise returns the full named result.

## Value

A
[`tibble::tibble()`](https://tibble.tidyverse.org/reference/tibble.html),
named character vector, or named list (see
[`gdal_vector_driver_opts()`](http://docs.jimbrig.com/gdalvector/reference/gdal_vector_driver_opts.md)).

## See also

[`gdal_creation_opts()`](http://docs.jimbrig.com/gdalvector/reference/gdal_creation_opts.md),
[`gdal_vector_driver_opts()`](http://docs.jimbrig.com/gdalvector/reference/gdal_vector_driver_opts.md)

## Examples

``` r
gdal_vector_driver_creation_opts("Parquet", sub_type = "layer")
#> Error in gdal_vector_driver_opts(driver, type = "creation", sub_type = sub_type): `driver` must be a valid GDAL driver. Run `gdal_drivers_list()` for
#> available options.
gdal_vector_driver_creation_opts_values("GPKG", sub_type = "layer")
#> $ASPATIAL_VARIANT
#> [1] "GPKG_ATTRIBUTES" "NOT_REGISTERED" 
#> 
#> $DATETIME_PRECISION
#> [1] "AUTO"        "MILLISECOND" "SECOND"      "MINUTE"     
#> 
#> $GEOMETRY_NULLABLE
#> [1] "YES" "NO" 
#> 
#> $OVERWRITE
#> [1] "YES" "NO" 
#> 
#> $PRECISION
#> [1] "YES" "NO" 
#> 
#> $SPATIAL_INDEX
#> [1] "YES" "NO" 
#> 
#> $TRUNCATE_FIELDS
#> [1] "YES" "NO" 
#> 
```
