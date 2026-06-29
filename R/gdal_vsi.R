#  ------------------------------------------------------------------------
#
# Title : GDAL Virtual File System (VSI)
#    By : Jimmy Briggs
#  Date : 2026-05-28
#
#  ------------------------------------------------------------------------

# https://gdal.org/en/stable/user/virtual_file_systems.html

# path -------------------------------------------------------------------------------------------------------------

#' Convert a Path to a GDAL VSI Path
#'
#' @param path A path, URL, or object with a `vsi_path()` method.
#' @param ... Passed to methods.
#'
#' @return Character vector of VSI paths.
#' @export
vsi_path <- function(path, ...) {
  if (length(path) > 1L) {
    return(purrr::map_chr(path, vsi_path, ...))
  }
  if (is_vsi_path(path)) {
    return(path)
  }

  out <- path
  if (grepl("^(https?|ftp)://", out)) {
    out <- vsi_curl(out)
  }
  if (is_zip(out)) {
    out <- vsi_zip(out)
  }
  out
}

# exists ----------------------------------------------------------------------------------------------------------

#' Test Whether a VSI Path Exists
#'
#' @param path Path to test.
#'
#' @return Logical vector.
#' @export
vsi_exists <- function(path) {
  path <- vsi_path(path)
  if (length(path) > 1L) {
    return(purrr::map_lgl(path, vsi_exists))
  }
  gdalraster::vsi_stat_exists(path)
}


# glob ------------------------------------------------------------------------------------------------------------

vsi_glob <- function(x, pattern = NULL) {
  if (!is.null(pattern)) {
    x <- file.path(x, pattern)
  }
  gdalraster::vsi_glob(x, show_progress = TRUE)
}

# meta ------------------------------------------------------------------------------------------------------------

#' Get VSI File Metadata
#'
#' @param path Path to inspect.
#' @param domain Metadata domain, typically `"HEADERS"` or `"ZIP"`.
#'
#' @return Named character vector of metadata entries.
#' @export
vsi_meta <- function(path, domain = "HEADERS") {
  path <- vsi_path(path)
  gdalraster::vsi_get_file_metadata(path, domain = domain)
}

#' Get the Size of a VSI Path
#'
#' @param path Path to inspect.
#'
#' @returns
#' The size of the file/object in bytes, formatted using [rlang::as_bytes()].
#'
#' @importFrom gdalraster vsi_stat_size
#' @importFrom rlang as_bytes
#'
#' @export
vsi_size <- function(path) {
  path <- vsi_path(path)
  if (length(path) > 1L) {
    return(purrr::map_dbl(path, vsi_size))
  }
  gdalraster::vsi_stat_size(path) |>
    as.double() |>
    rlang::as_bytes()
}

#' Get the Type of a VSI Path
#'
#' @param path Path to inspect.
#'
#' @return Character vector of path types.
#' @export
vsi_type <- function(path) {
  path <- vsi_path(path)
  if (length(path) > 1L) {
    return(purrr::map_chr(path, vsi_type))
  }
  gdalraster::vsi_stat_type(path)
}


# copy ------------------------------------------------------------------------------------------------------------

# sync ------------------------------------------------------------------------------------------------------------

#' Sync Between VSI Paths
#'
#' @param src Source path.
#' @param dst Destination path.
#' @param ... Passed to [gdalraster::vsi_sync()].
#'
#' @return Invisibly returns the sync result from GDAL.
#' @export
vsi_sync <- function(src, dst, ...) {
  gdalraster::vsi_sync(src = vsi_path(src), target = dst, ...)
}

# utilities -------------------------------------------------------------------------------------------------------

#' Strip the Outermost VSI Handler
#'
#' @param path Path to strip.
#' @param recurse Logical; if `TRUE` (default), strips all nested VSI handlers,
#'   otherwise only the outermost one.
#'
#' @return Character vector with the outermost VSI handler removed.
#' @export
vsi_strip <- function(path, recurse = TRUE) {
  if (length(path) > 1L) {
    return(purrr::map_chr(path, vsi_strip))
  }
  if (!is_vsi_path(path)) {
    return(path)
  }
  if (!recurse) {
    return(sub("^/vsi[a-z0-9]+/+", "", path))
  }
  repeat {
    new_path <- sub("^/vsi[a-z0-9]+/+", "", path)
    if (identical(new_path, path)) {
      break
    }
    path <- new_path
  }
  path
}

vsi_ls <- function(x, ...) {
  gdalraster::vsi_read_dir(x, ...)
}

vsi_list_available <- function() {
  gdalraster::vsi_get_fs_prefixes()
}

vsi_list_options <- function(dsn) {
  gdalraster::vsi_get_fs_options(filename = dsn, as_list = FALSE) |>
    xml_parse_gdal_options()
}

# handlers ---------------------------------------------------------------------------------------------------------

#' List VSI Handlers Used by a Path
#'
#' @param path VSI path.
#'
#' @return Character vector of handler names.
#' @export
vsi_handlers <- function(path) {
  if (!is_vsi_path(path)) {
    return(character())
  }
  matches <- regmatches(path, gregexpr("/vsi[a-z0-9]+/", path))[[1]]
  if (!length(matches)) {
    return(character())
  }
  gsub("^/|/$", "", matches)
}

#' Wrap a Path with `/vsizip/`
#'
#' @param path Path to a ZIP archive.
#'
#' @return Character vector of `/vsizip/` paths.
#' @export
vsi_zip <- function(path) {
  if (length(path) > 1L) {
    return(purrr::map_chr(path, vsi_zip))
  }
  if (startsWith(path, "/vsizip/")) {
    return(path)
  }
  paste0("/vsizip/", path)
}

#' Wrap a URL with `/vsicurl/`
#'
#' @param url URL to wrap.
#'
#' @return Character vector of `/vsicurl/` paths.
#' @export
vsi_curl <- function(url) {
  if (length(url) > 1L) {
    return(purrr::map_chr(url, vsi_curl))
  }
  if (startsWith(url, "/vsicurl/")) {
    return(url)
  }
  paste0("/vsicurl/", url)
}

#' Build a `/vsizip//vsicurl/` Path
#'
#' @param url Remote ZIP URL.
#' @param inner Optional inner file path within the ZIP archive.
#'
#' @return Character scalar.
#' @export
vsi_zip_curl <- function(url, inner = NULL) {
  check_url(url)
  path <- vsi_zip(vsi_curl(url))
  if (!is.null(inner) && nzchar(inner)) {
    path <- paste0(path, "/", inner)
  }
  path
}

#' Build a `/vsiaz/` Path
#'
#' @param container Azure Blob container name.
#' @param blob Blob path within the container.
#'
#' @return Character scalar.
#' @export
vsi_azure <- function(container, blob) {
  check_string(container)
  check_string(blob)
  path <- paste0("/vsiaz/", container, "/", blob)
  if (is_zip(blob)) {
    return(vsi_zip(path))
  }
  path
}

#' Convert a URI to a GDAL VSI Path
#'
#' @param uri URI or URL.
#'
#' @return Character vector of VSI paths.
#' @export
vsi_from_uri <- function(uri) {
  if (length(uri) > 1L) {
    return(purrr::map_chr(uri, vsi_from_uri))
  }
  gdalraster::vsi_uri_to_vsi_path(uri)
}
