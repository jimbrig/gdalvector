# GDAL VSI Options

Construct a `gdal_vsi_opts()` object from `NAME = value` pairs,
optionally scoped to a `vsi_path`. These are config-like options for
GDAL virtual file systems (e.g. cloud storage credentials and HTTP
tuning) and render as `--config NAME=VALUE`.

## Usage

``` r
gdal_vsi_opts(..., vsi_path = NULL)
```

## Arguments

- ...:

  Named VSI options (`NAME = value`).

- vsi_path:

  Optional VSI path prefix (e.g. `"/vsis3/bucket"`).

## Value

A `gdal_vsi_opts()` object.

## Examples

``` r
gdal_vsi_opts(AWS_REGION = "us-east-1", vsi_path = "/vsis3/my-bucket")
#> <gdal_vsi_opts/gdal_opts>
#> ℹ VSI Options: AWS_REGION=us-east-1
#> ℹ Command Line: --config 'AWS_REGION=us-east-1'
```
