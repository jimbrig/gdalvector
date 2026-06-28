# https://duckdb.org/docs/current/configuration/overview#configuration-reference
duckdb_connect <- function(
  path = ":memory:",
  use_adbc = TRUE,
  extensions = c("spatial"),
  memory_limit = "8GB",
  threads = 10L,
  ...,
  read_only = FALSE,
  bigint = "integer64",
  config = list(),
  environment_scan = FALSE,
  debug = FALSE,
  timezone = "UTC",
  geometry = "wk"
) {
  conn <- duckdb::dbConnect(duckdb::duckdb(dbdir = path, read_only = read_only, ...))
  if (!is.null(memory_limit)) {
    mem_sql <- glue::glue_sql("SET memory_limit = {memory_limit};", .con = conn)
    duckdb::sql_exec(mem_sql, conn = conn)
  }
  if (!is.null(threads)) {
    thread_sql <- glue::glue_sql("SET threads = {threads};", .con = conn)
    duckdb::sql_exec(thread_sql, conn = conn)
  }
  if (!is.null(extensions) && length(extensions) > 0L) {
    purrr::walk(
      extensions,
      function(ext, conn) {
        duckdb::sql_exec(glue::glue_sql("LOAD {ext};", .con = conn), conn = conn)
      },
      conn = conn
    )
  }

  conn
}

# ddb <- duckdb::duckdb(dbdir = duckdb:::DBDIR_MEMORY, read_only = FALSE, bigint = "integer64", config = list(), environment_scan = FALSE)
# class(ddb)
# [1] "duckdb_driver

# DBI::dbGetQuery(gpkg_conn, "SELECT * FROM gpkg_extensions")

# if (use_adbc) {
#   db <- adbcdrivermanager::adbc_database_init(duckdb::duckdb_adbc(), path = path)
#   conn <- adbcdrivermanager::adbc_connection_init(database = adbc_db)
#   if (!is.null(memory_limit)) {
#     mem_sql <- glue::glue_sql("SET memory_limit = {memory_limit};", .con = conn)
#     duckdb::sql_exec(mem_sql, conn = conn)
#     adbcdrivermanager::execute_adbc(conn, mem_sql)
#   }
#   if (!is.null(threads)) {
#     thread_sql <- glue::glue_sql("SET threads = {threads};", .con = duckdb_conn)
#     adbcdrivermanager::execute_adbc(conn, thread_sql)
#   }
# }
