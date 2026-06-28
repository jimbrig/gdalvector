#  ------------------------------------------------------------------------
#
# Title : FlatGeoBuf Validation
#    By : Jimmy Briggs
#  Date : 2026-06-11
#
#  ------------------------------------------------------------------------

# constants -------------------------------------------------------------------------------------------------------

#' @keywords internal
#' @noRd
FGB_MAGIC_BYTES <- as.raw(c(0x66, 0x67, 0x62, 0x03, 0x66, 0x67, 0x62, 0x01))


# main validation -------------------------------------------------------------------------------------------------

fgb_validate <- function(fgb_dsn, ...) {
  sep <- "-------------------------------------------"
  msg_checks <- c("FlatGeoBuf Validation Checks", sep, c("i" = "FlatGeoBuf DSN: {.path {fgb_dsn}}"), sep)
  file_info <- fs::file_info(fgb_dsn)
  # TODO
  cli::cli_bullets(msg_checks)
}


# validate - magic header -----------------------------------------------------------------------------------------

fgb_validate_magic_header <- function(fgb_dsn, quiet = FALSE) {
  header <- fgb_magic_header(fgb_dsn)
  identical(header$raw, FGB_MAGIC_BYTES)
  # new_validation_check_result(
  #   check = identical(header$raw, FGB_MAGIC_BYTES),
  #   msg_success = "Validation of FlatGeoBuf magic bytes header for {.path {basename(path)}} successful!",
  #   msg_failure = "Validation of FlatGeoBuf magic bytes header for {.path {basename(path)}} failed: expected {.field {format_hex(FGB_MAGIC_BYTES)}} but found {.field {format_hex(header$raw)}}.",
  #   path = fgb_dsn
  # )
}

fgb_magic_header <- function(path) {
  if (is_vsi_path(path)) {
    check_abort("Magic header validation not currently supported for VSI paths.")
  }
  check_file(path, ext = "fgb")
  read_magic_header(path = path, n = 8L)
}

# validate - spatial index ----------------------------------------------------------------------------------------

fgb_validate_spatial_index <- function(fgb_dsn) {
  gdal_vector_get_capability(capability = "FastSpatialFilter", fgb_dsn)
}

#' Validate Spatial Index RAM Requirement
#'
#' @description
#' Validates if the available RAM is sufficient to build a spatial index for a FlatGeobuf file based on the number of
#' features and an estimated RAM requirement of 83 bytes per feature.
#'
#' @param fgb_dsn The data source name (DSN) of the FlatGeobuf file to validate.
#' @param force Logical indicating whether to force the feature count (default: `FALSE`).
#' @param quiet Logical indicating whether to suppress success messages (default: `FALSE`).
#'
#' @returns
#' Returns `TRUE` if sufficient RAM is available to build the spatial index, and `FALSE` otherwise.
#' Also provides informative messages about the RAM requirements and availability.
#'
#' @export
#'
#' @importFrom rlang as_bytes try_fetch
#' @importFrom cli cli_alert_success cli_alert_danger
fgb_validate_spatial_index_ram <- function(fgb_dsn, force = FALSE, quiet = FALSE) {
  features <- gdal_vector_feature_count(dsn = fgb_dsn, layer = gdal_vector_layer(fgb_dsn), force = force)
  required_ram <- features * 83L
  required_ram_str <- rlang::as_bytes(required_ram)
  actual_ram_str <- rlang::as_bytes(as.numeric(sys_available_ram()))
  rlang::try_fetch(
    {
      check_available_ram(required_ram)
      if (!quiet) {
        cli::cli_alert_success(
          c(
            "Sufficient RAM available to build spatial index for {.path {fgb_dsn}}: ",
            "{.field {actual_ram_str}} Available; {.field {required_ram_str}} Required"
          )
        )
      }
      return(TRUE)
    },
    error = function(err) {
      cli::cli_alert_danger(
        c(
          "Insufficient RAM to build spatial index for {.path {fgb_dsn}}: ",
          "{.field {actual_ram_str}} Available; {.field {required_ram_str}} Required"
        )
      )
      return(FALSE)
    }
  )
}
