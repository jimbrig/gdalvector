#  ------------------------------------------------------------------------
#
# Title : File Utilities
#    By : Jimmy Briggs
#  Date : 2026-06-22
#
#  ------------------------------------------------------------------------

local_file_info <- function(path, ...) {
  fs_info <- fs::file_info(path) |>
    tibble::as_tibble() |>
    dplyr::mutate(dplyr::across(c("path", "type", "size", "permissions", tidyselect::ends_with("_time")), as.character))
}

local_file_signature <- function(path) {
  check_file(path)
  local_file_info(path) |>
    tidyr::unite("signature", tidyselect::everything(), sep = "|", remove = TRUE) |>
    dplyr::pull(.data$signature) |>
    cli::hash_xxhash64()
}
