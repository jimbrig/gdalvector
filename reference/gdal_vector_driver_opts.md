# GDAL Vector Driver Options

Look up the documented options for the core supported vector drivers
(see
[GDAL_VECTOR_DRIVERS](http://docs.jimbrig.com/gdalvector/reference/gdal_drivers.md)),
drawn from the merged option table assembled at package load
(driver-metadata XML for open/creation options plus the curated
configuration options).

- `gdal_vector_driver_opts()`: the full option table, optionally
  filtered by `type`, `sub_type`, and `scope`.

- `gdal_vector_driver_opt_defaults()`: a named vector mapping option
  name to its declared default.

- `gdal_vector_driver_opt_values()`: a named list mapping option name to
  its allowed values (booleans expanded to `c("YES", "NO")`); only
  options that declare a constrained set appear.

- `gdal_vector_driver_opt_types()`: a named vector mapping option name
  to its `data_type`.

## Usage

``` r
gdal_vector_driver_opts(
  driver = NULL,
  type = NULL,
  sub_type = NULL,
  scope = NULL
)

gdal_vector_driver_opt_defaults(
  driver,
  type = NULL,
  sub_type = NULL,
  scope = NULL
)

gdal_vector_driver_opt_values(
  driver,
  type = NULL,
  sub_type = NULL,
  scope = NULL
)

gdal_vector_driver_opt_types(
  driver,
  type = NULL,
  sub_type = NULL,
  scope = NULL
)
```

## Arguments

- driver:

  Character scalar GDAL driver short name (e.g. `"GPKG"`). When `NULL`
  (only for `gdal_vector_driver_opts()`), the options for all core
  vector drivers are returned.

- type:

  Optional option channel to filter to: one of `"config"`, `"open"`, or
  `"creation"`.

- sub_type:

  Optional creation sub-type to filter to: `"dataset"` or `"layer"`.

- scope:

  Optional data-type scope to filter to (e.g. `"vector"`, `"all"`).

## Value

- `gdal_vector_driver_opts()`: a
  [`tibble::tibble()`](https://tibble.tidyverse.org/reference/tibble.html)
  of options.

- `gdal_vector_driver_opt_defaults()` /
  `gdal_vector_driver_opt_types()`: a named character vector.

- `gdal_vector_driver_opt_values()`: a named list of character vectors.

## See also

[`gdal_vector_driver_open_opts()`](http://docs.jimbrig.com/gdalvector/reference/gdal_vector_driver_open_opts.md),
[`gdal_vector_driver_creation_opts()`](http://docs.jimbrig.com/gdalvector/reference/gdal_vector_driver_creation_opts.md),
[`gdal_vector_driver_config_opts()`](http://docs.jimbrig.com/gdalvector/reference/gdal_vector_driver_config_opts.md)

## Examples

``` r
gdal_vector_driver_opts("GPKG", type = "open")
#> # A tibble: 4 × 9
#>   driver type  sub_type name          description scope default values data_type
#>   <chr>  <chr> <chr>    <chr>         <chr>       <chr> <chr>   <list> <chr>    
#> 1 GPKG   open  NA       IMMUTABLE     Whether th… all   NA      <chr>  boolean  
#> 2 GPKG   open  NA       LIST_ALL_TAB… Whether al… vect… AUTO    <chr>  string-s…
#> 3 GPKG   open  NA       NOLOCK        Whether th… all   NA      <chr>  boolean  
#> 4 GPKG   open  NA       PRELUDE_STAT… SQL statem… rast… NA      <chr>  string   
gdal_vector_driver_opt_defaults("GPKG", type = "open")
#> LIST_ALL_TABLES 
#>          "AUTO" 
```
