#  ------------------------------------------------------------------------
#
# Title : GeoPackage Validation
#    By : Jimmy Briggs
#  Date : 2026-05-29
#
#  ------------------------------------------------------------------------

# gpkg validation -------------------------------------------------------------------------------------------------

gpkg_validate <- function(gpkg_path, ...) {}


# file info -------------------------------------------------------------------------------------------------------

# magic bytes -----------------------------------------------------------------------------------------------------

gpkg_validate_magic_header <- function(gpkg_path, call = rlang::caller_env()) {
  header <- gpkg_read_magic_header(gpkg_path, call = call)
  chk <- identical(header, "SQLite format 3")
  if (chk) {
    gdal_validation_pass(
      "gpkg_magic_header",
      "Magic header bytes for {.path {gpkg_path}} match the valid {.field 'SQLite format 3'} expected pattern.",
      detail = list(
        gpkg_path = gpkg_path,
        actual = header,
        expected = "SQLite format 3",
        reference = "OGC GeoPackage §1.1.3.1.1 Req. 1"
      )
    )
  }
}

gpkg_read_magic_header <- function(gpkg_path, call = rlang::caller_env()) {
  check_file(path, ext = "gpkg", call = call)
  purrr::pluck(read_magic_header(path = gpkg_path, n = 16L), "str", .default = NULL)
}
