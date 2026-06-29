# `gdalvector` Conventions

## File Naming

### Core `R/*.R` Package Files

Core `R/*.R` package files:

- `R/aaa.R`:
- `R/zzz.R`:
- `R/gdalvector-package.R`:
- `R/gdalvector-conditions.R`:
- `R/gdalvector-options.R`:

and also:

- `R/sysdata.rda`:

### Core `GDAL` Vector Modules

Core `GDAL` abstractions (`R/gdal_*.R`):

- `R/gdal_sitrep.R`:
- `R/gdal_config.R`:
- `R/gdal_options.R`:
- `R/gdal_drivers.R`:
- `R/gdal_vsi.R`:
- `R/gdal_vector.R`:
- `R/gdal_pipeline.R`:
- `R/gdal_gdalg.R`:

### Driver-Specific Modules

Core modules for each of the primary supported GDAL vector driver formats.

GeoPackage (`"GPKG"` and `"SQLite"`) (`R/gpkg_*.R`):

- `R/gpkg_options.R`:
- `R/gpkg_pragmas.R`:
- `R/gpkg_connect.R`:
- `R/gpkg_validate.R`:

FGB (`"FlatGeobuf"`) (`R/fgb_*.R`):

- `R/fgb_options.R`:
- `R/fgb_validate.R`:

(Geo)Parquet (`"Parquet"` and `"Arrow"`) (`R/gpq_*.R`):

- `R/gpq_options.R`:
- `R/gpq_validate.R`:

Shapefiles (`"ESRI Shapefile"`):
