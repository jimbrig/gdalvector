# Parse XML for GDAL Options

Parses the XML from GDAL driver metadata into structured `tbl_df`
tibbles.

The function is meant to be flexible enough to be able to parse any of
the possible XML metadata structures from GDAL's registered (vector)
driver's metadata: `DMD_OPENOPTIONLIST`, `DMD_CREATIONOPTIONLIST`, and
`DS_LAYER_CREATIONOPTIONLIST`.

## Usage

``` r
xml_parse_gdal_options(
  xml,
  driver = NA_character_,
  type = c("config", "open", "creation"),
  sub_type = NA_character_,
  scope = c("vector", "raster", "all"),
  call = rlang::caller_env()
)
```

## Arguments

- xml:

  The XML to be parsed. Must be either a valid XML character string or
  an `xml2::xml_document` object.

- driver:

  (Optional) GDAL driver name added to the resulting
  [`tibble::tibble()`](https://tibble.tidyverse.org/reference/tibble.html).
  Useful for when merging options across multiple drivers. Defaults to
  `NA` and is not validated against the registered GDAL drivers, so it
  should be used with caution and primarily for internal use.

- type:

  The option type being parsed, one of `"config"`, `"open"`, or
  `"creation"`.

- sub_type:

  For `type = "creation"`, the creation option level, one of `"dataset"`
  or `"layer"`. Ignored (forced to `NA`) for other types.

- scope:

  (Optional) The scope of the options being parsed in terms of the
  supported data types, i.e. `vector` vs. `raster` or both. For example,
  `GPKG` has `scope`s defined for `"vector"`, `"raster"`,
  `"raster,vector"`, and `NA`. Use this argument to filter out for only
  the options for a specific scope. Will always include the `NA` scoped
  options, as those are not explicitly defined for a specific scope and
  are likely applicable to all scopes. Defaults to `NULL` and will not
  filter for any specific scope, returning all options regardless of
  scope. Provided value must be one of `"vector"`, `"raster"`, or
  `"all"` if not `NULL`. Note that the scope values are not standardized
  across all GDAL drivers, so use with caution and always check the
  resulting tibbles for the expected scope values when working with
  drivers supporting both raster and vector data.

- call:

  The calling function, used for error handling and messaging.

## Value

[`tibble::tibble()`](https://tibble.tidyverse.org/reference/tibble.html)
with fields for `name`, `description`, `scope`, `type`, `default`, and
`values` (a list-column with a character vector for the possible
values).

Additional fields for `driver` and `opt_type` may be included if those
parameters are provided.

## Examples

``` r
# parse DS_LAYER_CREATIONOPTIONLIST
gdalraster::gdal_get_driver_md("GPKG", mdi_name = "DS_LAYER_CREATIONOPTIONLIST") |>
  xml_parse_gdal_options()
#> # A tibble: 11 × 9
#>    driver type   sub_type name        description scope default values data_type
#>    <chr>  <chr>  <chr>    <chr>       <chr>       <chr> <chr>   <list> <chr>    
#>  1 NA     config NA       GEOMETRY_N… Name of ge… all   geom    <chr>  string   
#>  2 NA     config NA       GEOMETRY_N… Whether th… all   YES     <chr>  boolean  
#>  3 NA     config NA       FID         Name of th… all   fid     <chr>  string   
#>  4 NA     config NA       OVERWRITE   Whether to… all   NO      <chr>  boolean  
#>  5 NA     config NA       PRECISION   Whether te… all   YES     <chr>  boolean  
#>  6 NA     config NA       TRUNCATE_F… Whether to… all   NO      <chr>  boolean  
#>  7 NA     config NA       SPATIAL_IN… Whether to… all   YES     <chr>  boolean  
#>  8 NA     config NA       IDENTIFIER  Identifier… all   NA      <chr>  string   
#>  9 NA     config NA       DESCRIPTION Descriptio… all   NA      <chr>  string   
#> 10 NA     config NA       ASPATIAL_V… How to reg… all   GPKG_A… <chr>  string-s…
#> 11 NA     config NA       DATETIME_P… Number of … all   AUTO    <chr>  string-s…

# parse DMD_CREATIONOPTIONLIST
gdalraster::gdal_get_driver_md("GPKG", mdi_name = "DMD_CREATIONOPTIONLIST") |>
  xml_parse_gdal_options()
#> # A tibble: 5 × 9
#>   driver type   sub_type name         description scope default values data_type
#>   <chr>  <chr>  <chr>    <chr>        <chr>       <chr> <chr>   <list> <chr>    
#> 1 NA     config NA       VERSION      Set GeoPac… all   AUTO    <chr>  string-s…
#> 2 NA     config NA       DATETIME_FO… How to enc… all   WITH_TZ <chr>  string-s…
#> 3 NA     config NA       ADD_GPKG_OG… Whether to… all   YES     <chr>  boolean  
#> 4 NA     config NA       CRS_WKT_EXT… Whether to… all   NA      <chr>  boolean  
#> 5 NA     config NA       METADATA_TA… Whether to… all   NA      <chr>  boolean  

# parse DMD_OPENOPTIONLIST
gdalraster::gdal_get_driver_md("GPKG", mdi_name = "DMD_OPENOPTIONLIST") |>
  xml_parse_gdal_options()
#> # A tibble: 4 × 9
#>   driver type   sub_type name         description scope default values data_type
#>   <chr>  <chr>  <chr>    <chr>        <chr>       <chr> <chr>   <list> <chr>    
#> 1 NA     config NA       LIST_ALL_TA… Whether al… vect… AUTO    <chr>  string-s…
#> 2 NA     config NA       PRELUDE_STA… SQL statem… rast… NA      <chr>  string   
#> 3 NA     config NA       NOLOCK       Whether th… all   NA      <chr>  boolean  
#> 4 NA     config NA       IMMUTABLE    Whether th… all   NA      <chr>  boolean  
```
