#  ------------------------------------------------------------------------
#
# Title : Validation Utilities
#    By : Jimmy Briggs
#  Date : 2026-06-19
#
#  ------------------------------------------------------------------------

# schema validation -----------------------------------------------------------------------------------------------

validate_json_schema <- function(x, schema, engine = "ajv", verbose = TRUE, ..., call = rlang::caller_env()) {
  if (!is_valid_json_str(x) && is_valid_json_file(x)) {
    x <- yyjsonr::read_json_file(x, opts = JSON_READ_OPTS) |> yyjsonr::write_json_str(opts = JSON_WRITE_OPTS)
  } else if (is.list(x)) {
    x <- yyjsonr::write_json_str(x, opts = JSON_WRITE_OPTS)
  }
  check_json_str(x, call = call)
  check_json_schema_file(schema, call = call)
  jsonvalidate::json_validate(json = x, schema = schema, verbose = verbose, engine = engine, ...)
}
