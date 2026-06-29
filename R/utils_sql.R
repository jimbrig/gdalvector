#  ------------------------------------------------------------------------
#
# Title : SQL Utilities
#    By : Jimmy Briggs
#  Date : 2026-06-17
#
#  ------------------------------------------------------------------------

sql_has_spatial_index <- function(layer, geom_col, as = NULL) {
  hold <- glue::glue("SELECT HasSpatialIndex('{layer}', '{geom_col}')")
  if (!is.null(as)) {
    return(paste0(hold, " AS ", as))
  }
  hold
}

#' SQL Pragma Builder
#'
#' @description
#' Constructs a SQL `PRAGMA` statement for a given name and optional value.
#'
#' @param name The pragma name.
#' @param value Optional pragma value. When supplied, builds a `PRAGMA name = value` assignment.
#'
#' @keywords internal
#' @noRd
sql_pragma <- function(name, value = NULL) {
  hold <- glue::glue("PRAGMA {name}")
  if (!is.null(value)) {
    return(paste0(hold, " = ", value))
  }
  hold
}

#' Build a SQL `IN` Clause
#'
#' @description
#' Constructs a SQL `IN` or `NOT IN` clause for a given field and set of values.
#'
#' @param field Character. The column name.
#' @param values Values to include in the clause.
#' @param negate Logical. If `TRUE`, use `NOT IN`. Default is `FALSE`.
#'
#' @returns
#' A character string containing the SQL clause.
#'
#' @keywords internal
#'
#' @examples
#' \dontrun{
#' non_conus_state_fips <- c("02", "15", "60", "66", "69", "72", "74", "78")
#' sql_in(field = "STATEFP", values = non_conus_state_fips, negate = TRUE)
#' }
sql_in <- function(field, values, negate = FALSE) {
  check_string(field)
  values <- as.character(values)
  if (!length(values)) {
    return(NULL)
  }
  vals <- glue::glue_sql_collapse(values)

  values <- gsub("'", "''", values, fixed = TRUE)
  quoted <- paste0("'", values, "'", collapse = ", ")
  stmnt <- if (negate) " NOT IN (" else " IN ("
  paste0(field, stmnt, quoted, ")")
}

#' Build a SQL `ST_IsValid` WHERE Clause
#'
#' @description
#' Constructs a SQL `ST_IsValid()` expression for filtering geometries.
#'
#' @param geom_col Character. The name of the geometry column.
#' @param negate Logical. If `TRUE`, filters for *invalid* geometries. Default is `FALSE`.
#'
#' @returns
#' A character string containing the SQL expression.
#'
#' @export
#'
#' @examples
#' sql_where_valid_geom("geom")
#' sql_where_valid_geom("geom", negate = TRUE)
sql_where_valid_geom <- function(geom_col, negate = FALSE) {
  hold <- glue::glue("ST_IsValid({geom_col})")
  if (negate) {
    return(paste0("NOT ", hold))
  }
  hold
}
