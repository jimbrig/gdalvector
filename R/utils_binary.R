#  ------------------------------------------------------------------------
#
# Title : Binary Encoding Utilities
#    By : Jimmy Briggs
#  Date : 2026-06-11
#
#  ------------------------------------------------------------------------

# conversions -----------------------------------------------------------------------------------------------------

char_to_raw <- function(str) {
  charToRaw(str)
}

char_to_int <- function(x, size = 4L, endian = "big") {
  raw_to_int(char_to_raw(x), size = size, endian = endian)
}

char_to_hex_str <- function(x, size = 4L, endian = "big", width = 8L, prefix = TRUE, upper = TRUE) {
  char_to_int(x, size = size, endian = endian) |> int_to_hex_str(width = width, prefix = prefix, upper = upper)
}

raw_to_char <- function(x, multiple = FALSE) {
  rawToChar(x = x, multiple = multiple)
}

raw_to_hex_str <- function(x, size = 4L, sep = " ", prefix = TRUE, upper = TRUE) {
  hold <- format(as.hexmode(raw_to_int(x, size = size)), width = size, upper.case = upper)
  if (prefix) {
    hold <- paste0("0x", hold)
  }
  hold
}

raw_to_int <- function(x, size = 4L, endian = "big", signed = TRUE) {
  readBin(x, what = "integer", size = size, endian = endian, signed = signed)
}

# decode a 64-bit integer from 8 raw bytes via bit64. base `readBin()` cannot read 8-byte integers, but a bit64
# `integer64` stores its value as the raw bits of a double, so reading the bytes as a double and reinterpreting the
# class yields the correct signed value (with none of the manual two's-complement handling getting in the way).
raw_to_int64 <- function(x, endian = "little") {
  out <- readBin(x, what = "double", n = 1L, size = 8L, endian = endian)
  class(out) <- "integer64"
  out
}

int_to_hex_str <- function(x, width = 8L, prefix = TRUE, upper = TRUE) {
  hold <- format(as.hexmode(x), width = width, upper.case = upper)
  if (prefix) {
    hold <- paste0("0x", hold)
  }
  hold
}

hex_str_to_int <- function(x) {
  strtoi(x)
}

hex_str_to_raw <- function(x) {
  x <- gsub("^0[xX]|\\s+", "", x)
  stopifnot(nchar(x) %% 2L == 0L)
  pairs <- regmatches(x, gregexpr(".{2}", x))[[1]]
  as.raw(strtoi(pairs, base = 16L))
}

sf_raw_to_hex <- function(x) {
  sf::rawToHex(x)
}

# strip embedded nulls --------------------------------------------------------------------------------------------

strip_null_bytes <- function(x) {
  x[x != as.raw(0x00)]
}

# strip gpkg wkb header -------------------------------------------------------------------------------------------

strip_gpkg_wkb_header <- function(wkb) {
  flags <- as.integer(wkb[4])
  env_type <- bitwAnd(bitwShiftR(flags, 1L), 7L)
  env_bytes <- c(0L, 32L, 48L, 48L, 64L)[env_type + 1L]
  header_n <- 8L + env_bytes
  wkb[(header_n + 1L):length(wkb)]
}

# magic headers ---------------------------------------------------------------------------------------------------

#' Read File Magic Header Bytes
#'
#' @description
#' Reads the first `n` bytes of a file and returns the raw bytes and their string representation.
#'
#' @param path Character. Path to the file.
#' @param n Integer. Number of bytes to read. Default is `4L`.
#' @param ... Additional arguments passed to [readBin()].
#'
#' @returns
#' A `magic_header` list containing `path`, `raw`, and `str` elements.
#'
#' @keywords internal
#'
#' @examples
#' \dontrun{
#' read_magic_header(pkg_sys_extdata("gpkg/cb_2025_us_all_20m.gpkg"), n = 15L)
#' }
read_magic_header <- function(path, n = 4L, ...) {
  check_file(path)
  header_raw <- strip_null_bytes(readBin(path, what = "raw", n = n, ...))
  header_str <- rawToChar(header_raw)
  structure(
    list(path = path, raw = header_raw, str = header_str),
    class = c("magic_header", "list")
  )
}


as_magic_raw <- function(x, type = c("auto", "raw", "hex_str", "char")) {
  type <- rlang::arg_match(type)
  if (is.raw(x)) {
    return(x)
  }
  switch(
    type,
    raw = x,
    hex_str = hex_str_to_raw(x),
    char = char_to_raw(x),
    auto = {
      stripped <- gsub("^0[xX]|\\s+", "", x)
      if (grepl("^0[xX]", x) && grepl("^[0-9a-fA-F]+$", stripped) && nchar(stripped) %% 2L == 0L) {
        hex_str_to_raw(stripped)
      } else {
        char_to_raw(x)
      }
    }
  )
}

# validate that a file begins with an expected magic-byte pattern (n bytes read, inferred from the
# pattern length when NULL; offset allows non-zero starts).
#' @keywords internal
#' @noRd
validate_magic_header <- function(path, pattern, n = NULL, offset = 0L, type = "auto", strip_null = TRUE) {
  check_file(path)
  pattern_raw <- as_magic_raw(pattern, type = type)
  n_bytes <- n %||% length(pattern_raw)
  con <- file(path, "rb")
  on.exit(close(con))
  if (offset > 0L) {
    readBin(con, "raw", n = offset)
  }
  header_raw <- readBin(con, "raw", n = n_bytes)
  cmp_raw <- if (strip_null) header_raw[header_raw != as.raw(0x00)] else header_raw
  is_valid <- identical(cmp_raw[seq_len(min(length(cmp_raw), length(pattern_raw)))], pattern_raw)
  if (is_valid) {
    cli::cli_alert_success(
      "Magic header bytes for {.path {basename(path)}} match the expected pattern: {.field {char_to_hex_str(pattern)}}."
    )
    return(TRUE)
  }
  cli::cli_alert_danger(
    "Magic header bytes for {.path {basename(path)}} do not match the expected pattern: {.field {char_to_hex_str(pattern)}}."
  )
  cli::cli_alert_info("Expected: {.field {char_to_hex_str(pattern)}}")
  cli::cli_alert_info("Actual:   {.field {char_to_hex_str(header_raw)}}")
  return(FALSE)
}

# bytes -----------------------------------------------------------------------------------------------------------
