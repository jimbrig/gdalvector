# GeoPackage Creation Options

Construct a
[`gdal_creation_opts()`](http://docs.jimbrig.com/gdalvector/reference/gdal_creation_opts.md)
object for the `GPKG` driver. The typed arguments are layer-creation
options (`level = "layer"`, the default, `--lco`); dataset-creation
options (`VERSION`, `METADATA_TABLES`, `ADD_GPKG_OGR_CONTENTS`, ...) are
supplied through `...` together with `level = "dataset"`.

## Usage

``` r
gpkg_creation_opts(
  fid = NULL,
  geometry_name = NULL,
  geometry_nullable = NULL,
  spatial_index = NULL,
  identifier = NULL,
  description = NULL,
  launder = NULL,
  overwrite = NULL,
  ...,
  level = c("layer", "dataset"),
  .set_defaults = FALSE
)
```

## Arguments

- fid:

  Name of the FID column (`FID`). GDAL default `"fid"`.

- geometry_name:

  Name of the geometry column (`GEOMETRY_NAME`). GDAL default `"geom"`.

- geometry_nullable:

  Value for `GEOMETRY_NULLABLE` (logical -\> `"YES"`/`"NO"`).

- spatial_index:

  Value for `SPATIAL_INDEX` (logical -\> `"YES"`/`"NO"`). GDAL default
  `"YES"`.

- identifier:

  Value for `IDENTIFIER` (contents-table identifier).

- description:

  Value for `DESCRIPTION` (contents-table description).

- launder:

  Value for `LAUNDER` (logical -\> `"YES"`/`"NO"`). GDAL default `"NO"`.

- overwrite:

  Value for `OVERWRITE` (logical -\> `"YES"`/`"NO"`). GDAL default
  `"NO"`.

- ...:

  Additional `NAME = value` options passed through verbatim alongside
  the typed arguments. They are coerced and validated against the driver
  metadata in the same way, and take precedence over a typed argument
  that sets the same option.

- level:

  Creation-option level, `"layer"` (default, `--lco`) or `"dataset"`
  (`--co`). Dataset-level options (e.g. `VERSION`, `METADATA_TABLES`,
  `ADD_GPKG_OGR_CONTENTS`) are supplied through `...` with
  `level = "dataset"`.

- .set_defaults:

  Logical. If `TRUE`, options left unset (`NULL`) are filled with the
  driver's documented GDAL metadata defaults (via the relevant
  `gdal_vector_driver_*_opts_defaults()`); user-supplied values always
  take precedence. Defaults to `FALSE`.

## Value

A
[`gdal_creation_opts()`](http://docs.jimbrig.com/gdalvector/reference/gdal_creation_opts.md)
object for the `GPKG` driver.

## See also

[`gpkg_open_opts()`](http://docs.jimbrig.com/gdalvector/reference/gpkg_open_opts.md),
[`gdal_creation_opts()`](http://docs.jimbrig.com/gdalvector/reference/gdal_creation_opts.md)

- [GDAL GPKG (GeoPackage) vector
  driver](https://gdal.org/en/stable/drivers/vector/gpkg.html)

- [GPKG open
  options](https://gdal.org/en/stable/drivers/vector/gpkg.html#open-options)

- [GDAL configuration
  options](https://gdal.org/en/stable/user/configoptions.html)

- [SQLite `PRAGMA` statements](https://www.sqlite.org/pragma.html)

- [GeoPackage specification](https://www.geopackage.org/spec/)

## Examples

``` r
gpkg_creation_opts(geometry_name = "geom", spatial_index = TRUE)
#> <gdal_creation_opts/gdal_opts>
#> ℹ Driver: GPKG
#> ℹ Creation Options: GEOMETRY_NAME=geom, SPATIAL_INDEX=YES
#> ℹ Command Line: --output-format 'GPKG' --layer-creation-option 'GEOMETRY_NAME=geom' --layer-creation-option 'SPATIAL_INDEX=YES'
gpkg_creation_opts(VERSION = "1.4", level = "dataset")
#> <gdal_creation_opts/gdal_opts>
#> ℹ Driver: GPKG
#> ℹ Creation Options: VERSION=1.4
#> ℹ Command Line: --output-format 'GPKG' --creation-option 'VERSION=1.4'
```
