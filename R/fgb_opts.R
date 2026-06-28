#  ------------------------------------------------------------------------
#
# Title : FlatGeobuf Options
#    By : Jimmy Briggs
#  Date : 2026-06-21
#
#  ------------------------------------------------------------------------

# config ----------------------------------------------------------------------------------------------------------

#' FlatGeobuf Configuration Options
#'
#' @description
#' The `FlatGeobuf` driver exposes no documented configuration options. This constructor exists for
#' interface symmetry with the other driver option families; it warns and returns an empty
#' [gdal_config_opts()] object.
#'
#' @param ... Ignored (no configuration options are available for this driver).
#'
#' @returns An (empty) [gdal_config_opts()] object for the `FlatGeobuf` driver.
#' @export
#'
#' @seealso [fgb_open_opts()], [fgb_creation_opts()]
#'
#' @examples
#' fgb_config_opts()
fgb_config_opts <- function(...) {
  gdal_warn_opts(
    "The {.field FlatGeobuf} driver has no documented configuration options.",
    cls = "gdal_opts_empty_warning"
  )
  new_gdal_config_opts(driver = "FlatGeobuf")
}

# open ------------------------------------------------------------------------------------------------------------

#' FlatGeobuf Open Options
#'
#' @description
#' Construct a [gdal_open_opts()] object for the `FlatGeobuf` driver. Only options you supply are
#' emitted; values are validated against the driver's registered metadata.
#'
#' @param verify_buffers Value for `VERIFY_BUFFERS`. Logical `TRUE`/`FALSE` (coerced to `"YES"`/
#'   `"NO"`) controlling whether flatbuffer integrity is verified on read. `"YES"` (the GDAL default)
#'   guards against corrupt data at a small performance cost; `"NO"` is faster but unsafe on
#'   malformed files. `NULL` (default) leaves it unset.
#' @inheritParams .shared_params
#'
#' @returns A [gdal_open_opts()] object for the `FlatGeobuf` driver.
#' @export
#'
#' @seealso [fgb_creation_opts()], [gdal_open_opts()]
#'
#' ```{r child = "man/fragments/fgb_links.md"}
#' ```
#'
#' @examples
#' fgb_open_opts()
#' fgb_open_opts(verify_buffers = FALSE)
#' fgb_open_opts(.set_defaults = TRUE)
fgb_open_opts <- function(verify_buffers = NULL, .set_defaults = FALSE) {
  opts <- .gdal_opts_normalize(list(
    VERIFY_BUFFERS = as_gdal_boolean(verify_buffers)
  ))
  if (length(opts) > 0L) {
    check_gdal_opts(opts, gdal_vector_driver_open_opts_values("FlatGeobuf"))
  }
  if (isTRUE(.set_defaults)) {
    opts <- utils::modifyList(as.list(gdal_vector_driver_open_opts_defaults("FlatGeobuf")), opts)
  }
  new_gdal_open_opts(opts, driver = "FlatGeobuf")
}

# creation --------------------------------------------------------------------------------------------------------

#' FlatGeobuf Creation Options
#'
#' @description
#' Construct a layer-level [gdal_creation_opts()] object for the `FlatGeobuf` driver. Only options
#' you supply are emitted; values are validated against the driver's registered metadata.
#'
#' @param spatial_index Value for `SPATIAL_INDEX`. Logical `TRUE`/`FALSE` (coerced to `"YES"`/`"NO"`)
#'   controlling whether a packed Hilbert R-tree spatial index is written. GDAL defaults to `"YES"`.
#' @param temporary_dir Directory for temporary files during write (`TEMPORARY_DIR`).
#' @param title Layer title (`TITLE`).
#' @param description Layer description (`DESCRIPTION`).
#' @inheritParams .shared_params
#'
#' @returns A layer-level [gdal_creation_opts()] object for the `FlatGeobuf` driver.
#' @export
#'
#' @seealso [fgb_open_opts()], [gdal_creation_opts()]
#'
#' ```{r child = "man/fragments/fgb_links.md"}
#' ```
#'
#' @examples
#' fgb_creation_opts(spatial_index = TRUE, title = "Parcels")
fgb_creation_opts <- function(
  spatial_index = NULL,
  temporary_dir = NULL,
  title = NULL,
  description = NULL,
  .set_defaults = FALSE
) {
  opts <- .gdal_opts_normalize(list(
    SPATIAL_INDEX = as_gdal_boolean(spatial_index),
    TEMPORARY_DIR = temporary_dir,
    TITLE = title,
    DESCRIPTION = description
  ))
  if (length(opts) > 0L) {
    check_gdal_opts(opts, gdal_vector_driver_creation_opts_values("FlatGeobuf", sub_type = "layer"))
  }
  if (isTRUE(.set_defaults)) {
    opts <- utils::modifyList(
      as.list(gdal_vector_driver_creation_opts_defaults("FlatGeobuf", sub_type = "layer")),
      opts
    )
  }
  new_gdal_creation_opts(opts, driver = "FlatGeobuf", level = "layer")
}
