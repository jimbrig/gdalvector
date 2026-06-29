## Core Docs

- [GDAL — GDAL documentation](https://gdal.org/en/stable/index.html)
- [Programs — GDAL documentation](https://gdal.org/en/stable/programs/index.html)
- [Vector drivers — GDAL documentation](https://gdal.org/en/stable/drivers/vector/index.html)
- [Multi-threading — GDAL documentation](https://gdal.org/en/stable/user/multithreading.html)
- [GDAL Virtual File Systems (compressed, network hosted, etc...): /vsimem, /vsizip, /vsitar, /vsicurl, ... — GDAL documentation](https://gdal.org/en/stable/user/virtual_file_systems.html)
- [Configuration options — GDAL documentation](https://gdal.org/en/stable/user/configoptions.html)
- [List of Options and Where they are Documented — GDAL documentation](https://gdal.org/en/stable/user/configoptions.html#list-of-configuration-options-and-where-they-are-documented)

- [gdal vector — GDAL documentation](https://gdal.org/en/stable/programs/gdal_vector.html)
- [Security considerations — GDAL documentation](https://gdal.org/en/stable/user/security.html#known-issues-in-api)
- [API — GDAL documentation](https://gdal.org/en/stable/api/index.html)
    - [C API — GDAL documentation](https://gdal.org/en/stable/api/index.html#c-api)
    - [C++ API — GDAL documentation](https://gdal.org/en/stable/api/index.html#id3)
- [RFC list — GDAL documentation](https://gdal.org/en/stable/development/rfc/index.html)

## Relevant Pipeline Docs

- [gdal vector pipeline — GDAL documentation](https://gdal.org/en/stable/programs/gdal_vector_pipeline.html#gdal-vector-pipeline)
- [gdal vector pipeline read — GDAL documentation](https://gdal.org/en/stable/programs/gdal_vector_read.html)
- [gdal vector pipeline read — GDAL documentation](https://gdal.org/en/stable/programs/gdal_vector_pipeline.html#read)
- [gdal vector pipeline write — GDAL documentation](https://gdal.org/en/stable/programs/gdal_vector_pipeline.html#write)
- [gdal vector pipeline write — GDAL documentation](https://gdal.org/en/stable/programs/gdal_vector_write.html)
- [gdal vector pipeline tee — GDAL documentation](https://gdal.org/en/stable/programs/gdal_vector_pipeline.html#tee)
- [gdal pipeline output nested pipeline — GDAL documentation](https://gdal.org/en/stable/programs/gdal_pipeline.html#gdal-output-nested-pipeline)
- [gdal vector pipeline partition — GDAL documentation](https://gdal.org/en/stable/programs/gdal_vector_pipeline.html#partition)
- [gdal vector materialize — GDAL documentation](https://gdal.org/en/stable/programs/gdal_vector_materialize.html)
- [gdal vector partition — GDAL documentation](https://gdal.org/en/stable/programs/gdal_vector_partition.html)
- [gdal vector index — GDAL documentation](https://gdal.org/en/stable/programs/gdal_vector_index.html)
- [gdal vector info — GDAL documentation](https://gdal.org/en/stable/programs/gdal_vector_info.html)
- [gdal vector export-schema — GDAL documentation](https://gdal.org/en/stable/programs/gdal_vector_export_schema.html)

### Vector commands

> [!NOTE]
> **Source**: <https://gdal.org/en/stable/programs/index.html#vector-commands>

Single operations:

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

Pipelines:

-   [gdal vector pipeline](https://gdal.org/en/stable/programs/gdal_vector_pipeline.html#gdal-vector-pipeline): Process a vector dataset applying several steps

### Virtual System Interface (VSI) commands

> [!NOTE]
> **Source**: <https://gdal.org/en/stable/programs/index.html#virtual-system-interface-vsi-commands>

-   [gdal vsi](https://gdal.org/en/stable/programs/gdal_vsi.html#gdal-vsi): Entry point for GDAL Virtual System Interface (VSI) commands
-   [gdal vsi copy](https://gdal.org/en/stable/programs/gdal_vsi_copy.html#gdal-vsi-copy): Copy files located on GDAL Virtual System Interface (VSI)
-   [gdal vsi delete](https://gdal.org/en/stable/programs/gdal_vsi_delete.html#gdal-vsi-delete): Delete files located on GDAL Virtual System Interface (VSI)
-   [gdal vsi list](https://gdal.org/en/stable/programs/gdal_vsi_list.html#gdal-vsi-list): List files of one of the GDAL Virtual System Interface (VSI)
-   [gdal vsi move](https://gdal.org/en/stable/programs/gdal_vsi_move.html#gdal-vsi-move): Move/rename a file/directory located on GDAL Virtual System Interface (VSI)
-   [gdal vsi sync](https://gdal.org/en/stable/programs/gdal_vsi_sync.html#gdal-vsi-sync): Synchronize source and target file/directory located on GDAL Virtual System Interface (VSI)
-   [gdal vsi sozip](https://gdal.org/en/stable/programs/gdal_vsi_sozip.html#gdal-vsi-sozip): SOZIP (Seek-Optimized ZIP) related commands



### Driver specific commands

> [!NOTE]
> **Source**: <https://gdal.org/en/stable/programs/index.html#driver-specific-commands>

-   [gdal driver cog validate](https://gdal.org/en/stable/programs/gdal_driver_cog_validate.html#gdal-driver-cog-validate): Validate if a TIFF file is a Cloud Optimized GeoTIFF
-   [gdal driver gpkg repack](https://gdal.org/en/stable/programs/gdal_driver_gpkg_repack.html#gdal-driver-gpkg-repack): Repack/vacuum in-place a GeoPackage dataset
-   [gdal driver gpkg validate](https://gdal.org/en/stable/programs/gdal_driver_gpkg_validate.html#gdal-driver-gpkg-validate): Validate conformance of a GeoPackage dataset against the GeoPackage specification
-   [gdal driver gti create](https://gdal.org/en/stable/programs/gdal_driver_gti_create.html#gdal-driver-gti-create): Create an index of raster datasets compatible of the GDAL Tile Index (GTI) driver
-   [gdal driver openfilegdb repack](https://gdal.org/en/stable/programs/gdal_driver_openfilegdb_repack.html#gdal-driver-openfilegdb-repack): Repack in-place a FileGeodatabase dataset
-   [gdal driver parquet create-metadata-file](https://gdal.org/en/stable/programs/gdal_driver_parquet_create_metadata_file.html#gdal-driver-parquet-create-metadata-file): Create the _metadata file for a partitioned Parquet dataset
-   [gdal driver pdf list-layer](https://gdal.org/en/stable/programs/gdal_driver_pdf_list_layers.html#gdal-driver-pdf-list-layers): Return the list of layers of a PDF file.
