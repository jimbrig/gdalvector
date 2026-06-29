# OpenFileGDB Creation Options

Construct a layer-level
[`gdal_creation_opts()`](http://docs.jimbrig.com/gdalvector/reference/gdal_creation_opts.md)
object for the `OpenFileGDB` driver. Typed arguments cover the common
layer options; advanced coordinate-precision grid options (`XORIGIN`,
`XYSCALE`, `XYTOLERANCE`, `Z*`/`M*`) may be supplied through `...`.

## Usage

``` r
gdb_creation_opts(
  fid = NULL,
  geometry_name = NULL,
  geometry_nullable = NULL,
  configuration_keyword = NULL,
  target_arcgis_version = NULL,
  create_multipatch = NULL,
  create_shape_area_and_length_fields = NULL,
  time_in_utc = NULL,
  column_types = NULL,
  feature_dataset = NULL,
  layer_alias = NULL,
  documentation = NULL,
  ...,
  .set_defaults = FALSE
)
```

## Arguments

- fid:

  Name of the OID column (`FID`). GDAL default `"OBJECTID"`.

- geometry_name:

  Name of the geometry column (`GEOMETRY_NAME`). GDAL default `"SHAPE"`.

- geometry_nullable:

  Value for `GEOMETRY_NULLABLE` (logical -\> `"YES"`/`"NO"`).

- configuration_keyword:

  Value for `CONFIGURATION_KEYWORD` (storage configuration).

- target_arcgis_version:

  Value for `TARGET_ARCGIS_VERSION`.

- create_multipatch:

  Value for `CREATE_MULTIPATCH` (logical -\> `"YES"`/`"NO"`).

- create_shape_area_and_length_fields:

  Value for `CREATE_SHAPE_AREA_AND_LENGTH_FIELDS` (logical -\>
  `"YES"`/`"NO"`).

- time_in_utc:

  Value for `TIME_IN_UTC` (logical -\> `"YES"`/`"NO"`).

- column_types:

  Value for `COLUMN_TYPES` (e.g. `"field=fgdb_type,..."`).

- feature_dataset:

  Value for `FEATURE_DATASET`.

- layer_alias:

  Value for `LAYER_ALIAS`.

- documentation:

  Value for `DOCUMENTATION` (XML documentation string).

- ...:

  Additional `NAME = value` layer-creation options (e.g. coordinate-grid
  options).

- .set_defaults:

  Logical. If `TRUE`, options left unset (`NULL`) are filled with the
  driver's documented GDAL metadata defaults (via the relevant
  `gdal_vector_driver_*_opts_defaults()`); user-supplied values always
  take precedence. Defaults to `FALSE`.

## Value

A layer-level
[`gdal_creation_opts()`](http://docs.jimbrig.com/gdalvector/reference/gdal_creation_opts.md)
object for the `OpenFileGDB` driver.

## See also

[`gdb_open_opts()`](http://docs.jimbrig.com/gdalvector/reference/gdb_open_opts.md),
[`gdal_creation_opts()`](http://docs.jimbrig.com/gdalvector/reference/gdal_creation_opts.md)

## Examples

``` r
gdb_creation_opts(geometry_name = "SHAPE", target_arcgis_version = "ALL")
#> <gdal_creation_opts/gdal_opts>
#> ℹ Driver: OpenFileGDB
#> ℹ Creation Options: GEOMETRY_NAME=SHAPE, TARGET_ARCGIS_VERSION=ALL
#> ℹ Command Line: --output-format 'OpenFileGDB' --layer-creation-option 'GEOMETRY_NAME=SHAPE' --layer-creation-option 'TARGET_ARCGIS_VERSION=ALL'
```
