#  ------------------------------------------------------------------------
#
# Title : JSON Utilities
#    By : Jimmy Briggs
#  Date : 2026-06-23
#
#  ------------------------------------------------------------------------


# read ------------------------------------------------------------------------------------------------------------

read_json <- function(x, ...) {
  UseMethod("read_json")
}

read_json.character <- function(x, ...) {
  if (is_valid_json_file(x)) {
    yyjsonr::read_json_file(x, opts = JSON_READ_OPTS, ...)
  }
  if (is_valid_json_str(x)) {
    yyjsonr::read_json_str(x, opts = JSON_READ_OPTS, ...)
  }
  gdal_abort_check(msg = "Provided {.arg x} is not a valid JSON file path or string", call = rlang::caller_env())
}


# write -----------------------------------------------------------------------------------------------------------


