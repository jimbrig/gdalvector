# Build a SQL `IN` Clause

Constructs a SQL `IN` or `NOT IN` clause for a given field and set of
values.

## Usage

``` r
sql_in(field, values, negate = FALSE)
```

## Arguments

- field:

  Character. The column name.

- values:

  Values to include in the clause.

- negate:

  Logical. If `TRUE`, use `NOT IN`. Default is `FALSE`.

## Value

A character string containing the SQL clause.

## Examples

``` r
non_conus_state_fips <- c("02", "15", "60", "66", "69", "72", "74", "78")
sql_in(field = "STATEFP", values = non_conus_state_fips, negate = TRUE)
#> Error in sql_in(field = "STATEFP", values = non_conus_state_fips, negate = TRUE): could not find function "sql_in"
```
