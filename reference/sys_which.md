# `sys_which` - System `which`

Lightweight, convenience wrapper around
[`base::Sys.which()`](https://rdrr.io/r/base/Sys.which.html) and
[`base::normalizePath()`](https://rdrr.io/r/base/normalizePath.html).

## Usage

``` r
sys_which(x, winslash = "/", ...)
```

## Arguments

- x:

  Passed to [`Sys.which()`](https://rdrr.io/r/base/Sys.which.html)
  `names` argument.

- winslash:

  the separator to be used on Windows – ignored elsewhere. Must be one
  of `c("/", "\\")`.

- ...:

  Arguments passed on to
  [`base::normalizePath`](https://rdrr.io/r/base/normalizePath.html)

  `path`

  :   character vector of file paths.

  `mustWork`

  :   logical: if `TRUE` then an error is given if the result cannot be
      determined; if `NA` then a warning.

## Value

Character vector of paths, if found. If not found returns `NULL` instead
of `""`.

## Examples

``` r
if (FALSE) { # \dontrun{
sys_which("gdal")
} # }
```
