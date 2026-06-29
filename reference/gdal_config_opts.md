# GDAL Configuration Options

Construct a `gdal_config_opts()` object from `NAME = value` pairs.
Configuration options are global, stateful settings applied to the GDAL
process (via
[`gdalraster::set_config_option()`](https://firelab.github.io/gdalraster/reference/set_config_option.html)
/ the CLI `--config` flag), and are *not* algorithm arguments. When
`driver` is supplied, values for boolean options are validated against
the driver metadata.

## Usage

``` r
gdal_config_opts(..., driver = NULL, .set_defaults = FALSE)
```

## Arguments

- ...:

  Named configuration options as `KEY=VALUE` pairs.

- driver:

  Optional GDAL driver short name (e.g. `"GPKG"`) to associate.

- .set_defaults:

  Logical. If `TRUE`, options left unset (`NULL`) are filled with the
  driver's documented GDAL metadata defaults (via the relevant
  `gdal_vector_driver_*_opts_defaults()`); user-supplied values always
  take precedence. Defaults to `FALSE`.

## Value

A `gdal_config_opts()` object.

## Examples

``` r
gdal_config_opts(CPL_DEBUG = "ON", GDAL_NUM_THREADS = "ALL_CPUS")
#> <gdal_config_opts/gdal_opts>
#> ℹ Configuration Options: CPL_DEBUG=ON, GDAL_NUM_THREADS=ALL_CPUS
#> ℹ Command Line: --config 'CPL_DEBUG=ON' --config 'GDAL_NUM_THREADS=ALL_CPUS'
```
