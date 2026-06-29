# Strip the Outermost VSI Handler

Strip the Outermost VSI Handler

## Usage

``` r
vsi_strip(path, recurse = TRUE)
```

## Arguments

- path:

  Path to strip.

- recurse:

  Logical; if `TRUE` (default), strips all nested VSI handlers,
  otherwise only the outermost one.

## Value

Character vector with the outermost VSI handler removed.
