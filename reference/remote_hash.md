# Get the Hash of a Remote File from its URL

Retrieves the hash of a remote file from its URL.

## Usage

``` r
remote_hash(url, algo = "md5")
```

## Arguments

- url:

  Character string specifying the URL of the remote file.

- algo:

  Character string specifying hash algorithm ("md5", "sha1", "sha256",
  "sha512").

## Value

A character string representing the hash of the remote file.

## Examples

``` r
if (FALSE) { # \dontrun{
url <- "https://www2.census.gov/geo/tiger/GENZ2024/shp/cb_2024_us_state_20m.zip"
remote_hash(url)
} # }
```
