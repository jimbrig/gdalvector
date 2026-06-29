#  ------------------------------------------------------------------------
#
# Title : GDAL Options
#    By : Jimmy Briggs
#  Date : 2026-06-10
#
#  ------------------------------------------------------------------------

#' GDAL Options
#'
#' @name gdal_opts
#'
#' @description
#' GDAL options control how the GDAL/OGR library reads, writes, and otherwise processes geospatial
#' data. This package models the distinct GDAL option *channels* as a small family of S3 classes,
#' each backed by a named list of `NAME = "VALUE"` pairs (values stored as their coerced GDAL
#' strings) plus a `driver` attribute, so a set of options is an inert, composable value that can be
#' rendered on demand to whichever form a given consumer needs.
#'
#' In the GDAL CLI, an option is supplied via one of these argument flags:
#'
#' ```plaintext
#' --config <NAME>=<VALUE>
#' --open-option / --oo <NAME>=<VALUE>
#' --creation-option / --co <NAME>=<VALUE>
#' --layer-creation-option / --lco <NAME>=<VALUE>
#' ```
#'
#' @section Classes:
#' All four classes share the `gdal_opts` base (a named `list`) and differ only by channel:
#'
#' ```plaintext
#' gdal_opts
#'  |- gdal_config_opts                          --config      CPLSetConfigOption()
#'  |- gdal_open_opts                            --oo          GDALOpenEx()
#'  |- gdal_creation_opts  (level = layer)       --lco         GDALDatasetCreateLayer()
#'  |                      (level = dataset)     --co          GDALCreate()
#'  |- gdal_vsi_opts       (vsi_path)            --config      VSISetPathSpecificOption()
#' ```
#'
#' - [gdal_config_opts()]: global, stateful configuration options. Applied to the process/session
#'   (via [gdalraster::set_config_option()]), not as an algorithm argument.
#' - [gdal_open_opts()]: driver open options.
#' - [gdal_creation_opts()]: driver dataset- or layer-creation options, selected by `level`.
#' - [gdal_vsi_opts()]: virtual file system (VSI) path-scoped options (config-like).
#'
#' @section Rendering:
#' A `gdal_opts` value is rendered with [as_gdal_args()] (CLI token vector for
#' [gdalraster::gdal_alg()] / [gdalraster::gdal_run()]), [as_config_option()] (a `NAME = VALUE`
#' character vector for [gdalraster::set_config_option()], config/VSI only), or [gdal_render()]
#' (a copy-pasteable shell snippet).
#'
#' @seealso
#' [as_gdal_args()], [as_config_option()], [gdal_render()]; and the typed per-driver builders
#' [gpkg_open_opts()], [gpq_creation_opts()], [shp_open_opts()], [fgb_creation_opts()],
#' [gdb_open_opts()].
NULL

# base class ------------------------------------------------------------------------------------------------------

#' @keywords internal
#' @noRd
new_gdal_opts <- function(x = list(), subclass, driver = NULL, level = NULL, vsi_path = NULL) {
  structure(
    x,
    driver = driver,
    level = level,
    vsi_path = vsi_path,
    class = c(subclass, "gdal_opts", "list")
  )
}

# config options --------------------------------------------------------------------------------------------------

#' GDAL Configuration Options
#'
#' @description
#' Construct a [gdal_config_opts()] object from `NAME = value` pairs. Configuration options are
#' global, stateful settings applied to the GDAL process (via [gdalraster::set_config_option()] /
#' the CLI `--config` flag), and are *not* algorithm arguments. When `driver` is supplied, values
#' for boolean options are validated against the driver metadata.
#'
#' @param ... Named configuration options as `KEY=VALUE` pairs.
#' @param driver Optional GDAL driver short name (e.g. `"GPKG"`) to associate.
#' @inheritParams .shared_params
#'
#' @returns
#' A [gdal_config_opts()] object.
#'
#' @export
#'
#' @importFrom rlang list2
#' @importFrom utils modifyList
#'
#' @examples
#' gdal_config_opts(CPL_DEBUG = "ON", GDAL_NUM_THREADS = "ALL_CPUS")
gdal_config_opts <- function(..., driver = NULL, .set_defaults = FALSE) {
  opts <- rlang::list2(...)
  if (isTRUE(.set_defaults) && !is.null(driver)) {
    opts <- utils::modifyList(as.list(gdal_vector_driver_config_opts_defaults(driver)), opts)
  }
  as_gdal_config_opts(opts, driver = driver)
}

#' @keywords internal
#' @noRd
new_gdal_config_opts <- function(x = list(), driver = NULL) {
  new_gdal_opts(x, subclass = "gdal_config_opts", driver = driver)
}

#' Coerce to GDAL Configuration Options
#'
#' @description
#' Coerce a named list, a `KEY=VALUE` character vector, a driver-metadata tibble, or an existing
#' `gdal_config_opts` to the [gdal_config_opts()] class.
#'
#' @param x Object to coerce.
#' @param ... Unused; for method extensibility.
#' @param driver Optional GDAL driver short name to attach.
#' @inheritParams rlang::args_error_context
#'
#' @returns A [gdal_config_opts()] object.
#' @export
as_gdal_config_opts <- function(x, ..., driver = NULL, call = rlang::caller_env()) {
  UseMethod("as_gdal_config_opts")
}

#' @rdname as_gdal_config_opts
#' @export
as_gdal_config_opts.default <- function(x, ..., driver = NULL, call = rlang::caller_env()) {
  gdal_abort_opts(
    "Can't coerce {.cls {class(x)}} to {.cls gdal_config_opts}.",
    cls = "gdal_opts_coerce_error",
    call = call
  )
}

#' @rdname as_gdal_config_opts
#' @export
as_gdal_config_opts.gdal_config_opts <- function(x, ..., driver = NULL, call = rlang::caller_env()) {
  if (!is.null(driver)) {
    attr(x, "driver") <- driver
  }
  x
}

#' @rdname as_gdal_config_opts
#' @export
as_gdal_config_opts.list <- function(x, ..., driver = NULL, call = rlang::caller_env()) {
  new_gdal_config_opts(.gdal_opts_normalize(x, call = call), driver = driver)
}

#' @rdname as_gdal_config_opts
#' @export
as_gdal_config_opts.character <- function(x, ..., driver = NULL, call = rlang::caller_env()) {
  new_gdal_config_opts(.gdal_opts_parse_kv(x, call = call), driver = driver)
}

#' @rdname as_gdal_config_opts
#' @export
as_gdal_config_opts.tbl_df <- function(x, ..., driver = NULL, call = rlang::caller_env()) {
  new_gdal_config_opts(.gdal_opts_from_md(x), driver = driver)
}

# open options ----------------------------------------------------------------------------------------------------

#' @keywords internal
#' @noRd
new_gdal_open_opts <- function(x = list(), driver = NULL) {
  new_gdal_opts(x, subclass = "gdal_open_opts", driver = driver)
}

#' Coerce to GDAL Open Options
#'
#' @description
#' Coerce a named list, a `KEY=VALUE` character vector, a driver-metadata tibble, or an existing
#' `gdal_open_opts` to the [gdal_open_opts()] class.
#'
#' @inheritParams as_gdal_config_opts
#'
#' @returns A [gdal_open_opts()] object.
#' @export
as_gdal_open_opts <- function(x, ..., driver = NULL, call = rlang::caller_env()) {
  UseMethod("as_gdal_open_opts")
}

#' @rdname as_gdal_open_opts
#' @export
as_gdal_open_opts.default <- function(x, ..., driver = NULL, call = rlang::caller_env()) {
  gdal_abort_opts(
    "Can't coerce {.cls {class(x)}} to {.cls gdal_open_opts}.",
    cls = "gdal_opts_coerce_error",
    call = call
  )
}

#' @rdname as_gdal_open_opts
#' @export
as_gdal_open_opts.gdal_open_opts <- function(x, ..., driver = NULL, call = rlang::caller_env()) {
  if (!is.null(driver)) {
    attr(x, "driver") <- driver
  }
  x
}

#' @rdname as_gdal_open_opts
#' @export
as_gdal_open_opts.list <- function(x, ..., driver = NULL, call = rlang::caller_env()) {
  new_gdal_open_opts(.gdal_opts_normalize(x, call = call), driver = driver)
}

#' @rdname as_gdal_open_opts
#' @export
as_gdal_open_opts.character <- function(x, ..., driver = NULL, call = rlang::caller_env()) {
  new_gdal_open_opts(.gdal_opts_parse_kv(x, call = call), driver = driver)
}

#' @rdname as_gdal_open_opts
#' @export
as_gdal_open_opts.tbl_df <- function(x, ..., driver = NULL, call = rlang::caller_env()) {
  new_gdal_open_opts(.gdal_opts_from_md(x), driver = driver)
}

#' GDAL Open Options
#'
#' @description
#' Construct a [gdal_open_opts()] object from `NAME = value` pairs (the GDAL `--oo` /
#' `GDALOpenEx()` open-option channel).
#'
#' @param ... Named open options (`NAME = value`). Logical values are coerced to `"YES"`/`"NO"`.
#' @param driver Optional GDAL driver short name to associate.
#' @inheritParams .shared_params
#'
#' @returns A [gdal_open_opts()] object.
#' @export
#'
#' @examples
#' gdal_open_opts(LIST_ALL_TABLES = FALSE, driver = "GPKG")
gdal_open_opts <- function(..., driver = NULL, .set_defaults = FALSE) {
  opts <- rlang::list2(...)
  if (isTRUE(.set_defaults) && !is.null(driver)) {
    opts <- utils::modifyList(as.list(gdal_vector_driver_open_opts_defaults(driver)), opts)
  }
  as_gdal_open_opts(opts, driver = driver)
}

# creation options ------------------------------------------------------------------------------------------------

#' @keywords internal
#' @noRd
new_gdal_creation_opts <- function(x = list(), driver = NULL, level = c("layer", "dataset")) {
  level <- rlang::arg_match(level)
  new_gdal_opts(x, subclass = "gdal_creation_opts", driver = driver, level = level)
}

#' Coerce to GDAL Creation Options
#'
#' @description
#' Coerce a named list, a `KEY=VALUE` character vector, a driver-metadata tibble, or an existing
#' `gdal_creation_opts` to the [gdal_creation_opts()] class.
#'
#' @inheritParams as_gdal_config_opts
#' @param level Creation-option level: `"layer"` (`--lco`) or `"dataset"` (`--co`).
#'
#' @returns A [gdal_creation_opts()] object.
#' @export
as_gdal_creation_opts <- function(x, ..., driver = NULL, level = c("layer", "dataset"), call = rlang::caller_env()) {
  UseMethod("as_gdal_creation_opts")
}

#' @rdname as_gdal_creation_opts
#' @export
as_gdal_creation_opts.default <- function(
  x,
  ...,
  driver = NULL,
  level = c("layer", "dataset"),
  call = rlang::caller_env()
) {
  gdal_abort_opts(
    "Can't coerce {.cls {class(x)}} to {.cls gdal_creation_opts}.",
    cls = "gdal_opts_coerce_error",
    call = call
  )
}

#' @rdname as_gdal_creation_opts
#' @export
as_gdal_creation_opts.gdal_creation_opts <- function(
  x,
  ...,
  driver = NULL,
  level = c("layer", "dataset"),
  call = rlang::caller_env()
) {
  if (!is.null(driver)) {
    attr(x, "driver") <- driver
  }
  if (!missing(level) && !is.null(level)) {
    attr(x, "level") <- rlang::arg_match(level)
  }
  x
}

#' @rdname as_gdal_creation_opts
#' @export
as_gdal_creation_opts.list <- function(
  x,
  ...,
  driver = NULL,
  level = c("layer", "dataset"),
  call = rlang::caller_env()
) {
  level <- rlang::arg_match(level)
  new_gdal_creation_opts(.gdal_opts_normalize(x, call = call), driver = driver, level = level)
}

#' @rdname as_gdal_creation_opts
#' @export
as_gdal_creation_opts.character <- function(
  x,
  ...,
  driver = NULL,
  level = c("layer", "dataset"),
  call = rlang::caller_env()
) {
  level <- rlang::arg_match(level)
  new_gdal_creation_opts(.gdal_opts_parse_kv(x, call = call), driver = driver, level = level)
}

#' @rdname as_gdal_creation_opts
#' @export
as_gdal_creation_opts.tbl_df <- function(
  x,
  ...,
  driver = NULL,
  level = c("layer", "dataset"),
  call = rlang::caller_env()
) {
  level <- rlang::arg_match(level)
  new_gdal_creation_opts(.gdal_opts_from_md(x), driver = driver, level = level)
}

#' GDAL Creation Options
#'
#' @description
#' Construct a [gdal_creation_opts()] object from `NAME = value` pairs. The `level` controls whether
#' these are dataset-creation options (`--co`) or layer-creation options (`--lco`, the default).
#'
#' @param ... Named creation options (`NAME = value`). Logical values are coerced to `"YES"`/`"NO"`.
#' @param driver Optional GDAL driver short name to associate.
#' @param level Creation-option level, `"layer"` (default) or `"dataset"`.
#' @inheritParams .shared_params
#'
#' @returns A [gdal_creation_opts()] object.
#' @export
#'
#' @examples
#' gdal_creation_opts(COMPRESSION = "ZSTD", driver = "Parquet")
gdal_creation_opts <- function(..., driver = NULL, level = c("layer", "dataset"), .set_defaults = FALSE) {
  level <- rlang::arg_match(level)
  opts <- rlang::list2(...)
  if (isTRUE(.set_defaults) && !is.null(driver)) {
    opts <- utils::modifyList(as.list(gdal_vector_driver_creation_opts_defaults(driver, sub_type = level)), opts)
  }
  as_gdal_creation_opts(opts, driver = driver, level = level)
}

# vsi options -----------------------------------------------------------------------------------------------------

#' @keywords internal
#' @noRd
new_gdal_vsi_opts <- function(x = list(), vsi_path = NULL) {
  new_gdal_opts(x, subclass = "gdal_vsi_opts", vsi_path = vsi_path)
}

#' Coerce to GDAL VSI Options
#'
#' @description
#' Coerce a named list, a `KEY=VALUE` character vector, or an existing `gdal_vsi_opts` to the
#' [gdal_vsi_opts()] class. VSI options are path-scoped, config-like settings applied via
#' [gdalraster::vsi_set_path_option()].
#'
#' @inheritParams as_gdal_config_opts
#' @param vsi_path Optional VSI path prefix the options apply to (e.g. `"/vsis3/bucket"`).
#'
#' @returns A [gdal_vsi_opts()] object.
#' @export
as_gdal_vsi_opts <- function(x, ..., vsi_path = NULL, call = rlang::caller_env()) {
  UseMethod("as_gdal_vsi_opts")
}

#' @rdname as_gdal_vsi_opts
#' @export
as_gdal_vsi_opts.default <- function(x, ..., vsi_path = NULL, call = rlang::caller_env()) {
  gdal_abort_opts(
    "Can't coerce {.cls {class(x)}} to {.cls gdal_vsi_opts}.",
    cls = "gdal_opts_coerce_error",
    call = call
  )
}

#' @rdname as_gdal_vsi_opts
#' @export
as_gdal_vsi_opts.gdal_vsi_opts <- function(x, ..., vsi_path = NULL, call = rlang::caller_env()) {
  if (!is.null(vsi_path)) {
    attr(x, "vsi_path") <- vsi_path
  }
  x
}

#' @rdname as_gdal_vsi_opts
#' @export
as_gdal_vsi_opts.list <- function(x, ..., vsi_path = NULL, call = rlang::caller_env()) {
  new_gdal_vsi_opts(.gdal_opts_normalize(x, call = call), vsi_path = vsi_path)
}

#' @rdname as_gdal_vsi_opts
#' @export
as_gdal_vsi_opts.character <- function(x, ..., vsi_path = NULL, call = rlang::caller_env()) {
  new_gdal_vsi_opts(.gdal_opts_parse_kv(x, call = call), vsi_path = vsi_path)
}

#' GDAL VSI Options
#'
#' @description
#' Construct a [gdal_vsi_opts()] object from `NAME = value` pairs, optionally scoped to a `vsi_path`.
#' These are config-like options for GDAL virtual file systems (e.g. cloud storage credentials and
#' HTTP tuning) and render as `--config NAME=VALUE`.
#'
#' @param ... Named VSI options (`NAME = value`).
#' @param vsi_path Optional VSI path prefix (e.g. `"/vsis3/bucket"`).
#'
#' @returns A [gdal_vsi_opts()] object.
#' @export
#'
#' @examples
#' gdal_vsi_opts(AWS_REGION = "us-east-1", vsi_path = "/vsis3/my-bucket")
gdal_vsi_opts <- function(..., vsi_path = NULL) {
  as_gdal_vsi_opts(rlang::list2(...), vsi_path = vsi_path)
}

# algorithm arguments ---------------------------------------------------------------------------------------------

#' Convert GDAL Options to Algorithm Arguments
#'
#' @description
#' Render a [gdal_opts()] object to the form consumed by the GDAL algorithm API
#' ([gdalraster::gdal_alg()] / [gdalraster::gdal_run()]).
#'
#' @details
#' For repeated options (`--oo`/`--co`/`--lco`), GDAL requires each value to be preceded by its own
#' flag - values are never comma-packed (a packed value would corrupt options such as
#' `PRELUDE_STATEMENTS` that themselves contain `;`/`,`). Accordingly:
#'
#' - `cli = TRUE` (default) emits a flat token vector `c("--open-option", "K=V", "--open-option",
#'   "K2=V2", ...)`, suitable as the `args` to [gdalraster::gdal_alg()].
#' - `cli = FALSE` emits an unnamed `c("K=V", ...)` vector, suitable for a single
#'   `alg$setArg(<flag>, .)` call.
#'
#' @param x A [gdal_opts()] object (or a character vector / list, passed through).
#' @param cli Logical; emit interleaved CLI tokens (`TRUE`, default) or a bare `KEY=VALUE` vector.
#' @param long Logical; use long flag names (`--open-option`) rather than aliases (`--oo`).
#' @param with_format Logical; prepend the `--input-format`/`--output-format` flag and driver when
#'   known (open/creation only).
#' @param ... Passed to methods.
#'
#' @returns A character vector.
#' @export
#'
#' @examples
#' as_gdal_args(gdal_open_opts(LIST_ALL_TABLES = FALSE, driver = "GPKG"))
#' as_gdal_args(gdal_open_opts(LIST_ALL_TABLES = FALSE), cli = FALSE)
as_gdal_args <- function(x, ...) {
  UseMethod("as_gdal_args")
}

#' @rdname as_gdal_args
#' @export
as_gdal_args.gdal_opts <- function(x, cli = TRUE, long = FALSE, with_format = FALSE, ...) {
  payload <- .gdal_opts_payload(x)
  if (length(payload) == 0L) {
    return(character())
  }
  kv <- paste0(names(payload), "=", unlist(payload, use.names = FALSE))
  if (!isTRUE(cli)) {
    return(unname(kv))
  }
  flag <- gdal_opts_cli_flag(x, long = long)
  tokens <- as.vector(rbind(flag, kv))
  if (isTRUE(with_format)) {
    fmt_flag <- gdal_opts_format_flag(x)
    drv <- attr(x, "driver")
    if (!is.null(fmt_flag) && !is.null(drv)) {
      tokens <- c(fmt_flag, drv, tokens)
    }
  }
  tokens
}

#' @rdname as_gdal_args
#' @export
as_gdal_args.character <- function(x, ...) {
  x
}

#' @rdname as_gdal_args
#' @export
as_gdal_args.list <- function(x, ...) {
  unlist(lapply(x, as_gdal_args, ...), use.names = FALSE)
}

#' @rdname as_gdal_args
#' @export
as_gdal_args.default <- function(x, ...) {
  gdal_abort_opts(
    "Can't convert {.cls {class(x)}} to GDAL arguments.",
    cls = "gdal_opts_coerce_error"
  )
}

# configuration option vector -------------------------------------------------------------------------------------

#' Convert GDAL Configuration Options to a Config-Option Vector
#'
#' @description
#' Render a [gdal_config_opts()] or [gdal_vsi_opts()] object to a named character vector
#' `c(NAME = "VALUE")`, the form consumed by [gdalraster::set_config_option()]. Configuration
#' options are ignored by the GDAL algorithm API and must be applied to the process/session this
#' way (or via the CLI `--config` flag, see [as_gdal_args()]).
#'
#' @param x A [gdal_config_opts()] or [gdal_vsi_opts()] object.
#' @param ... Passed to methods.
#'
#' @returns A named character vector.
#' @export
#'
#' @examples
#' as_config_option(gdal_config_opts(CPL_DEBUG = "ON"))
as_config_option <- function(x, ...) {
  UseMethod("as_config_option")
}

#' @rdname as_config_option
#' @export
as_config_option.gdal_config_opts <- function(x, ...) {
  .gdal_opts_config_vector(x)
}

#' @rdname as_config_option
#' @export
as_config_option.gdal_vsi_opts <- function(x, ...) {
  .gdal_opts_config_vector(x)
}

#' @rdname as_config_option
#' @export
as_config_option.default <- function(x, ...) {
  gdal_abort_opts(
    "{.arg x} must be a {.cls gdal_config_opts} or {.cls gdal_vsi_opts} object.",
    cls = "gdal_opts_coerce_error"
  )
}

# validation ------------------------------------------------------------------------------------------------------

#' Validate GDAL Options Against Driver Metadata
#'
#' @description
#' Check a [gdal_opts()] object against its driver's registered metadata: unknown option names,
#' invalid enumerated (`string-select`) values, and invalid boolean values. Validation is advisory
#' and non-blocking - it warns (with classed conditions) and returns a logical, leaving the decision
#' to act at the call site.
#'
#' @param x A [gdal_open_opts()], [gdal_creation_opts()], or [gdal_config_opts()] object.
#' @param driver GDAL driver short name; defaults to the object's `driver` attribute.
#' @inheritParams rlang::args_error_context
#'
#' @returns Invisibly, `TRUE` if valid, `FALSE` if any problems were found, or `NA` if validation
#'   could not be performed (no driver).
#' @export
#'
#' @examples
#' validate_gdal_opts(gdal_open_opts(LIST_ALL_TABLES = "NO", driver = "GPKG"))
validate_gdal_opts <- function(x, driver = attr(x, "driver"), call = rlang::caller_env()) {
  check_inherits(x, "gdal_opts", call = call)
  if (is.null(driver)) {
    gdal_warn_opts("Cannot validate options without a {.arg driver}.")
    return(invisible(NA))
  }
  check_gdal_driver_name(driver, call = call)

  if (is_gdal_open_opts(x)) {
    md <- gdal_vector_driver_open_opts(driver)
    kind <- "open"
  } else if (is_gdal_creation_opts(x)) {
    md <- gdal_vector_driver_creation_opts(driver, sub_type = attr(x, "level"))
    kind <- "creation"
  } else if (is_gdal_config_opts(x)) {
    md <- gdal_vector_driver_config_opts(driver)
    kind <- "config"
  } else {
    gdal_abort_opts("Cannot validate {.cls {class(x)[[1]]}} objects.", call = call)
  }

  payload <- .gdal_opts_payload(x)
  if (length(payload) == 0L) {
    return(invisible(TRUE))
  }

  keys <- names(payload)
  valid <- TRUE

  unknown <- keys[!(toupper(keys) %in% toupper(md$name))]
  if (length(unknown) > 0L) {
    valid <- FALSE
    gdal_warn_opts(
      "Unknown {kind} option{?s} for driver {.field {driver}}: {.val {unknown}}.",
      cls = "gdal_opts_unknown_warning"
    )
  }

  values <- .gdal_opts_md_values(md)
  for (k in keys) {
    allowed <- values[[toupper(k)]]
    if (is.null(allowed)) {
      next
    }
    v <- payload[[k]]
    if (!(toupper(v) %in% toupper(allowed))) {
      valid <- FALSE
      gdal_warn_opts(
        "Invalid value {.val {v}} for {kind} option {.field {k}}; allowed: {.val {allowed}}.",
        cls = "gdal_opts_value_warning"
      )
    }
  }

  invisible(valid)
}

# format and print ------------------------------------------------------------------------------------------------

#' @export
format.gdal_opts <- function(x, ..., style = c("inline", "block")) {
  style <- rlang::arg_match(style)
  cls <- paste(class(x)[1:2], collapse = "/")
  drv <- attr(x, "driver")
  payload <- .gdal_opts_payload(x)
  label <- gdal_opts_label(x)
  n <- length(payload)
  keys <- names(payload)
  vals <- unlist(payload, use.names = FALSE)
  kv <- if (n > 0L) paste(paste0(keys, "=", vals), collapse = ", ") else ""
  cmd <- if (n > 0L) gdal_opts_cmd_inline(x) else ""

  cli::cli_fmt({
    d <- cli::cli_div(theme = gdalvector_cli_theme())
    cli::cli_text("{.cls {cls}}")
    if (!is.null(drv)) {
      cli::cli_alert_info("Driver: {.drv {drv}}")
    }
    if (n == 0L) {
      cli::cli_alert_info("No {tolower(label)} set.")
    } else if (identical(style, "inline") && n <= 4L) {
      cli::cli_alert_info("{label}: {.field {kv}}")
      cli::cli_alert_info("Command Line: {cmd}")
    } else {
      cli::cli_alert_info("{label} ({n}):")
      for (i in seq_len(n)) {
        cli::cli_text("    {.optname {keys[i]}} = {.optval {vals[i]}}")
      }
      cli::cli_alert_info("Command Line: {cmd}")
    }
    cli::cli_end(d)
  })
}

#' @export
print.gdal_opts <- function(x, ...) {
  cat(format(x, ...), sep = "\n")
  invisible(x)
}

#' @export
c.gdal_opts <- function(...) {
  dots <- list(...)
  dots <- dots[!vapply(dots, is.null, logical(1))]
  if (length(dots) == 0L) {
    return(NULL)
  }
  drivers <- unique(unlist(lapply(dots, attr, "driver")))
  if (length(drivers) > 1L) {
    gdal_warn_opts(
      "Combining options from multiple drivers: {.field {drivers}}.",
      cls = "gdal_opts_merge_warning"
    )
  }
  levels <- unique(unlist(lapply(dots, attr, "level")))
  if (length(levels) > 1L) {
    gdal_warn_opts(
      "Combining creation options of multiple levels: {.field {levels}}.",
      cls = "gdal_opts_merge_warning"
    )
  }
  proto <- dots[[1]]
  merged <- Reduce(function(a, b) utils::modifyList(a, b), lapply(dots, .gdal_opts_payload))
  structure(
    merged,
    driver = attr(proto, "driver"),
    level = attr(proto, "level"),
    vsi_path = attr(proto, "vsi_path"),
    class = class(proto)
  )
}

#' @export
as.character.gdal_opts <- function(x, ...) {
  as_gdal_args(x, cli = FALSE)
}

#' @export
as.list.gdal_opts <- function(x, ...) {
  .gdal_opts_payload(x)
}

# rendering -------------------------------------------------------------------------------------------------------

#' Render GDAL Options as a Shell Command Snippet
#'
#' @description
#' Render a [gdal_opts()] object to a copy-pasteable, multi-line shell snippet with one
#' flag/value pair per line and the appropriate line-continuation for the target shell. Only the
#' option flags (and the leading `--input-format`/`--output-format` when the driver is known) are
#' rendered; the base `gdal` invocation and datasets are not included.
#'
#' @param x A [gdal_opts()] object.
#' @param shell Target shell dialect controlling quoting and continuation: `"bash"`/`"sh"`
#'   (`\\`, single quotes), `"pwsh"` (`` ` ``, single quotes), or `"cmd"` (`^`, double quotes).
#'
#' @returns A length-1 character string (embedded newlines), or `""` when there are no options.
#' @export
#'
#' @examples
#' gdal_render(gdal_creation_opts(COMPRESSION = "ZSTD", driver = "Parquet"), shell = "bash")
gdal_render <- function(x, shell = c("bash", "sh", "pwsh", "cmd")) {
  shell <- rlang::arg_match(shell)
  check_inherits(x, "gdal_opts")
  tokens <- as_gdal_args(x, cli = TRUE, long = TRUE, with_format = TRUE)
  if (length(tokens) == 0L) {
    return("")
  }
  quote <- if (shell == "cmd") "\"" else "'"
  cont <- switch(shell, bash = " \\", sh = " \\", pwsh = " `", cmd = " ^")
  flags <- tokens[c(TRUE, FALSE)]
  vals <- tokens[c(FALSE, TRUE)]
  lines <- paste0(flags, " ", quote, vals, quote)
  paste(lines, collapse = paste0(cont, "\n"))
}

# CLI flag for an opts object's family; `long` selects long form over the short alias.
#' @keywords internal
#' @noRd
gdal_opts_cli_flag <- function(x, long = FALSE) {
  if (is_gdal_config_opts(x) || is_gdal_vsi_opts(x)) {
    return("--config")
  }
  if (is_gdal_open_opts(x)) {
    return(if (long) "--open-option" else "--oo")
  }
  if (is_gdal_creation_opts(x)) {
    if (identical(attr(x, "level"), "dataset")) {
      return(if (long) "--creation-option" else "--co")
    }
    return(if (long) "--layer-creation-option" else "--lco")
  }
  gdal_abort_opts("Cannot determine a CLI flag for {.cls {class(x)[[1]]}}.")
}

# the format-selection flag whose value is the driver (open -> input, creation -> output).
#' @keywords internal
#' @noRd
gdal_opts_format_flag <- function(x) {
  if (is_gdal_open_opts(x)) {
    return("--input-format")
  }
  if (is_gdal_creation_opts(x)) {
    return("--output-format")
  }
  NULL
}

# human-facing label for the options block.
#' @keywords internal
#' @noRd
gdal_opts_label <- function(x) {
  if (is_gdal_config_opts(x)) {
    return("Configuration Options")
  }
  if (is_gdal_open_opts(x)) {
    return("Open Options")
  }
  if (is_gdal_creation_opts(x)) {
    return("Creation Options")
  }
  if (is_gdal_vsi_opts(x)) {
    return("VSI Options")
  }
  "Options"
}

# single-line command rendering, e.g. "--input-format 'GPKG' --open-option 'LIST_ALL_TABLES=NO'".
#' @keywords internal
#' @noRd
gdal_opts_cmd_inline <- function(x) {
  tokens <- as_gdal_args(x, cli = TRUE, long = TRUE, with_format = TRUE)
  if (length(tokens) == 0L) {
    return("")
  }
  is_flag <- startsWith(tokens, "--")
  rendered <- ifelse(is_flag, tokens, sprintf("'%s'", tokens))
  paste(rendered, collapse = " ")
}

# utilities -------------------------------------------------------------------------------------------------------

# coerce a logical/character to GDAL's "YES"/"NO" boolean form (NULL/NA/empty -> NULL so the option
# is dropped). the single coercion driver builders apply to boolean arguments.
#' @keywords internal
#' @noRd
as_gdal_boolean <- function(x) {
  if (is.null(x)) {
    return(NULL)
  }
  if (length(x) == 1L && (is.na(x) || !nzchar(as.character(x)))) {
    return(NULL)
  }
  if (is.logical(x)) {
    return(if (isTRUE(x)) "YES" else "NO")
  }
  as.character(x)
}

# internal --------------------------------------------------------------------------------------------------------

# normalize an arbitrary named list/character into the canonical payload: a named list of length-1
# coerced GDAL strings, UPPERCASE names, with NULL/NA/empty dropped and duplicate names de-duped
# (last wins). the single structural normalization point for the whole opts system.
#' @keywords internal
#' @noRd
.gdal_opts_normalize <- function(x, call = rlang::caller_env()) {
  empty <- stats::setNames(list(), character())
  if (is.null(x) || length(x) == 0L) {
    return(empty)
  }
  if (!is.list(x)) {
    x <- as.list(x)
  }
  x <- purrr::compact(x)
  keep <- vapply(x, function(v) length(v) > 0L && !(length(v) == 1L && is.na(v)), logical(1))
  x <- x[keep]
  if (length(x) == 0L) {
    return(empty)
  }
  check_named2(x, call = call)
  scalar <- vapply(x, function(v) length(v) == 1L, logical(1))
  if (!all(scalar)) {
    gdal_abort_opts(
      "Each option value must be a single value; offending: {.field {names(x)[!scalar]}}.",
      cls = "gdal_opts_value_error",
      call = call
    )
  }
  vals <- lapply(x, .gdal_opts_format_value)
  names(vals) <- toupper(names(x))
  if (anyDuplicated(names(vals))) {
    vals <- vals[!duplicated(names(vals), fromLast = TRUE)]
  }
  vals
}

# coerce a single R value to its GDAL string form (scientific-notation safe for numerics; logical
# -> YES/NO).
#' @keywords internal
#' @noRd
.gdal_opts_format_value <- function(v) {
  if (is.logical(v)) {
    return(if (isTRUE(v)) "YES" else "NO")
  }
  if (is.numeric(v)) {
    return(format(v, scientific = FALSE, trim = TRUE))
  }
  as.character(v)
}

# the bare named-list payload of a gdal_opts (no class, no attrs besides names).
#' @keywords internal
#' @noRd
.gdal_opts_payload <- function(x) {
  out <- unclass(x)
  attributes(out) <- list(names = names(out))
  out
}

# parse a character vector of "KEY=VALUE" strings into a normalized named list.
#' @keywords internal
#' @noRd
.gdal_opts_parse_kv <- function(x, call = rlang::caller_env()) {
  x <- x[!is.na(x) & nzchar(x)]
  if (length(x) == 0L) {
    return(stats::setNames(list(), character()))
  }
  if (!all(grepl("=", x, fixed = TRUE))) {
    gdal_abort_opts(
      "Character options must be {.code KEY=VALUE} strings.",
      cls = "gdal_opts_coerce_error",
      call = call
    )
  }
  keys <- sub("=.*$", "", x)
  vals <- sub("^[^=]*=", "", x)
  .gdal_opts_normalize(stats::setNames(as.list(vals), keys), call = call)
}

# name -> default named list from a driver-metadata tibble (rows with a declared default).
#' @keywords internal
#' @noRd
.gdal_opts_from_md <- function(md) {
  if (!all(c("name", "default") %in% names(md))) {
    return(stats::setNames(list(), character()))
  }
  md <- md[!is.na(md$default), , drop = FALSE]
  .gdal_opts_normalize(stats::setNames(as.list(md$default), md$name))
}

# name -> allowed-values named list from a driver-metadata tibble, keeping only options that
# declare a constrained value set (booleans already expanded to c("YES","NO") upstream).
#' @keywords internal
#' @noRd
.gdal_opts_md_values <- function(md) {
  has_vals <- !vapply(md$values, function(v) length(v) == 0L || (length(v) == 1L && is.na(v)), logical(1))
  stats::setNames(md$values[has_vals], toupper(md$name[has_vals]))
}

# named character vector c(NAME = "VALUE") for set_config_option(); empty -> named character(0).
#' @keywords internal
#' @noRd
.gdal_opts_config_vector <- function(x) {
  payload <- .gdal_opts_payload(x)
  if (length(payload) == 0L) {
    return(stats::setNames(character(), character()))
  }
  unlist(payload)
}
