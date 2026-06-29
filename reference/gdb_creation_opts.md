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

  Value for `FID` (name of the OID column). GDAL default `"OBJECTID"`.

- geometry_name:

  Value for `GEOMETRY_NAME`. GDAL default `"SHAPE"`.

- geometry_nullable:

  Value for `GEOMETRY_NULLABLE` (logical -\> `"YES"`/`"NO"`). GDAL
  default `"YES"`.

- configuration_keyword:

  Value for `CONFIGURATION_KEYWORD`. One of `DEFAULTS`/
  `MAX_FILE_SIZE_4GB`/`MAX_FILE_SIZE_256TB`. GDAL default `"DEFAULTS"`
  (UTF-8 text, up to 1 TB).

- target_arcgis_version:

  Value for `TARGET_ARCGIS_VERSION` (GDAL \>= 3.9). One of `ALL`/
  `ARCGIS_PRO_3_2_OR_LATER` (the latter required to create
  `Integer64`/`Date`/`Time` fields). GDAL default `"ALL"`.

- create_multipatch:

  Value for `CREATE_MULTIPATCH` (logical -\> `"YES"`/`"NO"`); write
  MultiPolygon layers as MultiPatch.

- create_shape_area_and_length_fields:

  Value for `CREATE_SHAPE_AREA_AND_LENGTH_FIELDS` (logical -\>
  `"YES"`/`"NO"`); auto-populated `Shape_Area`/`Shape_Length` fields.
  GDAL default `"NO"`.

- time_in_utc:

  Value for `TIME_IN_UTC` (logical -\> `"YES"`/`"NO"`).

- column_types:

  Value for `COLUMN_TYPES` (`"field_name=fgdb_field_type,..."`) forcing
  FileGDB field types.

- feature_dataset:

  Value for `FEATURE_DATASET` (FeatureDataset folder for the new layer;
  created if it does not exist).

- layer_alias:

  Value for `LAYER_ALIAS` (layer-name alias).

- documentation:

  Value for `DOCUMENTATION` (XML documentation string).

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
object for the `OpenFileGDB` driver.

## See also

[`gdb_open_opts()`](http://docs.jimbrig.com/gdalvector/reference/gdb_open_opts.md),
[`gdal_creation_opts()`](http://docs.jimbrig.com/gdalvector/reference/gdal_creation_opts.md)

- [OpenFileGDB GDAL
  Driver](https://gdal.org/en/stable/drivers/vector/openfilegdb.html)

  - [OpenFileGDB GDAL Open
    Options](https://gdal.org/en/stable/drivers/vector/openfilegdb.html#open-options)

  - [OpenFileGDB GDAL Layer Creation
    Options](https://gdal.org/en/stable/drivers/vector/openfilegdb.html#layer-creation-options)

  - [OpenFileGDB GDAL Configuration
    Options](https://gdal.org/en/stable/drivers/vector/openfilegdb.html#configuration-options)

- [ESRI File Geodatabase (.gdb)
  Format](https://desktop.arcgis.com/en/arcmap/latest/manage-data/administer-file-gdbs/file-geodatabases.htm)

## Examples

``` r
gdb_creation_opts(geometry_name = "SHAPE", target_arcgis_version = "ALL")
#> <gdal_creation_opts/gdal_opts>
#> ℹ Driver: OpenFileGDB
#> ℹ Creation Options: GEOMETRY_NAME=SHAPE, TARGET_ARCGIS_VERSION=ALL
#> ℹ Command Line: --output-format 'OpenFileGDB' --layer-creation-option 'GEOMETRY_NAME=SHAPE' --layer-creation-option 'TARGET_ARCGIS_VERSION=ALL'
```
