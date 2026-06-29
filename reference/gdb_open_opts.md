# OpenFileGDB Open Options

Construct a
[`gdal_open_opts()`](http://docs.jimbrig.com/gdalvector/reference/gdal_open_opts.md)
object for the `OpenFileGDB` driver.

## Usage

``` r
gdb_open_opts(list_all_tables = NULL, .set_defaults = FALSE)
```

## Arguments

- list_all_tables:

  Value for `LIST_ALL_TABLES` (`"YES"`/`"NO"`; logical coerced). Whether
  to list all tables, including system/internal `GDB_*` tables. GDAL
  default `"NO"`.

- .set_defaults:

  Logical. If `TRUE`, options left unset (`NULL`) are filled with the
  driver's documented GDAL metadata defaults (via the relevant
  `gdal_vector_driver_*_opts_defaults()`); user-supplied values always
  take precedence. Defaults to `FALSE`.

## Value

A
[`gdal_open_opts()`](http://docs.jimbrig.com/gdalvector/reference/gdal_open_opts.md)
object for the `OpenFileGDB` driver.

## See also

[`gdb_creation_opts()`](http://docs.jimbrig.com/gdalvector/reference/gdb_creation_opts.md),
[`gdal_open_opts()`](http://docs.jimbrig.com/gdalvector/reference/gdal_open_opts.md)

## Examples

``` r
gdb_open_opts(list_all_tables = TRUE)
#> <gdal_open_opts/gdal_opts>
#> ℹ Driver: OpenFileGDB
#> ℹ Open Options: LIST_ALL_TABLES=YES
#> ℹ Command Line: --input-format 'OpenFileGDB' --open-option 'LIST_ALL_TABLES=YES'
```
