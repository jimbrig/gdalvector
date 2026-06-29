# GDAL Vector Driver Configuration Options

Accessors for a driver's configuration options (the `--config` channel).
Configuration options are sourced from curated package data, since GDAL
does not expose them in driver metadata.

- `gdal_vector_driver_config_opts()`: the configuration-option table for
  `driver`.

- `gdal_vector_driver_config_opts_defaults()`: name to default (all, or
  one when `opt_name` given).

- `gdal_vector_driver_config_opts_values()`: name to allowed values
  (only constrained options).

- `gdal_vector_driver_config_opts_types()`: name to `data_type`.

## Usage

``` r
gdal_vector_driver_config_opts(driver)

gdal_vector_driver_config_opts_defaults(driver, opt_name = NULL)

gdal_vector_driver_config_opts_values(driver, opt_name = NULL)

gdal_vector_driver_config_opts_types(driver)
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

[`gdal_config_opts()`](http://docs.jimbrig.com/gdalvector/reference/gdal_config_opts.md),
[`gdal_vector_driver_opts()`](http://docs.jimbrig.com/gdalvector/reference/gdal_vector_driver_opts.md)

## Examples

``` r
gdal_vector_driver_config_opts("GPKG")
#> # A tibble: 8 × 9
#>   driver type   sub_type name         description scope default values data_type
#>   <chr>  <chr>  <chr>    <chr>        <chr>       <chr> <chr>   <list> <chr>    
#> 1 GPKG   config NA       OGR_CURRENT… "the drive… vect… NA      <chr>  NA       
#> 2 GPKG   config NA       OGR_GPKG_NU… "(GDAL >= … vect… NA      <chr>  NA       
#> 3 GPKG   config NA       OGR_SQLITE_… "increases… vect… NA      <chr>  NA       
#> 4 GPKG   config NA       OGR_SQLITE_… "can be us… vect… NA      <chr>  NA       
#> 5 GPKG   config NA       OGR_SQLITE_… "(GDAL >= … vect… NA      <chr>  string-l…
#> 6 GPKG   config NA       OGR_SQLITE_… "with this… vect… NA      <chr>  NA       
#> 7 GPKG   config NA       OGR_SQLITE_… "setting t… vect… NA      <chr>  NA       
#> 8 GPKG   config NA       SQLITE_USE_… "YES enabl… vect… NA      <chr>  boolean  
gdal_vector_driver_config_opts_values("GPKG")
#> $OGR_SQLITE_LOAD_EXTENSIONS
#> [1] "<extension1,...,extensionN>" "ENABLE_SQL_LOAD_EXTENSION"  
#> 
#> $SQLITE_USE_OGR_VFS
#> [1] "YES" "NO" 
#> 
```
