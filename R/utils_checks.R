#  ------------------------------------------------------------------------
#
# Title : Check Utilities
#    By : Jimmy Briggs
#  Date : 2026-05-31
#
#  ------------------------------------------------------------------------

# topic -----------------------------------------------------------------------------------------------------------

#' Check Functions
#'
#' @name checks
#' @family checks
#' @family utils
#'
#' @description
#' Collection of various checking functions primarily used for incorporating argument validation checks for package
#' functions.
#'
#' These check functions act as assertions, and will either return the provided objects invisibly, or throw exceptions.
NULL


# imports ---------------------------------------------------------------------------------------------------------

#' @importFrom rlang caller_arg caller_env
NULL

#' @keywords internal
#' @noRd
obj_type_friendly <- utils::getFromNamespace("obj_type_friendly", ns = "rlang")


# check_abort -----------------------------------------------------------------------------------------------------

#' Simple Alias for Check Aborts
#'
#' @keywords internal
#' @noRd
check_abort <- gdal_abort_check

# inherits ------------------------------------------------------------------------------------------------------

#' Class Inheritence Checks
#'
#' @description
#' These functions perform checks that assert the underlying class of objects passed to them.
#'
#' - `check_inherits()`: checks that object `x` is of class `class` using [base::inherits()]
#' - `check_inherits2()`: checks that object `x` is of class `class` using [base::.class2()]
#' - `check_inherits_any()`: checks that object `x` is at least one of the provided `classes` via [rlang::inherits_any()]
#' - `check_inherits_all()`: checks that object `x` is all of the provided `classes` via [rlang::inherits_all()]
#'
#' If validation fails for any of these functions, an error is thrown via `check_abort()` displaying a friendly
#' error message.
#'
#' @param x The object to check.
#' @param class,classes The name of the class or classes to use during checking.
#' @inheritParams rlang::args_error_context
#'
#' @returns
#' If checks pass, invisibly returns the provided `x` object. If checks fail, a condition error is thrown.
#'
#' @export
check_inherits <- function(x, class, arg = rlang::caller_arg(x), call = rlang::caller_env()) {
  if (!inherits(x, class)) {
    check_abort("{.arg {arg}} must inherit from class {.cls {class}}, not {.obj_type_friendly {x}}.", call = call)
  }
  invisible(x)
}

#' @rdname check_inherits
#' @export
check_inherits2 <- function(x, class, arg = rlang::caller_arg(x), call = rlang::caller_env()) {
  if (!(class %in% .class2(x))) {
    check_abort("{.arg {arg}} must inherit from class {.cls {class}}, not {.cls {.class2(x)}}", call = call)
  }
  invisible(x)
}

#' @rdname check_inherits
#' @export
#' @importFrom rlang inherits_any
check_inherits_any <- function(x, classes, arg = rlang::caller_arg(x), call = rlang::caller_env()) {
  if (!rlang::inherits_any(x, classes)) {
    check_abort(
      "{.arg {arg}} must inherit from one of the classes: {.cls {classes}}, not {.obj_type_friendly {x}}.",
      call = call
    )
  }
  invisible(x)
}

#' @rdname check_inherits
#' @export
#' @importFrom rlang inherits_all
check_inherits_all <- function(x, classes, arg = rlang::caller_arg(x), call = rlang::caller_env()) {
  if (!rlang::inherits_all(x, classes)) {
    check_abort(
      "{.arg {arg}} must inherit from all of the classes: {.cls {classes}}, not {.obj_type_friendly {x}}.",
      call = call
    )
  }
  invisible(x)
}

# empty -----------------------------------------------------------------------------------------------------------

#' Check Not Empty
#'
#' @description
#' Checks the provided `x` is not "empty" via [rlang::is_empty()].
#'
#' @inheritParams check_inherits
#'
#' @returns
#' If checks pass, invisibly returns the provided `x` object. If checks fail, a condition error is thrown.
#'
#' @export
#'
#' @importFrom rlang is_empty
check_not_empty <- function(x, arg = rlang::caller_arg(x), call = rlang::caller_env()) {
  if (rlang::is_empty(x)) {
    check_abort("{.arg {arg}} must not be empty.", call = call)
  }
  invisible(x)
}

# types -----------------------------------------------------------------------------------------------------------

#' Check String (Scalar)
#'
#' @description
#' Checks the provided `x` is a scalar string via [rlang::check_string()].
#'
#' @inheritParams check_inherits
#'
#' @returns
#' If checks pass, invisibly returns the provided `x` object. If checks fail, a condition error is thrown.
#'
#' @export
#'
#' @importFrom rlang check_string try_fetch
check_string <- function(x, arg = rlang::caller_arg(x), call = rlang::caller_env()) {
  rlang::try_fetch(
    {
      rlang::check_string(x, allow_empty = FALSE, arg = arg, call = call)
    },
    error = function(err) {
      check_abort("{.arg {arg}} must be a string, not {.obj_type_friendly {x}}.", arg = arg, call = call)
    }
  )
  invisible(x)
}

check_character <- function(x, arg = rlang::caller_arg(x), call = rlang::caller_env()) {
  if (!rlang::is_character(x)) {
    check_abort("{.arg {arg}} must be character, not {.obj_type_friendly {x}}.", call = call)
  }
  invisible(x)
}

check_logical <- function(x, arg = rlang::caller_arg(x), call = rlang::caller_env()) {
  if (!is.logical(x)) {
    check_abort("{.arg {arg}} must be a logical value, not {.obj_type_friendly {x}}.", call = call)
  }
  invisible(x)
}

check_numeric <- function(x, arg = rlang::caller_arg(x), call = rlang::caller_env()) {
  if (!is.numeric(x)) {
    check_abort("{.arg {arg}} must be a numeric value, not {.obj_type_friendly {x}}.", call = call)
  }
  invisible(x)
}

check_integer <- function(x, arg = rlang::caller_arg(x), call = rlang::caller_env()) {
  if (!rlang::is_integer(x)) {
    check_abort("{.arg {arg}} must be an integer, not {.obj_type_friendly {x}}.", call = call)
  }
  invisible(x)
}

check_percent <- function(x, arg = rlang::caller_arg(x), allow_negative = FALSE, call = rlang::caller_env()) {
  check_numeric(x, arg = arg, call = call)
  if (length(x) != 1 || is.na(x)) {
    check_abort("{.arg {arg}} must be a single numeric value, not {.obj_type_friendly {x}}.", call = call)
  }
  if (allow_negative) {
    if (x < -1 || x > 1) {
      check_abort("{.arg {arg}} must be between -1 and 1, not {.val {x}}.", call = call)
    }
  } else {
    if (x < 0 || x > 1) {
      check_abort("{.arg {arg}} must be between 0 and 1, not {.val {x}}.", call = call)
    }
  }
  invisible(x)
}


# expressions -----------------------------------------------------------------------------------------------------

check_function <- function(x, arg = rlang::caller_arg(x), call = rlang::caller_env()) {
  if (!is.function(x)) {
    check_abort("{.arg {arg}} must be a function, not {.obj_type_friendly {x}}.", call = call)
  }
  invisible(x)
}

# structures ------------------------------------------------------------------------------------------------------

check_vector <- function(x, arg = rlang::caller_arg(x), call = rlang::caller_env()) {
  if (!is.vector(x)) {
    check_abort("{.arg {arg}} must be a vector, not {.obj_type_friendly {x}}.", call = call)
  }
  if (length(x) == 0) {
    check_abort("{.arg {arg}} contains no elements.", call = call)
  }
  invisible(x)
}

check_matrix <- function(x, arg = rlang::caller_arg(x), call = rlang::caller_env()) {
  check_inherits(x, "matrix", arg = arg, call = call)
  if (nrow(x) == 0) {
    check_abort("{.arg {arg}} contains no rows.", call = call)
  }
  invisible(x)
}

check_list <- function(x, arg = rlang::caller_arg(x), call = rlang::caller_env()) {
  if (!is.list(x) || is.data.frame(x)) {
    check_abort("{.arg {arg}} must be a list, not {.obj_type_friendly {x}}.", call = call)
  }
  invisible(x)
}

check_data_frame <- function(x, arg = rlang::caller_arg(x), call = rlang::caller_env()) {
  if (!is.data.frame(x)) {
    check_abort("{.arg {arg}} must be a data frame, not {.obj_type_friendly {x}}.", call = call)
  }
  invisible(x)
}

check_tibble <- function(x, arg = rlang::caller_arg(x), call = rlang::caller_env()) {
  check_inherits(x, "tbl_df", arg = arg, call = call)
  invisible(x)
}

check_row <- function(x, arg = rlang::caller_arg(x), call = rlang::caller_env()) {
  check_data_frame(x, arg = arg, call = call)
  if (nrow(x) != 1) {
    check_abort("{.arg {arg}} must be a single row data frame, not {.obj_type_friendly {x}}.", call = call)
  }
  invisible(x)
}

# check_numeric
# check_integer
# check_integer32
# check_integer64
# check_logical
# check_whole_number
# check_date
# check_duration
# check_scalar
# check_vector
# check_matrix
# check_function
# check_expression
# check_list
# check_data_frame
# check_tibble
# check_str

# names -----------------------------------------------------------------------------------------------------------

#' @importFrom rlang is_named
check_named <- function(x, arg = rlang::caller_arg(x), call = rlang::caller_env()) {
  if (!rlang::is_named(x)) {
    check_abort("{.arg {arg}} must be a named vector or list.", call = call)
  }
  invisible(x)
}

#' @importFrom rlang is_named2
check_named2 <- function(x, arg = rlang::caller_arg(x), call = rlang::caller_env()) {
  if (!rlang::is_named2(x)) {
    check_abort("{.arg {arg}} must be a named vector or list.", call = call)
  }
  invisible(x)
}

check_names <- function(x, required, arg = rlang::caller_arg(x), call = rlang::caller_env()) {
  check_named(x, arg = arg, call = call)
  missing_names <- setdiff(required, names(x))
  if (length(missing_names) > 0) {
    check_abort("{.arg {arg}} is missing required names: {.field {missing_names}}.", call = call)
  }
  invisible(x)
}

# gdal ------------------------------------------------------------------------------------------------------------

check_gdal_vector <- function(x, arg = rlang::caller_arg(x), call = rlang::caller_env()) {
  check_inherits(x, "Rcpp_GDALVector")
  invisible(x)
}

check_gdal_raster <- function(x, arg = rlang::caller_arg(x), call = rlang::caller_env()) {
  check_inherits(x, "Rcpp_GDALRaster")
  invisible(x)
}

check_gdal_algorithm <- function(x, arg = rlang::caller_arg(x), call = rlang::caller_env()) {
  check_inherits(x, "Rcpp_GDALAlg")
  invisible(x)
}

check_gdal_driver <- function(x, arg = rlang::caller_arg(x), call = rlang::caller_env()) {
  check_inherits(x, "gdal_driver")
  invisible(x)
}

# `known` lists additional driver names to accept even when not registered in the running GDAL
# build (e.g. the package's core vector drivers, so opts can be crafted for a driver that is not
# locally installed - validation against driver metadata is best-effort and simply no-ops when the
# metadata is unavailable).
check_gdal_driver_name <- function(x, known = NULL, arg = rlang::caller_arg(x), call = rlang::caller_env()) {
  check_string(x, arg = arg, call = call)
  drvs <- gdal_driver_names(pattern = x)
  if (!(toupper(x) %in% toupper(c(drvs, known)))) {
    check_abort(
      "{.arg {arg}} must be a valid GDAL driver. Run {.code gdal_drivers_list()} for available options.",
      call = call
    )
  }
  invisible(x)
}

check_gdal_dsn <- function(x, arg = rlang::caller_arg(x), call = rlang::caller_env()) {
  check_inherits(x, "gdal_dsn", arg = arg, call = call)
  invisible(x)
}

check_dsn <- function(x, arg = rlang::caller_arg(x), call = rlang::caller_env()) {
  rlang::check_string(x, allow_empty = FALSE, arg = arg, call = call)
  invisible(x)
}

check_open_opts <- function(x, arg = rlang::caller_arg(x), call = rlang::caller_env()) {
  check_inherits(x, "gdal_open_opts", arg = arg, call = call)
  invisible(x)
}

check_gdalg <- function(x, arg = rlang::caller_arg(x), call = rlang::caller_env()) {
  check_inherits(x, "gdalg", arg = arg, call = call)
  invisible(x)
}

# assert a (non-NULL) option value is one of the driver's advertised values. the
# allowed set is sourced from driver metadata by the caller (e.g. via
# `gdal_driver_get_open_opts_values()`); an `NA`/empty set means unconstrained.
check_gdal_opt <- function(value, allowed, arg = rlang::caller_arg(value), call = rlang::caller_env()) {
  if (is.null(value)) {
    return(invisible(value))
  }
  allowed <- allowed[!is.na(allowed)]
  if (length(allowed) > 0L && !(toupper(value) %in% toupper(allowed))) {
    check_abort("{.arg {arg}} must be one of {.val {allowed}}, not {.val {value}}.", call = call)
  }
  invisible(value)
}

# validate a built option list against a driver's advertised values (one entry
# per option name). `values` is a named list as returned by
# `gdal_driver_get_*_opts_values()`; options with no constrained set are skipped.
check_gdal_opts <- function(opts, values, call = rlang::caller_env()) {
  for (nm in names(opts)) {
    check_gdal_opt(opts[[nm]], values[[nm]], arg = nm, call = call)
  }
  invisible(opts)
}

check_creation_opts <- function(x, arg = rlang::caller_arg(x), call = rlang::caller_env()) {
  check_inherits(x, "gdal_creation_opts", arg = arg, call = call)
  invisible(x)
}

check_config_opts <- function(x, arg = rlang::caller_arg(x), call = rlang::caller_env()) {
  check_inherits(x, "gdal_config_opts", arg = arg, call = call)
  invisible(x)
}

check_vsi_opts <- function(x, arg = rlang::caller_arg(x), call = rlang::caller_env()) {
  check_inherits(x, "gdal_vsi_opts", arg = arg, call = call)
  invisible(x)
}

# terra -----------------------------------------------------------------------------------------------------------

# httr2 -----------------------------------------------------------------------------------------------------------

check_request <- function(x, arg = rlang::caller_arg(x), call = rlang::caller_env()) {
  check_inherits(x, "httr2_request", arg = arg, call = call)
  invisible(x)
}

check_requests <- function(x, arg = rlang::caller_arg(x), call = rlang::caller_env()) {
  check_list(x, arg = arg, call = call)
  purrr::walk(x, check_request, call = call)
  invisible(x)
}

check_response <- function(x, arg = rlang::caller_arg(x), call = rlang::caller_env()) {
  check_inherits(x, "httr2_response", arg = arg, call = call)
  invisible(x)
}

check_responses <- function(x, arg = rlang::caller_arg(x), call = rlang::caller_env()) {
  check_list(x, arg = arg, call = call)
  purrr::walk(x, check_response, call = call)
  invisible(x)
}

check_headers <- function(x, arg = rlang::caller_arg(x), call = rlang::caller_env()) {
  check_inherits(x, "httr2_headers", arg = arg, call = call)
  invisible(x)
}

# files/paths -----------------------------------------------------------------------------------------------------

check_path <- function(x, arg = rlang::caller_arg(x), call = rlang::caller_env()) {
  rlang::check_string(x, allow_empty = FALSE, arg = arg, call = call)
  if (!file.exists(x)) {
    check_abort("{.arg {arg}} must be a valid file or folder path: {.file {x}} does not exist.", call = call)
  }
  invisible(x)
}

check_folder <- function(x, arg = rlang::caller_arg(x), call = rlang::caller_env()) {
  rlang::check_string(x, allow_empty = FALSE, arg = arg, call = call)
  if (!dir.exists(x)) {
    check_abort("{.arg {arg}} must be a valid folder path: {.path {x}} does not exist.", call = call)
  }
  invisible(x)
}

check_file <- function(x, ext = NULL, arg = rlang::caller_arg(x), call = rlang::caller_env()) {
  check_path(x, arg = arg, call = call)
  if (is.null(ext)) {
    return(invisible(x))
  }
  ext <- tolower(ext)
  ext <- gsub("*", "", ext, fixed = TRUE)
  # ext <- gsub(".", "", ext, fixed = TRUE)
  ext <- gsub("^\\.", "", ext)
  # ext_parts <- strsplit(ext, ".", fixed = TRUE)[[1]]
  # if (length(ext_parts) > 1L) {
  #   # for each ext_part, check, in order, it against the initial path, then the extension of the initial path sans ext, ...
  #   for (i in seq_along(ext_parts)) {
  #     ext_part <- ext_parts[i]
  #     if (tolower(tools::file_ext(x)) == ext_part) {
  #       return(invisible(x))
  #     }
  #     x <- sub(paste0("\\.", tools::file_ext(x), "$"), "", x)
  #   }
  # }

  if (length(ext) > 1L) {
    if (!any(tools::file_ext(x) %in% ext)) {
      check_abort("{.arg {arg}} must have one of the following extensions: {.field {ext}}.", call = call)
    }
  } else {
    if (tools::file_ext(x) != ext) {
      check_abort("{.arg {arg}} must have the extension {.field {ext}}.", call = call)
    }
  }
  invisible(x)
}

check_executable <- function(x, arg = rlang::caller_arg(x), call = rlang::caller_env()) {
  check_path(x, arg = arg, call = call)
  if (sys_platform() == "windows") {
    check_file(x, ext = c("cmd", "ps1", "bat", "exe", "R", "py", "vbs"), arg = arg, call = call)
  } else {
    executable <- fs::file_access(x, mode = "execute")
    if (!executable) {
      mode <- file.mode(x)
      perms <- fs::as_fs_perms(mode)
      str <- paste0(mode, " (", perms, ")")
      check_abort("{.arg {arg}} must be an executable file, not {.field {str}}")
    }
    invisible(x)
  }
}

check_vsi_path <- function(x, ext = NULL, arg = rlang::caller_arg(x), call = rlang::caller_env()) {
  if (!is_vsi_path(x)) {
    check_file(x, ext = ext, arg = arg, call = call)
  } else {
    if (is.null(ext)) {
      check_path(vsi_strip(x), arg = arg, call = call)
    } else {
      check_file(vsi_strip(x), ext = ext, arg = arg, call = call)
    }
  }
  invisible(x)
}

# connections -----------------------------------------------------------------------------------------------------

# supported types of connections:
# - DBI general (s4: DBIConnection, DBIObject)
# - Pool general (R6: Pool)
# - RStudio connections (s4: connConnection)
#
# SQLite via RSQLite (SQLiteConnection)
# Postgres via RPostgres (PqConnection)
# geopackage via gpkg (geopackage)
# DuckDB via duckdb (duckdb_connection)
#
# All of the above but via adbc (adbc_database)
# SedonaDB via sedonadb::sd_connect()

check_conn_dbi <- function(x, arg = rlang::caller_arg(x), call = rlang::caller_env()) {
  check_inherits2(x, "DBIConnection", arg = arg, call = call)
  invisible(x)
}

check_conn_pool <- function(x, arg = rlang::caller_arg(x), call = rlang::caller_env()) {
  check_inherits(x, "Pool", arg = arg, call = call)
  invisible(x)
}

check_conn_rstudio <- function(x, arg = rlang::caller_arg(x), call = rlang::caller_env()) {
  check_inherits(x, "connConnection", arg = arg, call = call)
  invisible(x)
}

check_conn_sqlite <- function(x, arg = rlang::caller_arg(x), call = rlang::caller_env()) {
  check_inherits(x, "SQLiteConnection", arg = arg, call = call)
  invisible(x)
}

check_conn_postgres <- function(x, arg = rlang::caller_arg(x), call = rlang::caller_env()) {
  check_inherits(x, "PqConnection", arg = arg, call = call)
  invisible(x)
}

check_postgres_uri <- function(x, arg = rlang::caller_arg(x), call = rlang::caller_env()) {
  check_string(x, call = call)
  parsed <- rlang::try_fetch(
    {
      httr2::url_parse(x)
    },
    error = function(err) {
      check_abort("Invalid database URI provided: {.arg {arg}}, must be a valid URI", call = call)
    }
  )
  conds <- all(
    identical("postgresql", parsed$scheme),
    !is.null(parsed$hostname),
    !is.null(parsed$username),
    !is.null(parsed$password),
    !is.null(parsed$path),
    parsed$path != ""
  )
  if (!conds) {
    check_abort(
      "Provided URI {.arg {arg}} must contain valid hostname, username, password, and database for a postgresql:// scheme",
      call = call
    )
  }
  invisible(x)
}

check_adbc_driver <- function(x, arg = rlang::caller_arg(x), call = rlang::caller_env()) {
  check_inherits_all(x, c("adbc_driver", "adbc_xptr"), arg = arg, call = call)
  invisible(x)
}

check_db_adbc <- function(x, arg = rlang::caller_arg(x), call = rlang::caller_env()) {
  check_inherits(x, "adbc_database", arg = arg, call = call)
  invisible(x)
}

check_conn_adbc <- function(x, arg = rlang::caller_arg(x), call = rlang::caller_env()) {
  check_inherits(x, "adbc_connection", arg = arg, call = call)
  invisible(x)
}

check_db_adbc_sqlite <- function(x, arg = rlang::caller_arg(x), call = rlang::caller_env()) {
  check_inherits(x, "adbcsqlite_database", arg = arg, call = call)
  invisible(x)
}

check_conn_adbc_sqlite <- function(x, arg = rlang::caller_arg(x), call = rlang::caller_env()) {
  check_inherits(x, "adbcsqlite_connection", arg = arg, call = call)
  invisible(x)
}

check_db_adbc_postgres <- function(x, arg = rlang::caller_arg(x), call = rlang::caller_env()) {
  check_inherits(x, "adbcpostgresql_database", arg = arg, call = call)
  invisible(x)
}

check_conn_adbc_postgres <- function(x, arg = rlang::caller_arg(x), call = rlang::caller_env()) {
  check_inherits(x, "adbcpostgresql_connection", arg = arg, call = call)
  invisible(x)
}

check_conn_gpkg <- function(x, arg = rlang::caller_arg(x), call = rlang::caller_env()) {
  check_inherits_any(x, c("geopackage", "SQLiteConnection", "adbcsqlite_connection"), arg = arg, call = call)
  invisible(x)
}

check_conn_duckdb <- function(x, arg = rlang::caller_arg(x), call = rlang::caller_env()) {
  check_inherits(x, "duckdb_connection", arg = arg, call = call)
  invisible(x)
}

check_conn_sedona <- function(x, arg = rlang::caller_arg(x), call = rlang::caller_env()) {
  check_inherits(x, "sedonadb::InternalContext")
  invisible(x)
}

check_conn_postgis <- function(x, arg = rlang::caller_arg(x), call = rlang::caller_env()) {
  check_inherits_any(x, c("Pool", "PqConnection", "adbcpostgresql_database"), arg = arg, call = call)
  invisible(x)
}


# regex -----------------------------------------------------------------------------------------------------------

check_regex <- function(x, pattern, arg = rlang::caller_arg(x), call = rlang::caller_env()) {
  if (!grepl(pattern, x)) {
    check_abort("{.arg {arg}} must match the regular expression pattern: {.field {pattern}}.", call = call)
  }
  invisible(x)
}

# urls ------------------------------------------------------------------------------------------------------------

check_url <- function(x, arg = rlang::caller_arg(x), call = rlang::caller_env()) {
  rlang::check_string(x, allow_empty = FALSE, arg = arg, call = call)
  check_regex(x, pattern = "^(http|https)://", arg = arg, call = call)
  invisible(x)
}

check_httr2_url <- function(x, arg = rlang::caller_arg(x), call = rlang::caller_env()) {
  check_inherits(x, "httr2_url", arg = arg, call = call)
  invisible(x)
}

check_arcgis_url <- function(x, arg = rlang::caller_arg(x), call = rlang::caller_env()) {
  check_inherits(x, "arcgis_url", arg = arg, call = call)
  invisible(x)
}

check_tiger_url <- function(x, arg = rlang::caller_arg(x), call = rlang::caller_env()) {
  check_inherits(x, "tiger_url", arg = arg, call = call)
  invisible(x)
}

check_ipv4 <- function(x, arg = rlang::caller_arg(x), call = rlang::caller_env()) {
  rlang::check_string(x, allow_empty = FALSE, arg = arg, call = call)
  pattern <- "^((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$"
  check_regex(x, pattern = pattern, arg = arg, call = call)
  invisible(x)
}


# json ------------------------------------------------------------------------------------------------------------

check_json_str <- function(x, arg = rlang::caller_arg(x), call = rlang::caller_env()) {
  if (!is_valid_json_str(x)) {
    check_abort("{.arg {arg}} must be a valid JSON string.", arg = arg, call = call)
  }
  invisible(x)
}

check_json_file <- function(x, arg = rlang::caller_arg(x), call = rlang::caller_env()) {
  if (!is_valid_json_file(x)) {
    check_abort("{.arg {arg}} must be a valid path to a JSON file.", arg = arg, call = call)
  }
  invisible(x)
}

check_json_schema_file <- function(x, arg = rlang::caller_arg(x), call = rlang::caller_env()) {
  check_file(x, ext = "json", arg = arg, call = call)
  check_json_file(x, arg = arg, call = call)
  invisible(x)
}

# xml -------------------------------------------------------------------------------------------------------------

check_xml <- function(x, arg = rlang::caller_arg(x), call = rlang::caller_env()) {
  check_inherits_any(x, c("xml_document", "xml_node", "xml_nodeset"), arg = arg, call = call)
  invisible(x)
}

check_xml_string <- function(x, arg = rlang::caller_arg(x), call = rlang::caller_env()) {
  if (!is_xml_string(x)) {
    check_abort("{.arg {arg}} must be a valid, parsable XML string.", arg = arg, call = call)
  }
  invisible(x)
}

check_xml_document <- function(x, arg = rlang::caller_arg(x), call = rlang::caller_env()) {
  check_inherits(x, "xml_document", arg = arg, call = call)
  invisible(x)
}

check_xml_file <- function(x, arg = rlang::caller_arg(x), call = rlang::caller_env()) {
  check_file(x, ext = c("xml", "xsd"), arg = arg, call = call)
  invisible(x)
}

check_xsd_file <- function(x, arg = rlang::caller_arg(x), call = rlang::caller_env()) {
  check_file(x, ext = c("xsd", "schema.xsd"), arg = arg, call = call)
  invisible(x)
}


# system ----------------------------------------------------------------------------------------------------------

#' Check Available RAM
#'
#' @description
#' Checks that the provided value `x` (in bytes) does not exceed the available system RAM as returned by
#' [sys_available_ram()]. If the check fails, an error is thrown.
#'
#' @inheritParams check_inherits
#'
#' @returns
#' If the check passes, invisibly returns the provided `x` value. If the check fails, a condition error is thrown
#' indicating that the provided value exceeds available system RAM.
#'
#' @export
check_available_ram <- function(x, arg = rlang::caller_arg(x), call = rlang::caller_env()) {
  sys_ram <- sys_available_ram()
  if (sys_ram <= x) {
    check_abort(
      "Provided {.arg {arg}} value of {.val {x}} bytes exceeds available system RAM of {.val {sys_ram}} bytes.",
      call = call
    )
  }
  invisible(x)
}

# spatial ---------------------------------------------------------------------------------------------------------

check_crs <- function(x, arg = rlang::caller_arg(x), call = rlang::caller_env()) {
  check_inherits_any(x, c("crs", "crs_wkt", "crs_proj"), arg = arg, call = call)
  invisible(x)
}

check_crs_epsg <- function(x, expected_epsg, arg = rlang::caller_arg(x), call = rlang::caller_env()) {
  check_crs(x, arg = arg, call = call)
  epsg <- sf::st_crs(x)$epsg
  if (is.na(epsg) || epsg != expected_epsg) {
    check_abort(
      "Provided {.arg {arg}} CRS {.field {epsg}} does not match expected {.field {expected_epsg}}",
      call = call
    )
  }
  invisible(x)
}

