#  ------------------------------------------------------------------------
#
# Title : Validation Utilities
#    By : Jimmy Briggs
#  Date : 2026-06-19
#
#  ------------------------------------------------------------------------

# schema validation -----------------------------------------------------------------------------------------------

#' Validate JSON Schema
#'
#' @description
#' Validates a JSON string or file against a provided JSON schema.
#'
#' @param x A JSON string, file path, or list to validate.
#' @param schema A JSON schema string or file path to validate against.
#' @inheritParams jsonvalidate::json_validate
#' @inheritDotParams jsonvalidate::json_validate
#'
#' @returns
#' Logical indicating whether the JSON is valid against the schema.
#'
#' @export
#'
#' @importFrom jsonvalidate json_validate
#' @importFrom yyjsonr write_json_str read_json_file
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

# TODO
validate_xml_schema <- function(x, schema, ..., call = rlang::caller_env()) {
  check_xml(x, call = call)
  check_xml_schema_file(schema, call = call)
  xml2::xml_validate(x, schema, ...)
}


