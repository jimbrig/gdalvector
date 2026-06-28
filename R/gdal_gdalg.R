#  ------------------------------------------------------------------------
#
# Title : GDALG
#    By : Jimmy Briggs
#  Date : 2026-06-11
#
#  ------------------------------------------------------------------------

# read write ------------------------------------------------------------------------------------------------------

gdalg_read <- function(path, ...) {}

gdalg_write <- function(x, path, ...) {}


# coercion --------------------------------------------------------------------------------------------------------

#' Coerce to GDALG
#'
#' @param x An object to coerce to class `"gdalg"`.
#' @param ... Additional arguments passed to specific methods.
#' @param call The calling environment, used for error messages.
#'
#' @returns
#' An object of class `"gdalg"`.
#'
#' @export
as_gdalg <- function(x, ..., call = rlang::caller_env()) {
  UseMethod("as_gdalg")
}

#' @export
as_gdalg.default <- function(x, ..., call = rlang::caller_env()) {
  check_abort("Don't know how to convert object of class {.cls {class(x)}} to class {.cls gdalg}.", call = call)
}

#' @export
as_gdalg.gdalg <- function(x, ..., call = rlang::caller_env()) {
  x
}

#' @export
#' @importFrom yyjsonr read_json_str read_json_file
#' @importFrom purrr pluck
as_gdalg.character <- function(x, ..., call = rlang::caller_env()) {
  if (is_valid_json_str(x)) {
    gdalg_list <- yyjsonr::read_json_str(x)
    gdalg_path <- NULL
  } else if (is_valid_json_file(x)) {
    gdalg_list <- yyjsonr::read_json_file(x)
    gdalg_path <- x
  } else {
    check_abort("Provided {.arg x} must be a valid JSON string or a path to a valid JSON GDALG file.", call = call)
  }
  cmd <- purrr::pluck(gdalg_list, "command_line", .default = NULL)
  if (is.null(cmd)) {
    gdal_abort_check("Provided {.arg x} must contain the {.field command_line} field.", call = call)
  }
  gdal_version <- purrr::pluck(gdalg_list, "gdal_version", .default = NULL)
  new_gdalg(command_line = cmd, gdal_version = gdal_version, .path = gdalg_path, ...)
}

#' @export
as_gdalg.list <- function(x, ..., call = rlang::caller_env()) {
  # check_names(x, required = c("command_line", "gdal_version"))
  # TODO
}

#' @export
as_gdalg.json <- function(x, ..., call = rlang::caller_env()) {
  # TODO
}


# constructor -----------------------------------------------------------------------------------------------------

new_gdalg <- function(command_line, relative_paths = TRUE, gdal_version = gdal_version_num(), .path = NULL) {
  structure(
    list(
      type = "gdal_streamed_alg",
      command_line = command_line,
      gdal_version = as.character(gdal_version),
      relative_paths_relative_to_this_file = relative_paths
    ),
    path = .path,
    class = c("gdalg", "list")
  )
}

# format and print ------------------------------------------------------------------------------------------------

#' @export
format.gdalg <- function(x, ...) {
  cmd <- if (nchar(x$command_line) > 70L) paste0(strtrim(x$command_line, 67), "...") else x$command_line
  c(
    cli::format_inline("{.cls {class(x)[[1]]}}"),
    cli::format_inline("Type: {.strong {x$type}}"),
    cli::format_inline("Command Line: {.field {cmd}}"),
    cli::format_inline("Relative Paths: {.field {x$relative_paths_relative_to_this_file}}"),
    cli::format_inline("GDAL Version: {.field {x$gdal_version}}")
  )
}

#' @export
print.gdalg <- function(x, ...) {
  cat(format(x, ...), sep = "\n")
  invisible(x)
}

gdalg_parse_command_line <- function(command_line) {
  tokens <- strsplit(command_line, "(?<!\\\\)\\s+(?=(?:[^\"]*\"[^\"]*\")*[^\"]*$)", perl = TRUE)[[1]]
  gsub("^\"|\"$", "", tokens)
}
