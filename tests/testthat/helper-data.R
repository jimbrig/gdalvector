# path to a file under tests/testthat/data/ (committed test data, e.g. small Parquet/GeoPackage samples).
test_data <- function(...) {
  testthat::test_path("data", ...)
}
