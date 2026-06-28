adbc_connect_postgres <- function(...) {}

adbc_connect_sqlite <- function(path, ...) {
  check_file(path)
  db <- adbcdrivermanager::adbc_database_init(driver = adbcsqlite::adbcsqlite(), uri = path)
  # check_db_adbc(db)
  # check_db_adbc_sqlite(db)
  # adbcdrivermanager::adbc_xptr_is_valid(db)
  adbcdrivermanager::adbc_connection_init(db)
  # check_conn_adbc(gpkg_adbc_conn)
  # check_conn_adbc_sqlite(gpkg_adbc_conn)
  # adbcdrivermanager::adbc_xptr_is_valid(gpkg_adbc_conn)
}
