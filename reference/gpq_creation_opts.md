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
  .set_defaults = FALSE
)
```

## Arguments

- compression:

  Value for `COMPRESSION` (e.g. `"ZSTD"`, `"SNAPPY"`).

- compression_level:

  Value for `COMPRESSION_LEVEL` (codec-dependent integer).

- geometry_encoding:

  Value for `GEOMETRY_ENCODING` (e.g. `"WKB"`, `"GEOARROW"`).

- row_group_size:

  Value for `ROW_GROUP_SIZE` (max rows per group).

- geometry_name:

  Value for `GEOMETRY_NAME`.

- fid:

  Value for `FID`.

- polygon_orientation:

  Value for `POLYGON_ORIENTATION`.

- edges:

  Value for `EDGES` (`"PLANAR"`/`"SPHERICAL"`).

- creator:

  Value for `CREATOR`.

- write_covering_bbox:

  Value for `WRITE_COVERING_BBOX` (logical -\> `"YES"`/`"NO"`).

- covering_bbox_name:

  Value for `COVERING_BBOX_NAME`.

- use_parquet_geo_types:

  Value for `USE_PARQUET_GEO_TYPES`.

- sort_by_bbox:

  Value for `SORT_BY_BBOX` (logical -\> `"YES"`/`"NO"`).

- timestamp_with_offset:

  Value for `TIMESTAMP_WITH_OFFSET`.

- coordinate_precision:

  Value for `COORDINATE_PRECISION` (only for `GEOMETRY_ENCODING=WKT`).

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
#> Error in gdal_vector_driver_opts(driver, type = "creation", sub_type = sub_type): `driver` must be a valid GDAL driver. Run `gdal_drivers_list()` for
#> available options.
```
