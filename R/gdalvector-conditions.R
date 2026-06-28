#  ------------------------------------------------------------------------
#
# Title : Package Conditions
#    By : Jimmy Briggs
#  Date : 2026-04-26
#
#  ------------------------------------------------------------------------

# topic -----------------------------------------------------------------------------------------------------------

# TODO

# conditions ------------------------------------------------------------------------------------------------------

gdal_abort <- function(
  msg = NULL,
  cls = NULL,
  ...,
  parent = NULL,
  call = rlang::caller_env(),
  .envir = parent.frame()
) {
  classes <- c(cls, "gdal_error", "gdal_condition")
  cli::cli_abort(message = msg, class = classes, parent = parent, call = call, .envir = .envir, ...)
}

gdal_warn <- function(msg, cls = NULL, ..., .envir = parent.frame()) {
  classes <- c(cls, "gdal_warning", "gdal_condition")
  cli::cli_warn(message = msg, class = classes, .envir = .envir, ...)
}

gdal_inform <- function(msg, cls = NULL, ..., .envir = parent.frame()) {
  classes <- c(cls, "gdal_message", "gdal_condition")
  cli::cli_inform(message = msg, class = classes, .envir = .envir, ...)
}

# checks ----------------------------------------------------------------------------------------------------------

gdal_abort_check <- function(msg, ..., call = rlang::caller_env(), .envir = parent.frame()) {
  gdal_abort(msg = msg, cls = "gdal_check_error", ..., call = call, .envir = .envir)
}

gdal_warn_check <- function(msg, ..., call = rlang::caller_env(), .envir = parent.frame()) {
  gdal_warn(msg = msg, cls = "gdal_check_warning", ..., call = call, .envir = .envir)
}

gdal_inform_check <- function(msg, ..., call = rlang::caller_env(), .envir = parent.frame()) {
  gdal_inform(msg = msg, cls = "gdal_check_message", ..., .envir = .envir)
}

# validations -----------------------------------------------------------------------------------------------------

gdal_abort_validation <- function(x, ..., call = rlang::caller_env(), .envir = parent.frame()) {
  check_inherits(x, "gdal_validation", call = call)
}

# custom ---------------------------------------------------------------------------------------------------------

gdal_abort_open <- function(msg, ..., call = rlang::caller_env(), .envir = parent.frame()) {
  gdal_abort(msg = msg, cls = "gdal_open_error", call = call, .envir = .envir, ...)
}

gdal_abort_driver <- function(msg, ..., call = rlang::caller_env(), .envir = parent.frame()) {
  gdal_abort(msg = msg, cls = "gdal_driver_error", call = call, .envir = .envir, ...)
}

gdal_abort_layer <- function(msg, ..., call = rlang::caller_env(), .envir = parent.frame()) {
  gdal_abort(msg = msg, cls = "gdal_layer_error", call = call, .envir = .envir, ...)
}

gdal_abort_vsi <- function(msg, ..., call = rlang::caller_env(), .envir = parent.frame()) {
  gdal_abort(msg = msg, cls = "gdal_vsi_error", call = call, .envir = .envir, ...)
}

gdal_abort_opts <- function(msg, cls = NULL, ..., call = rlang::caller_env(), .envir = parent.frame()) {
  gdal_abort(msg = msg, cls = c(cls, "gdal_opts_error"), call = call, .envir = .envir, ...)
}

gdal_warn_opts <- function(msg, cls = NULL, ..., .envir = parent.frame()) {
  gdal_warn(msg = msg, cls = c(cls, "gdal_opts_warning"), .envir = .envir, ...)
}

gdal_inform_opts <- function(msg, cls = NULL, ..., .envir = parent.frame()) {
  gdal_inform(msg = msg, cls = c(cls, "gdal_opts_message"), .envir = .envir, ...)
}
