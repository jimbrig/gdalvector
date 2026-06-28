#  ------------------------------------------------------------------------
#
# Title : gdalvector package
#    By : Jimmy Briggs
#  Date : 2026-05-31
#
#  ------------------------------------------------------------------------

# package docs ----------------------------------------------------------------------------------------------------

#' `gdalvector` Package
#'
#' @description
#' The `gdalvector` package provides tools for working with vector data using modern GDAL bindings in R. It builds
#' on top of the `gdalraster` package, but focuses on vector data sources and modern cloud-native formats and
#' specifications.
#'
#' @keywords internal
"_PACKAGE"

# imports ---------------------------------------------------------------------------------------------------------

## usethis namespace: start
#' @importFrom cli cli_abort cli_warn cli_inform
#' @importFrom rlang caller_arg caller_env caller_call caller_fn call_inspect current_call current_env current_fn
#' @importFrom rlang .data .env `%||%` `!!` `:=` `!!!`
#' @importFrom rlang abort warn inform cnd cnd_type error_cnd warning_cnd message_cnd cnd_signal catch_cnd try_fetch trace_back
#' @importFrom rlang new_environment empty_env on_load run_on_load local_use_cli
#' @importFrom stats setNames
#' @importFrom utils globalVariables modifyList packageVersion
## usethis namespace: end
NULL

# global variables -------------------------------------------------------

#' @keywords internal
#' @noRd
utils::globalVariables(c())
