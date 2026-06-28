# prelude pragmas -------------------------------------------------------------------------------------------------

#' GPKG Prelude `PRAGMA` Statements
#'
#' @description
#' Builds a `PRELUDE_STATEMENTS` string of SQLite `PRAGMA` directives for use as a GDAL open option
#' on GPKG / SQLite data sources.
#'
#' @param cache_size Integer. SQLite page cache size. Negative values are in kibibytes (e.g. `-4000000` ~ 4GB).
#' @param temp_store Character. Where temporary tables are stored: `"DEFAULT"`, `"FILE"`, or `"MEMORY"`.
#'   Also accepts integer `0L`, `1L`, `2L`.
#' @param mmap_size Numeric. Maximum number of bytes for memory-mapped I/O.
#' @param journal_mode Character. SQLite journal mode: `"DELETE"`, `"WAL"`, `"TRUNCATE"`, `"PERSIST"`,
#'   `"MEMORY"`, or `"OFF"`.
#' @param ... Additional PRAGMAs (not yet implemented).
#'
#' @returns
#' A single character string of semicolon-separated `PRAGMA` statements.
#' Used by [gpkg_open_opts()] for its `prelude_statements` argument.
#'
#' @export
#'
#' @examples
#' gpkg_prelude_pragmas(cache_size = -4000000, temp_store = "MEMORY", journal_mode = "WAL")
gpkg_prelude_pragmas <- function(
  cache_size = NULL,
  temp_store = NULL,
  mmap_size = NULL,
  journal_mode = NULL,
  ...
) {
  pragmas <- c()
  if (!is.null(cache_size)) {
    pragmas <- append(pragmas, paste0("PRAGMA cache_size=", as.character(cache_size), ";"))
  }
  if (!is.null(temp_store)) {
    if (is.integer(temp_store)) {
      temp_store <- switch(as.character(temp_store), "0" = "DEFAULT", "1" = "FILE", "2" = "MEMORY", "")
    }
    if (nzchar(temp_store)) {
      temp_store <- rlang::arg_match(temp_store, values = c("DEFAULT", "FILE", "MEMORY"))
      pragmas <- append(pragmas, paste0("PRAGMA temp_store=", temp_store, ";"))
    }
  }
  if (!is.null(mmap_size)) {
    pragmas <- append(pragmas, paste0("PRAGMA mmap_size=", as.character(mmap_size), ";"))
  }
  if (!is.null(journal_mode)) {
    rlang::arg_match(journal_mode, c("DELETE", "WAL", "TRUNCATE", "PERSIST", "MEMORY", "OFF"))
    pragmas <- append(pragmas, paste0("PRAGMA journal_mode=", journal_mode, ";"))
  }
  # TODO: handle dots
  paste(pragmas, collapse = "")
}

# query pragmas ---------------------------------------------------------------------------------------------------

gpkg_pragma_application_id <- function(gpkg_path) {
  gpkg_app_ids <- c("GPKG" = char_to_hex("GPKG"), "GP10" = char_to_hex("GP10"), "GP11" = char_to_hex("GP11"))
  app_id <- gpkg_pragma(gpkg_path, "application_id")
  app_id_str <- names(gpkg_app_ids[which(app_id == gpkg_app_ids)])
  names(app_id) <- app_id_str
  app_id
}


gpkg_pragma <- function(gpkg_path, pragma) {
  check_file(gpkg_path, "gpkg")
  gpkg_conn <- gpkg_connect(gpkg_path)
  pragma_sql <- sql_pragma(pragma)
  hold <- DBI::dbGetQuery(gpkg_conn, pragma_sql)
  DBI::dbDisconnect(gpkg_conn)
  if (inherits(hold, "data.frame")) {
    return(tibble::as_tibble(hold))
  }
  hold[[1]]
}
