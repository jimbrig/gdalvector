
#  ------------------------------------------------------------------------
#
# Title : GeoPackage Audit
#    By : Jimmy Briggs
#  Date : 2026-07-01
#
#  ------------------------------------------------------------------------

gpkg_contents <- function(gpkg_path) {
  check_file(gpkg_path, ext = ".gpkg")
  gpkg::gpkg_contents(gpkg_path) |> tibble::as_tibble()
}

gpkg_ogr_contents <- function(gpkg_path) {
  check_file(gpkg_path, ext = ".gpkg")
  gpkg::gpkg_ogr_contents(gpkg_path) |> tibble::as_tibble()
}

gpkg_spatial_ref_sys <- function(gpkg_path) {
  check_file(gpkg_path, ext = ".gpkg")
  gpkg::gpkg_spatial_ref_sys(gpkg_path) |> tibble::as_tibble()
}
