# Get the Size of a Remote File from its URL

Retrieves the size of a remote file by sending a `HEAD` request to the
specified URL and extracting the `Content-Length` header.

## Usage

``` r
remote_size(url)
```

## Arguments

- url:

  Character string specifying the URL of the remote file.

## Value

A numeric value representing the size of the remote file in bytes.

## Examples

``` r
if (FALSE) { # \dontrun{
url <- "https://www2.census.gov/geo/tiger/GENZ2024/shp/cb_2024_us_state_20m.zip"
remote_size(url)
} # }
```
