# Check if a Remote File Exists at a Given URL

Determines whether a remote file exists by sending a `HEAD` request to
the specified URL and checking the HTTP status code.

## Usage

``` r
remote_exists(url)
```

## Arguments

- url:

  Character string specifying the URL of the remote file.

## Value

A logical value: `TRUE` if the remote file exists (HTTP status 200),
`FALSE` otherwise.

## Examples

``` r
if (FALSE) { # \dontrun{
url <- "https://www2.census.gov/geo/tiger/GENZ2024/shp/cb_2024_us_state_20m.zip"
remote_exists(url)
} # }
```
