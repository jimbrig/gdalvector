# `sys_error_code` - System Error Codes

Get system error codes and their descriptions. If a specific code is
provided, returns the name, value, and description for that code. If no
code is provided, returns a tibble of all system error codes.

## Usage

``` r
sys_error_code(code = NULL)
```

## Arguments

- code:

  (Optional) Integer or character string representing the system error
  code to look up. If `NULL` (the default), returns all system error
  codes. Can be one or more codes to filter by.

## Value

A
[`tibble::tibble()`](https://tibble.tidyverse.org/reference/tibble.html)
with the `name`, `value`, and `description` of the system error code(s).
If one or more codes are provided, returns only the matching code(s). If
no codes are found, returns `NULL` invisibly.

## See also

[`ps::errno()`](https://ps.r-lib.org/reference/errno.html) for the
underlying system error codes data.

## Examples

``` r
if (FALSE) { # \dontrun{
# Get all system error codes
sys_error_code()

# Get specific error code information
sys_error_code(2)  # Example: ENOENT (No such file or directory)
} # }
```
