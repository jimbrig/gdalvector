# GeoParquet Schema

Read the tidied Parquet schema as a tibble: one row per leaf column with
its Parquet physical type, converted/logical types, repetition, mapped R
type, and (for geometry columns) the encoding and geometry types from
the `geo` metadata. For a high-level summary instead of the full table,
see
[`gpq_schema_info()`](http://docs.jimbrig.com/gdalvector/reference/gpq_schema_info.md).

## Usage

``` r
gpq_schema(gpq_path)
```

## Arguments

- gpq_path:

  Path to a (Geo)Parquet (`*.parquet`) file.

## Value

A
[`tibble::tibble()`](https://tibble.tidyverse.org/reference/tibble.html)
with columns `id`, `name`, `parquet_type`, `converted_type`,
`logical_type`, `repetition`, `r_type`, and `info`.

## Examples

``` r
f <- system.file("extdata/atlanta/atlanta.parquet", package = "gdalvector")
gpq_schema(f)
#> # A tibble: 6 × 8
#>      id name    parquet_type converted_type logical_type repetition r_type info 
#>   <int> <chr>   <chr>        <chr>          <chr>        <chr>      <chr>  <chr>
#> 1     1 OGC_FID INT64        INT_64         NA           OPTIONAL   double NA   
#> 2     2 source… BYTE_ARRAY   UTF8           NA           OPTIONAL   chara… NA   
#> 3     3 geoid   BYTE_ARRAY   UTF8           NA           OPTIONAL   chara… NA   
#> 4     4 state_… BYTE_ARRAY   UTF8           NA           OPTIONAL   chara… NA   
#> 5     5 county… BYTE_ARRAY   UTF8           NA           OPTIONAL   chara… NA   
#> 6     6 geom    BYTE_ARRAY   NA             UNKNOWN()    OPTIONAL   blob   WKB …
```
