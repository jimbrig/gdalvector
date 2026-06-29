# Perform a `HEAD` HTTP Request for a Remote URL

Sends a `HEAD` request to the specified URL and retrieves the response
headers.

This function is useful for checking the existence of a resource or
retrieving metadata without downloading the entire content.

## Usage

``` r
remote_head(url)
```

## Arguments

- url:

  Character string specifying the URL to send the `HEAD` request to.

## Value

A list containing:

- `request`: The
  [`httr2::request()`](https://httr2.r-lib.org/reference/request.html)

- `response`: The
  [`httr2::response()`](https://httr2.r-lib.org/reference/response.html)

- `headers`: The
  [`httr2::resp_headers()`](https://httr2.r-lib.org/reference/resp_headers.html)
  from the response

## Examples

``` r
if (FALSE) { # \dontrun{
url <- "https://www2.census.gov/geo/tiger/GENZ2024/shp/cb_2024_us_state_20m.zip"
head_info <- remote_head(url)
print(head_info$headers)
} # }
```
