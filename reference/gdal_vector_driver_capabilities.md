# GDAL Vector Driver Capabilities

Return a driver's capability flags (the `DCAP_*` metadata items) as a
named logical vector.

## Usage

``` r
gdal_vector_driver_capabilities(driver)
```

## Arguments

- driver:

  Character scalar GDAL driver short name.

## Value

A named logical vector, one element per `DCAP_*` capability (name
without the `DCAP_` prefix retained as given by GDAL), `TRUE` where the
capability is advertised.

## See also

[`gdal_drivers()`](http://docs.jimbrig.com/gdalvector/reference/gdal_drivers.md)

## Examples

``` r
gdal_vector_driver_capabilities("GPKG")
#>                      DCAP_CREATE                  DCAP_CREATECOPY 
#>                             TRUE                             TRUE 
#>                DCAP_CREATE_FIELD                DCAP_CREATE_LAYER 
#>                             TRUE                             TRUE 
#>         DCAP_CREATE_RELATIONSHIP            DCAP_CURVE_GEOMETRIES 
#>                             TRUE                             TRUE 
#>              DCAP_DEFAULT_FIELDS                DCAP_DELETE_FIELD 
#>                             TRUE                             TRUE 
#>                DCAP_DELETE_LAYER         DCAP_DELETE_RELATIONSHIP 
#>                             TRUE                             TRUE 
#>               DCAP_FIELD_DOMAINS DCAP_FLUSHCACHE_CONSISTENT_STATE 
#>                             TRUE                             TRUE 
#>         DCAP_MEASURED_GEOMETRIES      DCAP_MULTIPLE_VECTOR_LAYERS 
#>                             TRUE                             TRUE 
#>              DCAP_NOTNULL_FIELDS          DCAP_NOTNULL_GEOMFIELDS 
#>                             TRUE                             TRUE 
#>                        DCAP_OPEN                      DCAP_RASTER 
#>                             TRUE                             TRUE 
#>               DCAP_RELATIONSHIPS               DCAP_RENAME_LAYERS 
#>                             TRUE                             TRUE 
#>              DCAP_REORDER_FIELDS               DCAP_UNIQUE_FIELDS 
#>                             TRUE                             TRUE 
#>         DCAP_UPDATE_RELATIONSHIP                      DCAP_VECTOR 
#>                             TRUE                             TRUE 
#>                   DCAP_VIRTUALIO                DCAP_Z_GEOMETRIES 
#>                             TRUE                             TRUE 
```
