# Render GDAL Options as a Shell Command Snippet

Render a
[`gdal_opts()`](http://docs.jimbrig.com/gdalvector/reference/gdal_opts.md)
object to a copy-pasteable, multi-line shell snippet with one flag/value
pair per line and the appropriate line-continuation for the target
shell. Only the option flags (and the leading
`--input-format`/`--output-format` when the driver is known) are
rendered; the base `gdal` invocation and datasets are not included.

## Usage

``` r
gdal_render(x, shell = c("bash", "sh", "pwsh", "cmd"))
```

## Arguments

- x:

  A
  [`gdal_opts()`](http://docs.jimbrig.com/gdalvector/reference/gdal_opts.md)
  object.

- shell:

  Target shell dialect controlling quoting and continuation:
  `"bash"`/`"sh"` (`\\`, single quotes), `"pwsh"` (`` ` ``, single
  quotes), or `"cmd"` (`^`, double quotes).

## Value

A length-1 character string (embedded newlines), or `""` when there are
no options.

## Examples

``` r
gdal_render(gdal_creation_opts(COMPRESSION = "ZSTD", driver = "Parquet"), shell = "bash")
#> [1] "--output-format 'Parquet' \\\n--layer-creation-option 'COMPRESSION=ZSTD'"
```
