# Is VSI Path

Check if a Path is a GDAL Virtual File System (VSI) Path or URL.

## Usage

``` r
is_vsi_path(x)
```

## Arguments

- x:

  Character string to check.

## Value

Logical indicating if the path starts with a valid VSI prefix (i.e.
`/vsicurl/` or `/vsizip/`).

## Examples

``` r
is_vsi_path("/vsizip/data.zip")      # TRUE
#> [1] TRUE
is_vsi_path("/vsicurl/data.geojson") # TRUE
#> [1] TRUE
is_vsi_path("data.geojson")          # FALSE
#> [1] FALSE
```
