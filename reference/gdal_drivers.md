# GDAL Drivers

Query the GDAL drivers registered in the active GDAL build.

- `gdal_drivers()`: returns a normalized
  [`tibble::tibble()`](https://tibble.tidyverse.org/reference/tibble.html)
  of driver metadata (identity, capabilities, supported extensions and
  SQL dialects), optionally filtered by a name pattern.

- `gdal_driver_names()`: returns just the short driver names.

The driver table is built once from
[`gdalraster::gdal_formats()`](https://firelab.github.io/gdalraster/reference/gdal_formats.html)
and cached for the session.

## Usage

``` r
gdal_drivers(pattern = NULL, ignore_case = TRUE)

gdal_driver_names(pattern = NULL)
```

## Arguments

- pattern:

  Optional character vector of regular-expression patterns. Drivers
  whose short or long name matches any pattern are returned. `NULL`
  (default) returns all drivers.

- ignore_case:

  Logical; match `pattern` case-insensitively. Defaults to `TRUE`.

## Value

- `gdal_drivers()`: a
  [`tibble::tibble()`](https://tibble.tidyverse.org/reference/tibble.html)
  with one row per driver.

- `gdal_driver_names()`: a character vector of short driver names.

## See also

[`gdal_vector_driver_opts()`](http://docs.jimbrig.com/gdalvector/reference/gdal_vector_driver_opts.md),
[`gdal_vector_driver_capabilities()`](http://docs.jimbrig.com/gdalvector/reference/gdal_vector_driver_capabilities.md)

## Examples

``` r
gdal_drivers()
#> # A tibble: 216 × 14
#>    driver short_name long_name extensions is_vector is_raster is_multidim_raster
#>    <chr>  <chr>      <chr>     <list>     <lgl>     <lgl>     <lgl>             
#>  1 VRT    VRT        Virtual … <chr [1]>  FALSE     TRUE      TRUE              
#>  2 DERIV… DERIVED    Derived … <chr [0]>  FALSE     TRUE      FALSE             
#>  3 GTiff  GTiff      GeoTIFF   <chr [2]>  FALSE     TRUE      FALSE             
#>  4 COG    COG        Cloud op… <chr [2]>  FALSE     TRUE      FALSE             
#>  5 NITF   NITF       National… <chr [1]>  FALSE     TRUE      FALSE             
#>  6 RPFTOC RPFTOC     Raster P… <chr [1]>  FALSE     TRUE      FALSE             
#>  7 ECRGT… ECRGTOC    ECRG TOC… <chr [1]>  FALSE     TRUE      FALSE             
#>  8 HFA    HFA        Erdas Im… <chr [1]>  FALSE     TRUE      FALSE             
#>  9 SAR_C… SAR_CEOS   CEOS SAR… <chr [0]>  FALSE     TRUE      FALSE             
#> 10 CEOS   CEOS       CEOS Ima… <chr [0]>  FALSE     TRUE      FALSE             
#> # ℹ 206 more rows
#> # ℹ 7 more variables: is_geography_network <lgl>, read_write <chr>,
#> #   supports_vsi <lgl>, supports_subdatasets <lgl>,
#> #   supports_multiple_layers <lgl>, supports_field_domains <lgl>,
#> #   sql_dialects <list>
gdal_drivers(c("parquet", "geojson"))
#> # A tibble: 2 × 14
#>   driver  short_name long_name extensions is_vector is_raster is_multidim_raster
#>   <chr>   <chr>      <chr>     <list>     <lgl>     <lgl>     <lgl>             
#> 1 GeoJSON GeoJSON    GeoJSON   <chr [2]>  TRUE      FALSE     FALSE             
#> 2 GeoJSO… GeoJSONSeq GeoJSON … <chr [2]>  TRUE      FALSE     FALSE             
#> # ℹ 7 more variables: is_geography_network <lgl>, read_write <chr>,
#> #   supports_vsi <lgl>, supports_subdatasets <lgl>,
#> #   supports_multiple_layers <lgl>, supports_field_domains <lgl>,
#> #   sql_dialects <list>
gdal_driver_names("gpkg")
#> [1] "GPKG"
```
