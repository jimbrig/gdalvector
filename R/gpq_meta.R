#  ------------------------------------------------------------------------
#
# Title : GeoParquet Metadata
#    By : Jimmy Briggs
#  Date : 2026-06-30
#
#  ------------------------------------------------------------------------

# topic -----------------------------------------------------------------------------------------------------------

#' GeoParquet Metadata
#'
#' @name gpq_meta
#' @family gpq
#'
#' @description
#' A family of functions for reading (Geo)Parquet metadata directly from the file footer; no data pages are read.
#' Each returns a classed list with `format()` and `print()` methods:
#'
#' - [gpq_file_info()]: file-level summary (sizes, versions, row groups).
#' - [gpq_schema_info()]: the Parquet schema (leaf columns, struct nodes, logical types).
#' - [gpq_row_groups()]: row group and column chunk statistics, with decoded min/max values.
#' - [gpq_geo_metadata()]: the GeoParquet (`geo`) and GDAL (`gdal:*`) key-value metadata.
#' - [gpq_inspect()]: all of the above, assembled into one object.
#'
#' The footer is read with [nanoparquet::read_parquet_metadata()] and embedded JSON metadata is parsed with
#' [yyjsonr::read_json_str()].
#'
#' @seealso
#' ```{r child = "man/fragments/gpq_links.md"}
#' ```
NULL


# file info -------------------------------------------------------------------------------------------------------

#' GeoParquet File Info
#'
#' @description
#' Summarize file-level information about a (Geo)Parquet file from its footer.
#'
#' @param gpq_path Path to a (Geo)Parquet (`*.parquet`) file.
#'
#' @returns
#' A `gpq_file_info` object (a list) with:
#' - `source`, `path`: the file name and full path.
#' - `file_size`: the file size in bytes.
#' - `parquet_version`, `geoparquet_version`: the format versions (the latter is `NA` for plain Parquet).
#' - `num_rows`, `num_cols`, `num_row_groups`: the row, column, and row group counts.
#' - `row_group_size`, `row_group_size_last`: the number of rows in the first and last row groups.
#' - `created_by`: the writing software.
#' - `kv_keys`: the key-value metadata keys present in the file.
#'
#' @export
#'
#' @importFrom nanoparquet read_parquet_info
#'
#' @examples
#' f <- system.file("extdata/atlanta/atlanta.parquet", package = "gdalvector")
#' gpq_file_info(f)
gpq_file_info <- function(gpq_path) {
  check_file(gpq_path, ext = "parquet")

  info <- nanoparquet::read_parquet_info(gpq_path)
  rd <- .gpq_read_meta(gpq_path)
  rg <- rd$meta$row_groups
  n_rg <- nrow(rg)

  structure(
    list(
      source = basename(gpq_path),
      path = gpq_path,
      file_size = info$file_size,
      parquet_version = info$parquet_version,
      geoparquet_version = rd$geo$version %||% NA_character_,
      num_rows = info$num_rows,
      num_cols = info$num_cols,
      num_row_groups = info$num_row_groups,
      row_group_size = if (n_rg > 0L) rg$num_rows[1L] else NA_real_,
      row_group_size_last = if (n_rg > 0L) rg$num_rows[n_rg] else NA_real_,
      created_by = info$created_by,
      kv_keys = rd$kvm$key
    ),
    class = c("gpq_file_info", "list")
  )
}

#' @export
#'
#' @importFrom cli cli_text
#' @importFrom rlang as_bytes
format.gpq_file_info <- function(x, ...) {
  gpq_cli_fmt({
    cli::cli_text("{.cls {class(x)}}")
    cli_kv(list(
      "Source" = x$source,
      "File size" = rlang::as_bytes(x$file_size),
      "Parquet version" = x$parquet_version,
      "GeoParquet version" = x$geoparquet_version,
      "Rows" = x$num_rows,
      "Columns" = x$num_cols,
      "Row groups" = x$num_row_groups,
      "Row group size" = x$row_group_size,
      "Created by" = x$created_by,
      "Metadata keys" = x$kv_keys
    ))
  })
}

#' @export
print.gpq_file_info <- function(x, ...) {
  cat(format(x, ...), sep = "\n")
  invisible(x)
}


# schema ----------------------------------------------------------------------------------------------------------

#' GeoParquet Schema
#'
#' @description
#' Read the tidied Parquet schema as a tibble: one row per leaf column with its Parquet physical type,
#' converted/logical types, repetition, mapped R type, and (for geometry columns) the encoding and geometry types
#' from the `geo` metadata. For a high-level summary instead of the full table, see [gpq_schema_info()].
#'
#' @inheritParams gpq_file_info
#'
#' @returns
#' A [tibble::tibble()] with columns `id`, `name`, `parquet_type`, `converted_type`, `logical_type`, `repetition`,
#' `r_type`, and `info`.
#'
#' @export
#'
#' @importFrom nanoparquet read_parquet_schema
#'
#' @examples
#' f <- system.file("extdata/atlanta/atlanta.parquet", package = "gdalvector")
#' gpq_schema(f)
gpq_schema <- function(gpq_path) {
  check_file(gpq_path, ext = "parquet")
  raw <- nanoparquet::read_parquet_schema(gpq_path)
  .gpq_schema_columns(raw, .gpq_read_meta(gpq_path)$geo$columns)
}

#' GeoParquet Schema Info
#'
#' @description
#' Summarize the Parquet schema of a (Geo)Parquet file: leaf column and struct node counts, the geometry column(s),
#' and the distribution of Parquet physical types. The full per-column table is available from [gpq_schema()] or the
#' object's `columns` element.
#'
#' @inheritParams gpq_file_info
#'
#' @returns
#' A `gpq_schema_info` object (a list) with `source`, `path`, `struct_nodes`, `columns` (the [gpq_schema()] tibble),
#' and the `n_leaf`/`n_struct` counts.
#'
#' @export
#'
#' @importFrom nanoparquet read_parquet_schema
#' @importFrom tibble as_tibble
#'
#' @examples
#' f <- system.file("extdata/atlanta/atlanta.parquet", package = "gdalvector")
#' gpq_schema_info(f)
gpq_schema_info <- function(gpq_path) {
  check_file(gpq_path, ext = "parquet")

  raw <- nanoparquet::read_parquet_schema(gpq_path)
  columns <- .gpq_schema_columns(raw, .gpq_read_meta(gpq_path)$geo$columns)

  # leaf columns carry a physical `type`; the root (always the first entry) and struct/group nodes (e.g.
  # `geometry_bbox`) do not.
  is_leaf <- !is.na(raw$type)
  is_struct <- !is_leaf & seq_len(nrow(raw)) != 1L

  structure(
    list(
      source = basename(gpq_path),
      path = gpq_path,
      struct_nodes = tibble::as_tibble(raw[is_struct, , drop = FALSE]),
      columns = columns,
      n_leaf = nrow(columns),
      n_struct = sum(is_struct)
    ),
    class = c("gpq_schema_info", "list")
  )
}

#' @export
#'
#' @importFrom cli cli_text
#' @importFrom stats setNames
format.gpq_schema_info <- function(x, ...) {
  geom <- x$columns[!is.na(x$columns$info), , drop = FALSE]
  types <- sort(table(x$columns$parquet_type), decreasing = TRUE)
  gpq_cli_fmt({
    cli::cli_text("{.cls {class(x)}}")
    cli_kv(list(
      "Leaf columns" = x$n_leaf,
      "Struct nodes" = if (x$n_struct > 0L) x$struct_nodes$name else NA,
      "Geometry" = if (nrow(geom) > 0L) paste0(geom$name, " (", geom$info, ")") else NA
    ))
    cli_kv(stats::setNames(as.integer(types), names(types)), title = "Parquet types")
    cli::cli_text("{.emph Full column table via} {.fn gpq_schema}")
  })
}

#' @export
print.gpq_schema_info <- function(x, ...) {
  cat(format(x, ...), sep = "\n")
  invisible(x)
}


# row groups ------------------------------------------------------------------------------------------------------

#' GeoParquet Row Groups and Statistics
#'
#' @description
#' Read row group and column chunk statistics. Parquet stores chunk min/max statistics as raw bytes in the column's
#' physical type; these are decoded to R scalars and aggregated into a per-column summary across all row groups.
#'
#' @inheritParams gpq_file_info
#'
#' @returns
#' A `gpq_row_groups` object (a list) with:
#' - `source`, `path`: the file name and full path.
#' - `row_groups`: a per-row-group [tibble::tibble()].
#' - `column_chunks`: the raw per-chunk [tibble::tibble()] with leaf column names and decoded min/max appended.
#' - `col_summary`: a one-row-per-column [tibble::tibble()] aggregated across all row groups.
#'
#' @export
#'
#' @importFrom nanoparquet read_parquet_metadata
#' @importFrom tibble as_tibble
#' @importFrom purrr map_chr map2
#' @importFrom dplyr group_by summarise first
#'
#' @examples
#' f <- system.file("extdata/atlanta/atlanta.parquet", package = "gdalvector")
#' gpq_row_groups(f)
gpq_row_groups <- function(gpq_path) {
  check_file(gpq_path, ext = "parquet")

  meta <- nanoparquet::read_parquet_metadata(gpq_path)
  rg <- tibble::as_tibble(meta$row_groups)
  cc <- tibble::as_tibble(meta$column_chunks)

  cc$col_name <- purrr::map_chr(cc$path_in_schema, paste, collapse = ".")
  cc$min_stat <- purrr::map2(cc$min_value, cc$type, .gpq_decode_stat)
  cc$max_stat <- purrr::map2(cc$max_value, cc$type, .gpq_decode_stat)

  col_summary <- cc |>
    dplyr::group_by(.data$column, .data$col_name) |>
    dplyr::summarise(
      type = dplyr::first(.data$type),
      codec = dplyr::first(.data$codec),
      num_values = sum(.data$num_values, na.rm = TRUE),
      null_count = sum(.data$null_count, na.rm = TRUE),
      min = .gpq_global_stat(.data$min_stat, min),
      max = .gpq_global_stat(.data$max_stat, max),
      compressed = sum(.data$total_compressed_size, na.rm = TRUE),
      uncompressed = sum(.data$total_uncompressed_size, na.rm = TRUE),
      .groups = "drop"
    )

  structure(
    list(
      source = basename(gpq_path),
      path = gpq_path,
      row_groups = rg,
      column_chunks = cc,
      col_summary = col_summary
    ),
    class = c("gpq_row_groups", "list")
  )
}

#' @export
#'
#' @importFrom cli cli_text
#' @importFrom dplyr mutate
#' @importFrom rlang as_bytes
#' @importFrom utils capture.output
format.gpq_row_groups <- function(x, n = 20L, ...) {
  summary <- dplyr::mutate(
    x$col_summary,
    compressed = rlang::as_bytes(.data$compressed),
    uncompressed = rlang::as_bytes(.data$uncompressed)
  )
  c(
    gpq_cli_fmt(cli::cli_text("{.cls {class(x)}} ({nrow(x$row_groups)} row group{?s})")),
    utils::capture.output(print(summary, n = n))
  )
}

#' @export
print.gpq_row_groups <- function(x, ...) {
  cat(format(x, ...), sep = "\n")
  invisible(x)
}


# geo metadata ----------------------------------------------------------------------------------------------------

#' GeoParquet and GDAL Metadata
#'
#' @description
#' Read and parse the GeoParquet (`geo`) and GDAL (`gdal:creation-options`, `gdal:schema`) key-value metadata, plus
#' any `pandas` metadata. Geometry column metadata is accessed via the declared `primary_column`, and the `crs` field
#' is normalized to a `type`/`name`/`authority` summary across its three forms: absent (`NULL`), a PROJJSON object,
#' or a WKT string.
#'
#' @inheritParams gpq_file_info
#'
#' @returns
#' A `gpq_geo_metadata` object (a list). When no `geo` metadata is present, `is_geoparquet` is `FALSE` and the
#' geospatial fields are omitted.
#'
#' @export
#'
#' @examples
#' f <- system.file("extdata/atlanta/atlanta.parquet", package = "gdalvector")
#' gpq_geo_metadata(f)
gpq_geo_metadata <- function(gpq_path) {
  check_file(gpq_path, ext = "parquet")

  rd <- .gpq_read_meta(gpq_path)
  kvm <- rd$kvm
  geo <- rd$geo

  if (is.null(geo)) {
    gdal_warn(
      c(
        "No {.field geo} metadata found in {.path {basename(gpq_path)}}.",
        "i" = "This file does not appear to be a GeoParquet file."
      ),
      cls = "gpq_not_geoparquet_warning"
    )
    return(structure(
      list(source = basename(gpq_path), path = gpq_path, is_geoparquet = FALSE),
      class = c("gpq_geo_metadata", "list")
    ))
  }

  geom <- geo$columns[[geo$primary_column]]
  crs <- .gpq_crs_summary(geom$crs)

  structure(
    list(
      source = basename(gpq_path),
      path = gpq_path,
      is_geoparquet = TRUE,
      version = geo$version,
      primary_column = geo$primary_column,
      encoding = geom$encoding,
      geometry_types = geom$geometry_types,
      bbox = geom$bbox,
      orientation = geom$orientation %||% NA_character_,
      edges = geom$edges %||% NA_character_,
      covering = geom$covering,
      crs_type = crs$type,
      crs_name = crs$name,
      crs_authority = crs$authority,
      crs_raw = geom$crs,
      gdal_creation_opts = .gpq_parse_kv_json(kvm, "gdal:creation-options"),
      gdal_schema = .gpq_parse_kv_json(kvm, "gdal:schema"),
      pandas_meta = .gpq_parse_kv_json(kvm, "pandas"),
      kv_keys = kvm$key
    ),
    class = c("gpq_geo_metadata", "list")
  )
}

#' @export
#'
#' @importFrom cli cli_text
format.gpq_geo_metadata <- function(x, ...) {
  gpq_cli_fmt({
    cli::cli_text("{.cls {class(x)}}")
    if (!isTRUE(x$is_geoparquet)) {
      cli::cli_text("{.emph No {.field geo} metadata; not a GeoParquet file.}")
    } else {
      cli_kv(
        list(
          "Version" = x$version,
          "Primary column" = x$primary_column,
          "Encoding" = x$encoding,
          "Geometry types" = x$geometry_types,
          "Orientation" = x$orientation,
          "Edges" = x$edges,
          "Bounding box" = x$bbox
        ),
        title = "GeoParquet"
      )
      cli_kv(
        list("Type" = x$crs_type, "Name" = x$crs_name, "Authority" = x$crs_authority),
        title = "CRS"
      )
      if (!is.null(x$gdal_creation_opts)) {
        cli_kv(x$gdal_creation_opts, title = "GDAL Creation Options")
      }
      if (!is.null(x$covering)) {
        cli::cli_text("{.strong Covering:}")
        cli_json(x$covering)
      }
      if (!is.null(x$gdal_schema)) {
        cli::cli_text("{.emph GDAL OGR schema present; see} {.code x$gdal_schema}")
      }
      if (!is.null(x$pandas_meta)) {
        cli::cli_text("{.emph Pandas metadata present; see} {.code x$pandas_meta}")
      }
    }
  })
}

#' @export
print.gpq_geo_metadata <- function(x, ...) {
  cat(format(x, ...), sep = "\n")
  invisible(x)
}


# inspect ---------------------------------------------------------------------------------------------------------

#' Comprehensive GeoParquet Introspection
#'
#' @description
#' Assemble [gpq_file_info()], [gpq_schema_info()], [gpq_row_groups()] and [gpq_geo_metadata()] into a single object.
#'
#' @inheritParams gpq_file_info
#'
#' @returns
#' A `gpq_inspect` object (a list) with `file_info`, `schema`, `row_groups` and `geo_metadata` elements.
#'
#' @export
#'
#' @examples
#' f <- system.file("extdata/atlanta/atlanta.parquet", package = "gdalvector")
#' gpq_inspect(f)
gpq_inspect <- function(gpq_path) {
  check_file(gpq_path, ext = "parquet")

  structure(
    list(
      file_info = gpq_file_info(gpq_path),
      schema = gpq_schema_info(gpq_path),
      row_groups = gpq_row_groups(gpq_path),
      geo_metadata = gpq_geo_metadata(gpq_path)
    ),
    class = c("gpq_inspect", "list")
  )
}

#' @export
#'
#' @importFrom cli cli_text
format.gpq_inspect <- function(x, ...) {
  parts <- list(x$file_info, x$schema, x$row_groups, x$geo_metadata)
  c(
    gpq_cli_fmt(cli::cli_text("{.cls {class(x)}}")),
    "",
    unlist(lapply(parts, function(part) c(format(part, ...), "")), use.names = FALSE)
  )
}

#' @export
print.gpq_inspect <- function(x, ...) {
  cat(format(x, ...), sep = "\n")
  invisible(x)
}


# internal --------------------------------------------------------------------------------------------------------

# read the footer once and return the metadata, the key-value metadata frame, and the parsed `geo` blob.
#' @keywords internal
#' @noRd
#' @importFrom nanoparquet read_parquet_metadata
.gpq_read_meta <- function(gpq_path) {
  meta <- nanoparquet::read_parquet_metadata(gpq_path)
  kvm <- .gpq_kvm(meta$file_meta_data)
  list(meta = meta, kvm = kvm, geo = .gpq_parse_kv_json(kvm, "geo"))
}

# extract the key-value metadata (a list-column on the one-row file_meta_data frame).
#' @keywords internal
#' @noRd
#' @importFrom tibble tibble
.gpq_kvm <- function(file_meta_data) {
  kvm <- file_meta_data$key_value_metadata[[1L]]
  if (is.null(kvm) || nrow(kvm) == 0L) {
    return(tibble::tibble(key = character(), value = character()))
  }
  kvm
}

# look up a single key in a key-value frame and parse its value as JSON (NULL when absent / NA / unparseable).
#' @keywords internal
#' @noRd
#' @importFrom yyjsonr read_json_str
#' @importFrom rlang try_fetch
.gpq_parse_kv_json <- function(kvm, key) {
  val <- kvm$value[kvm$key == key]
  if (length(val) != 1L || is.na(val)) {
    return(NULL)
  }
  rlang::try_fetch(yyjsonr::read_json_str(val), error = function(cnd) NULL)
}

# build the one-row-per-leaf-column schema tibble from a raw nanoparquet schema and the parsed `geo` columns. leaf
# columns are those carrying a physical `type`; the `info` column annotates geometry columns with their encoding and
# geometry types.
#' @keywords internal
#' @noRd
#' @importFrom tibble tibble
#' @importFrom purrr map_chr
.gpq_schema_columns <- function(raw, geo_cols) {
  leaf <- raw[!is.na(raw$type), , drop = FALSE]
  tibble::tibble(
    id = seq_len(nrow(leaf)),
    name = leaf$name,
    parquet_type = leaf$type,
    converted_type = leaf$converted_type,
    logical_type = purrr::map_chr(leaf$logical_type, .gpq_logical_type_str),
    repetition = leaf$repetition_type,
    r_type = leaf$r_type,
    info = purrr::map_chr(leaf$name, function(nm) {
      gc <- geo_cols[[nm]]
      if (is.null(gc)) {
        return(NA_character_)
      }
      trimws(paste(gc$encoding %||% "", paste(gc$geometry_types, collapse = ", ")))
    })
  )
}

# render a nanoparquet `logical_type` list element (e.g. list(type = "DECIMAL", scale = 2)) as a string.
# `lt$type` is `NULL` when `lt` is `NULL`, an empty list, or simply has no type, so one guard covers all three.
#' @keywords internal
#' @noRd
#' @importFrom rlang is_empty
.gpq_logical_type_str <- function(lt) {
  if (is.null(lt$type)) {
    return(NA_character_)
  }
  extras <- lt[names(lt) != "type"]
  if (rlang::is_empty(extras)) {
    return(paste0(lt$type, "()"))
  }
  kv <- paste(names(extras), unlist(extras), sep = "=", collapse = ", ")
  paste0(lt$type, "(", kv, ")")
}

# normalize a GeoParquet `crs` field to a `type`/`name`/`authority` summary, read directly from the embedded
# metadata (no GDAL/PROJ calls). A `NULL` crs means the GeoParquet default of OGC:CRS84 (lon/lat WGS 84); a list is
# a PROJJSON object carrying its own `name` and `id`; anything else is an authority or WKT string.
#' @keywords internal
#' @noRd
#' @importFrom purrr pluck
.gpq_crs_summary <- function(crs) {
  if (is.null(crs)) {
    return(list(type = "default", name = "WGS 84 (CRS84)", authority = "OGC:CRS84"))
  }
  if (!is.list(crs)) {
    return(list(type = "string", name = NA_character_, authority = as.character(crs)[[1L]]))
  }
  id <- crs$id %||% purrr::pluck(crs, "ids", 1L)
  authority <- if (!is.null(id)) paste0(id$authority, ":", id$code) else NA_character_
  list(
    type = "PROJJSON",
    name = crs$name %||% NA_character_,
    authority = authority
  )
}

# decode a raw binary Parquet min/max statistic to an R scalar based on the column's physical type, returning `NA`
# on unsupported types or any decode failure (statistics are optional and may be absent).
#' @keywords internal
#' @noRd
#' @importFrom rlang try_fetch
.gpq_decode_stat <- function(raw_val, parquet_type) {
  if (length(raw_val) == 0L) {
    return(NA)
  }
  rlang::try_fetch(
    switch(
      parquet_type,
      BOOLEAN = as.logical(as.integer(raw_val[1L])),
      INT32 = readBin(raw_val, "integer", size = 4L, n = 1L, endian = "little"),
      INT64 = as.numeric(raw_to_int64(raw_val)),
      FLOAT = readBin(raw_val, "double", size = 4L, n = 1L, endian = "little"),
      DOUBLE = readBin(raw_val, "double", size = 8L, n = 1L, endian = "little"),
      BYTE_ARRAY = ,
      FIXED_LEN_BYTE_ARRAY = raw_to_char(strip_null_bytes(raw_val)),
      NA
    ),
    error = function(cnd) NA
  )
}

# reduce a column's per-row-group decoded statistics to a single formatted scalar (numeric -> `fn`, character ->
# lexical `fn`). used inside the `col_summary` group/summarise to produce global min/max strings.
#' @keywords internal
#' @noRd
#' @importFrom purrr discard
#' @importFrom rlang is_empty
.gpq_global_stat <- function(vals, fn) {
  vals <- purrr::discard(vals, \(v) all(is.na(v)))
  if (rlang::is_empty(vals)) {
    return("-")
  }
  v <- unlist(vals, use.names = FALSE)
  out <- if (is.character(v)) fn(v) else suppressWarnings(fn(as.numeric(v), na.rm = TRUE))
  if (is.numeric(out)) format(out, big.mark = ",", scientific = FALSE, trim = TRUE) else as.character(out)
}
