
#  ------------------------------------------------------------------------
#
# Title : GDAL Vector Checks
#    By : Jimmy Briggs
#  Date : 2026-07-01
#
#  ------------------------------------------------------------------------


gdal_vector_check_spatial_index <- function(
  dsn,
  layer = gdal_vector_layer(dsn),
  geom_col = gdal_vector_layer_geom_col(dsn = dsn, layer = layer),
  ...
) {
  index_check_sql <- sql_has_spatial_index(layer = layer, geom_col = geom_col, as = "has_spatial_index")
  index_check_vec <- gdalraster::ogr_execute_sql(dsn = dsn, sql = index_check_sql, dialect = "SQLITE")
  withr::defer(expr = {
    index_check_vec$close()
  })
  index_check_val <- index_check_vec$fetch(-1L)[["HasSpatialIndex"]]
  identical(index_check_val, 1L)
}
