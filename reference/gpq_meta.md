# GeoParquet Metadata

A family of functions for reading (Geo)Parquet metadata directly from
the file footer; no data pages are read. Each returns a classed list
with [`format()`](https://rdrr.io/r/base/format.html) and
[`print()`](https://rdrr.io/r/base/print.html) methods:

- [`gpq_file_info()`](http://docs.jimbrig.com/gdalvector/reference/gpq_file_info.md):
  file-level summary (sizes, versions, row groups).

- [`gpq_schema_info()`](http://docs.jimbrig.com/gdalvector/reference/gpq_schema_info.md):
  the Parquet schema (leaf columns, struct nodes, logical types).

- [`gpq_row_groups()`](http://docs.jimbrig.com/gdalvector/reference/gpq_row_groups.md):
  row group and column chunk statistics, with decoded min/max values.

- [`gpq_geo_metadata()`](http://docs.jimbrig.com/gdalvector/reference/gpq_geo_metadata.md):
  the GeoParquet (`geo`) and GDAL (`gdal:*`) key-value metadata.

- [`gpq_inspect()`](http://docs.jimbrig.com/gdalvector/reference/gpq_inspect.md):
  all of the above, assembled into one object.

The footer is read with
[`nanoparquet::read_parquet_metadata()`](https://nanoparquet.r-lib.org/reference/read_parquet_metadata.html)
and embedded JSON metadata is parsed with
[`yyjsonr::read_json_str()`](https://coolbutuseless.github.io/package/yyjsonr/reference/read_json_str.html).

## See also

- [GeoParquet Home Page](https://geoparquet.org/)

- [(Geo)Parquet GDAL
  Driver](https://gdal.org/en/stable/drivers/vector/parquet.html)

  - [(Geo)Parquet GDAL Layer Creation
    Options](https://gdal.org/en/stable/drivers/vector/parquet.html#layer-creation-options)

  - [(Geo)Parquet GDAL Open
    Options](https://gdal.org/en/stable/drivers/vector/parquet.html#open-options)

- [Best Practices for Distributing
  GeoParquet](https://github.com/opengeospatial/geoparquet/blob/main/format-specs/distributing-geoparquet.md)
