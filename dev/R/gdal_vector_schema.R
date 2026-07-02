#  ------------------------------------------------------------------------
#
# Title : GDAL Vector Schema
#    By : Jimmy Briggs
#  Date : 2026-06-29
#
#  ------------------------------------------------------------------------

# type map --------------------------------------------------------------------------------------------------------

#' GDAL Vector Type Map
#'
#' @description
#' The canonical lookup table that ties together the various type vocabularies a single field passes through over the
#' course of a vector pipeline:
#'
#' - `ogr_type`: the `OFT*` enum reported by [gdal_vector_layer_definition()] (`getLayerDefn`).
#' - `field_type`: the friendly name reported by [gdal_vector_schema()] (`export-schema`) and accepted by the
#'   `gdal vector set-field-type --field-type` argument.
#' - `sql_type`: the type name used in a `CAST(<col> AS <type>)` expression under the OGR SQLite dialect.
#' - `arrow_type`: the Arrow/Parquet logical type a field lands on when written to (Geo)Parquet.
#' - `r_type`: the corresponding R type/class.
#'
#' @returns
#' A [tibble::tibble()] with one row per supported type.
#'
#' @export
#'
#' @examples
#' gdal_vector_type_map()
gdal_vector_type_map <- function() {
  tibble::tribble(
    ~ogr_type,      ~field_type,  ~sql_type,   ~arrow_type,     ~r_type,
    "OFTString",    "String",     "TEXT",      "utf8",          "character",
    "OFTInteger",   "Integer",    "INTEGER",   "int32",         "integer",
    "OFTInteger64", "Integer64",  "INTEGER64", "int64",         "integer64",
    "OFTReal",      "Real",       "REAL",      "float64",       "double",
    "OFTDate",      "Date",       "DATE",      "date32",        "Date",
    "OFTDateTime",  "DateTime",   "DATETIME",  "timestamp[ms]", "POSIXct",
    "OFTTime",      "Time",       "TIME",      "time32[ms]",    "hms",
    "OFTBinary",    "Binary",     "BLOB",      "binary",        "blob"
  )
}

# translate a vector of `field_type` values into another column of the type map. unknown types resolve to `NA` and,
# for `sql_type`, fall back to `TEXT` so an un-mapped field still produces a valid (if lossy) cast.
gdal_vector_type_lookup <- function(
  field_type,
  to = c("sql_type", "arrow_type", "ogr_type", "r_type"),
  fallback = NA_character_
) {
  to <- rlang::arg_match(to)
  map <- gdal_vector_type_map()
  out <- map[[to]][match(field_type, map$field_type)]
  out[is.na(out)] <- fallback
  out
}

# schema spec -----------------------------------------------------------------------------------------------------

#' Build a GDAL Vector Schema Spec
#'
#' @description
#' Builds the editable "schema spec" that drives [gdal_vector_schema_pipeline_args()] and the individual emitters. It
#' is a single [tibble::tibble()] with exactly one row per **output** field, seeded from the data source's exported
#' schema ([gdal_vector_schema()]) so that, by default, the target schema is identical to the source schema.
#'
#' You then edit the returned tibble - toggle `keep`, change `target_name` (rename), change `target_type` (retype),
#' and/or reorder via `order` - and hand it to the emitters. The emitters inspect the diff between the source and
#' target columns to decide which pipeline steps are actually required (see [gdal_vector_schema_pipeline_args()]).
#'
#' The spec columns are:
#'
#' \describe{
#'   \item{`order`}{Integer output ordering (lower comes first).}
#'   \item{`role`}{One of `"fid"`, `"attribute"`, or `"geometry"`.}
#'   \item{`keep`}{Logical; whether the field is carried into the output.}
#'   \item{`source_name`}{The field name in the source layer (`"rowid"` for the synthetic FID row).}
#'   \item{`source_type`}{The source `field_type` (see [gdal_vector_type_map()]).}
#'   \item{`source_subtype`}{The source subtype, e.g. `"JSON"`, else `"None"`.}
#'   \item{`nullable`}{Logical; source nullability.}
#'   \item{`target_name`}{The output field name (seeded from `source_name`).}
#'   \item{`target_type`}{The output `field_type` (seeded from `source_type`).}
#' }
#'
#' @param dsn The data source name (path or connection string).
#' @param layer The layer name. Defaults to the first layer via [gdal_vector_layer()].
#' @param keep_fid Logical; whether to seed a synthetic FID row that carries the (virtual) feature id through as an
#'   attribute via `CAST(rowid AS INTEGER) AS <fid_name>`. Many drivers (e.g. GeoPackage) expose the FID as a virtual
#'   column that is *not* a real field, so this is the reliable way to retain it. Defaults to `TRUE`.
#' @param fid_name,fid_type The target name and type for the synthetic FID row. Defaults to `"source_fid"` and
#'   `"Integer64"`.
#' @param geom_name The target name for the geometry field. Defaults to `"geometry"`.
#' @param ... Passed on to [gdal_vector_schema()].
#'
#' @returns
#' A `gdal_vector_schema_spec` tibble.
#'
#' @export
gdal_vector_schema_spec <- function(
  dsn,
  layer = gdal_vector_layer(dsn),
  keep_fid = TRUE,
  fid_name = "source_fid",
  fid_type = "Integer64",
  geom_name = "geometry",
  ...
) {
  schema <- gdal_vector_schema(dsn = dsn, layer = layer, ...)
  lyr <- schema$layers[[1]]

  attrs <- purrr::map(
    lyr$fields,
    function(f) {
      tibble::tibble(
        role = "attribute",
        source_name = f$name %||% NA_character_,
        source_type = f$type %||% NA_character_,
        source_subtype = f$subType %||% "None",
        nullable = f$nullable %||% TRUE
      )
    }
  ) |>
    purrr::list_rbind()

  rows <- list(attrs)

  if (isTRUE(keep_fid)) {
    fid_row <- tibble::tibble(
      role = "fid",
      source_name = "rowid",
      source_type = "Integer",
      source_subtype = "None",
      nullable = FALSE
    )
    rows <- c(list(fid_row), rows)
  }

  geom_field <- lyr$geometryFields[[1]]
  if (!is.null(geom_field)) {
    geom_row <- tibble::tibble(
      role = "geometry",
      source_name = geom_field$name %||% "geom",
      source_type = geom_field$type %||% NA_character_,
      source_subtype = "None",
      nullable = geom_field$nullable %||% FALSE
    )
    rows <- c(rows, list(geom_row))
  }

  spec <- purrr::list_rbind(rows)

  spec <- spec |>
    dplyr::mutate(
      keep = TRUE,
      target_name = dplyr::case_when(
        .data$role == "fid" ~ fid_name,
        .data$role == "geometry" ~ geom_name,
        TRUE ~ .data$source_name
      ),
      target_type = dplyr::case_when(
        .data$role == "fid" ~ fid_type,
        TRUE ~ .data$source_type
      ),
      order = dplyr::row_number()
    ) |>
    dplyr::select(
      "order",
      "role",
      "keep",
      "source_name",
      "source_type",
      "source_subtype",
      "nullable",
      "target_name",
      "target_type"
    )

  structure(spec, class = c("gdal_vector_schema_spec", class(spec)))
}

# return the kept rows of a spec, ordered, with an optional role filter.
schema_spec_kept <- function(spec, roles = NULL) {
  out <- spec[spec$keep %in% TRUE, , drop = FALSE]
  if (!is.null(roles)) {
    out <- out[out$role %in% roles, , drop = FALSE]
  }
  out[order(out$order), , drop = FALSE]
}

# emitters --------------------------------------------------------------------------------------------------------

#' Emit the `select --fields` Field List from a Schema Spec
#'
#' @description
#' Returns the comma-delimited list of source field names for the kept attribute fields, suitable for the
#' `gdal vector select --fields` step. Geometry is retained by GDAL automatically and so is omitted, and the
#' synthetic FID row cannot be expressed this way (its presence forces the SQL path - see
#' [gdal_vector_schema_pipeline_args()]).
#'
#' @param spec A [gdal_vector_schema_spec()].
#'
#' @returns A single comma-delimited character string.
#'
#' @export
schema_spec_select_fields <- function(spec) {
  kept <- schema_spec_kept(spec, roles = "attribute")
  paste(kept$source_name, collapse = ",")
}

#' Emit the SQLite-dialect SELECT from a Schema Spec
#'
#' @description
#' Builds the `SELECT` statement (OGR SQLite dialect) that renames and casts source fields into the target schema.
#' Attribute fields become `CAST(<source> AS <sql_type>) AS <target>`, the synthetic FID row becomes
#' `CAST(rowid AS INTEGER) AS <target>`, and the geometry field becomes `<source> AS <target>` (no cast).
#'
#' @param spec A [gdal_vector_schema_spec()].
#' @param layer The source layer name for the `FROM` clause.
#' @param where Optional additional `WHERE` clause (without the `WHERE` keyword).
#' @param exclude_empty_geom Logical; if `TRUE` (default) adds `NOT ST_IsEmpty(<geom>)` to the `WHERE` clause.
#'
#' @returns A single character string containing the SQL statement.
#'
#' @export
schema_spec_sql <- function(spec, layer, where = NULL, exclude_empty_geom = TRUE) {
  kept <- schema_spec_kept(spec)

  geom_src <- kept$source_name[kept$role == "geometry"]

  exprs <- purrr::pmap_chr(
    list(kept$role, kept$source_name, kept$target_name, kept$target_type),
    function(role, source_name, target_name, target_type) {
      switch(
        role,
        fid = sprintf("CAST(%s AS INTEGER) AS %s", source_name, target_name),
        geometry = sprintf("%s AS %s", source_name, target_name),
        sprintf(
          "CAST(%s AS %s) AS %s",
          source_name,
          gdal_vector_type_lookup(target_type, to = "sql_type", fallback = "TEXT"),
          target_name
        )
      )
    }
  )

  select_clause <- paste0("SELECT\n  ", paste(exprs, collapse = ",\n  "))
  from_clause <- paste0("FROM ", layer)

  conds <- c(
    if (isTRUE(exclude_empty_geom) && length(geom_src)) sprintf("NOT ST_IsEmpty(%s)", geom_src[[1]]),
    where
  )
  where_clause <- if (length(conds)) paste0("WHERE ", paste(conds, collapse = " AND ")) else NULL

  paste(c(select_clause, from_clause, where_clause), collapse = "\n")
}

#' Emit `set-field-type` Pipeline Steps from a Schema Spec
#'
#' @description
#' Builds the flat character vector of `! set-field-type --field-name <f> --field-type <t>` steps used to pin
#' field types before a (Geo)Parquet write. This is necessary because a `CAST` in SQL is not honored on output for
#' (Geo)Parquet: an all-`NULL` column in a filtered slice is inferred as `String`, and populated integers come back
#' as 32-bit `Integer`.
#'
#' @param spec A [gdal_vector_schema_spec()].
#' @param policy Which fields receive an explicit step:
#'   \describe{
#'     \item{`"nonstring_keys"`}{(default) non-`String` fields plus any `force_keys`.}
#'     \item{`"all_nonstring"`}{all non-`String` fields.}
#'     \item{`"all"`}{every kept attribute/FID field.}
#'     \item{`"retyped"`}{only fields whose `target_type` differs from `source_type`.}
#'   }
#' @param force_keys Character vector of target field names to always include (used by the `"nonstring_keys"`
#'   policy, e.g. FIPS/`geoid` string keys that must be pinned as `String`).
#'
#' @returns A flat character vector of pipeline arguments (empty if nothing qualifies).
#'
#' @export
schema_spec_set_field_type_args <- function(
  spec,
  policy = c("nonstring_keys", "all_nonstring", "all", "retyped"),
  force_keys = character()
) {
  policy <- rlang::arg_match(policy)
  kept <- schema_spec_kept(spec, roles = c("fid", "attribute"))

  keep_row <- switch(
    policy,
    nonstring_keys = kept$target_type != "String" | kept$target_name %in% force_keys,
    all_nonstring = kept$target_type != "String",
    all = rep(TRUE, nrow(kept)),
    retyped = kept$target_type != kept$source_type
  )

  sel <- kept[keep_row, , drop = FALSE]
  if (nrow(sel) == 0L) {
    return(character())
  }

  purrr::map2(
    sel$target_name,
    sel$target_type,
    \(field, type) c("!", "set-field-type", "--field-name", field, "--field-type", type)
  ) |>
    purrr::reduce(c)
}

#' Emit the `set-geom-type` Pipeline Step from a Schema Spec
#'
#' @param spec A [gdal_vector_schema_spec()].
#' @param multi Logical; add `--multi` to promote to the multi-part geometry type. Defaults to `TRUE`.
#' @param skip Logical; add `--skip` to skip features that cannot be converted. Defaults to `TRUE`.
#'
#' @returns A flat character vector of pipeline arguments (empty if no geometry is kept).
#'
#' @export
schema_spec_set_geom_type_args <- function(spec, multi = TRUE, skip = TRUE) {
  has_geom <- any(spec$keep %in% TRUE & spec$role == "geometry")
  if (!has_geom) {
    return(character())
  }
  c("!", "set-geom-type", if (isTRUE(multi)) "--multi", if (isTRUE(skip)) "--skip")
}

#' Emit the Arrow/Parquet Type Map from a Schema Spec
#'
#' @description
#' Returns the target field names mapped to their Arrow/Parquet logical types (see [gdal_vector_type_map()]), useful
#' for validating a written Parquet schema or constructing an Arrow schema. The geometry field maps to `"wkb"`.
#'
#' @param spec A [gdal_vector_schema_spec()].
#'
#' @returns A named character vector (`target_name` -> `arrow_type`).
#'
#' @export
schema_spec_arrow <- function(spec) {
  kept <- schema_spec_kept(spec)
  arrow <- gdal_vector_type_lookup(kept$target_type, to = "arrow_type")
  arrow[kept$role == "geometry"] <- "wkb"
  rlang::set_names(arrow, kept$target_name)
}

# plan & pipeline -------------------------------------------------------------------------------------------------

#' Plan the Schema Transformation from a Spec
#'
#' @description
#' Inspects the diff between the source and target columns of a [gdal_vector_schema_spec()] and reports which
#' transformation kinds are present and the resulting pipeline `method`:
#'
#' - `"sql"`: required when any field is renamed, the synthetic FID is kept, or a `where`/empty-geometry filter must
#'   ride along with the projection.
#' - `"select"`: when fields are only being subset (dropped) - emits `select --fields`.
#' - `"none"`: a pure pass-through (all fields kept, no rename).
#'
#' Type changes are handled by `set-field-type` regardless of method, so they do not by themselves force SQL.
#'
#' @param spec A [gdal_vector_schema_spec()].
#' @param where,exclude_empty_geom See [schema_spec_sql()]. A non-`NULL` `where` (or `exclude_empty_geom = TRUE` with
#'   a geometry present) forces the `"sql"` method.
#'
#' @returns A list with logical flags (`rename`, `retype`, `drop`, `fid`, `filter`) and the chosen `method`.
#'
#' @export
schema_spec_plan <- function(spec, where = NULL, exclude_empty_geom = TRUE) {
  kept <- schema_spec_kept(spec)
  attrs <- kept[kept$role %in% c("fid", "attribute"), , drop = FALSE]

  has_fid <- any(kept$role == "fid")
  has_rename <- any(kept$target_name != kept$source_name)
  has_retype <- any(attrs$target_type != attrs$source_type)
  has_drop <- any(!(spec$keep %in% TRUE))
  has_geom <- any(kept$role == "geometry")
  has_filter <- !is.null(where) || (isTRUE(exclude_empty_geom) && has_geom)

  method <- if (has_fid || has_rename || has_filter) {
    "sql"
  } else if (has_drop) {
    "select"
  } else {
    "none"
  }

  list(
    rename = has_rename,
    retype = has_retype,
    drop = has_drop,
    fid = has_fid,
    filter = has_filter,
    method = method
  )
}

#' Emit the Schema Pipeline Steps from a Spec
#'
#' @description
#' The top-level decision engine. Given a (possibly edited) [gdal_vector_schema_spec()], it emits the minimal set of
#' `gdal vector pipeline` steps required to realize the target schema, ready to be spliced between a `read` and a
#' `write` step (each step is prefixed with the `!` connector). The emitted steps, in order, are:
#'
#' 1. Either `select --fields ...` (subset only) or `sql --sql ... --dialect ...` (rename / FID / filter), per
#'    [schema_spec_plan()]. For the `select` path a separate `filter --where ...` step is emitted first when a
#'    filter is needed.
#' 2. `make-valid` (optional, off by default).
#' 3. `set-geom-type --multi --skip` when a geometry is kept.
#' 4. `set-field-type` steps to pin output types (see [schema_spec_set_field_type_args()]).
#'
#' @param spec A [gdal_vector_schema_spec()].
#' @param layer The source layer name (for the SQL `FROM` clause and `select`).
#' @param where,exclude_empty_geom See [schema_spec_sql()].
#' @param dialect The SQL dialect for the `sql` step. Defaults to `"SQLITE"`.
#' @param make_valid Logical; insert a `make-valid` step after the projection. Defaults to `FALSE`.
#' @param set_field_type_policy,force_keys See [schema_spec_set_field_type_args()].
#' @param multi,skip See [schema_spec_set_geom_type_args()].
#'
#' @returns A flat character vector of pipeline arguments.
#'
#' @export
#'
#' @examples
#' \dontrun{
#' spec <- gdal_vector_schema_spec(dsn)
#' # ... edit target_name / target_type / keep ...
#' args <- gdal_vector_schema_pipeline_args(
#'   spec,
#'   layer = gpkg_layer,
#'   force_keys = c("geoid", "state_fips", "county_fips")
#' )
#' gdalraster::gdal_run("vector pipeline", args = c("read", "--input", dsn, args, "write", "--output", out))
#' }
gdal_vector_schema_pipeline_args <- function(
  spec,
  layer,
  where = NULL,
  exclude_empty_geom = TRUE,
  dialect = "SQLITE",
  make_valid = FALSE,
  set_field_type_policy = c("nonstring_keys", "all_nonstring", "all", "retyped"),
  force_keys = character(),
  multi = TRUE,
  skip = TRUE
) {
  set_field_type_policy <- rlang::arg_match(set_field_type_policy)
  plan <- schema_spec_plan(spec, where = where, exclude_empty_geom = exclude_empty_geom)

  projection <- switch(
    plan$method,
    sql = c(
      "!",
      "sql",
      "--sql",
      schema_spec_sql(spec, layer = layer, where = where, exclude_empty_geom = exclude_empty_geom),
      "--dialect",
      dialect
    ),
    select = {
      filter_step <- if (isTRUE(plan$filter)) {
        conds <- c(
          if (isTRUE(exclude_empty_geom)) {
            geom_src <- spec$source_name[spec$role == "geometry"]
            if (length(geom_src)) sprintf("NOT ST_IsEmpty(%s)", geom_src[[1]])
          },
          where
        )
        if (length(conds)) c("!", "filter", "--where", paste(conds, collapse = " AND "))
      }
      c(filter_step, "!", "select", "--fields", schema_spec_select_fields(spec))
    },
    none = character()
  )

  c(
    projection,
    if (isTRUE(make_valid)) c("!", "make-valid"),
    schema_spec_set_geom_type_args(spec, multi = multi, skip = skip),
    schema_spec_set_field_type_args(spec, policy = set_field_type_policy, force_keys = force_keys)
  )
}
