# Get Local & Remote Resources Last-Modified Timestamp

These functions derive timestamps for local and remote resources.

- `remote_last_modified()`: Parses the `Last-Modified` HTTP response
  header as the timestamp. Returns `NA` if the header is not available.

- `local_last_modified()`: Local file last modified timestamp.

## Usage

``` r
remote_last_modified(url)

local_last_modified(path)
```

## Arguments

- url:

  Character string specifying the URL of the remote file.

- path:

  Path to local file to get the last modified timestamp for.

## Value

- `remote_last_modified()`: `POSIXct` datetime representing the
  `Last-Modified` header timestamp, or `NA` if not provided by the
  server.

- `local_last_modified()`: `POSIXct` datetime of the file's last
  modification.

## Examples

``` r
if (FALSE) { # \dontrun{
url <- "https://www2.census.gov/geo/tiger/GENZ2024/shp/cb_2024_us_state_20m.zip"
remote_last_modified(url)

path <- "data-raw/cache/tiger/GENZ2024/shp/cb_2024_us_state_20m.zip"
local_last_modified(path)
} # }
```
