# `sys_os` - System OS Name

Get the current machine's operating system name.

## Usage

``` r
sys_os()
```

## Value

Character string resulting from `Sys.info()[["sysname"]]`, which will be
one of c("windows", "linux", "darwin", etc.) depending on the system.

## Examples

``` r
if (FALSE) { # \dontrun{
sys_os()
} # }
```
