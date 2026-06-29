# GDAL Vector Driver Open Options

Accessors for a driver's open options (the `--oo` / `GDALOpenEx()`
channel), parsed from the driver's `DMD_OPENOPTIONLIST` metadata.

- `gdal_vector_driver_open_opts()`: the open-option table for `driver`.

- `gdal_vector_driver_open_opts_defaults()`: name to default (all, or
  one when `opt_name` given).

- `gdal_vector_driver_open_opts_values()`: name to allowed values (only
  constrained options).

- `gdal_vector_driver_open_opts_types()`: name to `data_type`.

## Usage

``` r
gdal_vector_driver_open_opts(driver)

gdal_vector_driver_open_opts_defaults(driver, opt_name = NULL)

gdal_vector_driver_open_opts_values(driver, opt_name = NULL)

gdal_vector_driver_open_opts_types(driver)
```

## Arguments

- driver:

  Character scalar GDAL driver short name.

- opt_name:

  Optional single option name. When supplied, returns the value for that
  option only; otherwise returns the full named result.

## Value

A
[`tibble::tibble()`](https://tibble.tidyverse.org/reference/tibble.html),
named character vector, or named list (see
[`gdal_vector_driver_opts()`](http://docs.jimbrig.com/gdalvector/reference/gdal_vector_driver_opts.md)).

## See also

[`gdal_open_opts()`](http://docs.jimbrig.com/gdalvector/reference/gdal_open_opts.md),
[`gdal_vector_driver_opts()`](http://docs.jimbrig.com/gdalvector/reference/gdal_vector_driver_opts.md)

## Examples

``` r
gdal_vector_driver_open_opts("GPKG")
#> # A tibble: 4 × 9
#>   driver type  sub_type name          description scope default values data_type
#>   <chr>  <chr> <chr>    <chr>         <chr>       <chr> <chr>   <list> <chr>    
#> 1 GPKG   open  NA       IMMUTABLE     Whether th… all   NA      <chr>  boolean  
#> 2 GPKG   open  NA       LIST_ALL_TAB… Whether al… vect… AUTO    <chr>  string-s…
#> 3 GPKG   open  NA       NOLOCK        Whether th… all   NA      <chr>  boolean  
#> 4 GPKG   open  NA       PRELUDE_STAT… SQL statem… rast… NA      <chr>  string   
gdal_vector_driver_open_opts_values("GPKG", "LIST_ALL_TABLES")
#> [1] "AUTO" "YES"  "NO"  
```
