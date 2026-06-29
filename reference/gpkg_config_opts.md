# GeoPackage Configuration Options

Construct a
[`gdal_config_opts()`](http://docs.jimbrig.com/gdalvector/reference/gdal_config_opts.md)
object for the `GPKG` driver. These are global configuration options
applied to the GDAL process.

## Usage

``` r
gpkg_config_opts(
  sqlite_cache = NULL,
  sqlite_journal = NULL,
  sqlite_synchronous = NULL,
  sqlite_pragma = NULL,
  use_ogr_vfs = NULL,
  num_threads = NULL,
  ...,
  .set_defaults = FALSE
)
```

## Arguments

- sqlite_cache:

  Value for `OGR_SQLITE_CACHE` (SQLite page cache, in MB).

- sqlite_journal:

  Value for `OGR_SQLITE_JOURNAL` (journal mode).

- sqlite_synchronous:

  Value for `OGR_SQLITE_SYNCHRONOUS` (e.g. `"OFF"`).

- sqlite_pragma:

  Value for `OGR_SQLITE_PRAGMA` (e.g. `"pragma_name=value,..."`).

- use_ogr_vfs:

  Value for `SQLITE_USE_OGR_VFS` (logical -\> `"YES"`/`"NO"`).

- num_threads:

  Value for `OGR_GPKG_NUM_THREADS` (integer or `"ALL_CPUS"`).

- ...:

  Additional `NAME = value` configuration options passed through after
  coercion.

- .set_defaults:

  Logical. If `TRUE`, options left unset (`NULL`) are filled with the
  driver's documented GDAL metadata defaults (via the relevant
  `gdal_vector_driver_*_opts_defaults()`); user-supplied values always
  take precedence. Defaults to `FALSE`.

## Value

A
[`gdal_config_opts()`](http://docs.jimbrig.com/gdalvector/reference/gdal_config_opts.md)
object for the `GPKG` driver.

## See also

[`gpkg_open_opts()`](http://docs.jimbrig.com/gdalvector/reference/gpkg_open_opts.md),
[`gpkg_creation_opts()`](http://docs.jimbrig.com/gdalvector/reference/gpkg_creation_opts.md),
[`gdal_config_opts()`](http://docs.jimbrig.com/gdalvector/reference/gdal_config_opts.md)

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
gpkg_config_opts(sqlite_synchronous = "OFF", use_ogr_vfs = TRUE, num_threads = "ALL_CPUS")
#> <gdal_config_opts/gdal_opts>
#> ℹ Driver: GPKG
#> ℹ Configuration Options: OGR_SQLITE_SYNCHRONOUS=OFF, SQLITE_USE_OGR_VFS=YES, OGR_GPKG_NUM_THREADS=ALL_CPUS
#> ℹ Command Line: --config 'OGR_SQLITE_SYNCHRONOUS=OFF' --config 'SQLITE_USE_OGR_VFS=YES' --config 'OGR_GPKG_NUM_THREADS=ALL_CPUS'
```
