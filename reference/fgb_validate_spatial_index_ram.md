# Validate Spatial Index RAM Requirement

Validates if the available RAM is sufficient to build a spatial index
for a FlatGeobuf file based on the number of features and an estimated
RAM requirement of 83 bytes per feature.

## Usage

``` r
fgb_validate_spatial_index_ram(fgb_dsn, force = FALSE, quiet = FALSE)
```

## Arguments

- fgb_dsn:

  The data source name (DSN) of the FlatGeobuf file to validate.

- force:

  Logical indicating whether to force the feature count (default:
  `FALSE`).

- quiet:

  Logical indicating whether to suppress success messages (default:
  `FALSE`).

## Value

Returns `TRUE` if sufficient RAM is available to build the spatial
index, and `FALSE` otherwise. Also provides informative messages about
the RAM requirements and availability.
