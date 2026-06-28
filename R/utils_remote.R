#  ------------------------------------------------------------------------
#
# Title : Remote Utilities
#    By : Jimmy Briggs
#  Date : 2025-12-08
#
#  ------------------------------------------------------------------------

# ping ------------------------------------------------------------------------------------------------------------

#' Ping
#'
#' @description
#' Pings a remote URL.
#'
#' @param url The remote URL
#' @param timeout Timeout in seconds. Defaults to `5L`.
#'
#' @returns
#' `TRUE` if successfully pinged, `FALSE` otherwise.
#'
#' @export
#'
#' @importFrom httr2 request req_method req_timeout req_perform resp_check_status
#' @importFrom rlang try_fetch
ping <- function(url, timeout = 5L) {
  req <- httr2::request(url) |>
    httr2::req_method("HEAD")

  if (!is.null(timeout)) {
    req <- httr2::req_timeout(req, seconds = timeout)
  }

  rlang::try_fetch(
    {
      resp <- httr2::req_perform(req)
      httr2::resp_check_status(resp)
      return(TRUE)
    },
    error = function(err) {
      return(FALSE)
    }
  )
}

# head ------------------------------------------------------------------------------------------------------------

#' Perform a `HEAD` HTTP Request for a Remote URL
#'
#' @description
#' Sends a `HEAD` request to the specified URL and retrieves the response headers.
#'
#' This function is useful for checking the existence of a resource or retrieving metadata
#' without downloading the entire content.
#'
#' @param url Character string specifying the URL to send the `HEAD` request to.
#'
#' @returns
#' A list containing:
#' - `request`: The [httr2::request()]
#' - `response`: The [httr2::response()]
#' - `headers`: The [httr2::resp_headers()] from the response
#'
#' @export
#'
#' @importFrom httr2 request req_method req_perform resp_headers
#'
#' @examples
#' \dontrun{
#' url <- "https://www2.census.gov/geo/tiger/GENZ2024/shp/cb_2024_us_state_20m.zip"
#' head_info <- remote_head(url)
#' print(head_info$headers)
#' }
remote_head <- function(url) {
  req_head <- httr2::request(url) |> httr2::req_method("HEAD")
  resp_head <- httr2::req_perform(req_head)
  resp_head_headers <- httr2::resp_headers(resp_head)
  list(
    request = req_head,
    response = resp_head,
    headers = resp_head_headers
  )
}

# exists ----------------------------------------------------------------------------------------------------------

#' Check if a Remote File Exists at a Given URL
#'
#' @description
#' Determines whether a remote file exists by sending a `HEAD` request to the specified
#' URL and checking the HTTP status code.
#'
#' @param url Character string specifying the URL of the remote file.
#'
#' @returns
#' A logical value: `TRUE` if the remote file exists (HTTP status 200), `FALSE` otherwise.
#'
#' @export
#'
#' @importFrom httr2 resp_status
#'
#' @examples
#' \dontrun{
#' url <- "https://www2.census.gov/geo/tiger/GENZ2024/shp/cb_2024_us_state_20m.zip"
#' remote_exists(url)
#' }
remote_exists <- function(url) {
  head_info <- remote_head(url)
  head_resp <- head_info$response
  httr2::resp_status(head_resp) == 200L
}

# last modified ---------------------------------------------------------------------------------------------------

#' Get Local & Remote Resources Last-Modified Timestamp
#'
#' @description
#' These functions derive timestamps for local and remote resources.
#'
#' - `remote_last_modified()`: Parses the `Last-Modified` HTTP response header as the timestamp.
#'   Returns `NA` if the header is not available.
#' - `local_last_modified()`: Local file last modified timestamp.
#'
#' @param url Character string specifying the URL of the remote file.
#' @param path Path to local file to get the last modified timestamp for.
#'
#' @returns
#' - `remote_last_modified()`: `POSIXct` datetime representing the `Last-Modified` header timestamp, or `NA` if not provided by the
#' server.
#' - `local_last_modified()`: `POSIXct` datetime of the file's last modification.
#'
#' @export
#'
#' @importFrom purrr pluck
#'
#' @examples
#' \dontrun{
#' url <- "https://www2.census.gov/geo/tiger/GENZ2024/shp/cb_2024_us_state_20m.zip"
#' remote_last_modified(url)
#'
#' path <- "data-raw/cache/tiger/GENZ2024/shp/cb_2024_us_state_20m.zip"
#' local_last_modified(path)
#' }
remote_last_modified <- function(url) {
  check_url(url)
  head_info <- remote_head(url)
  last_modified_str <- purrr::pluck(head_info, "headers", "last-modified", .default = NA_character_)
  if (is.na(last_modified_str)) {
    return(NA)
  }
  .parse_http_date(last_modified_str)
}

#' @rdname remote_last_modified
#' @export
local_last_modified <- function(path) {
  check_file(x = path, ext = NULL)
  file.info(path)$mtime
}

#' Get the Size of a Remote File from its URL
#'
#' @description
#' Retrieves the size of a remote file by sending a `HEAD` request to the specified
#' URL and extracting the `Content-Length` header.
#'
#' @param url Character string specifying the URL of the remote file.
#'
#' @returns
#' A numeric value representing the size of the remote file in bytes.
#'
#' @export
#'
#' @importFrom purrr pluck
#' @importFrom rlang as_bytes
#'
#' @examples
#' \dontrun{
#' url <- "https://www2.census.gov/geo/tiger/GENZ2024/shp/cb_2024_us_state_20m.zip"
#' remote_size(url)
#' }
remote_size <- function(url) {
  check_url(url)
  head_info <- remote_head(url)
  bytes <- as.numeric(purrr::pluck(head_info, "headers", "content-length", .default = NA_real_))
  rlang::as_bytes(bytes)
}

#' Get the Hash of a Remote File from its URL
#'
#' @description
#' Retrieves the hash of a remote file from its URL.
#'
#' @param url Character string specifying the URL of the remote file.
#' @param algo Character string specifying hash algorithm ("md5", "sha1", "sha256", "sha512").
#'
#' @returns
#' A character string representing the hash of the remote file.
#'
#' @export
#'
#' @importFrom rlang arg_match0
#'
#' @examples
#' \dontrun{
#' url <- "https://www2.census.gov/geo/tiger/GENZ2024/shp/cb_2024_us_state_20m.zip"
#' remote_hash(url)
#' }
remote_hash <- function(url, algo = "md5") {
  check_url(url)
  algo <- rlang::arg_match0(algo, .hash_algos)
  hash_func <- .get_hash_func(algo)
  url_con <- url(url, open = "rb")
  on.exit(close(url_con), add = TRUE)
  hash_func(url_con)
}

#' Get the Hash of a Local File
#'
#' @description
#' Retrieves the hash of a local file from its path.
#'
#' @param path Character string specifying the path to the local file.
#' @param algo Character string specifying hash algorithm ("md5", "sha1", "sha256", "sha512").
#'
#' @returns
#' A character string representing the hash of the local file.
#'
#' @export
#'
#' @importFrom rlang arg_match0
#'
#' @examples
#' \dontrun{
#' path <- "data-raw/cache/tiger/GENZ2024/shp/cb_2024_us_state_20m.zip"
#' local_hash(path)
#' }
local_hash <- function(path, algo = "md5") {
  check_file(path)
  algo <- rlang::arg_match0(algo, .hash_algos)
  hash_func <- .get_hash_func(algo)
  file_con <- file(path, open = "rb", raw = TRUE)
  on.exit(close(file_con), add = TRUE)
  hash_func(file_con)
}

#' Remote File Download with Change Detection
#'
#' @description
#' Downloads a remote file only if it has changed since the cached version.
#' Uses HTTP Last-Modified header when available (fast), falls back to hash
#' comparison for legacy servers.
#'
#' @param url Character string specifying the URL of the remote file.
#' @param destfile Character string specifying the destination path.
#' @param timeout Numeric value specifying HTTP request timeout in seconds. Defaults to `600L`.
#' #' @param max_tries Integer; maximum number of download attempts on failure. Defaults to `3L`.
#' @param extract Logical; if `TRUE` and the file is a ZIP, extracts it after download.
#' @param force Logical; if `TRUE`, always download regardless of cache state.
#' @param algo Character string specifying hash algorithm ("md5", "sha1", "sha256", "sha512").
#'   Only used as fallback if Last-Modified header unavailable.
#'
#' @returns
#' Invisibly returns the path to the downloaded file.
#'
#' @export
#'
#' @importFrom cli cli_alert_info cli_alert_success cli_alert_warning cli_alert_danger cli_abort
#' @importFrom httr2 request req_timeout req_perform resp_is_error resp_status
remote_download <- function(
  url,
  destfile,
  extract = FALSE,
  timeout = 600L,
  max_tries = 3L,
  force = FALSE,
  algo = "md5"
) {
  check_url(url)
  if (file.exists(destfile) && !force) {
    cli::cli_alert_info("File {.file {destfile}} already exists. Checking if remote changed...")
    remote_mtime <- remote_last_modified(url)
    if (!is.na(remote_mtime)) {
      local_mtime <- local_last_modified(destfile)
      if (remote_mtime <= local_mtime) {
        cli::cli_alert_success("Local file is up to date. Skipping download.")
        if (extract && tools::file_ext(destfile) == "zip") {
          extract_dir <- file.path(dirname(destfile), tools::file_path_sans_ext(basename(destfile)))
          dir.create(extract_dir, showWarnings = FALSE, recursive = TRUE)
          cli::cli_progress_step(
            "Extracting {.file {basename(destfile)}}",
            msg_done = "Extracted {.file {basename(destfile)}} to {.file {extract_dir}}"
          )
          unzip(destfile, exdir = extract_dir, overwrite = TRUE)
          cli::cli_progress_done()
        }
        return(invisible(destfile))
      }
    } else {
      cli::cli_alert_info("Last-Modified header not available. Using hash comparison...")
      if (identical(remote_hash(url, algo), local_hash(destfile, algo))) {
        cli::cli_alert_success("Local file matches remote file. Skipping download.")
        if (extract && tools::file_ext(destfile) == "zip") {
          extract_dir <- file.path(dirname(destfile), tools::file_path_sans_ext(basename(destfile)))
          dir.create(extract_dir, showWarnings = FALSE, recursive = TRUE)
          cli::cli_progress_step(
            "Extracting {.file {basename(destfile)}}",
            msg_done = "Extracted {.file {basename(destfile)}} to {.file {extract_dir}}"
          )
          unzip(destfile, exdir = extract_dir, overwrite = TRUE)
          cli::cli_progress_done()
        }
        return(invisible(destfile))
      }
    }
    cli::cli_alert_warning("Remote file has changed. Downloading new file...")
  }
  if (!dir.exists(dirname(destfile))) {
    dir.create(dirname(destfile), showWarnings = FALSE, recursive = TRUE)
  }
  req <- httr2::request(url) |>
    httr2::req_timeout(timeout) |>
    httr2::req_retry(max_tries = 3L) |>
    httr2::req_progress(type = "down") |>
    httr2::req_options(followlocation = TRUE, maxredirs = 10L)
  resp <- httr2::req_perform(req, path = destfile)
  httr2::resp_check_status(resp)
  cli::cli_alert_success("Downloaded file to {.file {destfile}}.")
  if (extract && tools::file_ext(destfile) == "zip") {
    extract_dir <- file.path(dirname(destfile), tools::file_path_sans_ext(basename(destfile)))
    dir.create(extract_dir, showWarnings = FALSE, recursive = TRUE)
    cli::cli_progress_step(
      "Extracting {.file {basename(destfile)}}",
      msg_done = "Extracted {.file {basename(destfile)}} to {.file {extract_dir}}"
    )
    unzip(destfile, exdir = extract_dir, overwrite = TRUE)
    cli::cli_progress_done()
  }
  invisible(destfile)
}

#' List files at a remote HTTP directory index
#'
#' @description
#' Performs a `GET` request against an Apache-style autoindex URL and returns
#' the relative file/directory hrefs listed on the page. Works with Census
#' Bureau TIGER and GENZ directory listings.
#'
#' @param url Character. The directory index URL (must return `text/html`).
#' @param pattern Optional regex to filter returned hrefs (e.g. `"\\.zip$"`).
#' @param full_url Logical. If `TRUE`, returns fully-qualified URLs by joining
#'   `url` with each relative href. Default `FALSE`.
#'
#' @returns
#' A character vector of relative (or absolute, if `full_url = TRUE`)
#' file/directory hrefs, `NA`s and navigation links excluded.
#'
#' @export
#'
#' @importFrom httr2 request req_method req_perform resp_check_status resp_body_string
#' @importFrom xml2 read_html
#' @importFrom rvest html_nodes html_attr
remote_list <- function(url, pattern = NULL, full_url = FALSE) {
  check_url(url)
  resp <- httr2::request(url) |>
    httr2::req_method("GET") |>
    httr2::req_timeout(seconds = 10L) |>
    httr2::req_options(followlocation = TRUE, maxredirs = 10L) |>
    httr2::req_perform()
  httr2::resp_check_status(resp)
  httr2::resp_check_content_type(resp, valid_types = "text/html")
  html <- xml2::read_html(httr2::resp_body_string(resp))
  hrefs <- rvest::html_attr(rvest::html_nodes(html, "a"), "href")
  hrefs <- hrefs[!is.na(hrefs)]
  hrefs <- hrefs[!grepl("^[?]C=", hrefs)]
  hrefs <- hrefs[!grepl("^https?://", hrefs)]
  hrefs <- hrefs[!grepl("^/", hrefs)]
  hrefs <- hrefs[hrefs != "../"]
  if (!is.null(pattern)) {
    hrefs <- hrefs[grepl(pattern, hrefs)]
  }
  if (full_url) {
    base <- sub("/$", "", url)
    hrefs <- paste0(base, "/", hrefs)
  }
  hrefs
}

# internal --------------------------------------------------------------------------------------------------------

#' @keywords internal
#' @noRd
.hash_algos <- c("md5", "sha1", "sha256", "sha512")

#' @keywords internal
#' @noRd
#' @importFrom openssl md5 sha1 sha256 sha512
#' @importFrom cli cli_abort
.get_hash_func <- function(algo) {
  switch(
    algo,
    md5 = openssl::md5,
    sha1 = openssl::sha1,
    sha256 = openssl::sha256,
    sha512 = openssl::sha512,
    cli::cli_abort("Unsupported hash algorithm: {.field {algo}}")
  )
}

#' @keywords internal
#' @noRd
#' @importFrom withr local_locale
.parse_http_date <- function(x) {
  withr::local_locale(LC_TIME = "C")
  out <- as.POSIXct(strptime(x, "%a, %d %b %Y %H:%M:%S", tz = "UTC"))
  attr(out, "tzone") <- NULL
  out
}
