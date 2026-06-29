#  ------------------------------------------------------------------------
#
# Title : GeoPackage (GPKG) Options
#    By : Jimmy Briggs
#  Date : 2026-06-28
#
#  ------------------------------------------------------------------------

# config ----------------------------------------------------------------------------------------------------------

#' GeoPackage Configuration Options
#'
#' @description
#' Construct a [gdal_config_opts()] object for the `GPKG` driver. These are global configuration options
#' applied to the GDAL process.
#'
#' @param sqlite_cache Value for `OGR_SQLITE_CACHE` (SQLite page cache, in MB).
#' @param sqlite_journal Value for `OGR_SQLITE_JOURNAL` (journal mode).
#' @param sqlite_synchronous Value for `OGR_SQLITE_SYNCHRONOUS` (e.g. `"OFF"`).
#' @param sqlite_pragma Value for `OGR_SQLITE_PRAGMA` (e.g. `"pragma_name=value,..."`).
#' @param use_ogr_vfs Value for `SQLITE_USE_OGR_VFS` (logical -> `"YES"`/`"NO"`).
#' @param num_threads Value for `OGR_GPKG_NUM_THREADS` (integer or `"ALL_CPUS"`).
#' @param ... Additional `NAME = value` configuration options passed through after coercion.
#' @inheritParams .shared_params
#'
#' @returns A [gdal_config_opts()] object for the `GPKG` driver.
#' @export
#'
#' @seealso [gpkg_open_opts()], [gpkg_creation_opts()], [gdal_config_opts()]
#'
#' ```{r child = "man/fragments/gpkg_links.md"}
#' ```
#'
#' @examples
#' gpkg_config_opts(sqlite_synchronous = "OFF", use_ogr_vfs = TRUE, num_threads = "ALL_CPUS")
gpkg_config_opts <- function(
  sqlite_cache = NULL,
  sqlite_journal = NULL,
  sqlite_synchronous = NULL,
  sqlite_pragma = NULL,
  use_ogr_vfs = NULL,
  num_threads = NULL,
  ...,
  .set_defaults = FALSE
) {
  opts <- .gdal_opts_normalize(c(
    list(
      OGR_SQLITE_CACHE = sqlite_cache,
      OGR_SQLITE_JOURNAL = sqlite_journal,
      OGR_SQLITE_SYNCHRONOUS = sqlite_synchronous,
      OGR_SQLITE_PRAGMA = sqlite_pragma,
      SQLITE_USE_OGR_VFS = as_gdal_boolean(use_ogr_vfs),
      OGR_GPKG_NUM_THREADS = num_threads
    ),
    rlang::list2(...)
  ))
  if (length(opts) > 0L) {
    check_gdal_opts(opts, gdal_vector_driver_config_opts_values("GPKG"))
  }
  if (isTRUE(.set_defaults)) {
    opts <- utils::modifyList(as.list(gdal_vector_driver_config_opts_defaults("GPKG")), opts)
  }
  new_gdal_config_opts(opts, driver = "GPKG")
}

# open ------------------------------------------------------------------------------------------------------------

#' GeoPackage GDAL Open Options
#'
#' @description
#' Construct a [gdal_open_opts()] object for the `GPKG` (GeoPackage) driver.
#'
#' @details
#' Because a GeoPackage is a SQLite database, several open options carry performance and safety implications.
#' Of note is the `PRELUDE_STATEMENTS` open option, which allows you to specify arbitrary SQL statements that will
#' run before any other queries once connected to the SQLite3 connection is established. This is commonly used to
#' [attach another database](https://www.sqlite.org/lang_attach.html) and issue cross-database requests, but
#' we use it more commonly here to set `PRAGMA` statements to optimize performance and avoid the global configuration
#' `OGR_SQLITE_*` options.
#'
#' Each open option is enumerated and described below:
#'
#' - `LIST_ALL_TABLES=[AUTO/YES/NO]`: Defaults to `AUTO`. Whether all tables, including those not listed in `gpkg_contents`,
#'   should be listed. If `AUTO`, all tables including those not listed in `gpkg_contents` will be listed, except if
#'   the `aspatial` extension is found or a table is registered as 'attributes' in `gpkg_contents`. If `YES`,
#'   all tables including those not listed in `gpkg_contents` will be listed, in all cases. If `NO`, only tables
#'   registered as `'features'`, `'attributes'` or `'aspatial'` will be listed.
#'
#' - `PRELUDE_STATEMENTS=[SQL]`: (GDAL >= 3.2) SQL statement(s) to send on the SQLite3 connection before any other ones.
#'   In case of several statements, they must be separated with the semicolon (`;`) sign. This option may be useful to
#'   attach another database to the current one and issue cross-database requests.
#'
#' - `NOLOCK=[YES/NO]`: (GDAL >= 3.4.2) Defaults to `NO`. Whether the database should be used without doing any file
#'   locking. Setting it to `YES` will only be honored when opening in read-only mode and if the journal mode is not `WAL`.
#'   This corresponds to the `nolock=1` query parameter described at <https://www.sqlite.org/uri.html>.
#'
#' - `IMMUTABLE=[YES/NO]`: (GDAL >= 3.5.3) Whether the database should be opened by assuming that the file cannot be
#'   modified by another process. This will skip any checks for change detection. This can be useful for `WAL`
#'   enabled files on read-only storage. GDAL will automatically try to turn it on when not being able to open in
#'   read-only mode a WAL enabled file. This corresponds to the immutable=1 query parameter described at
#'   <https://www.sqlite.org/uri.html>.
#'
#' @param list_all_tables Value for `LIST_ALL_TABLES` (`"AUTO"`/`"YES"`/`"NO"`; logical coerced).
#'   Whether to list tables not registered in `gpkg_contents`. GDAL default `"AUTO"`.
#' @param prelude_statements SQL/`PRAGMA` statements for `PRELUDE_STATEMENTS` (a single string; see
#'   [gpkg_prelude_pragmas()]).
#' @param nolock Value for `NOLOCK` (logical -> `"YES"`/`"NO"`); open in nolock mode (skip SQLite
#'   locking; only safe for read-only access to media nothing else can write).
#' @param immutable Value for `IMMUTABLE` (logical -> `"YES"`/`"NO"`); declare the database
#'   immutable. Only when the file genuinely cannot change.
#' @inheritParams .shared_params
#'
#' @returns
#' A [gdal_open_opts()] object for the `GPKG` driver.
#'
#' @export
#'
#' @seealso [gpkg_prelude_pragmas()], [gpkg_creation_opts()], [gdal_open_opts()]
#'
#' ```{r child = "man/fragments/gpkg_links.md"}
#' ```
#'
#' @examples
#' gpkg_open_opts(list_all_tables = FALSE, nolock = TRUE)
#'
#' prelude <- gpkg_prelude_pragmas(cache_size = -4000000, temp_store = "MEMORY")
#' gpkg_open_opts(list_all_tables = FALSE, prelude_statements = prelude)
gpkg_open_opts <- function(
  list_all_tables = NULL,
  prelude_statements = NULL,
  nolock = NULL,
  immutable = NULL,
  .set_defaults = FALSE
) {
  opts <- .gdal_opts_normalize(list(
    LIST_ALL_TABLES = as_gdal_boolean(list_all_tables),
    PRELUDE_STATEMENTS = if (!is.null(prelude_statements) && nzchar(prelude_statements)) prelude_statements,
    NOLOCK = as_gdal_boolean(nolock),
    IMMUTABLE = as_gdal_boolean(immutable)
  ))
  if (length(opts) > 0L) {
    check_gdal_opts(opts, gdal_vector_driver_open_opts_values("GPKG"))
  }
  if (isTRUE(.set_defaults)) {
    opts <- utils::modifyList(as.list(gdal_vector_driver_open_opts_defaults("GPKG")), opts)
  }
  new_gdal_open_opts(opts, driver = "GPKG")
}

# creation --------------------------------------------------------------------------------------------------------

#' GeoPackage Creation Options
#'
#' @description
#' Construct a [gdal_creation_opts()] object for the `GPKG` driver. The typed arguments are
#' layer-creation options (`level = "layer"`, the default, `--lco`); dataset-creation options
#' (`VERSION`, `METADATA_TABLES`, `ADD_GPKG_OGR_CONTENTS`, ...) are supplied through `...` together
#' with `level = "dataset"`.
#'
#' @param fid Name of the FID column (`FID`). GDAL default `"fid"`.
#' @param geometry_name Name of the geometry column (`GEOMETRY_NAME`). GDAL default `"geom"`.
#' @param geometry_nullable Value for `GEOMETRY_NULLABLE` (logical -> `"YES"`/`"NO"`).
#' @param spatial_index Value for `SPATIAL_INDEX` (logical -> `"YES"`/`"NO"`). GDAL default `"YES"`.
#' @param identifier Value for `IDENTIFIER` (contents-table identifier).
#' @param description Value for `DESCRIPTION` (contents-table description).
#' @param launder Value for `LAUNDER` (logical -> `"YES"`/`"NO"`).
#' @param overwrite Value for `OVERWRITE` (logical -> `"YES"`/`"NO"`).
#' @param ... Additional `NAME = value` creation options (dataset-level options when
#'   `level = "dataset"`).
#' @param level Creation-option level, `"layer"` (default) or `"dataset"`.
#' @inheritParams .shared_params
#'
#' @returns A [gdal_creation_opts()] object for the `GPKG` driver.
#' @export
#'
#' @seealso [gpkg_open_opts()], [gdal_creation_opts()]
#'
#' ```{r child = "man/fragments/gpkg_links.md"}
#' ```
#'
#' @examples
#' gpkg_creation_opts(geometry_name = "geom", spatial_index = TRUE)
#' gpkg_creation_opts(VERSION = "1.4", level = "dataset")
gpkg_creation_opts <- function(
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
) {
  level <- rlang::arg_match(level)
  opts <- .gdal_opts_normalize(c(
    list(
      FID = fid,
      GEOMETRY_NAME = geometry_name,
      GEOMETRY_NULLABLE = as_gdal_boolean(geometry_nullable),
      SPATIAL_INDEX = as_gdal_boolean(spatial_index),
      IDENTIFIER = identifier,
      DESCRIPTION = description,
      LAUNDER = as_gdal_boolean(launder),
      OVERWRITE = as_gdal_boolean(overwrite)
    ),
    rlang::list2(...)
  ))
  if (length(opts) > 0L) {
    check_gdal_opts(opts, gdal_vector_driver_creation_opts_values("GPKG", sub_type = level))
  }
  if (isTRUE(.set_defaults)) {
    opts <- utils::modifyList(as.list(gdal_vector_driver_creation_opts_defaults("GPKG", sub_type = level)), opts)
  }
  new_gdal_creation_opts(opts, driver = "GPKG", level = level)
}


# prelude pragmas -------------------------------------------------------------------------------------------------

#' GeoPackage Prelude `PRAGMA` Statements
#'
#' @description
#' Build a `PRELUDE_STATEMENTS` string of SQLite `PRAGMA` directives for use as a GPKG/SQLite open option.
#' The result is a single semicolon-separated string. Because it embeds `;` (and possibly `,`), it is carried
#' as single `--open-option` value and rendered as such.
#'
#' @param cache_size Integer page cache size. Negative values are in kibibytes (e.g. `-4000000` is
#'   roughly 4 GB).
#' @param temp_store Where temporary tables live: `"DEFAULT"`, `"FILE"`, or `"MEMORY"` (also accepts
#'   integer `0L`/`1L`/`2L`).
#' @param mmap_size Maximum bytes for memory-mapped I/O.
#' @param journal_mode SQLite journal mode: `"DELETE"`, `"WAL"`, `"TRUNCATE"`, `"PERSIST"`,
#'   `"MEMORY"`, or `"OFF"`.
#' @param ... Additional raw `PRAGMA ...;` statement strings appended verbatim.
#'
#' @returns A length-1 character string of semicolon-separated `PRAGMA` statements (or `""`).
#' @export
#'
#' @seealso [gpkg_open_opts()]
#'
#' @examples
#' gpkg_prelude_pragmas(cache_size = -4000000, temp_store = "MEMORY", journal_mode = "WAL")
gpkg_prelude_pragmas <- function(cache_size = NULL, temp_store = NULL, mmap_size = NULL, journal_mode = NULL, ...) {
  pragmas <- character()
  if (!is.null(cache_size)) {
    pragmas <- c(
      pragmas,
      paste0("PRAGMA cache_size=", format(as.integer(cache_size), scientific = FALSE, trim = TRUE), ";")
    )
  }
  if (!is.null(temp_store)) {
    if (is.numeric(temp_store)) {
      temp_store <- switch(as.character(as.integer(temp_store)), "0" = "DEFAULT", "1" = "FILE", "2" = "MEMORY", "")
    }
    if (nzchar(temp_store)) {
      temp_store <- rlang::arg_match(temp_store, c("DEFAULT", "FILE", "MEMORY"))
      pragmas <- c(pragmas, paste0("PRAGMA temp_store=", temp_store, ";"))
    }
  }
  if (!is.null(mmap_size)) {
    pragmas <- c(
      pragmas,
      paste0("PRAGMA mmap_size=", format(as.numeric(mmap_size), scientific = FALSE, trim = TRUE), ";")
    )
  }
  if (!is.null(journal_mode)) {
    journal_mode <- rlang::arg_match(journal_mode, c("DELETE", "WAL", "TRUNCATE", "PERSIST", "MEMORY", "OFF"))
    pragmas <- c(pragmas, paste0("PRAGMA journal_mode=", journal_mode, ";"))
  }
  extra <- unlist(rlang::list2(...), use.names = FALSE)
  if (length(extra) > 0L) {
    pragmas <- c(pragmas, as.character(extra))
  }
  paste(pragmas, collapse = "")
}
