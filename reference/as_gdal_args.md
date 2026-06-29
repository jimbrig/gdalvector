# Convert GDAL Options to Algorithm Arguments

Render a
[`gdal_opts()`](http://docs.jimbrig.com/gdalvector/reference/gdal_opts.md)
object to the form consumed by the GDAL algorithm API
([`gdalraster::gdal_alg()`](https://firelab.github.io/gdalraster/reference/gdal_cli.html)
/
[`gdalraster::gdal_run()`](https://firelab.github.io/gdalraster/reference/gdal_cli.html)).

## Usage

``` r
as_gdal_args(x, ...)

# S3 method for class 'gdal_opts'
as_gdal_args(x, cli = TRUE, long = FALSE, with_format = FALSE, ...)

# S3 method for class 'character'
as_gdal_args(x, ...)

# S3 method for class 'list'
as_gdal_args(x, ...)

# Default S3 method
as_gdal_args(x, ...)
```

## Arguments

- x:

  A
  [`gdal_opts()`](http://docs.jimbrig.com/gdalvector/reference/gdal_opts.md)
  object (or a character vector / list, passed through).

- ...:

  Passed to methods.

- cli:

  Logical; emit interleaved CLI tokens (`TRUE`, default) or a bare
  `KEY=VALUE` vector.

- long:

  Logical; use long flag names (`--open-option`) rather than aliases
  (`--oo`).

- with_format:

  Logical; prepend the `--input-format`/`--output-format` flag and
  driver when known (open/creation only).

## Value

A character vector.

## Details

For repeated options (`--oo`/`--co`/`--lco`), GDAL requires each value
to be preceded by its own flag - values are never comma-packed (a packed
value would corrupt options such as `PRELUDE_STATEMENTS` that themselves
contain `;`/`,`). Accordingly:

- `cli = TRUE` (default) emits a flat token vector
  `c("--open-option", "K=V", "--open-option", "K2=V2", ...)`, suitable
  as the `args` to
  [`gdalraster::gdal_alg()`](https://firelab.github.io/gdalraster/reference/gdal_cli.html).

- `cli = FALSE` emits an unnamed `c("K=V", ...)` vector, suitable for a
  single `alg$setArg(<flag>, .)` call.

## Examples

``` r
as_gdal_args(gdal_open_opts(LIST_ALL_TABLES = FALSE, driver = "GPKG"))
#> [1] "--oo"               "LIST_ALL_TABLES=NO"
as_gdal_args(gdal_open_opts(LIST_ALL_TABLES = FALSE), cli = FALSE)
#> [1] "LIST_ALL_TABLES=NO"
```
