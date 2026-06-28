gpkg_connect <- function(
  gpkg_path,
  method = c("dbi", "adbc", "duckdb"),
  read_only = TRUE,
  cache_size = NULL,
  mmap_size = NULL,
  synchronous = NULL,
  ...
) {
  check_file(gpkg_path, ext = "gpkg")
  method <- rlang::arg_match(method)
  switch(
    method,
    "dbi" = sqlite_connect(gpkg_path, read_only = read_only, cache_size = cache_size, synchronous = synchronous, ...),
    "adbc" = adbc_connect_sqlite(gpkg_path, ...),
    "duckdb" = NULL
  )
}
