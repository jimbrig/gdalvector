#  ------------------------------------------------------------------------
#
# Title : XML Utilities
#    By : Jimmy Briggs
#  Date : 2026-06-10
#
#  ------------------------------------------------------------------------

# parse gdal docs -------------------------------------------------------------------------------------------------

parse_gdal_driver_config_opts <- function(driver, ...) {
  driver_url <- gdal_vector_driver_docs_urls[[driver]]
  rvest::read_html(driver_url) |>
    xml_parse_gdal_driver_config_opts(scope = "vector", driver = driver, type = "config")
}

# https://gdal.org/en/stable/drivers/vector/shapefile.html#configuration-options

#' Parse GDAL Driver Configuration Options from XML
#'
#' @description
#' Parses the configuration options for a GDAL driver from the provided XML document. This function
#' is specifically designed to extract the configuration options listed in the "Configuration Options" section of a GDAL
#' driver's documentation page, which is typically structured as an unordered list (`<ul>`) with list
#' items (`<li>`) containing the option details.
#'
#' The function looks for the first `<ul>` element within the section with `id="configuration-options"` and extracts
#' the option name, description, default value, and possible values (if specified in brackets).
#' The resulting data is returned as a tibble with columns for `name`, `description`, `scope`, `default`, and `values`
#' (a list-column containing character vectors of possible values).
#'
#' @param xml The XML document to parse, typically obtained from a GDAL driver's documentation page.
#' @param scope The scope of the options being parsed, such as "vector", "raster", or "all".
#'   This is used to categorize the options based on their applicability to different data types. Defaults to "all".
#' @param driver The name of the GDAL driver for which the options are being parsed.
#'   This is used for labeling purposes in the resulting tibble. Defaults to `NULL`.
#' @param opt_type The type of options being parsed, such as "config", "open", or "creation".
#'   This is used for labeling purposes in the resulting tibble. Defaults to "config".
#' @param call The calling function, used for error handling and messaging.
#'
#' @returns
#' A tibble with columns for `name`, `description`, `scope`, `default`, and `values`
#'
#' @export
#'
#' @importFrom purrr map_dfr discard pluck
#' @importFrom rvest html_element html_elements html_text
#' @importFrom stringr str_extract str_trim str_remove fixed str_match str_split str_remove_all
#' @importFrom tibble tibble
xml_parse_gdal_driver_config_opts <- function(
  xml,
  scope = "all",
  driver = NULL,
  type = "config",
  call = rlang::caller_env()
) {
  check_xml_document(xml, call = call)
  config_ul <- rvest::html_element(xml, xpath = "//section[@id='configuration-options']//ul[1]")
  if (is.null(config_ul) || is.na(config_ul)) {
    gdal_warn("No configuration options section found for the driver '{.field {driver}}'.", call = call)
    return(.empty_xml_opts_tbl(driver = driver, type = type, scope = scope))
  }
  config_ul |>
    rvest::html_elements("li") |>
    purrr::map_dfr(
      function(li) {
        strong_node <- rvest::html_element(li, "strong")
        if (is.na(strong_node)) {
          return(NULL)
        }
        raw_name <- rvest::html_text(strong_node, trim = TRUE)
        full_text <- rvest::html_text(li, trim = TRUE)
        opt_name <- stringr::str_extract(raw_name, "^[A-Z][A-Z0-9_]+")
        opt_desc <- stringr::str_trim(stringr::str_remove(full_text, stringr::fixed(raw_name)))
        opt_default <- stringr::str_match(opt_desc, "[Dd]efaults? to [`'\"]?([^`'\".,\\s]+)[`'\"]?")[, 2]
        raw_bracket <- stringr::str_extract(raw_name, "\\[([^\\]]+)\\]")
        opt_values <- if (!is.na(raw_bracket)) {
          raw_bracket |>
            stringr::str_remove_all("[\\[\\]]") |>
            stringr::str_remove_all("\u200b") |>
            stringr::str_split("/") |>
            purrr::pluck(1) |>
            stringr::str_trim() |>
            purrr::discard(\(x) x == "")
        } else {
          NA_character_
        }
        opt_data_type <- NA_character_
        if (length(opt_values) > 0L) {
          if (identical(opt_values, c("YES", "NO")) || identical(opt_values, c("TRUE", "FALSE"))) {
            opt_data_type <- "boolean"
          } else if (length(opt_values) > 1L && is.character(opt_values)) {
            opt_data_type <- "string-list"
          }
        }

        tibble::tibble(
          driver = driver,
          type = type,
          sub_type = NA_character_,
          name = opt_name,
          description = opt_desc,
          scope = scope,
          default = if (!is.na(opt_default)) opt_default else NA_character_,
          values = list(opt_values),
          data_type = opt_data_type
        )
      }
    )
}


# driver metadata XML  --------------------------------------------------------------------------------------------

#' Parse XML for GDAL Options
#'
#' @description
#' Parses the XML from GDAL driver metadata into structured `tbl_df` tibbles.
#'
#' The function is meant to be flexible enough to be able to parse any of the possible
#' XML metadata structures from GDAL's registered (vector) driver's metadata:
#' `DMD_OPENOPTIONLIST`, `DMD_CREATIONOPTIONLIST`, and `DS_LAYER_CREATIONOPTIONLIST`.
#'
#' @param xml The XML to be parsed. Must be either a valid XML character string or an `xml2::xml_document` object.
#'
#' @param scope (Optional) The scope of the options being parsed in terms of the supported data types, i.e. `vector`
#'   vs. `raster` or both. For example, `GPKG` has `scope`s defined for `"vector"`, `"raster"`, `"raster,vector"`, and
#'   `NA`. Use this argument to filter out for only the options for a specific scope. Will always include the `NA` scoped
#'   options, as those are not explicitly defined for a specific scope and are likely applicable to all scopes. Defaults to `NULL`
#'   and will not filter for any specific scope, returning all options regardless of scope. Provided value
#'   must be one of `"vector"`, `"raster"`, or `"all"` if not `NULL`. Note that the scope values are not standardized
#'   across all GDAL drivers, so use with caution and always check the resulting tibbles for the expected scope values
#'   when working with drivers supporting both raster and vector data.
#'
#' @param driver,opt_type (Optional) Additional values that can be added to the resulting [tibble::tibble()]. Useful
#'   for when merging options across multiple drivers or option types. Defaults to `NULL` and the columns
#'   will only be included in the output when provided. These values are also not properly validated against
#'   the GDAL drivers or option types, so they should be used with caution and primarily for internal use.
#' @param call The calling function, used for error handling and messaging.
#'
#' @returns
#' [tibble::tibble()] with fields for `name`, `description`, `scope`, `type`, `default`, and
#' `values` (a list-column with a character vector for the possible values).
#'
#' Additional fields for `driver` and `opt_type` may be included if those parameters are provided.
#'
#' @export
#'
#' @importFrom rlang caller_env
#' @importFrom purrr map_dfr
#' @importFrom xml2 read_xml xml_find_all xml_attr xml_text
#' @importFrom tibble tibble add_column
#'
#' @examples
#' # parse DS_LAYER_CREATIONOPTIONLIST
#' gdalraster::gdal_get_driver_md("GPKG", mdi_name = "DS_LAYER_CREATIONOPTIONLIST") |>
#'   xml_parse_gdal_options()
#'
#' # parse DMD_CREATIONOPTIONLIST
#' gdalraster::gdal_get_driver_md("GPKG", mdi_name = "DMD_CREATIONOPTIONLIST") |>
#'   xml_parse_gdal_options()
#'
#' # parse DMD_OPENOPTIONLIST
#' gdalraster::gdal_get_driver_md("GPKG", mdi_name = "DMD_OPENOPTIONLIST") |>
#'   xml_parse_gdal_options()
#' @importFrom dplyr filter_out mutate replace_values
#' @importFrom purrr map_dfr
#' @importFrom rlang arg_match0
#' @importFrom tibble tibble add_column
#' @importFrom xml2 read_xml xml_find_all xml_text xml_attr
#' @importFrom dplyr filter_out mutate replace_values
#' @importFrom purrr map_dfr
#' @importFrom rlang arg_match0
#' @importFrom tibble tibble add_column
#' @importFrom xml2 read_xml xml_find_all xml_text xml_attr
#' @importFrom dplyr filter_out mutate replace_values
#' @importFrom purrr map_dfr
#' @importFrom rlang arg_match0
#' @importFrom tibble tibble add_column
#' @importFrom xml2 read_xml xml_find_all xml_text xml_attr
xml_parse_gdal_options <- function(
  xml,
  driver = NA_character_,
  type = c("config", "open", "creation"),
  sub_type = NA_character_,
  scope = c("vector", "raster", "all"),
  call = rlang::caller_env()
) {
  if (is.null(xml)) {
    return(.empty_xml_opts_tbl(driver = driver, type = type, sub_type = sub_type))
  }
  if (is.character(xml)) {
    check_xml_string(xml, call = call)
    xml_doc <- xml2::read_xml(xml)
  } else {
    check_xml(xml, call = call)
    xml_doc <- xml
  }

  check_gdal_driver_name(driver, call = call)
  type <- rlang::arg_match(type, error_call = call)
  scope <- rlang::arg_match(scope, error_call = call)
  if (type == "creation") {
    sub_type <- rlang::arg_match(sub_type, c("dataset", "layer"), error_call = call)
  } else {
    sub_type <- NA_character_
  }

  xml_opts <- xml2::xml_find_all(xml_doc, ".//Option")
  if (length(xml_opts) == 0L) {
    return(.empty_xml_opts_tbl(driver = driver, type = type, sub_type = sub_type, scope = scope))
  }

  hold <- purrr::map_dfr(xml_opts, function(opt) {
    vals <- xml2::xml_text(xml2::xml_find_all(opt, "Value"))
    vals_col <- if (length(vals) > 0L) list(vals) else list(NA_character_)
    tibble::tibble(
      driver = driver,
      type = type,
      sub_type = sub_type,
      name = xml2::xml_attr(opt, "name") %||% NA_character_,
      description = xml2::xml_attr(opt, "description") %||% NA_character_,
      scope = xml2::xml_attr(opt, "scope") %||% NA_character_,
      default = xml2::xml_attr(opt, "default") %||% NA_character_,
      values = vals_col,
      data_type = xml2::xml_attr(opt, "type") %||% NA_character_
    )
  })

  if (scope == "vector") {
    hold <- dplyr::filter_out(hold, .data$scope == "raster")
    hold <- dplyr::mutate(hold, scope = dplyr::replace_values(.data$scope, NA ~ "all"))
  }
  if (scope == "raster") {
    hold <- dplyr::filter_out(hold, .data$scope == "vector")
    hold <- dplyr::mutate(hold, scope = dplyr::replace_values(.data$scope, NA ~ "all"))
  }

  .replace_boolean_values(hold)
}


# vrt xml ---------------------------------------------------------------------------------------------------------

xml_parse_ogr_vrt_xml <- function(xml) {
  check_xml_document(xml)
  vrt_layers <- xml2::xml_find_all(xml, ".//OGRVRTLayer")
  if (length(vrt_layers) == 0L) {
    gdal_warn(
      "No OGRVRTLayer elements found in the provided XML. Returning an empty tibble.",
      call = rlang::caller_env()
    )
    return(.empty_ogr_vrt_layer_tbl())
  }
  purrr::map_dfr(vrt_layers, xml_parse_ogr_vrt_layer)
}

xml_parse_ogr_vrt_layer <- function(xml) {
  check_xml_nodeset(xml)
  vrt_layer_name <- xml2::xml_attr(xml, "name")
  src_data_source <- xml2::xml_text(xml2::xml_find_first(xml, "./SrcDataSource"))
  src_layer <- xml2::xml_text(xml2::xml_find_first(xml, "./SrcLayer"))
  geometry_type <- xml2::xml_text(xml2::xml_find_first(xml, "./GeometryType"))
  tibble::tibble(
    name = vrt_layer_name,
    source = src_data_source,
    layer = src_layer,
    geometry_type = geometry_type
  )
}

xml_validate_ogr_vrt_xml <- function(xml, schema = pkg_sys_schemas("ogrvrt.xsd"), call = rlang::caller_env()) {
  check_xml(xml, call = call)
  check_file(schema, ext = "xsd", call = call)
  xsd_schema <- xml2::read_xml(schema)
  chk <- xml2::xml_validate(xml, xsd_schema)
  # if (!chk) {
  # gdal_abort_validation()
  # gdal_abort("Provided XML does not conform to the OGR VRT schema. Validation errors: {paste(xml2::xml_validation_errors(xml), collapse = '; ')}", call = call)
  # }
  chk
}

.empty_ogr_vrt_layer_tbl <- function() {
  tibble::tibble(name = character(), source = character(), layer = character(), geometry_type = character())
}

# internal --------------------------------------------------------------------------------------------------------

#' @keywords internal
#' @noRd
#' @importFrom tibble tibble add_column
.empty_xml_opts_tbl <- function(driver = NULL, type = NULL, sub_type = NULL, scope = NULL) {
  driver <- if (is.null(driver)) character() else driver
  type <- if (is.null(type)) character() else type
  sub_type <- if (is.null(sub_type)) character() else sub_type
  scope <- if (is.null(scope)) character() else scope
  tibble::tibble(
    driver = driver,
    type = type,
    sub_type = sub_type,
    name = character(),
    description = character(),
    scope = scope,
    default = character(),
    values = list(),
    data_type = character()
  )
}

#' @keywords internal
#' @noRd
#' @importFrom dplyr filter bind_rows
#' @importFrom rlang .data
.replace_boolean_values <- function(df) {
  bools <- dplyr::filter(df, .data$data_type == "boolean")
  bools$values <- rep(list(c("YES", "NO")), nrow(bools))
  out <- dplyr::bind_rows(dplyr::filter(df, .data$data_type != "boolean"), bools)
  out[match(df$name, out$name), ]
}
