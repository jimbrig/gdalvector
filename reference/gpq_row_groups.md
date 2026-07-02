# GeoParquet Row Groups and Statistics

Read row group and column chunk statistics. Parquet stores chunk min/max
statistics as raw bytes in the column's physical type; these are decoded
to R scalars and aggregated into a per-column summary across all row
groups.

## Usage

``` r
gpq_row_groups(gpq_path)
```

## Arguments

- gpq_path:

  Path to a (Geo)Parquet (`*.parquet`) file.

## Value

A `gpq_row_groups` object (a list) with:

- `source`, `path`: the file name and full path.

- `row_groups`: a per-row-group
  [`tibble::tibble()`](https://tibble.tidyverse.org/reference/tibble.html).

- `column_chunks`: the raw per-chunk
  [`tibble::tibble()`](https://tibble.tidyverse.org/reference/tibble.html)
  with leaf column names and decoded min/max appended.

- `col_summary`: a one-row-per-column
  [`tibble::tibble()`](https://tibble.tidyverse.org/reference/tibble.html)
  aggregated across all row groups.

## Examples

``` r
f <- system.file("extdata/atlanta/atlanta.parquet", package = "gdalvector")
gpq_row_groups(f)
#> <gpq_row_groups/list> (1 row group)
#> # A tibble: 6 × 10
#>   column col_name    type     codec num_values null_count min   max   compressed
#>    <int> <chr>       <chr>    <chr>      <dbl>      <dbl> <chr> <chr>      <byt>
#> 1      0 OGC_FID     INT64    ZSTD       44578          0 0     44,5…   46.02 kB
#> 2      1 source_fid  BYTE_AR… ZSTD       44578          0 0001… fffd…  930.22 kB
#> 3      2 geoid       BYTE_AR… ZSTD       44578          0 13089 13121      254 B
#> 4      3 state_fips  BYTE_AR… ZSTD       44578          0 13    13          69 B
#> 5      4 county_fips BYTE_AR… ZSTD       44578          0 089   121        250 B
#> 6      5 geom        BYTE_AR… ZSTD       44578          0 -     -        1.36 MB
#> # ℹ 1 more variable: uncompressed <byt>
```
