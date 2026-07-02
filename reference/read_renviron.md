# Read `.Renviron` File

Simple wrapper around
[`base::readRenviron()`](https://rdrr.io/r/base/readRenviron.html) to
read a `.Renviron` file from a specified path. If no path is provided,
it defaults to the current working directory.

## Usage

``` r
read_renviron(path = NULL)
```

## Arguments

- path:

  The directory path where the `.Renviron` file is located. If `NULL`,
  defaults to the current working directory.

## Value

Invisibly returns `NULL`. The function is called for its side effect of
loading environment variables into the R session.
