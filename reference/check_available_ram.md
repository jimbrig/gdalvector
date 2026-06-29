# Check Available RAM

Checks that the provided value `x` (in bytes) does not exceed the
available system RAM as returned by
[`sys_available_ram()`](http://docs.jimbrig.com/gdalvector/reference/sys_available_ram.md).
If the check fails, an error is thrown.

## Usage

``` r
check_available_ram(x, arg = rlang::caller_arg(x), call = rlang::caller_env())
```

## Arguments

- x:

  The object to check.

- arg:

  An argument name as a string. This argument will be mentioned in error
  messages as the input that is at the origin of a problem.

- call:

  The execution environment of a currently running function, e.g.
  `caller_env()`. The function will be mentioned in error messages as
  the source of the error. See the `call` argument of
  [`abort()`](https://rlang.r-lib.org/reference/abort.html) for more
  information.

## Value

If the check passes, invisibly returns the provided `x` value. If the
check fails, a condition error is thrown indicating that the provided
value exceeds available system RAM.
