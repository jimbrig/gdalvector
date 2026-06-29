# GeoPackage Prelude `PRAGMA` Statements

Build a `PRELUDE_STATEMENTS` string of SQLite `PRAGMA` directives for
use as a GPKG/SQLite open option. The result is a single
semicolon-separated string. Because it embeds `;` (and possibly `,`), it
is carried as single `--open-option` value and rendered as such.

## Usage

``` r
gpkg_prelude_pragmas(
  cache_size = NULL,
  temp_store = NULL,
  mmap_size = NULL,
  journal_mode = NULL,
  ...
)
```

## Arguments

- cache_size:

  Integer page cache size. Negative values are in kibibytes (e.g.
  `-4000000` is roughly 4 GB).

- temp_store:

  Where temporary tables live: `"DEFAULT"`, `"FILE"`, or `"MEMORY"`
  (also accepts integer `0L`/`1L`/`2L`).

- mmap_size:

  Maximum bytes for memory-mapped I/O.

- journal_mode:

  SQLite journal mode: `"DELETE"`, `"WAL"`, `"TRUNCATE"`, `"PERSIST"`,
  `"MEMORY"`, or `"OFF"`.

- ...:

  Additional raw `PRAGMA ...;` statement strings appended verbatim.

## Value

A length-1 character string of semicolon-separated `PRAGMA` statements
(or `""`).

## See also

[`gpkg_open_opts()`](http://docs.jimbrig.com/gdalvector/reference/gpkg_open_opts.md)

## Examples

``` r
gpkg_prelude_pragmas(cache_size = -4000000, temp_store = "MEMORY", journal_mode = "WAL")
#> [1] "PRAGMA cache_size=-4000000;PRAGMA temp_store=MEMORY;PRAGMA journal_mode=WAL;"
```
