

## `gdal_opts.R`

`gdal_opts.R` manages the generic classes for all GDAL option variants using the following core classes:

-   `gdal_opts`
    -   `gdal_config_opts(..., driver = NULL)`: These represent “configuration”options, which are related to but not the same as the global runtime session configuration managed through the `gdal_config` abstractions. Particularly, when there are certain “config”options that are more or less specific to a driver/format and how to work with it. For example, the there are dedicated [Configuration Options for the ESRI Shapefile Driver](https://gdal.org/en/stable/drivers/vector/shapefile.html#configuration-options) that are still managed through the `–config` `CPLSetConfigOption()` C API. Driver specific modules will also maintain their own, more explicit, function signatures to provide an interface for managing these options, i.e. `shp_config_otps(shape_rewind_on_write, shape_restore_shx, shape_2gb_limit, shape_encoding)`, `gpkg_config_opts(...)`, etc.
    -   `gdal_open_opts(..., driver = NULL)`: These are a separate, per-dataset/layer open options are are specific to respective drivers only, i.e. the `GDALOpenEx()` C API. Similarly, these will also provide the layer that driver-specific modules will provide more explicit interfaces through, i.e. `shp_open_opts(...)`, `gpkg_open_opts(...)`, etc.
    -   `gdal_creation_opts(..., driver = NULL)`: Creation options are technically distinct in the underlying GDAL APIs between  `--creation-option`/`--co`, `dataset-creation-option`/`--dco` and `--layer-creation-option`/`--lco` options, however, we collapse these into a single class that includes an attribute specifying the scope of the creation option being defined, i.e. `new_gdal_creation_option()`



## GDAL Options

`gdal_opts(...)`

`new_gdal_opts(..., type = c("config", "open", "creation"), driver = NULL, scope = c("driver", "dataset", "layer"))`

## GDAL Drivers

-   Get Driver Metadata: calls `gdalraster::gdal_get_driver_md()` but parses the results.
    -   `DCAP_`: Driver Capability
    -   `DMD_`: Driver Metadata
        -   `DS_LAYER_CREATIONOPTIONLIST`