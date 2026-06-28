#  ------------------------------------------------------------------------
#
# Title : Kaggle Downloads
#    By : Jimmy Briggs
#  Date : 2026-06-11
#
#  ------------------------------------------------------------------------

# downloads -------------------------------------------------------------------------------------------------------

kaggle_q1_url <- "https://www.kaggle.com/api/v1/datasets/download/landrecordsus/us-parcel-layer?datasetVersionNumber=1"
kaggle_q2_url <- "https://www.kaggle.com/api/v1/datasets/download/landrecordsus/us-parcel-layer?datasetVersionNumber=2"

local_q1_file <- "G:\\SpatialData\\parcels\\landrecordsus\\LR_PARCEL_NATIONWIDE_FILE_US_2026_Q1.gpkg.zip"
local_q2_file <- "G:\\SpatialData\\parcels\\landrecordsus\\LR_PARCEL_NATIONWIDE_FILE_US_2026_Q2.gpkg.zip"

httr2::request(kaggle_q1_url) |>
  httr2::req_progress(type = "down") |>
  httr2::req_perform(path = local_q1_file)

httr2::request(kaggle_q2_url) |>
  httr2::req_progress(type = "down") |>
  httr2::req_perform(path = local_q2_file)

# <httr2_response>
# GET https://storage.googleapis.com:443/kaggle-data-sets/9200493/16492871/bundle/archive.zip?X-Goog-Algorithm=GOOG4-RSA-SHA256&X-Goog-Credential=gcp-kaggle-com%40kaggle-161607.iam.gserviceaccount.com%2F20260612%2Fauto%2Fstorage%2Fgoog4_request&X-Goog-Date=20260612T001151Z&X-Goog-Expires=259200&X-Goog-SignedHeaders=host&X-Goog-Signature=3ca935461bf21213154359bfb9938c99c415da02f48a4dcfc1ec504112ea852912229a48f6298a79bfc6ee02f31c17358c950a25b5edddcdac580129ad34b33a2391c9bc372d986f49213e7c716742f677798f58da4f766368702800ef47439d4782a4d7c111b625651d3b247cced3271439275934676492a824cebc7517da5f14fc0cec50e7c7d6847a9d2aac690f08e3e137cd3a42f9f3381cc3329f2fe86057fcc04cda691e0a81c2eb95aee6734815ed0916c4125ebd5064d56bbeb33d60e396266096db9382ec25d2a27e4c16b0cd0c573b5db194a3d922debc5fccf56f286dae3b0eba3b84d8388543451288c4a50932d75a6731182da2cb894162ea4a
# Status: 200 OK
# Content-Type: application/zip
# Body: On disk G:\SpatialData\parcels\landrecordsus\LR_PARCEL_NATIONWIDE_FILE_US_2026_Q2.gpkg.zip (63157971976 bytes)

# unzip -----------------------------------------------------------------------------------------------------------

# going to unzip to local C drive to ensure optimal performance (NVMe SSD, not external)
data_dir <- "C:\\GEODATA"
fs::dir_create(data_dir)
unzip(local_q1_file, exdir = data_dir)
unzip(local_q2_file, exdir = data_dir)

# metadata --------------------------------------------------------------------------------------------------------

# not sure how to get this outside of the web browser UI

croissant_metadata_file_v1 <- "G:\\SpatialData\\parcels\\landrecordsus\\us-parcel-layer-metadata-v1.json"
croissant_metadata_file_v2 <- "G:\\SpatialData\\parcels\\landrecordsus\\us-parcel-layer-metadata-v2.json"

croissant_metadata_v1 <- yyjsonr::read_json_file(croissant_metadata_file_v1)
croissant_metadata_v2 <- yyjsonr::read_json_file(croissant_metadata_file_v2)

# ogr schema ------------------------------------------------------------------------------------------------------

gpkg_v1_dsn <- "C:\\GEODATA\\LR_PARCEL_NATIONWIDE_FILE_US_2026_Q1.gpkg"
gpkg_v2_dsn <- "C:\\GEODATA\\LR_PARCEL_NATIONWIDE_FILE_US_2026_Q2.gpkg"

gpkg_v1_layer <- gdalraster::ogr_ds_layer_names(gpkg_v1_dsn)[[1]]
gpkg_v2_layer <- gdalraster::ogr_ds_layer_names(gpkg_v2_dsn)[[1]]

ogr_schema_file_v1 <- "G:\\SpatialData\\parcels\\landrecordsus\\LR_PARCEL_NATIONWIDE_FILE_US_2026_Q1.gpkg.schema.json"
ogr_schema_file_v2 <- "G:\\SpatialData\\parcels\\landrecordsus\\LR_PARCEL_NATIONWIDE_FILE_US_2026_Q2.gpkg.schema.json"

ogr_schema_v1 <- gdalraster::gdal_run(
  "vector export-schema",
  list(input = gpkg_v1_file, input_layer = gpkg_v1_layer)
)$output() |>
  yyjsonr::read_json_str(obj_of_arrs_to_df = FALSE, arr_of_objs_to_df = FALSE, arr_of_arrs_to_matrix = FALSE)

ogr_schema_v2 <- gdalraster::gdal_run(
  "vector export-schema",
  list(input = gpkg_v2_file, input_layer = gpkg_v2_layer)
)$output() |>
  yyjsonr::read_json_str(obj_of_arrs_to_df = FALSE, arr_of_objs_to_df = FALSE, arr_of_arrs_to_matrix = FALSE)

yyjsonr::write_json_file(ogr_schema_v1, ogr_schema_file_v1, pretty = TRUE, auto_unbox = TRUE)
yyjsonr::write_json_file(ogr_schema_v2, ogr_schema_file_v2, pretty = TRUE, auto_unbox = TRUE)
