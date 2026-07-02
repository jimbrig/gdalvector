# GeoParquet File Info

Summarize file-level information about a (Geo)Parquet file from its
footer.

## Usage

``` r
gpq_file_info(gpq_path)
```

## Arguments

- gpq_path:

  Path to a (Geo)Parquet (`*.parquet`) file.

## Value

A `gpq_file_info` object (a list) with:

- `source`, `path`: the file name and full path.

- `file_size`: the file size in bytes.

- `parquet_version`, `geoparquet_version`: the format versions (the
  latter is `NA` for plain Parquet).

- `num_rows`, `num_cols`, `num_row_groups`: the row, column, and row
  group counts.

- `row_group_size`, `row_group_size_last`: the number of rows in the
  first and last row groups.

- `created_by`: the writing software.

- `kv_keys`: the key-value metadata keys present in the file.

## Examples

``` r
f <- system.file("extdata/atlanta/atlanta.parquet", package = "gdalvector")
gpq_file_info(f)
#> <gpq_file_info/list>
#> • Source: "atlanta.parquet"
#> • File size: 2.34 MB
#> • Parquet version: 1
#> • GeoParquet version: "2.0.0"
#> • Rows: 44578
#> • Columns: 6
#> • Row groups: 1
#> • Row group size: 44578
#> • Created by: "DuckDB version v1.5.1 (build 7dbb2e646f)"
#> • Metadata keys: "geo"
```
