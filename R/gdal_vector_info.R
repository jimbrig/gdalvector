#  ------------------------------------------------------------------------
#
# Title : GDAL Vector Info
#    By : Jimmy Briggs
#  Date : 2026-06-10
#
#  ------------------------------------------------------------------------

gdal_vector_info <- function(dsn, layer = gdal_vector_layer(dsn), ...) {
  alg <- gdal_vector_info_alg(input = dsn, input_layer = layer, ..., output_format = "json")
  parsed <- alg$parseCommandLineArgs()
  run <- alg$run()
  withr::defer(expr = {
    alg$close()
    alg$release()
  })
  alg$output() |> yyjsonr::read_json_str(JSON_READ_OPTS)
}


gdal_vector_info_alg <- function(
  input,
  input_format = NULL,
  input_layer = NULL,
  output_format = NULL,
  open_options = NULL,
  features = NULL,
  summary = NULL,
  limit = NULL,
  sql = NULL,
  where = NULL,
  fid = NULL,
  dialect = NULL,
  crs_format = NULL,
  ...,
  parse = FALSE
) {
  alg_args <- list(
    input = input,
    input_format = input_format,
    input_layer = input_layer,
    output_format = output_format,
    open_option = open_options,
    features = features,
    summary = summary,
    limit = limit,
    sql = sql,
    where = where,
    fid = fid,
    dialect = dialect,
    crs_format = crs_format
  ) |>
    purrr::compact()

  gdalraster::gdal_alg(cmd = "vector info", args = alg_args, parse = parse)
}
