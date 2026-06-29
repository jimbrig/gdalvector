# GeoParquet Open Options

Construct a
[`gdal_open_opts()`](http://docs.jimbrig.com/gdalvector/reference/gdal_open_opts.md)
object for the `Parquet` (GeoParquet) driver.

## Usage

``` r
gpq_open_opts(
  geom_possible_names = NULL,
  crs = NULL,
  lists_as_string_json = NULL,
  .set_defaults = FALSE
)
```

## Arguments

- geom_possible_names:

  Value for `GEOM_POSSIBLE_NAMES` (comma-separated candidate geometry
  column names).

- crs:

  Value for `CRS` (override CRS for geometry columns, e.g.
  `"EPSG:4326"`).

- lists_as_string_json:

  Value for `LISTS_AS_STRING_JSON` (logical -\> `"YES"`/`"NO"`).

- .set_defaults:

  Logical. If `TRUE`, options left unset (`NULL`) are filled with the
  driver's documented GDAL metadata defaults (via the relevant
  `gdal_vector_driver_*_opts_defaults()`); user-supplied values always
  take precedence. Defaults to `FALSE`.

## Value

A
[`gdal_open_opts()`](http://docs.jimbrig.com/gdalvector/reference/gdal_open_opts.md)
object for the `Parquet` driver.

## See also

[`gpq_creation_opts()`](http://docs.jimbrig.com/gdalvector/reference/gpq_creation_opts.md),
[`gdal_open_opts()`](http://docs.jimbrig.com/gdalvector/reference/gdal_open_opts.md)

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
gpq_open_opts(crs = "EPSG:4326")
#> Error in gdal_vector_driver_opts(driver, type = "open"): `driver` must be a valid GDAL driver. Run `gdal_drivers_list()` for
#> available options.
```
