#  ------------------------------------------------------------------------
#
# Title : GDALG
#    By : Jimmy Briggs
#  Date : 2026-06-11
#
#  ------------------------------------------------------------------------


# read ------------------------------------------------------------------------------------------------------------

gdalg_read <- function(path, ...) {
  check_file(path, ext = "json")
  validate_gdalg_file(path)
  as_gdalg(read_json_file(path), .path = path)
}


# write -----------------------------------------------------------------------------------------------------------

gdalg_write <- function(x, path, ..., overwrite = FALSE) {
  check_gdalg(x)
  command_line <- x$command_line
  command_line_parsed <- gdalg_parse_command_line(command_line)
  if (command_line_parsed[[1]] == "gdal") {
    command_line_parsed <- command_line_parsed[-1]
  }
  alg_cmd <- paste(command_line_parsed[[1]], command_line_parsed[[2]], sep = " ")
  alg_args <- c(
    command_line_parsed[-c(1, 2)],
    "!", "write", "--output", path, "--output-format", "GDALG",
    if (overwrite) "--overwrite" else NULL
  )
  res <- rlang::try_fetch({
    gdalg_alg <- gdalraster::gdal_alg(cmd = alg_cmd, alg_args, parse = FALSE)
    gdalg_alg$run()
  }, error = function(e) {
    FALSE
  }, finally = {
    gdalg_alg$close()
    gdalg_alg$release()
  })
  if (res && file.exists(path)) {
    cli::cli_alert_success("GDALG written to {.file {path}}")
    return(invisible(path))
  }
  FALSE
}


# parse -----------------------------------------------------------------------------------------------------------

gdalg_parse_command_line <- function(command_line) {
  tokens <- strsplit(command_line, "(?<!\\\\)\\s+(?=(?:[^\"]*\"[^\"]*\")*[^\"]*$)", perl = TRUE)[[1]]
  gsub("^\"|\"$", "", tokens)
}


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
as_gdalg.list <- function(x, ..., .path = NULL, call = rlang::caller_env()) {
  check_names(x, required = c("type", "command_line", "gdal_version"))
  type <- purrr::pluck(x, "type", .default = NA_character_)
  if (!identical(type, "gdal_streamed_alg")) {
    gdal_abort_check("Provided list must have {.field type} field equal to {.field \"gdal_streamed_alg\"}.", call = call)
  }
  cmd <- purrr::pluck(x, "command_line", .default = NULL)
  ver <- purrr::pluck(x, "gdal_version", .default = gdal_version_num())
  rel_paths <- purrr::pluck(x, "relative_paths_relative_to_this_file", .default = NULL)
  new_gdalg(command_line = cmd, gdal_version = ver, relative_paths = rel_paths, .path = .path)
}

#' @export
as_gdalg.json <- function(x, ..., call = rlang::caller_env()) {
  # TODO
}


# constructor -----------------------------------------------------------------------------------------------------

new_gdalg <- function(command_line, relative_paths = TRUE, gdal_version = gdal_version_num(), .path = NULL) {

  gdalg <- list(
    type = "gdal_streamed_alg",
    command_line = command_line,
    gdal_version = as.character(gdal_version),
    relative_paths_relative_to_this_file = relative_paths
  ) |>
    purrr::compact()

  structure(
    gdalg,
    path = .path,
    class = c("gdalg", "list")
  )
}


# validate --------------------------------------------------------------------------------------------------------

validate_gdalg_file <- function(x, schema = pkg_sys_schemas("gdalg.schema.json"), ..., call = rlang::caller_env()) {
  res <- validate_json_schema(x, schema = schema, ..., call = call)
  if (res) {
    gdal_inform(c("v" = "Provided GDALG is valid against the GDALG schema"))
    return(res)
  }
  attr(res, "errors")
}

validate_gdalg <- function(x, schema = pkg_sys_schemas("gdalg.schema.json"), ..., call = rlang::caller_env()) {
  check_gdalg(x)
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


