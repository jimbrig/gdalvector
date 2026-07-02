#  ------------------------------------------------------------------------
#
# Title : GDAL Configuration File (gdalrc) I/O
#    By : Jimmy Briggs
#  Date : 2026-07-02
#
#  ------------------------------------------------------------------------

# https://gdal.org/en/stable/user/configoptions.html#gdal-configuration-file

# class -----------------------------------------------------------------------------------------------------------

#' GDAL Configuration File
#'
#' @name gdal_config_file
#'
#' @description
#' Read, write, and discover [GDAL configuration files](https://gdal.org/en/stable/user/configoptions.html#gdal-configuration-file)
#' (gdalrc). A parsed file is a classed `gdal_config_file` whose components are the package's
#' option value classes, so a file round-trips directly into the configuration system:
#'
#' - `configoptions`: the `[configoptions]` section as a [gdal_config_opts()] (GDAL >= 3.3).
#' - `directives`: the `[directives]` section as a named character vector (GDAL >= 3.6;
#'   e.g. `ignore-env-vars = "yes"`).
#' - `credentials`: the `[credentials]` section (GDAL >= 3.5) as a named list of
#'   [gdal_vsi_opts()] - each `[.subsection]`'s `path` key becomes the `vsi_path` binding, so
#'   path-bound credentials are first-class values.
#'
#' Functions:
#'
#' - `gdal_config_file_read(path)`: parse a gdalrc.
#' - `gdal_config_file_write(x, path)`: serialize a [gdal_config()] or `gdal_config_file` to a
#'   gdalrc. This is the **only lossless serialization** of a full configuration - path-bound VSI
#'   options cannot be expressed as CLI `--config` flags (see [as_gdal_args()]).
#' - `gdal_config_file(refresh)`: the file GDAL actually loaded at initialization, discovered via
#'   the `GDAL_CONFIG_FILE` environment variable then the user gdalrc
#'   (`%USERPROFILE%/.gdal/gdalrc` on Windows, `~/.gdal/gdalrc` otherwise), cached at package load.
#' - [as_gdal_config()]: convert a `gdal_config_file` to a [gdal_config()] value
#'   (configoptions + credentials), e.g. to apply it in-process via [gdal_config_set()].
#'
#' GDAL reads this file **once**, at driver registration (i.e. before this package loads), and
#' loads its `[configoptions]` into the in-memory configuration store (environment variables take
#' precedence over the file unless `ignore-env-vars=yes`). In-process it is therefore a
#' *discovery/provenance* input - setting `GDAL_CONFIG_FILE` after load has no effect on the
#' running process (and [gdal_config_set()] warns if you try). Written files target *future*
#' processes.
#'
#' @param path Path to a GDAL configuration file. For `gdal_config_file_write()`, the destination
#'   (written with secrets as-is - it is a credentials file; printing remains redacted).
#' @param x A [gdal_config()] or `gdal_config_file` object to serialize.
#' @param refresh Logical; re-discover and re-parse instead of using the value cached at package
#'   load. Defaults to `FALSE`.
#'
#' @returns
#' - `gdal_config_file_read()` / `gdal_config_file()`: a `gdal_config_file` object (`path`,
#'   `configoptions`, `directives`, `credentials`). For `gdal_config_file()`, `path` is `NULL`
#'   when no file was discovered.
#' - `gdal_config_file_write()`: invisibly, the written path.
#'
#' @seealso [gdal_config()], [gdal_config_set()], [gdal_config_sitrep()]
#'
#' @examples
#' \dontrun{
#' # the file GDAL loaded at startup, if any
#' gdal_config_file()
#'
#' # serialize the session's configuration for reuse by CLI tools / other processes
#' gdal_config_file_write(gdal_config_active(), "gdalrc")
#' }
NULL

#' @keywords internal
#' @noRd
new_gdal_config_file <- function(
  path = NULL,
  configoptions = as_gdal_config_opts(list()),
  directives = stats::setNames(character(), character()),
  credentials = list()
) {
  check_inherits(configoptions, "gdal_config_opts")
  purrr::walk(credentials, check_vsi_opts)
  names(credentials) <- purrr::map_chr(credentials, attr, "vsi_path")
  structure(
    list(
      path = path,
      configoptions = configoptions,
      directives = directives,
      credentials = credentials
    ),
    class = c("gdal_config_file", "list")
  )
}

# read ------------------------------------------------------------------------------------------------------------

#' @rdname gdal_config_file
#' @export
gdal_config_file_read <- function(path) {
  check_path(path)
  entries <- .gdalrc_entries(path)

  section_kv <- function(section) {
    hits <- entries[entries$section == section & is.na(entries$subsection), , drop = FALSE]
    stats::setNames(hits$value, hits$key)
  }

  cred_entries <- entries[entries$section == "credentials" & !is.na(entries$subsection), , drop = FALSE]
  credentials <- if (nrow(cred_entries) == 0L) {
    list()
  } else {
    cred_entries |>
      dplyr::group_by(.data$subsection) |>
      dplyr::group_map(function(rows, key) {
        vsi_path <- rows$value[rows$key == "path"]
        if (length(vsi_path) != 1L) {
          gdal_warn_config(
            "Skipping credentials subsection {.field [.{key$subsection}]}: it must declare exactly
             one {.code path} key.",
            cls = "gdal_config_file_warning"
          )
          return(NULL)
        }
        opts <- rows[rows$key != "path", , drop = FALSE]
        as_gdal_vsi_opts(stats::setNames(as.list(opts$value), opts$key), vsi_path = vsi_path)
      }) |>
      purrr::compact()
  }

  new_gdal_config_file(
    path = path,
    configoptions = as_gdal_config_opts(as.list(section_kv("configoptions"))),
    directives = section_kv("directives"),
    credentials = credentials
  )
}

# write -----------------------------------------------------------------------------------------------------------

#' @rdname gdal_config_file
#' @export
gdal_config_file_write <- function(x, path) {
  check_string(path)
  if (is_gdal_config(x)) {
    x <- new_gdal_config_file(configoptions = x$opts, credentials = unname(x$vsi))
  }
  check_inherits(x, "gdal_config_file")

  kv_lines <- function(payload) paste0(names(payload), "=", unlist(payload, use.names = FALSE))

  lines <- character()
  if (length(x$directives) > 0L) {
    lines <- c(lines, "[directives]", kv_lines(x$directives), "")
  }
  config_payload <- .gdal_opts_payload(x$configoptions)
  if (length(config_payload) > 0L) {
    lines <- c(lines, "[configoptions]", kv_lines(config_payload), "")
  }
  if (length(x$credentials) > 0L) {
    lines <- c(lines, "[credentials]")
    for (i in seq_along(x$credentials)) {
      cred <- x$credentials[[i]]
      vsi_path <- attr(cred, "vsi_path")
      label <- gsub("[^a-z0-9]+", "_", tolower(vsi_strip(vsi_path)))
      label <- gsub("^_+|_+$", "", label)
      if (!nzchar(label)) {
        label <- paste0("credentials_", i)
      }
      lines <- c(
        lines,
        paste0("[.", label, "]"),
        paste0("path=", vsi_path),
        kv_lines(.gdal_opts_payload(cred)),
        ""
      )
    }
  }

  writeLines(lines, path)
  invisible(path)
}

# discovery -------------------------------------------------------------------------------------------------------

#' @rdname gdal_config_file
#' @export
gdal_config_file <- function(refresh = FALSE) {
  state <- .gdal_config_state()
  if (isTRUE(refresh) || is.null(state$file)) {
    state$file <- .gdal_config_file_discover()
  }
  state$file
}

# coercion --------------------------------------------------------------------------------------------------------

#' @rdname gdal_config
#' @export
as_gdal_config.gdal_config_file <- function(x, ..., call = rlang::caller_env()) {
  new_gdal_config(x$configoptions, x$credentials)
}

# format and print ------------------------------------------------------------------------------------------------

#' @export
format.gdal_config_file <- function(x, ...) {
  config_payload <- .gdal_opts_payload(x$configoptions)

  gpq_cli_fmt({
    cli::cli_text("{.cls gdal_config_file}")
    if (is.null(x$path)) {
      cli::cli_alert_info("No GDAL config file detected.")
    } else {
      cli::cli_alert_info("Path: {.file {x$path}}")
    }
    if (length(x$directives) > 0L) {
      kv <- paste(names(x$directives), unname(x$directives), sep = "=", collapse = ", ")
      cli::cli_alert_info("Directives: {.field {kv}}")
    }
    if (length(config_payload) > 0L) {
      kv <- paste(
        purrr::imap_chr(config_payload, function(value, key) paste0(key, "=", cli_redact(key, value))),
        collapse = ", "
      )
      cli::cli_alert_info("Configuration Options ({length(config_payload)}): {.field {kv}}")
    }
    if (length(x$credentials) > 0L) {
      cli::cli_alert_info("Credentials ({length(x$credentials)} path{?s}):")
      for (path in names(x$credentials)) {
        payload <- .gdal_opts_payload(x$credentials[[path]])
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
print.gdal_config_file <- function(x, ...) {
  cat(format(x, ...), sep = "\n")
  invisible(x)
}

# internal --------------------------------------------------------------------------------------------------------

# parse a gdalrc into a tidy entries tibble (section, subsection, key, value). the grammar:
# `[section]` headers, `[.subsection]` relative headers (inside [credentials]), `#` comments, and
# KEY=VALUE lines (values may contain further `=`).
#' @keywords internal
#' @noRd
.gdalrc_entries <- function(path) {
  tibble::tibble(raw = stringr::str_trim(readLines(path, warn = FALSE))) |>
    dplyr::filter(nzchar(.data$raw), !stringr::str_starts(.data$raw, stringr::fixed("#"))) |>
    dplyr::mutate(
      is_subsection = stringr::str_detect(.data$raw, "^\\[\\..+\\]$"),
      is_section = !.data$is_subsection & stringr::str_detect(.data$raw, "^\\[.+\\]$"),
      section = dplyr::if_else(
        .data$is_section,
        tolower(stringr::str_remove_all(.data$raw, "^\\[|\\]$")),
        NA_character_
      ),
      subsection = dplyr::if_else(
        .data$is_subsection,
        stringr::str_remove_all(.data$raw, "^\\[\\.|\\]$"),
        NA_character_
      )
    ) |>
    tidyr::fill("section") |>
    dplyr::group_by(.data$section) |>
    tidyr::fill("subsection") |>
    dplyr::ungroup() |>
    dplyr::filter(!.data$is_section, !.data$is_subsection, stringr::str_detect(.data$raw, stringr::fixed("="))) |>
    tidyr::separate_wider_delim("raw", "=", names = c("key", "value"), too_many = "merge") |>
    dplyr::mutate(
      key = stringr::str_trim(.data$key),
      value = stringr::str_trim(.data$value)
    ) |>
    dplyr::select("section", "subsection", "key", "value")
}

# resolve the config file GDAL loaded at initialization: GDAL_CONFIG_FILE envvar first, then the
# user gdalrc.
#' @keywords internal
#' @noRd
.gdal_config_file_discover <- function() {
  path <- Sys.getenv("GDAL_CONFIG_FILE")
  if (!nzchar(path)) {
    home <- if (is_windows()) Sys.getenv("USERPROFILE") else Sys.getenv("HOME")
    candidate <- file.path(home, ".gdal", "gdalrc")
    path <- if (nzchar(home) && file.exists(candidate)) candidate else ""
  }
  if (!nzchar(path) || !file.exists(path)) {
    return(new_gdal_config_file())
  }
  gdal_config_file_read(path)
}
