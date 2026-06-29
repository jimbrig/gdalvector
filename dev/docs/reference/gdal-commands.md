## GDAL Commands

[TOC]

>   [!NOTE]
>   **Source:** <https://gdal.org/en/stable/programs/index.html#vector-commands>

### Vector Operations

-   [gdal vector](https://gdal.org/en/stable/programs/gdal_vector.html#gdal-vector): Entry point for vector commands
-   [gdal vector buffer](https://gdal.org/en/stable/programs/gdal_vector_buffer.html#gdal-vector-buffer): Compute a buffer around geometries of a vector dataset
-   [gdal vector check-coverage](https://gdal.org/en/stable/programs/gdal_vector_check_coverage.html#gdal-vector-check-coverage): Check a polygon coverage for validity
-   [gdal vector check-geometry](https://gdal.org/en/stable/programs/gdal_vector_check_geometry.html#gdal-vector-check-geometry): Check a dataset for invalid or non-simple geometries
-   [gdal vector clean-coverage](https://gdal.org/en/stable/programs/gdal_vector_clean_coverage.html#gdal-vector-clean-coverage): Remove gaps and overlaps in a polygon dataset
-   [gdal vector clip](https://gdal.org/en/stable/programs/gdal_vector_clip.html#gdal-vector-clip): Clip a vector dataset
-   [gdal vector combine](https://gdal.org/en/stable/programs/gdal_vector_combine.html#gdal-vector-combine): Combine geometries into collections
-   [gdal vector concat](https://gdal.org/en/stable/programs/gdal_vector_concat.html#gdal-vector-concat): Concatenate vector datasets
-   [gdal vector concave-hull](https://gdal.org/en/stable/programs/gdal_vector_concave_hull.html#gdal-vector-concave-hull): Compute the concave hull of geometries of a vector dataset
-   [gdal vector convert](https://gdal.org/en/stable/programs/gdal_vector_convert.html#gdal-vector-convert): Convert a vector dataset
-   [gdal vector convex-hull](https://gdal.org/en/stable/programs/gdal_vector_convex_hull.html#gdal-vector-convex-hull): Compute the convex hull of geometries of a vector dataset
-   [gdal vector create](https://gdal.org/en/stable/programs/gdal_vector_create.html#gdal-vector-create): Create a vector dataset
-   [gdal vector edit](https://gdal.org/en/stable/programs/gdal_vector_edit.html#gdal-vector-edit): Edit metadata of a vector dataset
-   [gdal vector explode-collections](https://gdal.org/en/stable/programs/gdal_vector_explode_collections.html#gdal-vector-explode-collections): Explode geometries of type collection of a vector dataset
-   [gdal vector export-schema](https://gdal.org/en/stable/programs/gdal_vector_export_schema.html#gdal-vector-export-schema): Export the OGR_SCHEMA from a vector dataset
-   [gdal vector filter](https://gdal.org/en/stable/programs/gdal_vector_filter.html#gdal-vector-filter): Filter a vector dataset
-   [gdal vector grid](https://gdal.org/en/stable/programs/gdal_vector_grid.html#gdal-vector-grid): Create a regular grid from scattered points
-   [gdal vector info](https://gdal.org/en/stable/programs/gdal_vector_info.html#gdal-vector-info): Get information on a vector dataset
-   [gdal vector index](https://gdal.org/en/stable/programs/gdal_vector_index.html#gdal-vector-index): Create a vector index of vector datasets
-   [gdal vector layer-algebra](https://gdal.org/en/stable/programs/gdal_vector_layer_algebra.html#gdal-vector-layer-algebra): Perform algebraic operation between 2 layers.
-   [gdal vector make-point](https://gdal.org/en/stable/programs/gdal_vector_make_point.html#gdal-vector-make-point): Create point geometries from coordinate fields
-   [gdal vector make-valid](https://gdal.org/en/stable/programs/gdal_vector_make_valid.html#gdal-vector-make-valid): Fix validity of geometries of a vector dataset
-   [gdal vector materialize](https://gdal.org/en/stable/programs/gdal_vector_materialize.html#gdal-vector-materialize): Materialize a piped dataset on disk to increase the efficiency of the following steps
-   [gdal vector partition](https://gdal.org/en/stable/programs/gdal_vector_partition.html#gdal-vector-partition): Partition a vector dataset into multiple files
-   [gdal vector rasterize](https://gdal.org/en/stable/programs/gdal_vector_rasterize.html#gdal-vector-rasterize): Burns vector geometries into a raster
-   [gdal vector pipeline read](https://gdal.org/en/stable/programs/gdal_vector_read.html#gdal-vector-read): Read a vector dataset (pipeline only)
-   [gdal vector rename-layer](https://gdal.org/en/stable/programs/gdal_vector_rename_layer.html#gdal-vector-rename-layer): Rename layer(s) of a vector dataset
-   [gdal vector reproject](https://gdal.org/en/stable/programs/gdal_vector_reproject.html#gdal-vector-reproject): Reproject a vector dataset
-   [gdal vector segmentize](https://gdal.org/en/stable/programs/gdal_vector_segmentize.html#gdal-vector-segmentize): Segmentize geometries of a vector dataset
-   [gdal vector select](https://gdal.org/en/stable/programs/gdal_vector_select.html#gdal-vector-select): Select a subset of fields from a vector dataset.
-   [gdal vector set-field-type](https://gdal.org/en/stable/programs/gdal_vector_set_field_type.html#gdal-vector-set-field-type): Modify the type of a field of a vector dataset
-   [gdal vector set-geom-type](https://gdal.org/en/stable/programs/gdal_vector_set_geom_type.html#gdal-vector-set-geom-type): Modify the geometry type of a vector dataset
-   [gdal vector simplify](https://gdal.org/en/stable/programs/gdal_vector_simplify.html#gdal-vector-simplify): Simplify geometries of a vector dataset
-   [gdal vector simplify-coverage](https://gdal.org/en/stable/programs/gdal_vector_simplify_coverage.html#gdal-vector-simplify-coverage): Simplify shared boundaries of a polygonal vector dataset
-   [gdal vector sort](https://gdal.org/en/stable/programs/gdal_vector_sort.html#gdal-vector-sort): Spatially sort a vector dataset
-   [gdal vector sql](https://gdal.org/en/stable/programs/gdal_vector_sql.html#gdal-vector-sql): Apply SQL statement(s) to a dataset
-   [gdal vector swap-xy](https://gdal.org/en/stable/programs/gdal_vector_swap_xy.html#gdal-vector-swap-xy): Swap X and Y coordinates of geometries of a vector dataset
-   [gdal vector update](https://gdal.org/en/stable/programs/gdal_vector_update.html#gdal-vector-update): Update an existing vector dataset with an input vector dataset
-   [gdal vector pipeline write](https://gdal.org/en/stable/programs/gdal_vector_write.html#gdal-vector-write): Write a vector dataset (pipeline only)

### Vector Pipelines

> [!NOTE]
> *A pipeline chains several steps, separated with the `!` (exclamation mark) character. The first step must be `read` or `concat`, and the last one `info`, `partition` or `write`. Each step has its own positional or non-positional arguments. Apart from `read`, `concat`, `info`, `partition` and `write`, all other steps can potentially be used several times in a pipeline.*

```pwsh
Usage: gdal vector pipeline [OPTIONS] <PIPELINE>

Process a vector dataset applying several steps.

Positional arguments:

Common Options:
  -h, --help                               Display help message and exit
  --json-usage                          Display usage as JSON document and exit
  --config <KEY>=<VALUE>   Configuration option [may be repeated]
  -q, --quiet                             Quiet mode (no progress bar or warning message) [not available in pipelines]

Options:
  --skip-errors                          Skip errors when writing features [not available in pipelines]

<PIPELINE> is of the form: read|concat [READ-OPTIONS] ( ! <STEP-NAME> [STEP-OPTIONS] )* ! write|info [WRITE-OPTIONS]
```

#### Pipelines General

-   [gdal vector pipeline](https://gdal.org/en/stable/programs/gdal_vector_pipeline.html#gdal-vector-pipeline): Process a vector dataset applying several steps
-   [gdal vector pipeline read](https://gdal.org/en/stable/programs/gdal_vector_read.html#gdal-vector-read): Read a vector dataset (pipeline only)
-   [gdal vector pipeline write](https://gdal.org/en/stable/programs/gdal_vector_write.html#gdal-vector-write): Write a vector dataset (pipeline only)

#### Pipeline Inputs

-   [gdal vector pipeline read](https://gdal.org/en/stable/programs/gdal_vector_read.html#gdal-vector-read): Read a vector dataset (pipeline only)
-   [gdal vector concat](https://gdal.org/en/stable/programs/gdal_vector_concat.html#gdal-vector-concat): Concatenate vector datasets

#### Pipeline Outputs

-   [gdal vector pipeline write](https://gdal.org/en/stable/programs/gdal_vector_write.html#gdal-vector-write): Write a vector dataset (pipeline only)
-   [gdal vector info](https://gdal.org/en/stable/programs/gdal_vector_info.html#gdal-vector-info): Get information on a vector dataset
-   [gdal vector partition](https://gdal.org/en/stable/programs/gdal_vector_partition.html#gdal-vector-partition): Partition a vector dataset into multiple files

#### Pipeline Intermediates

-   [gdal vector materialize](https://gdal.org/en/stable/programs/gdal_vector_materialize.html#gdal-vector-materialize): Materialize a piped dataset on disk to increase the efficiency of the following steps
-   [gdal vector tee](https://gdal.org/en/stable/programs/gdal_vector_pipeline.html#tee): Pipes the input into the output stream and side nested pipelines. Details for options can be found in [Output Nested Pipelines](https://gdal.org/en/stable/programs/gdal_pipeline.html#gdal-output-nested-pipeline)

#### Pipeline Steps

> [!NOTE]
> **Source**: <https://gdal.org/en/stable/programs/gdal_vector_pipeline.html#steps>

-   [buffer](https://gdal.org/en/stable/programs/gdal_vector_pipeline.html#buffer)
-   [check-coverage](https://gdal.org/en/stable/programs/gdal_vector_pipeline.html#check-coverage)
-   [check-geometry](https://gdal.org/en/stable/programs/gdal_vector_pipeline.html#check-geometry)
-   [clean-coverage](https://gdal.org/en/stable/programs/gdal_vector_pipeline.html#clean-coverage)
-   [clip](https://gdal.org/en/stable/programs/gdal_vector_pipeline.html#clip)
-   [combine](https://gdal.org/en/stable/programs/gdal_vector_pipeline.html#combine)
-   [concave-hull](https://gdal.org/en/stable/programs/gdal_vector_pipeline.html#concave-hull)
-   [concat](https://gdal.org/en/stable/programs/gdal_vector_pipeline.html#concat)
-   [convex-hull](https://gdal.org/en/stable/programs/gdal_vector_pipeline.html#convex-hull)
-   [create](https://gdal.org/en/stable/programs/gdal_vector_pipeline.html#create)
-   [dissolve](https://gdal.org/en/stable/programs/gdal_vector_pipeline.html#dissolve)
-   [edit](https://gdal.org/en/stable/programs/gdal_vector_pipeline.html#edit)
-   [explode-collections](https://gdal.org/en/stable/programs/gdal_vector_pipeline.html#explode-collections)
-   [export-schema](https://gdal.org/en/stable/programs/gdal_vector_pipeline.html#export-schema)
-   [external](https://gdal.org/en/stable/programs/gdal_vector_pipeline.html#external)
-   [filter](https://gdal.org/en/stable/programs/gdal_vector_pipeline.html#filter)
-   [info](https://gdal.org/en/stable/programs/gdal_vector_pipeline.html#info)
-   [limit](https://gdal.org/en/stable/programs/gdal_vector_pipeline.html#limit)
-   [make-point](https://gdal.org/en/stable/programs/gdal_vector_pipeline.html#make-point)
-   [make-valid](https://gdal.org/en/stable/programs/gdal_vector_pipeline.html#make-valid)
-   [materialize](https://gdal.org/en/stable/programs/gdal_vector_pipeline.html#materialize)
-   [partition](https://gdal.org/en/stable/programs/gdal_vector_pipeline.html#partition)
-   [read](https://gdal.org/en/stable/programs/gdal_vector_pipeline.html#read)
-   [rename-layer](https://gdal.org/en/stable/programs/gdal_vector_pipeline.html#rename-layer)
-   [reproject](https://gdal.org/en/stable/programs/gdal_vector_pipeline.html#reproject)
-   [segmentize](https://gdal.org/en/stable/programs/gdal_vector_pipeline.html#segmentize)
-   [select](https://gdal.org/en/stable/programs/gdal_vector_pipeline.html#select)
-   [set-field-type](https://gdal.org/en/stable/programs/gdal_vector_pipeline.html#set-field-type)
-   [set-geom-type](https://gdal.org/en/stable/programs/gdal_vector_pipeline.html#set-geom-type)
-   [simplify](https://gdal.org/en/stable/programs/gdal_vector_pipeline.html#simplify)
-   [simplify-coverage](https://gdal.org/en/stable/programs/gdal_vector_pipeline.html#simplify-coverage)
-   [sort](https://gdal.org/en/stable/programs/gdal_vector_pipeline.html#sort)
-   [sql](https://gdal.org/en/stable/programs/gdal_vector_pipeline.html#sql)
-   [swap-xy](https://gdal.org/en/stable/programs/gdal_vector_pipeline.html#swap-xy)
-   [tee](https://gdal.org/en/stable/programs/gdal_vector_pipeline.html#tee)
-   [update](https://gdal.org/en/stable/programs/gdal_vector_pipeline.html#update)
-   [write](https://gdal.org/en/stable/programs/gdal_vector_pipeline.html#write)

## Virtual System Interface (VSI) Commands

> [!NOTE]
> **Source:** <https://gdal.org/en/stable/programs/index.html#virtual-system-interface-vsi-commands>

-   [gdal vsi](https://gdal.org/en/stable/programs/gdal_vsi.html#gdal-vsi): Entry point for GDAL Virtual System Interface (VSI) commands
-   [gdal vsi copy](https://gdal.org/en/stable/programs/gdal_vsi_copy.html#gdal-vsi-copy): Copy files located on GDAL Virtual System Interface (VSI)
-   [gdal vsi delete](https://gdal.org/en/stable/programs/gdal_vsi_delete.html#gdal-vsi-delete): Delete files located on GDAL Virtual System Interface (VSI)
-   [gdal vsi list](https://gdal.org/en/stable/programs/gdal_vsi_list.html#gdal-vsi-list): List files of one of the GDAL Virtual System Interface (VSI)
-   [gdal vsi move](https://gdal.org/en/stable/programs/gdal_vsi_move.html#gdal-vsi-move): Move/rename a file/directory located on GDAL Virtual System Interface (VSI)
-   [gdal vsi sync](https://gdal.org/en/stable/programs/gdal_vsi_sync.html#gdal-vsi-sync): Synchronize source and target file/directory located on GDAL Virtual System Interface (VSI)
-   [gdal vsi sozip](https://gdal.org/en/stable/programs/gdal_vsi_sozip.html#gdal-vsi-sozip): SOZIP (Seek-Optimized ZIP) related commands

## Driver Specific Commands

> [!NOTE]
> **Source:** <https://gdal.org/en/stable/programs/index.html#driver-specific-commands>

-   [gdal driver gpkg repack](https://gdal.org/en/stable/programs/gdal_driver_gpkg_repack.html#gdal-driver-gpkg-repack): Repack/vacuum in-place a GeoPackage dataset
-   [gdal driver gpkg validate](https://gdal.org/en/stable/programs/gdal_driver_gpkg_validate.html#gdal-driver-gpkg-validate): Validate conformance of a GeoPackage dataset against the GeoPackage specification
-   [gdal driver openfilegdb repack](https://gdal.org/en/stable/programs/gdal_driver_openfilegdb_repack.html#gdal-driver-openfilegdb-repack): Repack in-place a FileGeodatabase dataset
-   [gdal driver cog validate](https://gdal.org/en/stable/programs/gdal_driver_cog_validate.html#gdal-driver-cog-validate): Validate if a TIFF file is a Cloud Optimized GeoTIFF
-   [gdal driver parquet create-metadata-file](https://gdal.org/en/stable/programs/gdal_driver_parquet_create_metadata_file.html#gdal-driver-parquet-create-metadata-file): Create the _metadata file for a partitioned Parquet dataset

Less Relevant:

-   [gdal driver gti create](https://gdal.org/en/stable/programs/gdal_driver_gti_create.html#gdal-driver-gti-create): Create an index of raster datasets compatible of the GDAL Tile Index (GTI) driver
-   [gdal driver pdf list-layer](https://gdal.org/en/stable/programs/gdal_driver_pdf_list_layers.html#gdal-driver-pdf-list-layers): Return the list of layers of a PDF file.

