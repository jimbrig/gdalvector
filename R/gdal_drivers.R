#  ------------------------------------------------------------------------
#
# Title : GDAL Vector Drivers
#    By : Jimmy Briggs
#  Date : 2026-06-13
#
#  ------------------------------------------------------------------------

# drivers ---------------------------------------------------------------------------------------------------------

#' GDAL Drivers
#'
#' @description
#' Query the GDAL drivers registered in the active GDAL build.
#'
#' - `gdal_drivers()`: returns a normalized [tibble::tibble()] of driver metadata (identity,
#'   capabilities, supported extensions and SQL dialects), optionally filtered by a name pattern.
#' - `gdal_driver_names()`: returns just the short driver names.
#'
#' The driver table is built once from [gdalraster::gdal_formats()] and cached for the session.
#'
#' @param pattern Optional character vector of regular-expression patterns. Drivers whose short or
#'   long name matches any pattern are returned. `NULL` (default) returns all drivers.
#' @param ignore_case Logical; match `pattern` case-insensitively. Defaults to `TRUE`.
#'
#' @returns
#' - `gdal_drivers()`: a [tibble::tibble()] with one row per driver.
#' - `gdal_driver_names()`: a character vector of short driver names.
#'
#' @export
#'
#' @seealso [gdal_vector_driver_opts()], [gdal_vector_driver_capabilities()]
#'
#' @examples
#' gdal_drivers()
#' gdal_drivers(c("parquet", "geojson"))
#' gdal_driver_names("gpkg")
gdal_drivers <- local({
  drivers_tbl <- NULL
  function(pattern = NULL, ignore_case = TRUE) {
    if (is.null(drivers_tbl)) {
      drivers_tbl <<- gdalraster::gdal_formats() |> .normalize_gdal_formats_tbl()
    }
    if (is.null(pattern)) {
      return(drivers_tbl)
    }
    pattern <- stringr::str_c(pattern, collapse = "|")
    rx <- stringr::regex(pattern, ignore_case = ignore_case)
    drivers_tbl |> dplyr::filter(stringr::str_detect(.data$driver, rx) | stringr::str_detect(.data$long_name, rx))
  }
})

#' @rdname gdal_drivers
#' @export
gdal_driver_names <- function(pattern = NULL) {
  gdal_drivers(pattern = pattern) |> dplyr::pull("driver")
}

# driver options --------------------------------------------------------------------------------------------------

#' GDAL Vector Driver Options
#'
#' @description
#' Look up the documented options for the core supported vector drivers (see
#' [GDAL_VECTOR_DRIVERS][gdal_drivers]), drawn from the merged option table assembled at package
#' load (driver-metadata XML for open/creation options plus the curated configuration options).
#'
#' - `gdal_vector_driver_opts()`: the full option table, optionally filtered by `type`, `sub_type`,
#'   and `scope`.
#' - `gdal_vector_driver_opt_defaults()`: a named vector mapping option name to its declared default.
#' - `gdal_vector_driver_opt_values()`: a named list mapping option name to its allowed values
#'   (booleans expanded to `c("YES", "NO")`); only options that declare a constrained set appear.
#' - `gdal_vector_driver_opt_types()`: a named vector mapping option name to its `data_type`.
#'
#' @param driver Character scalar GDAL driver short name (e.g. `"GPKG"`). When `NULL` (only for
#'   `gdal_vector_driver_opts()`), the options for all core vector drivers are returned.
#' @param type Optional option channel to filter to: one of `"config"`, `"open"`, or `"creation"`.
#' @param sub_type Optional creation sub-type to filter to: `"dataset"` or `"layer"`.
#' @param scope Optional data-type scope to filter to (e.g. `"vector"`, `"all"`).
#'
#' @returns
#' - `gdal_vector_driver_opts()`: a [tibble::tibble()] of options.
#' - `gdal_vector_driver_opt_defaults()` / `gdal_vector_driver_opt_types()`: a named character vector.
#' - `gdal_vector_driver_opt_values()`: a named list of character vectors.
#'
#' @export
#'
#' @seealso [gdal_vector_driver_open_opts()], [gdal_vector_driver_creation_opts()],
#'   [gdal_vector_driver_config_opts()]
#'
#' @examples
#' gdal_vector_driver_opts("GPKG", type = "open")
#' gdal_vector_driver_opt_defaults("GPKG", type = "open")
gdal_vector_driver_opts <- function(driver = NULL, type = NULL, sub_type = NULL, scope = NULL) {
  if (is.null(driver)) {
    drivers <- GDAL_VECTOR_DRIVERS
    return(
      purrr::map_dfr(drivers, function(driver) {
        gdal_vector_driver_opts(driver, type = type, sub_type = sub_type, scope = scope)
      })
    )
  }
  check_gdal_driver_name(driver)
  opts_tbl <- .pkg_env$gdal$drivers$opts_tbl |> dplyr::filter(.data$driver == .env$driver)
  if (!is.null(type)) {
    type <- rlang::arg_match(type, c("config", "open", "creation"))
    opts_tbl <- opts_tbl |> dplyr::filter(.data$type == .env$type)
  }
  if (!is.null(sub_type)) {
    sub_type <- rlang::arg_match(sub_type, c("dataset", "layer"))
    opts_tbl <- opts_tbl |> dplyr::filter(.data$type == "creation", .data$sub_type == .env$sub_type)
  }
  if (!is.null(scope)) {
    opts_tbl <- opts_tbl |> dplyr::filter(.data$scope %in% .env$scope)
  }
  opts_tbl
}

#' @rdname gdal_vector_driver_opts
#' @export
gdal_vector_driver_opt_defaults <- function(driver, type = NULL, sub_type = NULL, scope = NULL) {
  gdal_vector_driver_opts(driver, type = type, sub_type = sub_type, scope = scope) |>
    dplyr::select("name", "default") |>
    dplyr::filter(!is.na(.data$default)) |>
    tibble::deframe()
}

#' @rdname gdal_vector_driver_opts
#' @export
gdal_vector_driver_opt_values <- function(driver, type = NULL, sub_type = NULL, scope = NULL) {
  gdal_vector_driver_opts(driver, type = type, sub_type = sub_type, scope = scope) |>
    dplyr::select("name", "values") |>
    dplyr::filter(!is.na(.data$values)) |>
    tibble::deframe()
}

#' @rdname gdal_vector_driver_opts
#' @export
gdal_vector_driver_opt_types <- function(driver, type = NULL, sub_type = NULL, scope = NULL) {
  gdal_vector_driver_opts(driver, type = type, sub_type = sub_type, scope = scope) |>
    dplyr::select("name", "data_type") |>
    dplyr::filter(!is.na(.data$data_type)) |>
    tibble::deframe()
}

# config options --------------------------------------------------------------------------------------------------

#' GDAL Vector Driver Configuration Options
#'
#' @description
#' Accessors for a driver's configuration options (the `--config` channel). Configuration options
#' are sourced from curated package data, since GDAL does not expose them in driver metadata.
#'
#' - `gdal_vector_driver_config_opts()`: the configuration-option table for `driver`.
#' - `gdal_vector_driver_config_opts_defaults()`: name to default (all, or one when `opt_name` given).
#' - `gdal_vector_driver_config_opts_values()`: name to allowed values (only constrained options).
#' - `gdal_vector_driver_config_opts_types()`: name to `data_type`.
#'
#' @param driver Character scalar GDAL driver short name.
#' @param opt_name Optional single option name. When supplied, returns the value for that option
#'   only; otherwise returns the full named result.
#'
#' @returns A [tibble::tibble()], named character vector, or named list (see [gdal_vector_driver_opts()]).
#'
#' @export
#'
#' @seealso [gdal_config_opts()], [gdal_vector_driver_opts()]
#'
#' @examples
#' gdal_vector_driver_config_opts("GPKG")
#' gdal_vector_driver_config_opts_values("GPKG")
gdal_vector_driver_config_opts <- function(driver) {
  gdal_vector_driver_opts(driver, type = "config")
}

#' @rdname gdal_vector_driver_config_opts
#' @export
gdal_vector_driver_config_opts_defaults <- function(driver, opt_name = NULL) {
  hold <- gdal_vector_driver_config_opts(driver)
  if (is.null(opt_name)) {
    return(
      hold |> dplyr::select("name", "default") |> dplyr::filter(!is.na(.data$default)) |> tibble::deframe()
    )
  }
  opt_name <- rlang::arg_match(opt_name, hold$name)
  hold |> dplyr::filter(.data$name == .env$opt_name) |> dplyr::pull("default")
}

#' @rdname gdal_vector_driver_config_opts
#' @export
gdal_vector_driver_config_opts_values <- function(driver, opt_name = NULL) {
  hold <- gdal_vector_driver_config_opts(driver)
  if (is.null(opt_name)) {
    return(
      hold |> dplyr::select("name", "values") |> dplyr::filter(!is.na(.data$values)) |> tibble::deframe()
    )
  }
  opt_name <- rlang::arg_match(opt_name, hold$name)
  hold |> dplyr::filter(.data$name == .env$opt_name) |> dplyr::pull(.data$values) |> purrr::pluck(1L)
}

#' @rdname gdal_vector_driver_config_opts
#' @export
gdal_vector_driver_config_opts_types <- function(driver) {
  gdal_vector_driver_opt_types(driver, type = "config")
}

# open options ----------------------------------------------------------------------------------------------------

#' GDAL Vector Driver Open Options
#'
#' @description
#' Accessors for a driver's open options (the `--oo` / `GDALOpenEx()` channel), parsed from the
#' driver's `DMD_OPENOPTIONLIST` metadata.
#'
#' - `gdal_vector_driver_open_opts()`: the open-option table for `driver`.
#' - `gdal_vector_driver_open_opts_defaults()`: name to default (all, or one when `opt_name` given).
#' - `gdal_vector_driver_open_opts_values()`: name to allowed values (only constrained options).
#' - `gdal_vector_driver_open_opts_types()`: name to `data_type`.
#'
#' @inheritParams gdal_vector_driver_config_opts
#'
#' @returns A [tibble::tibble()], named character vector, or named list (see [gdal_vector_driver_opts()]).
#'
#' @export
#'
#' @seealso [gdal_open_opts()], [gdal_vector_driver_opts()]
#'
#' @examples
#' gdal_vector_driver_open_opts("GPKG")
#' gdal_vector_driver_open_opts_values("GPKG", "LIST_ALL_TABLES")
gdal_vector_driver_open_opts <- function(driver) {
  gdal_vector_driver_opts(driver, type = "open")
}

#' @rdname gdal_vector_driver_open_opts
#' @export
gdal_vector_driver_open_opts_defaults <- function(driver, opt_name = NULL) {
  hold <- gdal_vector_driver_open_opts(driver = driver)
  if (is.null(opt_name)) {
    return(
      hold |> dplyr::select("name", "default") |> dplyr::filter(!is.na(.data$default)) |> tibble::deframe()
    )
  }
  opt_name <- rlang::arg_match(opt_name, hold$name)
  hold |> dplyr::filter(.data$name == .env$opt_name) |> dplyr::pull(.data$default)
}

#' @rdname gdal_vector_driver_open_opts
#' @export
gdal_vector_driver_open_opts_values <- function(driver, opt_name = NULL) {
  hold <- gdal_vector_driver_open_opts(driver = driver)
  if (is.null(opt_name)) {
    return(
      hold |> dplyr::select("name", "values") |> dplyr::filter(!is.na(.data$values)) |> tibble::deframe()
    )
  }
  opt_name <- rlang::arg_match(opt_name, hold$name)
  hold |> dplyr::filter(.data$name == .env$opt_name) |> dplyr::pull(.data$values) |> purrr::pluck(1L)
}

#' @rdname gdal_vector_driver_open_opts
#' @export
gdal_vector_driver_open_opts_types <- function(driver) {
  gdal_vector_driver_opt_types(driver, type = "open")
}

# creation options ------------------------------------------------------------------------------------------------

#' GDAL Vector Driver Creation Options
#'
#' @description
#' Accessors for a driver's creation options, parsed from both the dataset-level
#' (`DMD_CREATIONOPTIONLIST`, `--co`) and layer-level (`DS_LAYER_CREATIONOPTIONLIST`, `--lco`)
#' metadata. Use `sub_type` to restrict to one level.
#'
#' - `gdal_vector_driver_creation_opts()`: the creation-option table for `driver`.
#' - `gdal_vector_driver_creation_opts_defaults()`: name to default (all, or one when `opt_name` given).
#' - `gdal_vector_driver_creation_opts_values()`: name to allowed values (only constrained options).
#' - `gdal_vector_driver_creation_opts_types()`: name to `data_type`.
#'
#' @inheritParams gdal_vector_driver_config_opts
#' @param sub_type Optional creation level to restrict to: `"dataset"` or `"layer"`.
#'
#' @returns A [tibble::tibble()], named character vector, or named list (see [gdal_vector_driver_opts()]).
#'
#' @export
#'
#' @seealso [gdal_creation_opts()], [gdal_vector_driver_opts()]
#'
#' @examples
#' gdal_vector_driver_creation_opts("Parquet", sub_type = "layer")
#' gdal_vector_driver_creation_opts_values("GPKG", sub_type = "layer")
gdal_vector_driver_creation_opts <- function(driver, sub_type = NULL) {
  gdal_vector_driver_opts(driver, type = "creation", sub_type = sub_type)
}

#' @rdname gdal_vector_driver_creation_opts
#' @export
gdal_vector_driver_creation_opts_defaults <- function(driver, sub_type = NULL, opt_name = NULL) {
  hold <- gdal_vector_driver_creation_opts(driver = driver, sub_type = sub_type)
  if (is.null(opt_name)) {
    return(
      hold |> dplyr::select("name", "default") |> dplyr::filter(!is.na(.data$default)) |> tibble::deframe()
    )
  }
  opt_name <- rlang::arg_match(opt_name, hold$name)
  hold |> dplyr::filter(.data$name == .env$opt_name) |> dplyr::pull(.data$default)
}

#' @rdname gdal_vector_driver_creation_opts
#' @export
gdal_vector_driver_creation_opts_values <- function(driver, sub_type = NULL, opt_name = NULL) {
  hold <- gdal_vector_driver_creation_opts(driver = driver, sub_type = sub_type)
  if (is.null(opt_name)) {
    return(
      hold |> dplyr::select("name", "values") |> dplyr::filter(!is.na(.data$values)) |> tibble::deframe()
    )
  }
  opt_name <- rlang::arg_match(opt_name, hold$name)
  hold |> dplyr::filter(.data$name == .env$opt_name) |> dplyr::pull(.data$values) |> purrr::pluck(1L)
}

#' @rdname gdal_vector_driver_creation_opts
#' @export
gdal_vector_driver_creation_opts_types <- function(driver, sub_type = NULL) {
  gdal_vector_driver_opt_types(driver, type = "creation", sub_type = sub_type)
}

# capabilities ----------------------------------------------------------------------------------------------------

#' GDAL Vector Driver Capabilities
#'
#' @description
#' Return a driver's capability flags (the `DCAP_*` metadata items) as a named logical vector.
#'
#' @param driver Character scalar GDAL driver short name.
#'
#' @returns A named logical vector, one element per `DCAP_*` capability (name without the `DCAP_`
#'   prefix retained as given by GDAL), `TRUE` where the capability is advertised.
#'
#' @export
#'
#' @seealso [gdal_drivers()]
#'
#' @examples
#' gdal_vector_driver_capabilities("GPKG")
gdal_vector_driver_capabilities <- function(driver) {
  x <- gdalraster::gdal_get_driver_md(driver)
  x <- x[stringr::str_detect(names(x), "DCAP_")]
  as.list(x[sort(names(x))]) |>
    purrr::map_lgl(~ ifelse(.x == "YES", TRUE, FALSE))
}

# initialization --------------------------------------------------------------------------------------------------

# build and cache the merged driver-option table into the package environment at load. config rows
# come from curated package data; open/creation rows are parsed from each core driver's metadata.
#' @keywords internal
#' @noRd
gdal_drivers_init <- function(refresh = FALSE) {
  if (!exists(".pkg_env")) {
    return(invisible())
  }
  if (!rlang::env_has(.pkg_env, "gdal")) {
    return(invisible())
  }
  if (!rlang::env_has(.pkg_env$gdal, "drivers")) {
    return(invisible())
  }

  env_gdal_drivers <- .pkg_env$gdal$drivers
  env_gdal_drivers$opts_tbl <- .init_driver_opts_tbl()
}

# internal --------------------------------------------------------------------------------------------------------

# assemble the single merged option table: curated config opts + parsed open opts + parsed
# dataset/layer creation opts, for the core vector drivers, ordered for stable lookup.
#' @keywords internal
#' @noRd
.init_driver_opts_tbl <- function() {
  dplyr::bind_rows(
    gdal_vector_driver_config_opts_tbl,
    purrr::map_dfr(GDAL_VECTOR_DRIVERS, function(driver) {
      open_opts_xml <- gdalraster::gdal_get_driver_md(driver, mdi_name = "DMD_OPENOPTIONLIST")
      xml_parse_gdal_options(open_opts_xml, driver = driver, type = "open", scope = "vector")
    }),
    purrr::map_dfr(GDAL_VECTOR_DRIVERS, function(driver) {
      dplyr::bind_rows(
        gdalraster::gdal_get_driver_md(format = driver, mdi_name = "DMD_CREATIONOPTIONLIST") |>
          xml_parse_gdal_options(driver = driver, type = "creation", sub_type = "dataset", scope = "vector"),
        gdalraster::gdal_get_driver_md(format = driver, mdi_name = "DS_LAYER_CREATIONOPTIONLIST") |>
          xml_parse_gdal_options(driver = driver, type = "creation", sub_type = "layer", scope = "vector")
      )
    })
  ) |>
    dplyr::arrange(.data$driver, .data$type, .data$sub_type, .data$name)
}

# split a whitespace-delimited string (or vector of them) into character vector(s).
#' @keywords internal
#' @noRd
.split_words <- function(x) {
  if (length(x) > 1L) {
    return(purrr::map(x, .split_words))
  }
  x <- trimws(x)
  if (!nzchar(x)) {
    return(character())
  }
  strsplit(x, "\\s+")[[1]]
}

# normalize the raw gdalraster::gdal_formats() table into the package's driver schema.
#' @keywords internal
#' @noRd
.normalize_gdal_formats_tbl <- function(x) {
  x |>
    tibble::as_tibble() |>
    dplyr::transmute(
      driver = .data$short_name,
      short_name = .data$short_name,
      long_name = .data$long_name,
      extensions = .split_words(.data$extensions),
      is_vector = .data$vector,
      is_raster = .data$raster,
      is_multidim_raster = .data$multidim_raster,
      is_geography_network = .data$geography_network,
      read_write = .data$rw_flag,
      supports_vsi = .data$virtual_io,
      supports_subdatasets = .data$subdatasets,
      supports_multiple_layers = .data$multiple_vec_layers,
      supports_field_domains = .data$read_field_domains,
      sql_dialects = .split_words(.data$sql_dialects)
    )
}
