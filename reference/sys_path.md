# `sys_path` - System PATH

Get the Current Machine's PATH Environment Variable as a Character
Vector

## Usage

``` r
sys_path(filter = NULL)
```

## Arguments

- filter:

  Optional character string. If provided, only paths containing this
  string will be returned.

## Value

Character vector of paths from the system's `PATH` environment variable,
split by the appropriate path separator for the operating system. If
`filter` is provided, only paths containing the filter string are
included in the returned vector. If no paths match the filter, an empty
character vector is returned: `character(0)`.

If `filter` is provided, only paths containing the filter string are
returned.

## Examples

``` r
if (FALSE) { # \dontrun{
sys_path()
} # }
```
