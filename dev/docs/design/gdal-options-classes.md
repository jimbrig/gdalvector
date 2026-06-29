# GDAL Options Classes

> [!NOTE]
> *This document provides an overview of the S3 classes used to abstract the underlying GDAL/OGR option systems and variants in `gdalvector`.*

## Overview

GDAL exposes several distinct option channels. `gdalvector` models each as its own S3 subclass of a root, generic `gdal_opts`
class (a simple key-value list emulating the `--config` `"KEY=VALUE"` semantics but as R an named list with attributes).

The primary option sub-classes are:

- `gdal_config_opts`: for GDAL global configuration options that follow the `--config "KEY=VALUE"` CLI semantics and
  `CPLSetConfigOption()` GDAL C/C++ APIs or respective environment variable settings. This class is also the parent
  to any needed additional sub-classes to separate the "special" forms of configuration options: 
  `gdal_vsi_opts` and the driver-specific `gdal_config_opts(driver = <driver>)` options but also potentially others
  as needed.
  
- `gdal_open_opts`: 


- `gdal_creation_opts`: uses the `level` attribute to distinguish between `--dataset-creation-option`/`--dsco` options
  vs. `--layer-creation-option`/`--lco` options, and also has a `driver` attribute to associate the options to 
  their respective drivers. The level attribute names are `c("layer", "dataset")`.
  

## `R/gdal_options.R`

`R/gdal_options.R` defines and manages the source code behind the generic S3 classes used to abstract the underlying
GDAL option systems and variants.

- `gdal_opts`
  - `gdal_config_opts`
  - `gdal_open_opts`
  - `gdal_creation_opts`

```plaintext
<list>
  └── <gdal_opts>
        ├── gdal_open_opts
        ├── gdal_creation_opts
        └── gdal_config_opts
