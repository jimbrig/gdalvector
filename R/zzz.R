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
#' @importFrom utils modifyList
rlang::on_load({
  pkg_env_init()
  gdal_config_init()
  gdal_drivers_init()
  rlang::local_use_cli()
  # layer the package's custom inline span styles (`.drv`, `.optname`, `.optval`, ...) onto the active cli theme
  # so output formatters can use them without re-applying a local theme on every call.
  options(cli.theme = utils::modifyList(getOption("cli.theme", default = list()), gdalvector_cli_theme()))
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
