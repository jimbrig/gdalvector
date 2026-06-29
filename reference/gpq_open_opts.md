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
  ...,
  .set_defaults = FALSE
)
```

## Arguments

- geom_possible_names:

  Value for `GEOM_POSSIBLE_NAMES` (GDAL \>= 3.8). Comma-separated list
  of candidate geometry column names, used only for files without
  GeoParquet metadata. GDAL default
  `"geometry,wkb_geometry,wkt_geometry"`.

- crs:

  Value for `CRS` (GDAL \>= 3.8). Set or override the CRS of geometry
  columns, typically `"AUTH:CODE"` (e.g. `"EPSG:4326"`), or a PROJ/WKT
  CRS string.

- lists_as_string_json:

  Value for `LISTS_AS_STRING_JSON` (GDAL \>= 3.12.1; logical -\>
  `"YES"`/`"NO"`). Report lists of strings/integers/reals as
  `String(JSON)` fields. GDAL default `"NO"`.

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
#> <gdal_open_opts/gdal_opts>
#> ℹ Driver: Parquet
#> ℹ Open Options: CRS=EPSG:4326
#> ℹ Command Line: --input-format 'Parquet' --open-option 'CRS=EPSG:4326'
```
