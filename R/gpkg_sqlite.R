#  ------------------------------------------------------------------------
#
# Title : GPKG SQLite
#    By : Jimmy Briggs
#  Date : 2026-06-22
#
#  ------------------------------------------------------------------------

gpkg_connect <- function(gpkg_path, read_only = TRUE, cache_size = NULL, synchronous = "off", ...) {
  flags <- if (read_only) RSQLite::SQLITE_RO else RSQLite::SQLITE_RWC
  DBI::dbConnect(
    drv = RSQLite::SQLite(),
    dbname = gpkg_path,
    flags = flags,
    cache_size = cache_size,
    synchronous = synchronous,
    ...
  )
}

gpkg_disconnect <- function(gpkg_conn) {
  check_conn_sqlite(gpkg_conn)
  DBI::dbDisconnect(gpkg_conn)
}

gpkg_pragma <- function(gpkg_conn, pragma_name) {
  check_conn_sqlite(gpkg_conn)
  DBI::dbGetQuery(gpkg_conn, sql_pragma(pragma_name))[[1]]
}

gpkg_list_pragmas <- function(gpkg_conn) {
  check_conn_sqlite(gpkg_conn)
  DBI::dbGetQuery(gpkg_conn, sql_pragma("pragma_list"))$name
}

gpkg_list_indexes <- function(gpkg_conn) {
  check_conn_sqlite(gpkg_conn)

  lyr_tbl_name <- dplyr::tbl(gpkg_conn, "gpkg_contents") |>
    dplyr::filter(.data$data_type == "features") |>
    dplyr::select("table_name") |>
    dplyr::collect() |>
    dplyr::pull("table_name")

  hold <- dplyr::tbl(gpkg_conn, "sqlite_master")

  btrees <- hold |>
    dplyr::filter(.data$type == "index", .data$tbl_name %in% lyr_tbl_name) |>
    dplyr::select("name", "tbl_name", "sql") |>
    dplyr::collect()

  rtrees <- hold |>
    dplyr::filter(.data$type == "table", stringr::str_detect(.data$name, stringr::fixed("rtree_"))) |>
    dplyr::select("name", "tbl_name", "sql") |>
    dplyr::collect()

  dplyr::bind_rows(btrees, rtrees) |>
    dplyr::arrange(.data$tbl_name, .data$name)
}

gpkg_list_indexable_columns <- function(gpkg_conn) {
  check_conn_sqlite(gpkg_conn)
  # DBI::dbGetQuery(gpkg_conn, "
  #   SELECT table_name, column_name
  #   FROM gpkg_geometry_columns
  #   UNION ALL
  #   SELECT table_name, column_name
  #   FROM gpkg_extensions
  #   WHERE extension_name = 'gpkg_rtree_index'
  # ")
}

# DBI::dbGetQuery(gpkg_conn, "EXPLAIN QUERY PLAN SELECT statefp, countyfp, COUNT(*) FROM lr_parcel_us GROUP BY statefp, countyfp")

# system.time({
#   states <- DBI::dbGetQuery(gpkg_conn, "
#     SELECT COUNT(DISTINCT statefp) AS n_states,
#            COUNT(DISTINCT countyfp) AS n_counties,
#            COUNT(DISTINCT statefp || countyfp) AS n_state_county
#     FROM lr_parcel_us
#   ")
# })

# gpkg_optimize <- function(gpkg_conn) {
#   check_conn_sqlite(gpkg_conn)
#   pragmas <- c(
#     sql_pragma("journal_mode", "WAL"),
#     sql_pragma("synchronous", "OFF"),
#     sql_pragma("cache_size", "-4000000"),
#     sql_pragma("temp_store", "MEMORY"),
#     sql_pragma("mmap_size", "8589934592")
#   )
# }
