# Read File Magic Header Bytes

Reads the first `n` bytes of a file and returns the raw bytes and their
string representation.

## Usage

``` r
read_magic_header(path, n = 4L, ...)
```

## Arguments

- path:

  Character. Path to the file.

- n:

  Integer. Number of bytes to read. Default is `4L`.

- ...:

  Additional arguments passed to
  [`readBin()`](https://rdrr.io/r/base/readBin.html).

## Value

A `magic_header` list containing `path`, `raw`, and `str` elements.

## Examples

``` r
read_magic_header(pkg_sys_extdata("gpkg/cb_2025_us_all_20m.gpkg"), n = 15L)
#> Error in read_magic_header(pkg_sys_extdata("gpkg/cb_2025_us_all_20m.gpkg"),     n = 15L): could not find function "read_magic_header"
```
