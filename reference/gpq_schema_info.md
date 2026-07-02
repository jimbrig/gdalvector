# GeoParquet Schema Info

Summarize the Parquet schema of a (Geo)Parquet file: leaf column and
struct node counts, the geometry column(s), and the distribution of
Parquet physical types. The full per-column table is available from
[`gpq_schema()`](http://docs.jimbrig.com/gdalvector/reference/gpq_schema.md)
or the object's `columns` element.

## Usage

``` r
gpq_schema_info(gpq_path)
```

## Arguments

- gpq_path:

  Path to a (Geo)Parquet (`*.parquet`) file.

## Value

A `gpq_schema_info` object (a list) with `source`, `path`,
`struct_nodes`, `columns` (the
[`gpq_schema()`](http://docs.jimbrig.com/gdalvector/reference/gpq_schema.md)
tibble), and the `n_leaf`/`n_struct` counts.

## Examples

``` r
f <- system.file("extdata/atlanta/atlanta.parquet", package = "gdalvector")
gpq_schema_info(f)
#> <gpq_schema_info/list>
#> • Leaf columns: 6
#> • Struct nodes: —
#> • Geometry: "geom (WKB MultiPolygon)"
#> Parquet types:
#> • BYTE_ARRAY: 5
#> • INT64: 1
#> Full column table via `gpq_schema()`
```
