# GeoParquet and GDAL Metadata

Read and parse the GeoParquet (`geo`) and GDAL (`gdal:creation-options`,
`gdal:schema`) key-value metadata, plus any `pandas` metadata. Geometry
column metadata is accessed via the declared `primary_column`, and the
`crs` field is normalized to a `type`/`name`/`authority` summary across
its three forms: absent (`NULL`), a PROJJSON object, or a WKT string.

## Usage

``` r
gpq_geo_metadata(gpq_path)
```

## Arguments

- gpq_path:

  Path to a (Geo)Parquet (`*.parquet`) file.

## Value

A `gpq_geo_metadata` object (a list). When no `geo` metadata is present,
`is_geoparquet` is `FALSE` and the geospatial fields are omitted.

## Examples

``` r
f <- system.file("extdata/atlanta/atlanta.parquet", package = "gdalvector")
gpq_geo_metadata(f)
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
```
