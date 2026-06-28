#  ------------------------------------------------------------------------
#
# Title : System Utilities
#    By : Jimmy Briggs
#  Date : 2026-06-02
#
#  ------------------------------------------------------------------------

read_renviron <- function(path = NULL) {
  if (is.null(path)) {
    path <- getwd()
  }
  file <- file.path(path, ".Renviron")
  if (!file.exists(file)) {
    return(invisible(NULL))
  }
  readRenviron(file)
  cli::cli_alert_success("Loaded environment variables from {.file {file}}.")
}


# RAM -------------------------------------------------------------------------------------------------------------

#' `sys_available_ram` - System Available RAM
#'
#' @description
#' Get the amount of usable physical RAM available to the R session using [gdalraster::get_usable_physical_ram()],
#' which calls the `CPLGetUsablePhysicalRAM()` C++ function from GDAL's Common Portable Library (CPL).
#'
#' @details
#' This function returns the total *physical RAM usable by a process, in bytes*.
#'
#' It will be limited to **2GB** for 32-bit processes.
#'
#' It takes into account resource limits (virtual memory) of POSIX systems. It additionally will take into account
#' `RLIMIT_RSS` on Linux.
#'
#' On Windows, it will return the total physical RAM minus the memory used by the system and other processes, as
#' reported by the Windows API, in bytes.
#'
#' @section FlatGeobuf Spatial Index RAM Check:
#'
#' This memory may already be partly accounted for by other processes, but is still useful for estimating how much
#' RAM is available for processing large vector data without causing out-of-memory errors.
#'
#' It is used by the [check_available_ram()] check utility which is used in [fgb_validate_spatial_index_ram()] to
#' ensure that there is sufficient RAM to build a spatial index for a given dataset:
#'
#' "The creation of the packet Hilbert R-Tree requires an amount of RAM which is at least the number of
#' features times 83 bytes."
#'
#' @returns
#' A numeric scalar representing the number of bytes as a [bit64::integer64()] type (or zero `0` in case of failure).
#'
#' @export
#'
#' @importFrom gdalraster get_usable_physical_ram
#'
#' @examples
#' \dontrun{
#' sys_available_ram()
#' }
sys_available_ram <- function() {
  gdalraster::get_usable_physical_ram()
}


# cpus ------------------------------------------------------------------------------------------------------------

#' `sys_num_cpus` - System Number of CPUs
#'
#' @description
#' Get the number of CPU cores available on the current machine using [gdalraster::get_num_cpus()],
#' which calls the internal GDAL C++ library function `GDALGetCPUs()`.
#'
#' @details
#' This method is more robust than `parallel::detectCores()` because it accounts for CPU
#' affinity, container limits, and other environmental restrictions that may cap the processing
#' pools actually available to the R session.
#'
#' However, on a standard unconstrained desktop machine, it will return the same value as
#' `parallel::detectCores(logical = TRUE)` because both report the total logical processing channels.
#'
#' - **Number of CPUs (GDAL):** `gdalraster::get_num_cpus()` queries the C++ backend to see how many logical
#'   execution slots (hardware threads) are exposed by the operating system.
#'
#' - **Number of Cores (parallel):** `parallel::detectCores(logical = TRUE)` targets the virtual threads generated
#'   by Hyper-Threading (Intel) or SMT (AMD). Conversely, running `parallel::detectCores(logical = FALSE)` attempts
#'   to return only the count of independent physical cores on the processor.
#'
#' @returns
#' Integer representing the number of CPU cores available to the R session.
#'
#' @importFrom gdalraster get_num_cpus
#'
#' @export
#'
#' @examples
#' \dontrun{
#' sys_num_cpus()
#' }
sys_num_cpus <- function() {
  gdalraster::get_num_cpus()
}


# which -----------------------------------------------------------------------------------------------------------

#' `sys_which` - System `which`
#'
#' @description
#' Lightweight, convenience wrapper around [base::Sys.which()] and [base::normalizePath()].
#'
#' @param x Passed to `Sys.which()` `names` argument.
#' @inheritParams base::normalizePath winslash
#' @inheritDotParams base::normalizePath
#'
#' @returns
#' Character vector of paths, if found. If not found returns `NULL` instead of `""`.
#'
#' @export
#'
#' @examples
#' \dontrun{
#' sys_which("gdal")
#' }
sys_which <- function(x, winslash = "/", ...) {
  hold <- Sys.which(x)
  if (!nzchar(hold)) {
    return(NULL)
  }
  normalize_path(hold, winslash = winslash, ...)
}


# platform & operating system -------------------------------------------------------------------------------------

#' `sys_platform` - System Platform
#'
#' @description
#' Get the current machine's platform (operating system "family")
#'
#' @returns
#' Character string resulting from `.Platform$OS.type`
#'
#' @export
#'
#' @examples
#' \dontrun{
#' sys_platform()
#' }
sys_platform <- function() {
  .Platform$OS.type
}

#' `sys_os` - System OS Name
#'
#' @description
#' Get the current machine's operating system name.
#'
#' @returns
#' Character string resulting from `Sys.info()[["sysname"]]`, which will be one of c("windows", "linux", "darwin", etc.)
#' depending on the system.
#'
#' @export
#'
#' @examples
#' \dontrun{
#' sys_os()
#' }
sys_os <- function() {
  Sys.info()[["sysname"]]
}


# path ------------------------------------------------------------------------------------------------------------

#' `sys_path` - System PATH
#'
#' @description
#' Get the Current Machine's PATH Environment Variable as a Character Vector
#'
#' @param filter Optional character string. If provided, only paths containing this string will be returned.
#'
#' @returns
#' Character vector of paths from the system's `PATH` environment variable, split by the appropriate path separator
#' for the operating system. If `filter` is provided, only paths containing the filter string are included in the
#' returned vector. If no paths match the filter, an empty character vector is returned: `character(0)`.
#'
#' If `filter` is provided, only paths containing the filter string are returned.
#'
#' @export
#'
#' @importFrom stringr str_split
#'
#' @examples
#' \dontrun{
#' sys_path()
#' }
sys_path <- function(filter = NULL) {
  path_sep <- if (sys_platform() == "windows") ";" else ":"
  hold <- Sys.getenv("PATH") |> stringr::str_split() |> unlist() |> normalize_path()
  if (is.null(filter)) {
    return(hold)
  }
  hold[stringr::str_detect(hold, filter)]
}

# process id ------------------------------------------------------------------------------------------------------

#' `sys_pid` - System Process ID
#'
#' @description
#' Get the current process ID of the R session.
#'
#' @returns
#' Integer representing the current process ID.
#'
#' @export
#'
#' @examples
#' \dontrun{
#' sys_pid()
#' }
sys_pid <- function() {
  Sys.getpid()
}


# error codes -----------------------------------------------------------------------------------------------------

#' `sys_error_code` - System Error Codes
#'
#' @description
#' Get system error codes and their descriptions. If a specific code is provided, returns the
#' name, value, and description for that code. If no code is provided, returns a tibble of all system error codes.
#'
#' @param code (Optional) Integer or character string representing the system error code to look up.
#'   If `NULL` (the default), returns all system error codes. Can be one or more codes to filter by.
#'
#' @returns
#' A [tibble::tibble()] with the `name`, `value`, and `description` of the system error code(s).
#' If one or more codes are provided, returns only the matching code(s). If no codes are found, returns `NULL` invisibly.
#'
#' @export
#'
#' @seealso [ps::errno()] for the underlying system error codes data.
#'
#' @importFrom ps errno
#' @importFrom tibble as_tibble
#' @importFrom dplyr filter
#' @importFrom cli cli_alert_warning
#'
#' @examples
#' \dontrun{
#' # Get all system error codes
#' sys_error_code()
#'
#' # Get specific error code information
#' sys_error_code(2)  # Example: ENOENT (No such file or directory)
#' }
sys_error_code <- function(code = NULL) {
  errs <- ps::errno() |> tibble::as_tibble()
  if (is.null(code)) {
    return(errs)
  }
  code <- as.integer(code)
  if (!code %in% errs$value) {
    cli::cli_alert_warning("Error code {.val {code}} not found in system error codes.")
    return(invisible(NULL))
  }
  errs |> dplyr::filter(.data$value %in% .env$code)
}

# internal --------------------------------------------------------------------------------------------------------

#' @keywords internal
#' @noRd
normalize_path <- function(path, winslash = "/", ...) {
  normalizePath(path, winslash = winslash, mustWork = FALSE, ...)
}
