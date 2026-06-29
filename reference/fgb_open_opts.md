# FlatGeobuf Open Options

Construct a
[`gdal_open_opts()`](http://docs.jimbrig.com/gdalvector/reference/gdal_open_opts.md)
object for the `FlatGeobuf` driver. Only options you supply are emitted;
values are validated against the driver's registered metadata.

## Usage

``` r
fgb_open_opts(verify_buffers = NULL, .set_defaults = FALSE)
```

## Arguments

- verify_buffers:

  Value for `VERIFY_BUFFERS`. Logical `TRUE`/`FALSE` (coerced to
  `"YES"`/ `"NO"`) controlling whether flatbuffer integrity is verified
  on read. `"YES"` (the GDAL default) guards against corrupt data at a
  small performance cost; `"NO"` is faster but unsafe on malformed
  files. `NULL` (default) leaves it unset.

- .set_defaults:

  Logical. If `TRUE`, options left unset (`NULL`) are filled with the
  driver's documented GDAL metadata defaults (via the relevant
  `gdal_vector_driver_*_opts_defaults()`); user-supplied values always
  take precedence. Defaults to `FALSE`.

## Value

A
[`gdal_open_opts()`](http://docs.jimbrig.com/gdalvector/reference/gdal_open_opts.md)
object for the `FlatGeobuf` driver.

## See also

[`fgb_creation_opts()`](http://docs.jimbrig.com/gdalvector/reference/fgb_creation_opts.md),
[`gdal_open_opts()`](http://docs.jimbrig.com/gdalvector/reference/gdal_open_opts.md)

- [FlatGeobuf Home Page](https://flatgeobuf.org/)

- [FlatGeobuf GDAL
  Driver](https://gdal.org/en/stable/drivers/vector/flatgeobuf.html)

  - [FlatGeobuf GDAL Open
    Options](https://gdal.org/en/stable/drivers/vector/flatgeobuf.html#open-options)

  - [FlatGeobuf GDAL Layer Creation
    Options](https://gdal.org/en/stable/drivers/vector/flatgeobuf.html#layer-creation-options)

## Examples

``` r
fgb_open_opts()
#> <gdal_open_opts/gdal_opts>
#> ℹ Driver: FlatGeobuf
#> ℹ No open options set.
fgb_open_opts(verify_buffers = FALSE)
#> <gdal_open_opts/gdal_opts>
#> ℹ Driver: FlatGeobuf
#> ℹ Open Options: VERIFY_BUFFERS=NO
#> ℹ Command Line: --input-format 'FlatGeobuf' --open-option 'VERIFY_BUFFERS=NO'
fgb_open_opts(.set_defaults = TRUE)
#> <gdal_open_opts/gdal_opts>
#> ℹ Driver: FlatGeobuf
#> ℹ Open Options: VERIFY_BUFFERS=YES
#> ℹ Command Line: --input-format 'FlatGeobuf' --open-option 'VERIFY_BUFFERS=YES'
```
