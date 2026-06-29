# Parse GDAL Driver Configuration Options from XML

Parses the configuration options for a GDAL driver from the provided XML
document. This function is specifically designed to extract the
configuration options listed in the "Configuration Options" section of a
GDAL driver's documentation page, which is typically structured as an
unordered list (`<ul>`) with list items (`<li>`) containing the option
details.

The function looks for the first `<ul>` element within the section with
`id="configuration-options"` and extracts the option name, description,
default value, and possible values (if specified in brackets). The
resulting data is returned as a tibble with columns for `name`,
`description`, `scope`, `default`, and `values` (a list-column
containing character vectors of possible values).

## Usage

``` r
xml_parse_gdal_driver_config_opts(
  xml,
  scope = "all",
  driver = NULL,
  type = "config",
  call = rlang::caller_env()
)
```

## Arguments

- xml:

  The XML document to parse, typically obtained from a GDAL driver's
  documentation page.

- scope:

  The scope of the options being parsed, such as "vector", "raster", or
  "all". This is used to categorize the options based on their
  applicability to different data types. Defaults to "all".

- driver:

  The name of the GDAL driver for which the options are being parsed.
  This is used for labeling purposes in the resulting tibble. Defaults
  to `NULL`.

- call:

  The calling function, used for error handling and messaging.

- opt_type:

  The type of options being parsed, such as "config", "open", or
  "creation". This is used for labeling purposes in the resulting
  tibble. Defaults to "config".

## Value

A tibble with columns for `name`, `description`, `scope`, `default`, and
`values`
