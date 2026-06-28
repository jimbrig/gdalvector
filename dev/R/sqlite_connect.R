sqlite_connect <- function(path = ":memory:", read_only = TRUE, cache_size = NULL, synchronous = "off", ...) {
  flags <- if (read_only) RSQLite::SQLITE_RO else RSQLite::SQLITE_RWC
  DBI::dbConnect(
    drv = RSQLite::SQLite(),
    dbname = path,
    flags = flags,
    cache_size = cache_size,
    synchronous = synchronous,
    ...
  )
}


sqlite_version <- function() {
  RSQLite::rsqliteVersion()
}

sqlite_pragma_list <- function(conn = NULL) {
  if (is.null(conn)) {
    conn <- sqlite_connect()
    withr::defer(DBI::dbDisconnect(conn))
  }
  check_conn_sqlite(conn)
  hold <- DBI::dbGetQuery(conn, sql_pragma("pragma_list"))
  hold$name
}

sqlite_pragma <- function(name, value = NULL, conn) {
  check_conn_sqlite(conn)
  hold <- DBI::dbGetQuery(conn = conn, sql_pragma(name = name, value = value))
  hold[[name]]
}
