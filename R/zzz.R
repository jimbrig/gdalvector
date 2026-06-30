#  ------------------------------------------------------------------------
#
# Title : zzz.R - onLoad & onAttach & initialization
#    By : Jimmy Briggs
#  Date : 2026-05-31
#
#  ------------------------------------------------------------------------

# environment -----------------------------------------------------------------------------------------------------

#' @keywords internal
#' @noRd
#' @importFrom rlang new_environment
.pkg_env <- rlang::new_environment()

# initializers ----------------------------------------------------------------------------------------------------

#' @keywords internal
#' @noRd
#' @importFrom rlang on_load local_use_cli
rlang::on_load({
  pkg_env_init()
  gdal_config_init()
  gdal_drivers_init()
  rlang::local_use_cli()
})

# onLoad ----------------------------------------------------------------------------------------------------------

#' @keywords internal
#' @noRd
#' @importFrom rlang run_on_load
.onLoad <- function(libname, pkgname) {
  rlang::run_on_load()
}

# onAttach --------------------------------------------------------------------------------------------------------

#' @keywords internal
#' @noRd
.onAttach <- function(libname, pkgname) {
  packageStartupMessage(pkg_startup_msg())
}


# onUnload --------------------------------------------------------------------------------------------------------

#' @keywords internal
#' @noRd
.onUnload <- function(libpath) {
  # TODO:
  # if any connections or stateful stashed classes are in the pkg_env etc. they s/b closed/released/managed properly...
  # reg.finalizer(...)
  # rlang::try_fetch({ DBI::dbDisconnect(db_store$get("conn")) }, error = function(e) NULL)
}


# onDetach --------------------------------------------------------------------------------------------------------

#' @keywords internal
#' @noRd
.onDetach <- function(libpath) {
  # ...
}
