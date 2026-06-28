#  ------------------------------------------------------------------------
#
# Title : GDAL OGR VRT Format
#    By : Jimmy Briggs
#  Date : 2026-06-16
#
#  ------------------------------------------------------------------------

# https://gdal.org/en/stable/drivers/vector/vrt.html

gdal_vrt_validate_schema <- function(path, call = rlang::caller_env()) {
  check_file(path, ext = "vrt", call = call)
  vrt_xml <- xml2::read_xml(path)
  schema_xml <- xml2::read_xml(pkg_sys_extdata("ogrvrt.xsd"))
  xml2::xml_validate(vrt_xml, schema_xml)
}
