# in-process gdal vector pipeline execution via the gdalraster algorithmic api.
#
# one call produces, for a given scenario:
#   1. the materialized output dataset on disk (FlatGeobuf, (Geo)Parquet, ...)
#   2. a .gdalg.json lineage sidecar (the serialized pipeline, for reproducibility)
#   3. a captured log file of every gdal message emitted while building the output
#
# args are passed to gdal_alg() as a FLAT CHARACTER VECTOR of tokens (not a single
# collapsed "pipeline" string). this matters: it preserves spaces in --where /
# --sql values without manual quoting, and the collapsed-string form fails for
# GDALG output (the parser tries to open the whole string as a file).
#
# logging: gdalraster routes gdal messages through R's message stream, so we
# capture them with capture.output(type = "message"). fully in-process. captures
# CPL_DEBUG / VSICURL output. avoid CPL_CURL_VERBOSE on threaded remote reads --
# its worker-thread output cannot be captured in-process and can crash the session.

# build the write-step tokens for a pipeline tail
gdal_write_step <- function(
  output,
  output_format = NULL,
  output_layer = NULL,
  creation_option = NULL,
  layer_creation_option = NULL,
  overwrite = TRUE,
  skip_errors = FALSE
) {
  repeated <- function(flag, values) {
    if (is.null(values) || !length(values)) {
      return(character())
    }
    as.vector(rbind(flag, values))
  }
  c(
    "write",
    "--output",
    output,
    if (!is.null(output_format)) c("--output-format", output_format),
    if (!is.null(output_layer)) c("--output-layer", output_layer),
    if (isTRUE(overwrite)) "--overwrite",
    if (isTRUE(skip_errors)) "--skip-errors",
    repeated("--co", creation_option),
    repeated("--lco", layer_creation_option)
  )
}

# apply named config options, returning the previous values for restoration
gdal_config_apply <- function(config) {
  if (is.null(config) || !length(config)) {
    return(stats::setNames(list(), character()))
  }
  old <- lapply(names(config), function(k) {
    v <- tryCatch(gdalraster::get_config_option(k), error = function(e) "")
    if (is.null(v) || !length(v)) "" else as.character(v[[1]])
  })
  names(old) <- names(config)
  for (k in names(config)) {
    gdalraster::set_config_option(k, as.character(config[[k]]))
  }
  old
}

gdal_config_restore <- function(old) {
  for (k in names(old)) {
    gdalraster::set_config_option(k, old[[k]])
  }
  invisible(TRUE)
}

# run one pipeline (flat token vector), capturing all gdal messages
gdal_alg_run_captured <- function(args, release = TRUE) {
  alg <- gdalraster::gdal_alg(cmd = "vector pipeline", args = args)
  result <- NULL
  messages <- utils::capture.output(
    result <- alg$run(),
    type = "message"
  )
  flushed <- if (isTRUE(result)) alg$close() else FALSE
  if (isTRUE(release)) {
    alg$release()
  }
  list(ok = isTRUE(result), flushed = isTRUE(flushed), messages = messages)
}

#' execute a gdal vector pipeline, materializing data + gdalg lineage + log
#'
#' @param steps character vector of pipeline tokens for the read step through the
#'   final transform step (no write step). use "!" elements to separate steps; a
#'   leading "!" is optional. multi-word values (e.g. a --where clause) must be a
#'   single vector element -- do NOT add quotes around them.
#' @param output path to the materialized output dataset.
#' @param output_format output driver short name (e.g. "FlatGeobuf", "Parquet").
#' @param output_layer optional output layer name.
#' @param creation_option,layer_creation_option character vectors of "KEY=VALUE".
#' @param overwrite,skip_errors logical write-step flags.
#' @param gdalg_file optional path for the .gdalg.json lineage sidecar.
#' @param log_file optional path for the captured log.
#' @param config named list of gdal config options (applied then restored).
#' @param append_log append to an existing log file instead of overwriting.
#' @returns (invisibly) a list with `output`, `gdalg_file`, `log_file`, `ok`,
#'   `flushed`, and `features`.
gdal_vector_pipeline_run <- function(
  steps,
  output,
  output_format = NULL,
  output_layer = NULL,
  creation_option = NULL,
  layer_creation_option = NULL,
  overwrite = TRUE,
  skip_errors = FALSE,
  gdalg_file = NULL,
  log_file = NULL,
  config = NULL,
  append_log = FALSE,
  call = rlang::caller_env()
) {
  if (length(steps) == 0L || !is.character(steps)) {
    cli::cli_abort("{.arg steps} must be a non-empty character vector.", call = call)
  }
  # normalize: ensure the inner steps begin with a "!" separator
  steps <- as.character(steps)
  if (!identical(steps[[1]], "!")) {
    steps <- c("!", steps)
  }

  old_config <- gdal_config_apply(config)
  on.exit(gdal_config_restore(old_config), add = TRUE)

  log_blocks <- character()
  add_block <- function(title, args, res) {
    log_blocks <<- c(
      log_blocks,
      sprintf("# %s: %s", title, format(Sys.time(), "%Y-%m-%d %H:%M:%S %Z")),
      sprintf("# command: gdal vector pipeline %s", paste(args, collapse = " ")),
      "",
      sprintf("[ok=%s flushed=%s]", res$ok, res$flushed),
      res$messages,
      ""
    )
  }

  # 1. gdalg lineage sidecar (serializes the pipeline definition)
  if (!is.null(gdalg_file)) {
    gdalg_args <- c(steps, "!", gdal_write_step(gdalg_file, output_format = "GDALG", overwrite = overwrite))
    res_gdalg <- gdal_alg_run_captured(gdalg_args)
    add_block("gdalg lineage", gdalg_args, res_gdalg)
    if (!res_gdalg$ok) cli::cli_alert_warning("gdalg lineage write failed for {.path {gdalg_file}}")
  }

  # 2. materialize the actual output dataset
  data_args <- c(
    steps,
    "!",
    gdal_write_step(
      output,
      output_format = output_format,
      output_layer = output_layer,
      creation_option = creation_option,
      layer_creation_option = layer_creation_option,
      overwrite = overwrite,
      skip_errors = skip_errors
    )
  )
  res_data <- gdal_alg_run_captured(data_args)
  add_block("materialize", data_args, res_data)

  # 3. write captured log
  if (!is.null(log_file)) {
    write(log_blocks, file = log_file, append = isTRUE(append_log))
  }

  features <- NA_integer_
  if (res_data$ok) {
    features <- tryCatch({
      gdalraster::push_error_handler("quiet")
      on.exit(gdalraster::pop_error_handler(), add = TRUE)
      v <- gdalraster::GDALVector$new(output)
      n <- v$getFeatureCount()
      v$close()
      n
    }, error = function(e) NA_integer_)
    if (is.na(features)) {
      cli::cli_alert_success("wrote {.path {output}}")
    } else {
      cli::cli_alert_success("wrote {.path {output}} ({features} features)")
    }
    if (!is.null(gdalg_file)) {
      cli::cli_alert_info("lineage: {.path {gdalg_file}}")
    }
    if (!is.null(log_file)) cli::cli_alert_info("log: {.path {log_file}}")
  } else {
    cli::cli_alert_danger("pipeline failed; see log {.path {log_file %||% '(none)'}}")
  }

  invisible(list(
    output = output,
    gdalg_file = gdalg_file,
    log_file = log_file,
    ok = res_data$ok,
    flushed = res_data$flushed,
    features = features
  ))
}
