# List files at a remote HTTP directory index

Performs a `GET` request against an Apache-style autoindex URL and
returns the relative file/directory hrefs listed on the page. Works with
Census Bureau TIGER and GENZ directory listings.

## Usage

``` r
remote_list(url, pattern = NULL, full_url = FALSE)
```

## Arguments

- url:

  Character. The directory index URL (must return `text/html`).

- pattern:

  Optional regex to filter returned hrefs (e.g. `"\\.zip$"`).

- full_url:

  Logical. If `TRUE`, returns fully-qualified URLs by joining `url` with
  each relative href. Default `FALSE`.

## Value

A character vector of relative (or absolute, if `full_url = TRUE`)
file/directory hrefs, `NA`s and navigation links excluded.
