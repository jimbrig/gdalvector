# Build a SQL `ST_IsValid` WHERE Clause

Constructs a SQL `ST_IsValid()` expression for filtering geometries.

## Usage

``` r
sql_where_valid_geom(geom_col, negate = FALSE)
```

## Arguments

- geom_col:

  Character. The name of the geometry column.

- negate:

  Logical. If `TRUE`, filters for *invalid* geometries. Default is
  `FALSE`.

## Value

A character string containing the SQL expression.

## Examples

``` r
sql_where_valid_geom("geom")
#> ST_IsValid(geom)
sql_where_valid_geom("geom", negate = TRUE)
#> [1] "NOT ST_IsValid(geom)"
```
