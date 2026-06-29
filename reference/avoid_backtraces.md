# Avoid backtraces in examples

This example should run first and set an option for the process that
builds the example. By default, pkgdown builds examples in a separate
process.

This also produces a help page that is not linked from anywhere.

## Examples

``` r
options(rlang_backtrace_on_error = "none")
```
