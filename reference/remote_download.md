# Remote File Download with Change Detection

Downloads a remote file only if it has changed since the cached version.
Uses HTTP Last-Modified header when available (fast), falls back to hash
comparison for legacy servers.

## Usage

``` r
remote_download(
  url,
  destfile,
  extract = FALSE,
  timeout = 600L,
  max_tries = 3L,
  force = FALSE,
  algo = "md5"
)
```

## Arguments

- url:

  Character string specifying the URL of the remote file.

- destfile:

  Character string specifying the destination path.

- extract:

  Logical; if `TRUE` and the file is a ZIP, extracts it after download.

- timeout:

  Numeric value specifying HTTP request timeout in seconds. Defaults to
  `600L`.

- max_tries:

  Integer; maximum number of download attempts on failure. Defaults to
  `3L`.

- force:

  Logical; if `TRUE`, always download regardless of cache state.

- algo:

  Character string specifying hash algorithm ("md5", "sha1", "sha256",
  "sha512"). Only used as fallback if Last-Modified header unavailable.

## Value

Invisibly returns the path to the downloaded file.
