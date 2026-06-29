# GeoPackage GDAL Open Options

Construct a
[`gdal_open_opts()`](http://docs.jimbrig.com/gdalvector/reference/gdal_open_opts.md)
object for the `GPKG` (GeoPackage) driver.

## Usage

``` r
gpkg_open_opts(
  list_all_tables = NULL,
  prelude_statements = NULL,
  nolock = NULL,
  immutable = NULL,
  ...,
  .set_defaults = FALSE
)
```

## Arguments

- list_all_tables:

  Value for `LIST_ALL_TABLES` (`"AUTO"`/`"YES"`/`"NO"`; logical
  coerced). Whether to list tables not registered in `gpkg_contents`.
  GDAL default `"AUTO"`.

- prelude_statements:

  SQL/`PRAGMA` statements for `PRELUDE_STATEMENTS` (a single string; see
  [`gpkg_prelude_pragmas()`](http://docs.jimbrig.com/gdalvector/reference/gpkg_prelude_pragmas.md)).

- nolock:

  Value for `NOLOCK` (logical -\> `"YES"`/`"NO"`); open in nolock mode
  (skip SQLite locking; only safe for read-only access to media nothing
  else can write).

- immutable:

  Value for `IMMUTABLE` (logical -\> `"YES"`/`"NO"`); declare the
  database immutable. Only when the file genuinely cannot change.

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

A
[`gdal_open_opts()`](http://docs.jimbrig.com/gdalvector/reference/gdal_open_opts.md)
object for the `GPKG` driver.

## Details

Because a GeoPackage is a SQLite database, several open options carry
performance and safety implications. Of note is the `PRELUDE_STATEMENTS`
open option, which allows you to specify arbitrary SQL statements that
will run before any other queries once connected to the SQLite3
connection is established. This is commonly used to [attach another
database](https://www.sqlite.org/lang_attach.html) and issue
cross-database requests, but we use it more commonly here to set
`PRAGMA` statements to optimize performance and avoid the global
configuration `OGR_SQLITE_*` options.

Each open option is enumerated and described below:

- `LIST_ALL_TABLES=[AUTO/YES/NO]`: Defaults to `AUTO`. Whether all
  tables, including those not listed in `gpkg_contents`, should be
  listed. If `AUTO`, all tables including those not listed in
  `gpkg_contents` will be listed, except if the `aspatial` extension is
  found or a table is registered as 'attributes' in `gpkg_contents`. If
  `YES`, all tables including those not listed in `gpkg_contents` will
  be listed, in all cases. If `NO`, only tables registered as
  `'features'`, `'attributes'` or `'aspatial'` will be listed.

- `PRELUDE_STATEMENTS=[SQL]`: (GDAL \>= 3.2) SQL statement(s) to send on
  the SQLite3 connection before any other ones. In case of several
  statements, they must be separated with the semicolon (`;`) sign. This
  option may be useful to attach another database to the current one and
  issue cross-database requests.

- `NOLOCK=[YES/NO]`: (GDAL \>= 3.4.2) Defaults to `NO`. Whether the
  database should be used without doing any file locking. Setting it to
  `YES` will only be honored when opening in read-only mode and if the
  journal mode is not `WAL`. This corresponds to the `nolock=1` query
  parameter described at <https://www.sqlite.org/uri.html>.

- `IMMUTABLE=[YES/NO]`: (GDAL \>= 3.5.3) Whether the database should be
  opened by assuming that the file cannot be modified by another
  process. This will skip any checks for change detection. This can be
  useful for `WAL` enabled files on read-only storage. GDAL will
  automatically try to turn it on when not being able to open in
  read-only mode a WAL enabled file. This corresponds to the immutable=1
  query parameter described at <https://www.sqlite.org/uri.html>.

## See also

[`gpkg_prelude_pragmas()`](http://docs.jimbrig.com/gdalvector/reference/gpkg_prelude_pragmas.md),
[`gpkg_creation_opts()`](http://docs.jimbrig.com/gdalvector/reference/gpkg_creation_opts.md),
[`gdal_open_opts()`](http://docs.jimbrig.com/gdalvector/reference/gdal_open_opts.md)

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
gpkg_open_opts(list_all_tables = FALSE, nolock = TRUE)
#> <gdal_open_opts/gdal_opts>
#> ℹ Driver: GPKG
#> ℹ Open Options: LIST_ALL_TABLES=NO, NOLOCK=YES
#> ℹ Command Line: --input-format 'GPKG' --open-option 'LIST_ALL_TABLES=NO' --open-option 'NOLOCK=YES'

prelude <- gpkg_prelude_pragmas(cache_size = -4000000, temp_store = "MEMORY")
gpkg_open_opts(list_all_tables = FALSE, prelude_statements = prelude)
#> <gdal_open_opts/gdal_opts>
#> ℹ Driver: GPKG
#> ℹ Open Options: LIST_ALL_TABLES=NO, PRELUDE_STATEMENTS=PRAGMA cache_size=-4000000;PRAGMA temp_store=MEMORY;
#> ℹ Command Line: --input-format 'GPKG' --open-option 'LIST_ALL_TABLES=NO' --open-option 'PRELUDE_STATEMENTS=PRAGMA cache_size=-4000000;PRAGMA temp_store=MEMORY;'
```
