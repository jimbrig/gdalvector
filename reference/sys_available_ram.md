# `sys_available_ram` - System Available RAM

Get the amount of usable physical RAM available to the R session using
[`gdalraster::get_usable_physical_ram()`](https://firelab.github.io/gdalraster/reference/get_usable_physical_ram.html),
which calls the `CPLGetUsablePhysicalRAM()` C++ function from GDAL's
Common Portable Library (CPL).

## Usage

``` r
sys_available_ram()
```

## Value

A numeric scalar representing the number of bytes as a
[`bit64::integer64()`](https://bit64.r-lib.org/reference/bit64-package.html)
type (or zero `0` in case of failure).

## Details

This function returns the total *physical RAM usable by a process, in
bytes*.

It will be limited to **2GB** for 32-bit processes.

It takes into account resource limits (virtual memory) of POSIX systems.
It additionally will take into account `RLIMIT_RSS` on Linux.

On Windows, it will return the total physical RAM minus the memory used
by the system and other processes, as reported by the Windows API, in
bytes.

## FlatGeobuf Spatial Index RAM Check

This memory may already be partly accounted for by other processes, but
is still useful for estimating how much RAM is available for processing
large vector data without causing out-of-memory errors.

It is used by the
[`check_available_ram()`](http://docs.jimbrig.com/gdalvector/reference/check_available_ram.md)
check utility which is used in
[`fgb_validate_spatial_index_ram()`](http://docs.jimbrig.com/gdalvector/reference/fgb_validate_spatial_index_ram.md)
to ensure that there is sufficient RAM to build a spatial index for a
given dataset:

"The creation of the packet Hilbert R-Tree requires an amount of RAM
which is at least the number of features times 83 bytes."

## Examples

``` r
if (FALSE) { # \dontrun{
sys_available_ram()
} # }
```
