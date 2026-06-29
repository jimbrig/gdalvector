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

- driver, opt_type:

  (Optional) Additional values that can be added to the resulting
  [`tibble::tibble()`](https://tibble.tidyverse.org/reference/tibble.html).
  Useful for when merging options across multiple drivers or option
  types. Defaults to `NULL` and the columns will only be included in the
  output when provided. These values are also not properly validated
  against the GDAL drivers or option types, so they should be used with
  caution and primarily for internal use.

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
#> Error: `driver` must be a string, not a character `NA`.

# parse DMD_CREATIONOPTIONLIST
gdalraster::gdal_get_driver_md("GPKG", mdi_name = "DMD_CREATIONOPTIONLIST") |>
  xml_parse_gdal_options()
#> Error: `driver` must be a string, not a character `NA`.

# parse DMD_OPENOPTIONLIST
gdalraster::gdal_get_driver_md("GPKG", mdi_name = "DMD_OPENOPTIONLIST") |>
  xml_parse_gdal_options()
#> Error: `driver` must be a string, not a character `NA`.
```
