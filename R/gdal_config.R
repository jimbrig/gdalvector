#  ------------------------------------------------------------------------
#
# Title : GDAL Configuration
#    By : Jimmy Briggs
#  Date : 2026-07-02
#
#  ------------------------------------------------------------------------

# class -----------------------------------------------------------------------------------------------------------

#' GDAL Configuration
#'
#' @name gdal_config
#'
#' @description
#' A `gdal_config` is an inert, composable *value* describing a GDAL configuration: one
#' [gdal_config_opts()] payload (options bound globally) plus zero or more path-bound
#' [gdal_vsi_opts()] payloads (options bound to a VSI path prefix, e.g. credentials for a specific
#' bucket). It is the unit the stateful verbs apply ([gdal_config_set()]), the scoped helpers pin
#' ([with_gdal_config()]), the session tracks ([gdal_config_active()]), and the GDAL configuration
#' file serializes ([gdal_config_file_write()]).
#'
#' - `gdal_config(...)`: construct from `KEY = value` pairs, [gdal_config_opts()] /
#'   [gdal_vsi_opts()] objects, named lists, `"KEY=VALUE"` strings, or other `gdal_config` values
#'   (later inputs win). Empty call gives an empty configuration.
#' - `as_gdal_config()`: coerce from the same inputs.
#' - `c()`: merge configurations (later values win, per key and per path).
#'
#' @section One key namespace, two binding tiers:
#' There is no separate "VSI option" key type - `AWS_ACCESS_KEY_ID` and `GDAL_HTTP_TIMEOUT` live in
#' the same namespace. What differs is the tier a *value* is bound at. GDAL resolves an option for
#' a path by checking the path-specific store first (`VSISetPathSpecificOption()`; longest-matching
#' prefix wins), then falling through the ordinary chain: thread-local, global in-memory
#' (`CPLSetConfigOption()`, which also holds config-file values loaded at GDAL initialization),
#' environment variable (live `getenv()`), built-in default. A [gdal_vsi_opts()] *without* a
#' `vsi_path` is therefore just config opts and merges into the global channel; *with* a
#' `vsi_path` it is kept path-bound in the `vsi` channel.
#'
#' @section Rendering:
#' `as_gdal_args()` renders the global channel as `--config KEY=VALUE` CLI tokens. Path-bound VSI
#' options **cannot** be expressed on the CLI at all - GDAL only accepts them in-process
#' ([gdalraster::vsi_set_path_option()]) or via the config file `[credentials]` section - so they
#' are omitted with a message by default; `flatten_vsi = TRUE` emits them as global `--config`
#' tokens instead (loses the path scoping; warns when paths carry conflicting values for the same
#' key). [gdal_config_file_write()] is the only lossless serialization of a full `gdal_config`.
#'
#' @param ... Configuration options: `KEY = value` pairs, [gdal_config_opts()] / [gdal_vsi_opts()]
#'   objects, named lists, `"KEY=VALUE"` character vectors, or `gdal_config` values. Open/creation
#'   options are rejected - they are per-call algorithm arguments (see [as_gdal_args()]), never
#'   configuration.
#' @param x Object to coerce.
#' @inheritParams rlang::args_error_context
#'
#' @returns
#' A `gdal_config` object: a list with elements `opts` (a [gdal_config_opts()]) and `vsi`
#' (a named list of path-bound [gdal_vsi_opts()], keyed by path prefix).
#'
#' @seealso [gdal_config_set()], [gdal_config_active()], [gdal_config_sitrep()],
#'   [gdal_config_file_read()], [with_gdal_config()]
#'
#' @export
#'
#' @importFrom rlang list2 names2 current_env
#' @importFrom stats setNames
#' @importFrom utils modifyList
#'
#' @examples
#' gdal_config(
#'   GDAL_NUM_THREADS = "ALL_CPUS",
#'   gpkg_config_opts(sqlite_synchronous = "OFF"),
#'   gdal_vsi_opts(AWS_S3_ENDPOINT = "t3.storage.dev", vsi_path = "/vsis3/my-bucket/")
#' )
gdal_config <- function(...) {
  dots <- rlang::list2(...)
  nms <- rlang::names2(dots)
  call <- rlang::current_env()
  payload <- stats::setNames(list(), character())
  vsi <- list()

  merge_vsi <- function(vsi, path, opts_payload) {
    current <- if (is.null(vsi[[path]])) list() else .gdal_opts_payload(vsi[[path]])
    vsi[[path]] <- as_gdal_vsi_opts(utils::modifyList(current, opts_payload), vsi_path = path)
    vsi
  }

  for (i in seq_along(dots)) {
    x <- dots[[i]]
    if (nzchar(nms[[i]])) {
      payload <- utils::modifyList(payload, .gdal_opts_normalize(stats::setNames(list(x), nms[[i]]), call = call))
      next
    }
    if (is_gdal_config(x)) {
      payload <- utils::modifyList(payload, .gdal_opts_payload(x$opts))
      for (path in names(x$vsi)) {
        vsi <- merge_vsi(vsi, path, .gdal_opts_payload(x$vsi[[path]]))
      }
      next
    }
    if (is_gdal_open_opts(x) || is_gdal_creation_opts(x)) {
      gdal_abort_config(
        c(
          "{.cls {class(x)[[1]]}} options are per-call algorithm arguments, not configuration.",
          "i" = "Pass them to the algorithm via {.fn as_gdal_args} instead."
        ),
        cls = "gdal_config_channel_error",
        call = call
      )
    }
    if (is_gdal_vsi_opts(x) && !is.null(attr(x, "vsi_path"))) {
      vsi <- merge_vsi(vsi, attr(x, "vsi_path"), .gdal_opts_payload(x))
      next
    }
    if (is_gdal_config_opts(x) || is_gdal_vsi_opts(x)) {
      payload <- utils::modifyList(payload, .gdal_opts_payload(x))
      next
    }
    if (is.list(x) || is.character(x)) {
      payload <- utils::modifyList(payload, .gdal_opts_payload(as_gdal_config_opts(x, call = call)))
      next
    }
    gdal_abort_config(
      "Can't interpret {.obj_type_friendly {x}} as configuration options.",
      cls = "gdal_config_channel_error",
      call = call
    )
  }

  new_gdal_config(as_gdal_config_opts(payload), vsi)
}

#' @keywords internal
#' @noRd
#' @importFrom purrr walk map_chr
new_gdal_config <- function(opts = as_gdal_config_opts(list()), vsi = list()) {
  check_inherits(opts, "gdal_config_opts")
  purrr::walk(vsi, check_vsi_opts)
  names(vsi) <- purrr::map_chr(vsi, attr, "vsi_path")
  structure(
    list(opts = opts, vsi = vsi),
    class = c("gdal_config", "list")
  )
}

# coercion --------------------------------------------------------------------------------------------------------

#' @rdname gdal_config
#' @export
#' @importFrom rlang caller_env
as_gdal_config <- function(x, ..., call = rlang::caller_env()) {
  UseMethod("as_gdal_config")
}

#' @rdname gdal_config
#' @export
as_gdal_config.default <- function(x, ..., call = rlang::caller_env()) {
  gdal_abort_config(
    "Can't coerce {.cls {class(x)}} to {.cls gdal_config}.",
    cls = "gdal_config_coerce_error",
    call = call
  )
}

#' @rdname gdal_config
#' @export
as_gdal_config.gdal_config <- function(x, ..., call = rlang::caller_env()) {
  x
}

#' @rdname gdal_config
#' @export
as_gdal_config.gdal_opts <- function(x, ..., call = rlang::caller_env()) {
  gdal_config(x)
}

#' @rdname gdal_config
#' @export
as_gdal_config.list <- function(x, ..., call = rlang::caller_env()) {
  gdal_config(x)
}

#' @rdname gdal_config
#' @export
as_gdal_config.character <- function(x, ..., call = rlang::caller_env()) {
  gdal_config(x)
}

# methods ---------------------------------------------------------------------------------------------------------

#' @export
#' @importFrom purrr compact
#' @importFrom rlang exec
c.gdal_config <- function(...) {
  dots <- purrr::compact(list(...))
  if (length(dots) == 0L) {
    return(NULL)
  }
  rlang::exec(gdal_config, !!!dots)
}

#' @export
#' @importFrom cli cli_text cli_alert_info
#' @importFrom purrr imap_chr
format.gdal_config <- function(x, ...) {
  n_opts <- length(.gdal_opts_payload(x$opts))
  n_vsi <- length(x$vsi)

  gpq_cli_fmt({
    cli::cli_text("{.cls gdal_config}")
    if (n_opts == 0L && n_vsi == 0L) {
      cli::cli_alert_info("Empty configuration.")
    }
    if (n_opts > 0L) {
      payload <- .gdal_opts_payload(x$opts)
      kv <- paste(
        purrr::imap_chr(payload, function(value, key) paste0(key, "=", cli_redact(key, value))),
        collapse = ", "
      )
      cli::cli_alert_info("Configuration Options ({n_opts}): {.field {kv}}")
    }
    if (n_vsi > 0L) {
      cli::cli_alert_info("VSI Path Options ({n_vsi} path{?s}):")
      for (path in names(x$vsi)) {
        payload <- .gdal_opts_payload(x$vsi[[path]])
        kv <- paste(
          purrr::imap_chr(payload, function(value, key) paste0(key, "=", cli_redact(key, value))),
          collapse = ", "
        )
        cli::cli_text("    {.file {path}}: {.field {kv}}")
      }
    }
  })
}

#' @export
print.gdal_config <- function(x, ...) {
  cat(format(x, ...), sep = "\n")
  invisible(x)
}

#' @rdname as_gdal_config_opts
#' @export
#' @importFrom rlang caller_env
as_gdal_config_opts.gdal_config <- function(x, ..., driver = NULL, call = rlang::caller_env()) {
  as_gdal_config_opts(x$opts, driver = driver, call = call)
}

#' @export
#' @importFrom purrr map
as.list.gdal_config <- function(x, ...) {
  list(
    opts = as.list(x$opts),
    vsi = purrr::map(x$vsi, as.list)
  )
}

#' Convert GDAL Configuration to Algorithm Arguments
#'
#' @description
#' Render the global channel of a [gdal_config()] as `--config KEY=VALUE` CLI tokens. Path-bound
#' VSI options cannot be expressed on the CLI (GDAL only accepts them in-process or via the config
#' file `[credentials]` section): by default they are omitted with a message; `flatten_vsi = TRUE`
#' emits them as global `--config` tokens instead - practically correct with a single credential
#' set, but the path scoping is lost (a warning is raised when paths carry conflicting values for
#' the same key). Use [gdal_config_file_write()] for a lossless serialization.
#'
#' @param flatten_vsi Logical; emit path-bound VSI options as global `--config` tokens. Defaults
#'   to `FALSE`.
#'
#' @rdname as_gdal_args
#' @export
#' @importFrom purrr map keep compact reduce
#' @importFrom utils modifyList
as_gdal_args.gdal_config <- function(x, ..., flatten_vsi = FALSE) {
  args <- as_gdal_args(x$opts, ...)
  if (length(x$vsi) == 0L) {
    return(args)
  }
  if (!isTRUE(flatten_vsi)) {
    gdal_inform_config(
      c(
        "Omitting path-bound VSI options for {.file {names(x$vsi)}}: they cannot be expressed as
         {.code --config} CLI flags.",
        "i" = "Use {.fn gdal_config_file_write} to serialize them (gdalrc {.field [credentials]}),
         or {.code flatten_vsi = TRUE} to emit them as global {.code --config} tokens."
      ),
      cls = "gdal_config_vsi_message"
    )
    return(args)
  }
  payloads <- purrr::map(x$vsi, .gdal_opts_payload)
  all_keys <- unlist(purrr::map(payloads, names), use.names = FALSE)
  conflicting <- unique(all_keys[duplicated(all_keys)]) |>
    purrr::keep(function(key) {
      values <- purrr::compact(purrr::map(payloads, key))
      length(unique(unlist(values))) > 1L
    })
  if (length(conflicting) > 0L) {
    gdal_warn_config(
      "Flattening VSI options with conflicting values across paths for {.field {conflicting}};
       the last path wins. The result does not preserve per-path credentials.",
      cls = "gdal_config_flatten_warning"
    )
  }
  flat <- purrr::reduce(payloads, utils::modifyList, .init = list())
  c(args, as_gdal_args(as_gdal_config_opts(flat), ...))
}

# active ----------------------------------------------------------------------------------------------------------

#' Active GDAL Configuration
#'
#' @description
#' The [gdal_config()] value this session has applied through [gdal_config_set()] (including any
#' load-time package defaults). Retrieve it to reuse the session's configuration elsewhere - e.g.
#' render it for a CLI invocation (`as_gdal_args(gdal_config_active())`) or serialize it
#' ([gdal_config_file_write()]).
#'
#' @returns
#' A [gdal_config()] value (empty when nothing has been applied).
#'
#' @seealso [gdal_config_set()], [gdal_config_sitrep()]
#'
#' @export
#'
#' @importFrom purrr imap
#'
#' @examples
#' gdal_config_active()
gdal_config_active <- function() {
  state <- .gdal_config_state()
  vstate <- .gdal_vsi_state()
  vsi <- purrr::imap(vstate$values, function(payload, path) {
    as_gdal_vsi_opts(as.list(payload), vsi_path = path)
  })
  new_gdal_config(as_gdal_config_opts(state$values), vsi)
}

# verbs -----------------------------------------------------------------------------------------------------------

#' Get, Set, Unset, and Reset GDAL Configuration
#'
#' @name gdal_config_set
#'
#' @description
#' The stateful verbs of the configuration system: they apply [gdal_config()] values to the
#' running GDAL process (via [gdalraster::set_config_option()] /
#' [gdalraster::vsi_set_path_option()]), track what was applied in the session's active
#' configuration ([gdal_config_active()]), and record what was in effect beforehand so state can
#' always be restored.
#'
#' - `gdal_config_set(...)`: apply options (same inputs as [gdal_config()]).
#' - `gdal_config_get()`: effective value(s), read live from GDAL (never from package state).
#' - `gdal_config_unset()`: remove options, with explicit semantics for the environment-variable
#'   fallback (`mode`).
#' - `gdal_config_reset()`: restore touched options to their pre-package state.
#'
#' For scoped (temporary) application, the recommended pattern around pipeline executions, see
#' [local_gdal_config()] / [with_gdal_config()].
#'
#' @section How GDAL resolves a configuration option:
#' For a given key, GDAL checks, in order: a thread-local option, the process-global in-memory
#' option (set via `CPLSetConfigOption()`; this also holds values loaded from the
#' [GDAL config file][gdal_config_file()] at initialization), an environment variable of the same
#' name (read live via `getenv()`), and finally the built-in default. Two consequences drive this
#' API's design:
#'
#' - **Set is authoritative**: a value applied with `gdal_config_set()` wins over an environment
#'   variable for as long as it is set.
#' - **Unset is not**: clearing the in-memory option (what `set_config_option(key, "")` does)
#'   merely *reveals* the environment variable underneath again. You cannot force GDAL's built-in
#'   default while an envvar exists - hence the explicit `mode` argument of `gdal_config_unset()`
#'   (`"reveal"`, `"mask"`, or `"scrub"`).
#'
#' Because environment variables, other packages, and the config file all write to the same GDAL
#' state, the package never mirrors values: reads always go to GDAL, and the package only records
#' the *deltas* it applied (plus what was effective beforehand, for restore).
#'
#' @section Known options:
#' Advisory typo checking (classed warning, never blocking - custom application-defined options
#' are legal) draws on: GDAL's compile-time known-option registry ([gdal_known_config_opts()],
#' parsed from the version-pinned GDAL source header), the VSI/network/credential
#' options enumerated from the running GDAL build ([gdalraster::vsi_get_fs_options()] across all
#' registered filesystems), the curated per-driver configuration options (driver metadata table),
#' and GDAL-relevant environment variables present at load. Keys GDAL already resolves to a value
#' are never flagged, and a key found in none of the lists is confirmed against the running build
#' itself via [gdal_config_option_known()] (GDAL >= 3.11) before a warning is raised.
#'
#' @inheritParams gdal_config
#' @param keys Character vector of configuration option names. For `gdal_config_get()` and
#'   `gdal_config_reset()`, `NULL` (default) means all keys the package has touched.
#' @param mode How `gdal_config_unset()` should treat the environment-variable fallback:
#'   - `"reveal"` (default): clear the in-memory option; if an envvar of the same name exists its
#'     value re-surfaces (a classed warning says so).
#'   - `"mask"`: set the option explicitly to its documented default (from the driver metadata or
#'     the runtime VSI metadata; errors when no documented default is known) - "GDAL default
#'     behavior" despite an envvar.
#'   - `"scrub"`: also remove the environment variable (`Sys.unsetenv()`); the removed value is
#'     recorded so `gdal_config_reset()` can restore it. A process-wide side effect - explicit
#'     opt-in only.
#'
#' @returns
#' - `gdal_config_get()`: a named character vector of effective values (`""` = not set).
#' - `gdal_config_set()` / `gdal_config_unset()`: invisibly, a named list of the prior effective
#'   values of the keys touched.
#' - `gdal_config_reset()`: invisibly, the character vector of keys restored.
#'
#' @seealso [gdal_config()], [gdal_config_active()], [gdal_config_sitrep()], [with_gdal_config()]
#'
#' @examples
#' \dontrun{
#' gdal_config_set(GDAL_NUM_THREADS = "ALL_CPUS", CPL_TMPDIR = tempdir())
#' gdal_config_get("GDAL_NUM_THREADS")
#' gdal_config_active()
#' gdal_config_reset()
#'
#' # driver-typed config opts flow straight in:
#' gdal_config_set(gpkg_config_opts(sqlite_synchronous = "OFF"))
#' gdal_config_reset()
#' }
NULL

#' @rdname gdal_config_set
#' @export
gdal_config_set <- function(...) {
  cfg <- gdal_config(...)
  invisible(.gdal_config_apply(cfg))
}

#' @rdname gdal_config_set
#' @export
#' @importFrom gdalraster get_config_option
#' @importFrom stats setNames
gdal_config_get <- function(keys = NULL) {
  if (is.null(keys)) {
    keys <- names(.gdal_config_state()$restore)
  }
  if (length(keys) == 0L) {
    return(stats::setNames(character(), character()))
  }
  check_character(keys)
  keys <- toupper(keys)
  vapply(stats::setNames(keys, keys), gdalraster::get_config_option, character(1))
}

#' @rdname gdal_config_set
#' @export
#' @importFrom gdalraster get_config_option
#' @importFrom rlang arg_match
gdal_config_unset <- function(keys, mode = c("reveal", "mask", "scrub")) {
  mode <- rlang::arg_match(mode)
  check_character(keys)
  keys <- toupper(keys)
  .gdal_config_check_keys(keys)

  state <- .gdal_config_state()
  prior <- list()

  for (key in keys) {
    prior[[key]] <- gdalraster::get_config_option(key)
    env_val <- Sys.getenv(key)

    if (identical(mode, "mask")) {
      default <- .gdal_config_known_default(key)
      if (is.na(default)) {
        gdal_abort_config(
          c(
            "No documented default is known for {.field {key}}; cannot {.arg mode} = {.val mask}.",
            "i" = "Use {.val reveal} (or {.val scrub}) instead, or set an explicit value."
          ),
          cls = "gdal_config_default_error"
        )
      }
      .gdal_config_put(key, default)
      next
    }

    # reveal, and scrub (which additionally removes the envvar)
    .gdal_config_put(key, "")
    if (nzchar(env_val)) {
      if (identical(mode, "scrub")) {
        state$restore[[key]]$scrubbed_env <- env_val
        Sys.unsetenv(key)
      } else {
        gdal_warn_config(
          c(
            "Unsetting {.field {key}} reveals the environment variable underneath:
             GDAL now resolves it to {.val {env_val}}.",
            "i" = "Use {.code mode = \"mask\"} to pin the documented default, or
             {.code mode = \"scrub\"} to remove the environment variable too."
          ),
          cls = "gdal_config_env_warning"
        )
      }
    }
  }

  invisible(prior)
}

#' @rdname gdal_config_set
#' @export
#' @importFrom gdalraster set_config_option vsi_set_path_option
#' @importFrom stats setNames
gdal_config_reset <- function(keys = NULL) {
  state <- .gdal_config_state()
  reset_vsi <- is.null(keys)
  if (is.null(keys)) {
    keys <- names(state$restore)
  } else {
    check_character(keys)
    keys <- toupper(keys)
  }

  restored <- character()
  for (key in keys) {
    entry <- state$restore[[key]]
    if (is.null(entry)) {
      next
    }
    if (!is.null(entry$scrubbed_env)) {
      do.call(Sys.setenv, stats::setNames(list(entry$scrubbed_env), key))
    }
    restore_to <- if (isTRUE(entry$prior_was_env) || !nzchar(entry$prior)) "" else entry$prior
    gdalraster::set_config_option(key, restore_to)
    state$restore[[key]] <- NULL
    state$values[[key]] <- NULL
    restored <- c(restored, key)
  }

  if (reset_vsi) {
    vstate <- .gdal_vsi_state()
    for (path in names(vstate$values)) {
      for (key in names(vstate$values[[path]])) {
        gdalraster::vsi_set_path_option(path, key, "")
      }
    }
    vstate$values <- list()
  }

  invisible(restored)
}

# scoped ----------------------------------------------------------------------------------------------------------

#' Scoped GDAL Configuration
#'
#' @name with_gdal_config
#'
#' @description
#' Apply GDAL configuration options for a limited scope and guarantee restoration afterwards -
#' even on error. This is the recommended pattern for workloads: the configuration channel is the
#' *execution environment* of a pipeline run (it cannot ride in algorithm arguments or a serialized
#' GDALG), so it should be pinned in place around the execution and cleaned up after.
#'
#' - `local_gdal_config()`: applies the options now and restores them when the calling frame (or
#'   `.local_envir`) exits, in the style of the withr `local_*()` functions.
#' - `with_gdal_config()`: applies the options, evaluates `code`, restores, and returns the value
#'   of `code`.
#'
#' Restoration is exact: the effective GDAL values *and* the package state are returned to their
#' condition at entry, so scoped usage never disturbs global configuration set via
#' [gdal_config_set()]. For VSI path-scoped options the prior value cannot be read back from GDAL,
#' so keys not previously set by the package are cleared on exit.
#'
#' @inheritParams gdal_config
#' @param .local_envir Environment whose exit triggers restoration. Defaults to the calling frame.
#' @param new Configuration options: a [gdal_config()] value or anything [gdal_config()] accepts.
#' @param code Code to execute with the configuration in place.
#'
#' @returns
#' - `local_gdal_config()`: invisibly, a named list of the prior effective values.
#' - `with_gdal_config()`: the value of `code`.
#'
#' @seealso [gdal_config()], [gdal_config_set()]
#'
#' @examples
#' \dontrun{
#' # pin the execution environment around a pipeline run; restored even on error
#' with_gdal_config(
#'   gdal_config(GDAL_NUM_THREADS = "ALL_CPUS", OGR_SQLITE_SYNCHRONOUS = "OFF"),
#'   gdalraster::gdal_run("vector convert", c("--input", "in.gpkg", "--output", "out.parquet"))
#' )
#'
#' # the CPL_DEBUG/GeoParquet guard (see the config docs) is just:
#' with_gdal_config(gdal_config(CPL_DEBUG = "OFF"), gdal_vector_info("data.parquet"))
#' }
NULL

#' @rdname with_gdal_config
#' @export
#' @importFrom gdalraster get_config_option set_config_option vsi_set_path_option
#' @importFrom stats setNames
#' @importFrom withr defer
local_gdal_config <- function(..., .local_envir = parent.frame()) {
  cfg <- gdal_config(...)
  state <- .gdal_config_state()
  vstate <- .gdal_vsi_state()

  keys <- names(.gdal_opts_payload(cfg$opts))
  snapshot <- lapply(stats::setNames(keys, keys), function(key) {
    list(effective = gdalraster::get_config_option(key), env = Sys.getenv(key))
  })
  values_before <- state$values
  restore_before <- state$restore
  vsi_values_before <- vstate$values

  prior <- .gdal_config_apply(cfg)

  withr::defer(
    {
      for (key in names(snapshot)) {
        s <- snapshot[[key]]
        restore_to <- if (nzchar(s$env) && identical(s$effective, s$env)) "" else s$effective
        gdalraster::set_config_option(key, restore_to)
      }
      for (path in names(cfg$vsi)) {
        for (key in names(.gdal_opts_payload(cfg$vsi[[path]]))) {
          prev <- vsi_values_before[[path]][[key]]
          gdalraster::vsi_set_path_option(path, key, if (is.null(prev)) "" else prev)
        }
      }
      state$values <- values_before
      state$restore <- restore_before
      vstate$values <- vsi_values_before
    },
    envir = .local_envir
  )

  invisible(prior)
}

#' @rdname with_gdal_config
#' @export
#' @importFrom rlang current_env
with_gdal_config <- function(new, code) {
  local_gdal_config(new, .local_envir = rlang::current_env())
  code
}

# sitrep ----------------------------------------------------------------------------------------------------------

#' GDAL Configuration Situational Report
#'
#' @description
#' A live, provenance-attributed report of the effective GDAL configuration landscape: for each
#' key with a visible signal, the effective value (read live from GDAL - the single source of
#' truth), the environment-variable value, what this package pinned, and a best-effort `source`
#' attribution:
#'
#' - `gdalvector`: currently pinned by this package ([gdal_config_set()]).
#' - `envvar`: resolved from an environment variable.
#' - `config_file`: matches a value declared in the discovered [GDAL config file][gdal_config_file()].
#' - `external`: set in GDAL's in-memory store by something else (another package, a direct
#'   [gdalraster::set_config_option()] call, ...).
#' - `unset`: no value in effect.
#'
#' Coverage spans keys pinned by the package, GDAL-relevant environment variables, config-file
#' entries, and a probe of the full known-option universe (runtime VSI metadata, driver metadata,
#' and the curated core names), so externally set in-memory values for any documented key are
#' discovered too. Secret-bearing values are redacted in printed output. A baseline sitrep taken
#' at package load is stashed internally ("the world as gdalvector found it").
#'
#' @returns
#' A `gdal_config_sitrep` object: `options` (tibble: `key`, `effective`, `envvar`, `set`,
#' `source`), `set` (the active session payload), `vsi` (path-bound options per prefix), `file`
#' (the discovered config file), and `time`. Has cli `format()`/`print()` and
#' [tibble::as_tibble()] methods.
#'
#' @seealso [gdal_config_active()], [gdal_config_file()], [gdal_config_set()]
#'
#' @export
#'
#' @importFrom dplyr bind_rows case_when if_else
#' @importFrom gdalraster get_config_option
#' @importFrom purrr map
#' @importFrom tibble tibble
#'
#' @examples
#' \dontrun{
#' gdal_config_sitrep()
#' tibble::as_tibble(gdal_config_sitrep())
#' }
gdal_config_sitrep <- function() {
  state <- .gdal_config_state()
  file <- gdal_config_file()
  env_now <- .gdal_config_env_snapshot()

  file_opts <- .gdal_opts_payload(file$configoptions)
  names(file_opts) <- toupper(names(file_opts))

  keys <- sort(unique(toupper(c(
    names(state$values),
    names(env_now),
    names(file_opts),
    .gdal_config_known_opts()
  ))))

  rows <- purrr::map(keys, function(key) {
    effective <- gdalraster::get_config_option(key)
    envvar <- Sys.getenv(key)
    pinned <- key %in% names(state$values)
    in_file <- key %in% names(file_opts)
    if (!nzchar(effective) && !nzchar(envvar) && !pinned && !in_file) {
      return(NULL)
    }
    source <- dplyr::case_when(
      pinned ~ "gdalvector",
      !nzchar(effective) ~ "unset",
      nzchar(envvar) && identical(effective, envvar) ~ "envvar",
      in_file && identical(effective, unname(unlist(file_opts[key]))) ~ "config_file",
      .default = "external"
    )
    tibble::tibble(
      key = key,
      effective = effective,
      envvar = dplyr::if_else(nzchar(envvar), envvar, NA_character_),
      set = if (pinned) state$values[[key]] else NA_character_,
      source = source
    )
  })

  structure(
    list(
      options = dplyr::bind_rows(rows),
      set = state$values,
      vsi = .gdal_vsi_state()$values,
      file = file,
      time = Sys.time()
    ),
    class = c("gdal_config_sitrep", "list")
  )
}

#' Coerce a Configuration Sitrep to Configuration Options
#'
#' @description
#' Bridge from the live view back to the value classes: extract a [gdal_config_opts()] object
#' from a [gdal_config_sitrep()]. From there the full render surface applies - [as_gdal_args()]
#' (`--config` CLI tokens), [gdal_render()], [as_config_option()].
#'
#' @param scope Which options to extract: `"session"` (default) takes only the options this
#'   package pinned via [gdal_config_set()]; `"effective"` takes every option with a non-empty
#'   effective value regardless of origin (envvars, config file, other packages) - useful for
#'   reproducing the session's configuration in a child process or CLI invocation.
#'
#' @rdname as_gdal_config_opts
#' @export
#' @importFrom rlang arg_match caller_env
#' @importFrom stats setNames
as_gdal_config_opts.gdal_config_sitrep <- function(
  x,
  ...,
  scope = c("session", "effective"),
  driver = NULL,
  call = rlang::caller_env()
) {
  scope <- rlang::arg_match(scope)
  payload <- if (identical(scope, "session")) {
    x$set
  } else {
    tbl <- x$options
    if (is.null(tbl) || nrow(tbl) == 0L) {
      list()
    } else {
      tbl <- tbl[nzchar(tbl$effective), , drop = FALSE]
      stats::setNames(as.list(tbl$effective), tbl$key)
    }
  }
  as_gdal_config_opts(as.list(payload), driver = driver, call = call)
}

#' @export
#' @importFrom tibble as_tibble
as_tibble.gdal_config_sitrep <- function(x, ...) {
  x$options
}

#' @export
#' @importFrom cli cli_text cli_alert_info
#' @importFrom purrr imap_chr
format.gdal_config_sitrep <- function(x, ...) {
  opts <- x$options
  n <- if (is.null(opts)) 0L else nrow(opts)

  gpq_cli_fmt({
    cli::cli_text("{.cls gdal_config_sitrep}")
    if (!is.null(x$file$path)) {
      n_file <- length(.gdal_opts_payload(x$file$configoptions))
      cli::cli_alert_info("Config file: {.file {x$file$path}} ({n_file} option{?s})")
    } else {
      cli::cli_alert_info("Config file: none detected")
    }
    if (n == 0L) {
      cli::cli_alert_info("No GDAL configuration options in effect.")
    } else {
      cli::cli_alert_info("Options in effect ({n}):")
      for (i in seq_len(n)) {
        key <- opts$key[[i]]
        val <- cli_redact(key, opts$effective[[i]])
        if (!nzchar(val)) {
          val <- "<unset>"
        }
        cli::cli_text("    {.optname {key}} = {.optval {val}} [{opts$source[[i]]}]")
      }
    }
    if (length(x$vsi) > 0L) {
      cli::cli_alert_info("VSI path options ({length(x$vsi)} path{?s}):")
      for (path in names(x$vsi)) {
        vals <- x$vsi[[path]]
        kv <- paste(
          purrr::imap_chr(as.list(vals), function(value, key) paste0(key, "=", cli_redact(key, value))),
          collapse = ", "
        )
        cli::cli_text("    {.file {path}}: {.field {kv}}")
      }
    }
  })
}

#' @export
print.gdal_config_sitrep <- function(x, ...) {
  cat(format(x, ...), sep = "\n")
  invisible(x)
}

# known options ---------------------------------------------------------------------------------------------------

#' Known GDAL Configuration Options
#'
#' @description
#' GDAL's compile-time known-configuration-option registry: the contents of
#' `port/cpl_known_config_options.h` in the GDAL source tree (generated upstream by
#' `collect_config_options.py`), which is the exact array `CPLGetKnownConfigOptions()`
#' (GDAL >= 3.11) returns. gdalraster does not bind that function, so the package parses the
#' version-pinned source header instead (`data-raw/scripts/gdal_known_config_options.R`, which
#' documents the pinned URL); a copy of the header is also bundled under `inst/schemas/` for
#' transparency (see `inst/schemas/schemas.R`).
#'
#' The pinned GDAL version is recorded in the `gdal_version` attribute of the returned tibble;
#' drift between that pin and the *running* GDAL build is covered at option-checking time by the
#' per-key runtime confirmation of [gdal_config_option_known()].
#'
#' @param pattern Optional character vector of regular-expression patterns; options whose `name`
#'   or `source` matches any pattern (case-insensitively) are returned. `NULL` (default) returns
#'   all options.
#'
#' @returns
#' A [tibble::tibble()] with columns `name` (option name) and `source` (the GDAL source file that
#' consumes it), carrying a `gdal_version` attribute with the header's version pin.
#'
#' @seealso [gdal_config_option_known()], [gdal_config_set()], [gdal_config_sitrep()]
#'
#' @export
#'
#' @importFrom dplyr filter
#' @importFrom stringr str_c str_detect regex
#'
#' @examples
#' gdal_known_config_opts()
#' gdal_known_config_opts("SQLITE")
#' attr(gdal_known_config_opts(), "gdal_version")
gdal_known_config_opts <- function(pattern = NULL) {
  tbl <- gdal_known_config_opts_tbl
  if (is.null(pattern)) {
    return(tbl)
  }
  check_character(pattern)
  rx <- stringr::regex(stringr::str_c(pattern, collapse = "|"), ignore_case = TRUE)
  tbl |>
    dplyr::filter(
      stringr::str_detect(.data$name, rx) |
        dplyr::coalesce(stringr::str_detect(.data$source, rx), FALSE)
    )
}

#' Check Configuration Option Names Against the Running GDAL Build
#'
#' @description
#' Ask the *running* GDAL build whether it knows a configuration option name. GDAL >= 3.11 emits a
#' warning from `CPLSetConfigOption()` for unknown option names when `CPL_DEBUG` is enabled; this
#' helper performs a no-op set of each key under a temporarily enabled `CPL_DEBUG` and captures
#' that signal, then restores all touched state. This is the runtime ground truth that
#' `CPLGetKnownConfigOptions()` would provide if gdalraster exposed it - exact for the loaded
#' build, unaffected by version drift in the generated known-option lists.
#'
#' Note that "unknown to GDAL" does not mean invalid: setting an unknown option is legal and
#' silently ignored (which is exactly why typo detection matters). Used internally to confirm
#' suspected-unknown keys before [gdal_config_set()] raises its advisory warning.
#'
#' @param keys Character vector of configuration option names.
#'
#' @returns
#' A named logical vector: `TRUE` when the running build knows the key, `FALSE` when it does not,
#' `NA` when detection is unavailable (GDAL < 3.11).
#'
#' @seealso [gdal_config_set()], [gdal_config_sitrep()]
#'
#' @export
#'
#' @importFrom gdalraster gdal_version_num get_config_option set_config_option
#' @importFrom stats setNames
#'
#' @examples
#' \dontrun{
#' gdal_config_option_known(c("GDAL_NUM_THREADS", "GDAL_NUM_THREDS"))
#' }
gdal_config_option_known <- function(keys) {
  check_character(keys)
  keys <- toupper(keys)
  if (gdalraster::gdal_version_num() < 3110000L) {
    return(stats::setNames(rep(NA, length(keys)), keys))
  }

  debug_before <- gdalraster::get_config_option("CPL_DEBUG")
  gdalraster::set_config_option("CPL_DEBUG", "ON")
  withr::defer(gdalraster::set_config_option("CPL_DEBUG", debug_before))

  vapply(
    stats::setNames(keys, keys),
    function(key) {
      current <- gdalraster::get_config_option(key)
      unknown <- FALSE
      capture <- function(cond) {
        if (grepl("Unknown configuration option", conditionMessage(cond), fixed = TRUE)) {
          unknown <<- TRUE
        }
      }
      muffled_set <- function(value) {
        withCallingHandlers(
          gdalraster::set_config_option(key, value),
          message = function(m) {
            capture(m)
            invokeRestart("muffleMessage")
          },
          warning = function(w) {
            capture(w)
            invokeRestart("muffleWarning")
          }
        )
      }
      muffled_set(if (nzchar(current)) current else "probe")
      if (!nzchar(current)) {
        muffled_set("")
      }
      !unknown
    },
    logical(1)
  )
}

# initialization --------------------------------------------------------------------------------------------------

# initialize the config state at package load: empty stores, a snapshot of GDAL-relevant
# environment variables, and config-file discovery. no GDAL side effects here - defaults (and the
# at-load baseline sitrep) are applied by gdal_config_init_defaults(), which runs after the driver
# metadata is available.
#' @keywords internal
#' @noRd
#' @importFrom rlang env_has
gdal_config_init <- function() {
  if (!exists(".pkg_env")) {
    return(invisible())
  }
  if (!rlang::env_has(.pkg_env, "gdal")) {
    return(invisible())
  }

  state <- .pkg_env$gdal$config
  state$values <- list()
  state$restore <- list()
  state$env_at_load <- .gdal_config_env_snapshot()
  state$file <- .gdal_config_file_discover()
  state$at_load <- NULL

  vstate <- .pkg_env$gdal$vsi
  vstate$values <- list()
  vstate$known_tbl <- NULL

  invisible()
}

# stash the at-load baseline sitrep ("the world as gdalvector found it", before any package
# defaults), then apply the curated fill-only session defaults: applied through gdal_config_set()
# (tracked, visible in the sitrep as source "gdalvector", reversible via gdal_config_reset()),
# only when the key currently resolves to nothing (a user envvar, gdalrc, or another package's
# setting always wins), and skipped entirely via options(gdalvector.config_defaults = FALSE).
#' @keywords internal
#' @noRd
#' @importFrom gdalraster get_config_option
#' @importFrom purrr iwalk
#' @importFrom rlang env_has
#' @importFrom stats setNames
gdal_config_init_defaults <- function() {
  if (!exists(".pkg_env")) {
    return(invisible())
  }
  if (!rlang::env_has(.pkg_env, "gdal")) {
    return(invisible())
  }

  state <- .pkg_env$gdal$config
  state$at_load <- gdal_config_sitrep()

  if (isFALSE(getOption("gdalvector.config_defaults", default = TRUE))) {
    return(invisible())
  }
  defaults <- c(GDAL_HTTP_USERAGENT = pkg_user_agent())
  purrr::iwalk(defaults, function(value, key) {
    current <- gdalraster::get_config_option(key)
    if (!nzchar(current)) {
      gdal_config_set(stats::setNames(list(value), key))
    } else if (identical(current, value)) {
      # the value in GDAL is exactly our own default: a previous load of this package pinned it
      # and the reload wiped the tracking state. re-adopt it so the active config reflects it and
      # gdal_config_reset() can still restore the pre-package state (unset).
      state$restore[[key]] <- list(prior = "", prior_was_env = FALSE, scrubbed_env = NULL)
      state$values[[key]] <- value
    }
    # any other non-empty value came from the user/environment: fill-only, never override
  })

  invisible()
}

# internal - state ------------------------------------------------------------------------------------------------

# the two state environments (created by pkg_env_init()):
# - config: `values` (named list KEY -> set value; the active configuration's global payload),
#           `restore` (named list KEY -> list(prior, prior_was_env, scrubbed_env)),
#           `env_at_load`, `file` (parsed gdal_config_file), `at_load` (baseline sitrep).
# - vsi:    `values` (named list path -> named character vector of KEY = value),
#           `known_tbl` (lazily cached runtime VSI option metadata, see .vsi_fs_options_tbl()).
# gdal_config_active() wraps `values` + vsi `values` into the classed gdal_config value on demand,
# so the classed view is always fresh while per-key mutation stays a plain list update.
#' @keywords internal
#' @noRd
.gdal_config_state <- function() {
  .pkg_env$gdal$config
}

#' @keywords internal
#' @noRd
.gdal_vsi_state <- function() {
  .pkg_env$gdal$vsi
}

# the single write primitive: record the pre-package state of a key on first touch (so reset
# always restores to the true pre-package state), apply the value to GDAL, and track it in
# `values`. an empty value drops the key from `values` (it is no longer pinned) while keeping the
# restore entry.
#' @keywords internal
#' @noRd
#' @importFrom gdalraster get_config_option set_config_option
.gdal_config_put <- function(key, value) {
  state <- .gdal_config_state()
  if (is.null(state$restore[[key]])) {
    prior <- gdalraster::get_config_option(key)
    state$restore[[key]] <- list(
      prior = prior,
      prior_was_env = nzchar(prior) && identical(prior, Sys.getenv(key)),
      scrubbed_env = NULL
    )
  }
  gdalraster::set_config_option(key, value)
  state$values[[key]] <- if (nzchar(value)) value else NULL
  invisible()
}

#' @keywords internal
#' @noRd
#' @importFrom gdalraster vsi_set_path_option
#' @importFrom stats setNames
.gdal_vsi_put <- function(path, key, value) {
  vstate <- .gdal_vsi_state()
  gdalraster::vsi_set_path_option(path, key, value)
  current <- vstate$values[[path]]
  if (is.null(current)) {
    current <- stats::setNames(character(), character())
  }
  current[[key]] <- value
  vstate$values[[path]] <- current
  invisible()
}

# apply a gdal_config value to GDAL. returns the named list of prior effective values for the
# global-channel keys set (the manual-restore contract of gdal_config_set).
#' @keywords internal
#' @noRd
#' @importFrom gdalraster get_config_option
.gdal_config_apply <- function(cfg) {
  payload <- .gdal_opts_payload(cfg$opts)
  .gdal_config_check_keys(names(payload))

  prior <- list()
  for (key in names(payload)) {
    if (identical(key, "GDAL_CONFIG_FILE")) {
      gdal_warn_config(
        c(
          "{.field GDAL_CONFIG_FILE} is only read at GDAL initialization;
           setting it now has no effect on the running process.",
          "i" = "It will only affect child processes that inherit it as an environment variable."
        ),
        cls = "gdal_config_file_warning"
      )
    }
    prior[[key]] <- gdalraster::get_config_option(key)
    .gdal_config_put(key, payload[[key]])
  }

  for (path in names(cfg$vsi)) {
    vsi_payload <- .gdal_opts_payload(cfg$vsi[[path]])
    for (key in names(vsi_payload)) {
      .gdal_vsi_put(path, key, vsi_payload[[key]])
    }
  }

  prior
}

# internal - known options ----------------------------------------------------------------------------------------

# advisory (warning, non-blocking) check of option names against the known sets - unknown keys are
# legal in GDAL (custom/app-defined), so this only guards against typos. keys missing from every
# list are confirmed against the running build (gdal_config_option_known()) before warning, so
# version drift in the generated lists never produces false positives.
#' @keywords internal
#' @noRd
#' @importFrom gdalraster get_config_option
.gdal_config_check_keys <- function(keys) {
  if (length(keys) == 0L) {
    return(invisible(TRUE))
  }
  known <- .gdal_config_known_opts()
  unknown <- keys[!(toupper(keys) %in% known)]
  # a key GDAL already resolves to a value is evidently in use somewhere; don't flag it
  unknown <- unknown[!vapply(unknown, function(k) nzchar(gdalraster::get_config_option(k)), logical(1))]
  if (length(unknown) > 0L) {
    confirmed <- gdal_config_option_known(unknown)
    unknown <- unknown[!confirmed %in% TRUE]
  }
  if (length(unknown) > 0L) {
    gdal_warn_config(
      "Unknown configuration option{?s}: {.field {unknown}} (not known to GDAL or the package
       option lists; a typo is silently ignored by GDAL).",
      cls = "gdal_config_unknown_warning"
    )
    return(invisible(FALSE))
  }
  invisible(TRUE)
}

# the known-option universe: GDAL's compile-time registry (gdal_known_config_opts(), parsed from
# the bundled version-pinned header), the runtime VSI/network options enumerated from the running
# build, curated per-driver config options (driver metadata table), and any GDAL-relevant envvars
# present at load (an app-defined option set via the environment is known to the user's setup by
# definition). anything the lists miss (e.g. version drift from the pinned header) is covered by
# the per-key runtime confirmation in gdal_config_option_known().
#' @keywords internal
#' @noRd
.gdal_config_known_opts <- function() {
  driver_opts <- character()
  drivers_env <- .pkg_env$gdal$drivers
  if (!is.null(drivers_env) && !is.null(drivers_env$opts_tbl)) {
    tbl <- drivers_env$opts_tbl
    driver_opts <- tbl$name[tbl$type == "config"]
  }
  toupper(unique(c(
    gdal_known_config_opts()$name,
    .vsi_fs_options_tbl()$name,
    driver_opts,
    names(.gdal_config_state()$env_at_load)
  )))
}

# documented default for a config option key: the curated per-driver config metadata first, then
# the runtime VSI option metadata.
#' @keywords internal
#' @noRd
.gdal_config_known_default <- function(key) {
  drivers_env <- .pkg_env$gdal$drivers
  if (!is.null(drivers_env) && !is.null(drivers_env$opts_tbl)) {
    tbl <- drivers_env$opts_tbl
    hits <- tbl[tbl$type == "config" & toupper(tbl$name) == toupper(key) & !is.na(tbl$default), , drop = FALSE]
    if (nrow(hits) > 0L) {
      return(hits$default[[1]])
    }
  }
  vsi_tbl <- .vsi_fs_options_tbl()
  if (nrow(vsi_tbl) > 0L) {
    hits <- vsi_tbl[toupper(vsi_tbl$name) == toupper(key) & !is.na(vsi_tbl$default), , drop = FALSE]
    if (nrow(hits) > 0L) {
      return(hits$default[[1]])
    }
  }
  NA_character_
}

# internal - environment ------------------------------------------------------------------------------------------

# snapshot of GDAL-relevant environment variables (live). prefix-based: these families are the
# documented GDAL/PROJ/cloud-credential namespaces.
#' @keywords internal
#' @noRd
.gdal_config_env_snapshot <- function() {
  env <- Sys.getenv(names = TRUE)
  pattern <- paste0(
    "^(GDAL_|CPL_|OGR_|OSR_|VSI_|SHAPE_|PROJ_|OSM_|CARTO_|",
    "AWS_|AZURE_|GS_|GOOGLE_APPLICATION|OSS_|SWIFT_|SQLITE_USE_OGR_VFS)"
  )
  hits <- env[grepl(pattern, names(env))]
  hits[order(names(hits))]
}
