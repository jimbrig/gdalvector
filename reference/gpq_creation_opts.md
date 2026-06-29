# GeoParquet Creation Options

Construct a layer-level
[`gdal_creation_opts()`](http://docs.jimbrig.com/gdalvector/reference/gdal_creation_opts.md)
object for the `Parquet` (GeoParquet) driver. Only options you supply
are emitted; enumerated values are validated against the driver
metadata.

## Usage

``` r
gpq_creation_opts(
  compression = NULL,
  compression_level = NULL,
  geometry_encoding = NULL,
  row_group_size = NULL,
  geometry_name = NULL,
  fid = NULL,
  polygon_orientation = NULL,
  edges = NULL,
  creator = NULL,
  write_covering_bbox = NULL,
  covering_bbox_name = NULL,
  use_parquet_geo_types = NULL,
  sort_by_bbox = NULL,
  timestamp_with_offset = NULL,
  coordinate_precision = NULL,
  ...,
  .set_defaults = FALSE
)
```

## Arguments

- compression:

  Value for `COMPRESSION`. One of
  `NONE`/`SNAPPY`/`GZIP`/`BROTLI`/`ZSTD`/ `LZ4_RAW`/`LZ4_HADOOP`
  (available values depend on how the Parquet library was built). GDAL
  default `"SNAPPY"` when available, otherwise `NONE`.

- compression_level:

  Value for `COMPRESSION_LEVEL` (GDAL \>= 3.12). Codec-dependent
  integer.

- geometry_encoding:

  Value for `GEOMETRY_ENCODING`. One of `WKB`/`WKT`/`GEOARROW`/
  `GEOARROW_INTERLEAVED`. GDAL default `"WKB"` (recommended for
  interoperability).

- row_group_size:

  Value for `ROW_GROUP_SIZE` (maximum rows per group). GDAL default
  `65536`.

- geometry_name:

  Value for `GEOMETRY_NAME`. GDAL default `"geometry"`.

- fid:

  Value for `FID` (name of the FID column to create; if unset, no FID
  column is created).

- polygon_orientation:

  Value for `POLYGON_ORIENTATION`. One of `COUNTERCLOCKWISE`/
  `UNMODIFIED`. GDAL default `"COUNTERCLOCKWISE"`.

- edges:

  Value for `EDGES`. One of `PLANAR`/`SPHERICAL`. GDAL default
  `"PLANAR"`.

- creator:

  Value for `CREATOR` (name of the creating application).

- write_covering_bbox:

  Value for `WRITE_COVERING_BBOX` (GDAL \>= 3.9). One of
  `AUTO`/`YES`/`NO` (logical coerced); write per-row
  `xmin/ymin/xmax/ymax` bounding-box columns for faster spatial
  filtering. GDAL default `"AUTO"`.

- covering_bbox_name:

  Value for `COVERING_BBOX_NAME` (GDAL \>= 3.13). Defaults to the
  geometry column name suffixed with `_bbox`.

- use_parquet_geo_types:

  Value for `USE_PARQUET_GEO_TYPES` (GDAL \>= 3.12; requires libarrow
  \>= 21). One of `YES`/`NO`/`ONLY`. GDAL default `"NO"`.

- sort_by_bbox:

  Value for `SORT_BY_BBOX` (GDAL \>= 3.9; logical -\> `"YES"`/`"NO"`).
  Spatially order features (via a temporary GeoPackage) for faster
  spatial filtering. GDAL default `"NO"`.

- timestamp_with_offset:

  Value for `TIMESTAMP_WITH_OFFSET` (GDAL \>= 3.13). One of
  `AUTO`/`YES`/`NO`. GDAL default `"AUTO"`.

- coordinate_precision:

  Value for `COORDINATE_PRECISION` (number of decimals for coordinates;
  only for `GEOMETRY_ENCODING=WKT`).

- ...:

  Additional `NAME = value` options passed through verbatim alongside
  the typed arguments. They are coerced and validated against the driver
  metadata in the same way, and take precedence over a typed argument
  that sets the same option.

- .set_defaults:

  Logical. If `TRUE`, options left unset (`NULL`) are filled with the
  driver's documented GDAL metadata defaults (via the relevant
  `gdal_vector_driver_*_opts_defaults()`); user-supplied values always
  take precedence. Defaults to `FALSE`.

## Value

A layer-level
[`gdal_creation_opts()`](http://docs.jimbrig.com/gdalvector/reference/gdal_creation_opts.md)
object for the `Parquet` driver.

## Distributing GeoParquet

Following the OGC *Best Practices for Distributing GeoParquet*, good
defaults for distribution are `ZSTD` compression at a moderate level, a
row-group size around 50000-150000, the per-row bounding-box covering
columns enabled, and spatially ordered features:

    gpq_creation_opts(
      compression = "ZSTD",
      compression_level = 15,
      row_group_size = 100000,
      write_covering_bbox = TRUE,
      sort_by_bbox = TRUE
    )

## See also

[`gpq_open_opts()`](http://docs.jimbrig.com/gdalvector/reference/gpq_open_opts.md),
[`gdal_creation_opts()`](http://docs.jimbrig.com/gdalvector/reference/gdal_creation_opts.md)

- [GeoParquet Home Page](https://geoparquet.org/)

- [(Geo)Parquet GDAL
  Driver](https://gdal.org/en/stable/drivers/vector/parquet.html)

  - [(Geo)Parquet GDAL Layer Creation
    Options](https://gdal.org/en/stable/drivers/vector/parquet.html#layer-creation-options)

  - [(Geo)Parquet GDAL Open
    Options](https://gdal.org/en/stable/drivers/vector/parquet.html#open-options)

- [Best Practices for Distributing
  GeoParquet](https://github.com/opengeospatial/geoparquet/blob/main/format-specs/distributing-geoparquet.md)

## Examples

``` r
gpq_creation_opts(compression = "ZSTD", geometry_encoding = "WKB")
#> Error in gpq_creation_opts(compression = "ZSTD", geometry_encoding = "WKB"): `driver` must be a valid GDAL driver. Run `gdal_drivers_list()` for
#> available options.
```
