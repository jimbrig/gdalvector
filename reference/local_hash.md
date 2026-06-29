# Get the Hash of a Local File

Retrieves the hash of a local file from its path.

## Usage

``` r
local_hash(path, algo = "md5")
```

## Arguments

- path:

  Character string specifying the path to the local file.

- algo:

  Character string specifying hash algorithm ("md5", "sha1", "sha256",
  "sha512").

## Value

A character string representing the hash of the local file.

## Examples

``` r
if (FALSE) { # \dontrun{
path <- "data-raw/cache/tiger/GENZ2024/shp/cb_2024_us_state_20m.zip"
local_hash(path)
} # }
```
