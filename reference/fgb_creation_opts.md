# FlatGeobuf Creation Options

Construct a layer-level
[`gdal_creation_opts()`](http://docs.jimbrig.com/gdalvector/reference/gdal_creation_opts.md)
object for the `FlatGeobuf` driver. Only options you supply are emitted;
values are validated against the driver's registered metadata.

## Usage

``` r
fgb_creation_opts(
  spatial_index = NULL,
  temporary_dir = NULL,
  title = NULL,
  description = NULL,
  ...,
  .set_defaults = FALSE
)
```

## Arguments

- spatial_index:

  Value for `SPATIAL_INDEX`. Logical `TRUE`/`FALSE` (coerced to
  `"YES"`/`"NO"`) controlling whether a packed Hilbert R-tree spatial
  index is written. GDAL default `"YES"`.

- temporary_dir:

  Value for `TEMPORARY_DIR` (path to an existing directory for temporary
  files; only used when `SPATIAL_INDEX = TRUE`. `"/vsimem/"` may be used
  for in-memory temporaries).

- title:

  Value for `TITLE` (GDAL \>= 3.9); dataset title (should be relatively
  short).

- description:

  Value for `DESCRIPTION` (GDAL \>= 3.9); dataset description (free-form
  long text).

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
object for the `FlatGeobuf` driver.

## See also

[`fgb_open_opts()`](http://docs.jimbrig.com/gdalvector/reference/fgb_open_opts.md),
[`gdal_creation_opts()`](http://docs.jimbrig.com/gdalvector/reference/gdal_creation_opts.md)

- [FlatGeobuf Home Page](https://flatgeobuf.org/)

- [FlatGeobuf GDAL
  Driver](https://gdal.org/en/stable/drivers/vector/flatgeobuf.html)

  - [FlatGeobuf GDAL Open
    Options](https://gdal.org/en/stable/drivers/vector/flatgeobuf.html#open-options)

  - [FlatGeobuf GDAL Layer Creation
    Options](https://gdal.org/en/stable/drivers/vector/flatgeobuf.html#layer-creation-options)

## Examples

``` r
fgb_creation_opts(spatial_index = TRUE, title = "Parcels")
#> <gdal_creation_opts/gdal_opts>
#> ℹ Driver: FlatGeobuf
#> ℹ Creation Options: SPATIAL_INDEX=YES, TITLE=Parcels
#> ℹ Command Line: --output-format 'FlatGeobuf' --layer-creation-option 'SPATIAL_INDEX=YES' --layer-creation-option 'TITLE=Parcels'
```
