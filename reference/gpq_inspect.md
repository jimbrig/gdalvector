# Comprehensive GeoParquet Introspection

Assemble
[`gpq_file_info()`](http://docs.jimbrig.com/gdalvector/reference/gpq_file_info.md),
[`gpq_schema_info()`](http://docs.jimbrig.com/gdalvector/reference/gpq_schema_info.md),
[`gpq_row_groups()`](http://docs.jimbrig.com/gdalvector/reference/gpq_row_groups.md)
and
[`gpq_geo_metadata()`](http://docs.jimbrig.com/gdalvector/reference/gpq_geo_metadata.md)
into a single object.

## Usage

``` r
gpq_inspect(gpq_path)
```

## Arguments

- gpq_path:

  Path to a (Geo)Parquet (`*.parquet`) file.

## Value

A `gpq_inspect` object (a list) with `file_info`, `schema`, `row_groups`
and `geo_metadata` elements.

## Examples

``` r
f <- system.file("extdata/atlanta/atlanta.parquet", package = "gdalvector")
gpq_inspect(f)
#> <gpq_inspect/list>
#> 
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
#> 
#> <gpq_schema_info/list>
#> • Leaf columns: 6
#> • Struct nodes: —
#> • Geometry: "geom (WKB MultiPolygon)"
#> Parquet types:
#> • BYTE_ARRAY: 5
#> • INT64: 1
#> Full column table via `gpq_schema()`
#> 
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
#> 
#> <gpq_geo_metadata/list>
#> GeoParquet:
#> • Version: "2.0.0"
#> • Primary column: "geom"
#> • Encoding: "WKB"
#> • Geometry types: "MultiPolygon"
#> • Orientation: —
#> • Edges: —
#> • Bounding box: -84.7884562, 33.5299127, -84.3444261, and 33.7876275
#> CRS:
#> • Type: "PROJJSON"
#> • Name: "WGS 84"
#> • Authority: "EPSG:4326"
#> 
```
