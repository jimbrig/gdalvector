#  ------------------------------------------------------------------------
#
# Title : Package Utilities
#    By : Jimmy Briggs
#  Date : 2026-05-31
#
#  ------------------------------------------------------------------------

# meta ------------------------------------------------------------------------------------------------------------

#' @keywords internal
#' @noRd
pkg_name <- function() {
  "gdalvector"
}

#' @keywords internal
#' @noRd
#' @importFrom utils packageVersion
pkg_version <- local({
  version <- NULL
  function() {
    if (is.null(version)) {
      version <<- as.character(utils::packageVersion(pkg_name()))
    }
    version
  }
})

# user agent ------------------------------------------------------------------------------------------------------

#' @keywords internal
#' @noRd
pkg_user_agent <- function() {
  paste0(pkg_name(), "/", pkg_version())
}

# system file -----------------------------------------------------------------------------------------------------

#' @keywords internal
#' @noRd
pkg_sys <- function(...) {
  system.file(..., package = pkg_name())
}

#' @keywords internal
#' @noRd
pkg_sys_config <- function(...) {
  pkg_sys("config", ...)
}

#' @keywords internal
#' @noRd
pkg_sys_extdata <- function(...) {
  pkg_sys("extdata", ...)
}

#' @keywords internal
#' @noRd
pkg_sys_schemas <- function(...) {
  pkg_sys("schemas", ...)
}

# example datasets ------------------------------------------------------------------------------------------------

pkg_example_data <- function(...) {
  if (length(rlang::list2(...)) == 0L) {
    fs::dir_tree(pkg_sys_extdata(), recurse = TRUE, regexp = "*.(gpkg|shp|geojson|json|csv|tsv|txt)", type = "file")
    return(invisible(NULL))
  }
  path <- pkg_sys_extdata(...)
  if (!file.exists(path)) {
    cli::cli_alert_danger("Example dataset {.val {path}} does not exist.")
    return(invisible(NULL))
  }
  path
}

# banner ----------------------------------------------------------------------------------------------------------

#' @keywords internal
#' @noRd
pkg_banner <- function() {
  # banner_lines <- readLines(pkg_sys_config("BANNER.txt"))
  # paste(banner_lines, collapse = "\n")
  .pkg_banner_str
}

# startup message -------------------------------------------------------------------------------------------------

#' @keywords internal
#' @noRd
#' @importFrom crayon green cyan yellow bold italic
pkg_startup_msg <- function() {
  msg_banner <- paste0(crayon::cyan(crayon::bold(pkg_banner())), "\n")
  msg_title <- paste0(crayon::bold(crayon::cyan(pkg_name(), paste0("v", pkg_version()))))
  msg_desc <- crayon::italic(crayon::cyan("Modern Package for GDAL Vector Data"))
  paste0(msg_banner, msg_title, " - ", msg_desc)
}

# environment -----------------------------------------------------------------------------------------------------

#' @keywords internal
#' @noRd
#' @importFrom rlang new_environment
pkg_env_init <- function() {
  if (!exists(".pkg_env")) {
    return()
  }

  # package config
  .pkg_env$config <- rlang::new_environment()
  .pkg_env$config$path <- Sys.getenv("R_CONFIG_FILE", pkg_sys_config("config.yml"))
  .pkg_env$config$active <- Sys.getenv("R_CONFIG_ACTIVE", "default")

  # gdal
  .pkg_env$gdal <- rlang::new_environment()
  .pkg_env$gdal$version <- NULL
  .pkg_env$gdal$sitrep <- rlang::new_environment()
  .pkg_env$gdal$config <- rlang::new_environment()
  .pkg_env$gdal$vsi <- rlang::new_environment()
  .pkg_env$gdal$drivers <- rlang::new_environment()
}

#' @keywords internal
#' @noRd
#' @importFrom rlang env_get
pkg_env_get <- function(key, default = NULL) {
  rlang::env_get(env = .pkg_env, nm = key, default = default)
}

#' @keywords internal
#' @noRd
#' @importFrom rlang env_poke
pkg_env_set <- function(key, value, create = FALSE) {
  rlang::env_poke(env = .pkg_env, nm = key, value = value, create = create)
}

#' @keywords internal
#' @noRd
#' @importFrom rlang env_cache
pkg_env_cache <- function(key, default) {
  rlang::env_cache(env = .pkg_env, nm = key, default = default)
}

# verbosity -------------------------------------------------------------------------------------------------------

pkg_is_verbose <- function() {
  getOption("gdalvector.verbose", default = "inform") %in% c("inform", "debug")
}

pkg_is_debug <- function() {
  identical(getOption("gdalvector.verbose", default = "inform"), "debug")
}


# internal --------------------------------------------------------------------------------------------------------

.pkg_banner_str <- r"(
              __      __                __
   ____ _____/ /___ _/ /   _____  _____/ /_____  _____
  / __ `/ __  / __ `/ / | / / _ \/ ___/ __/ __ \/ ___/
 / /_/ / /_/ / /_/ / /| |/ /  __/ /__/ /_/ /_/ / /
 \__, /\__,_/\__,_/_/ |___/\___/\___/\__/\____/_/
/____/
)"
