<img src="https://r2cdn.perplexity.ai/pplx-full-logo-primary-dark%402x.png" style="height:64px;margin-right:32px"/>

# help me figure out how to properly pass open options to algorithm arguments:

````
?gdalraster::gdal_run
...

Algorithm Argument Syntax
Arguments are given in R as a character vector or named list, but otherwise syntax basically matches the GDAL specification for arguments as they are given on the command line. Those specifications are listed here along with some amendments regarding the character vector and named list formats. Programmatic usage also allows passing and receiving datasets as objects (i.e., GDALRaster or GDALVector), in addition to dataset names (e.g., filename, URL, database connection string).

Commands accept one or several positional arguments, typically for dataset names (or in R as GDALRaster or GDALVector datasets). The order is input(s) first, output last. Positional arguments can also be specified as named arguments, if preferred to avoid any ambiguity.

Named arguments have:

at least one "long" name, preceded by two dash characters

optionally, auxiliary long names (i.e., aliases),

and optionally a one-letter short name, preceded by a single dash character, e.g., -f, --of, --format, --output-format <OUTPUT-FORMAT>

Boolean arguments are specified by just specifying the argument name in character vector format. In R list format, the named element must be assigned a value of logical TRUE.

Arguments that require a value are specified like:

-f VALUE for one-letter short names

--format VALUE or --format=VALUE for long names

in a named list, this might look like: args$format <- VALUE

Some arguments can be multi-valued. Some of them require all values to be packed together and separated with comma. This is, e.g., the case of:
--bbox <BBOX> Clipping bounding box as xmin,ymin,xmax,ymax
e.g., --bbox=2.1,49.1,2.9,49.9

Others accept each value to be preceded by a new mention of the argument name, e.g., c("--co", "COMPRESS=LZW", "--co", "TILED=YES"). For that one, if the value of the argument does not contain commas, the packed form is also accepted: --co COMPRESS=LZW,TILED=YES. Note that repeated mentions of an argument are possible in the character vector format for argument input, whereas arguments given in named list format must use argument long names as the list element names, and the packed format for the values (which can be a character vector or numeric vector of values).

Named arguments can be placed before or after positional arguments.
````

I tried so many different methods:

```R
> gpkg_open_opts <- list(
+   open_option = "LIST_ALL_TABLES=NO",
+   open_option = "PRELUDE_STATEMENTS=PRAGMA cache_size=-4000000;PRAGMA temp_store=MEMORY;PRAGMA mmap_size=8589934592;PRAGMA journal_mode=WAL;"
+ )
> gpkg_input_args <- utils::modifyList(
+   list(input = gpkg_path, input_format = gpkg_driver, input_layer = gpkg_layer),
+   gpkg_open_opts
+ )
> gpkg_input_args
$input
[1] "C:/GEODATA/LR_PARCEL_NATIONWIDE_FILE_US_2026_Q1.gpkg"

$input_format
[1] "GPKG"

$input_layer
[1] "lr_parcel_us"

$open_option
[1] "LIST_ALL_TABLES=NO"

> gpkg_open_opts <- c(
+   "LIST_ALL_TABLES=NO",
+   "PRELUDE_STATEMENTS=PRAGMA cache_size=-4000000;PRAGMA temp_store=MEMORY;PRAGMA mmap_size=8589934592;PRAGMA journal_mode=WAL;"
+ )
> gpkg_open_opts <- c(
+   "LIST_ALL_TABLES=NO",
+   "PRELUDE_STATEMENTS=PRAGMA cache_size=-4000000;PRAGMA temp_store=MEMORY;PRAGMA mmap_size=8589934592;PRAGMA journal_mode=WAL;"
+ )
> gpkg_input_args <- list(input = gpkg_path, input_format = gpkg_driver, input_layer = gpkg_layer, open_option = gpkg_open_opts)
> gpkg_input_args
$input
[1] "C:/GEODATA/LR_PARCEL_NATIONWIDE_FILE_US_2026_Q1.gpkg"

$input_format
[1] "GPKG"

$input_layer
[1] "lr_parcel_us"

$open_option
[1] "LIST_ALL_TABLES=NO"                                                                                                         
[2] "PRELUDE_STATEMENTS=PRAGMA cache_size=-4000000;PRAGMA temp_store=MEMORY;PRAGMA mmap_size=8589934592;PRAGMA journal_mode=WAL;"

> gpkg_schema <- gdalraster::gdal_run("vector export-schema", args = gpkg_input_args)$output() |> yyjsonr::read_json_str()
ℹ GDAL DEBUG: [Wed Jun 10 20:42:21 2026].3110, 1389.4310: CPLError: 'NO,PRELUDE_STATEMENTS=PRAGMA cache_size=-4000000;PRAGMA temp_store=MEMORY;PRAGMA mmap_size=8589934592;PRAGMA journal_mode=WAL;' is an unexpected value for LIST_ALL_TABLES open option of type string-select.
! GDAL WARNING 6: 'NO,PRELUDE_STATEMENTS=PRAGMA cache_size=-4000000;PRAGMA temp_store=MEMORY;PRAGMA mmap_size=8589934592;PRAGMA journal_mode=WAL;' is an unexpected value for LIST_ALL_TABLES open option of type string-select.
ℹ GDAL DEBUG: [Wed Jun 10 20:42:21 2026].3210, 1389.4410: GPKG: GeoPackage v1.2.0
ℹ GDAL DEBUG: [Wed Jun 10 20:42:21 2026].3260, 1389.4460: GDAL: GDALOpen(C:/GEODATA/LR_PARCEL_NATIONWIDE_FILE_US_2026_Q1.gpkg, this=0000008001B214F0) succeeds as GPKG.
> gpkg_open_opts <- c(
+   "LIST_ALL_TABLES=NO",
+   "PRELUDE_STATEMENTS='PRAGMA cache_size=-4000000;PRAGMA temp_store=MEMORY;PRAGMA mmap_size=8589934592;PRAGMA journal_mode=WAL;'"
+ )
> gpkg_input_args <- list(input = gpkg_path, input_format = gpkg_driver, input_layer = gpkg_layer, open_option = gpkg_open_opts)
> gpkg_schema <- gdalraster::gdal_run("vector export-schema", args = gpkg_input_args)$output() |> yyjsonr::read_json_str()
ℹ GDAL DEBUG: [Wed Jun 10 20:42:49 2026].4070, 1417.5270: CPLError: 'NO,PRELUDE_STATEMENTS='PRAGMA cache_size=-4000000;PRAGMA temp_store=MEMORY;PRAGMA mmap_size=8589934592;PRAGMA journal_mode=WAL;'' is an unexpected value for LIST_ALL_TABLES open option of type string-select.
! GDAL WARNING 6: 'NO,PRELUDE_STATEMENTS='PRAGMA cache_size=-4000000;PRAGMA temp_store=MEMORY;PRAGMA mmap_size=8589934592;PRAGMA journal_mode=WAL;'' is an unexpected value for LIST_ALL_TABLES open option of type string-select.
ℹ GDAL DEBUG: [Wed Jun 10 20:42:49 2026].4230, 1417.5430: GPKG: GeoPackage v1.2.0
ℹ GDAL DEBUG: [Wed Jun 10 20:42:49 2026].4290, 1417.5490: GDAL: GDALOpen(C:/GEODATA/LR_PARCEL_NATIONWIDE_FILE_US_2026_Q1.gpkg, this=0000008001B24250) succeeds as GPKG.
> gpkg_open_opts <- list(
+   "LIST_ALL_TABLES=NO",
+   "PRELUDE_STATEMENTS=PRAGMA cache_size=-4000000;PRAGMA temp_store=MEMORY;PRAGMA mmap_size=8589934592;PRAGMA journal_mode=WAL;"
+ )
> gpkg_input_args <- list(input = gpkg_path, input_format = gpkg_driver, input_layer = gpkg_layer, open_option = gpkg_open_opts)
> gpkg_schema <- gdalraster::gdal_run("vector export-schema", args = gpkg_input_args)$output() |> yyjsonr::read_json_str()
! an element of the input list is not a dataset object
! an element of the input list is not a dataset object
✖ unhandled list input for: open-option
ℹ GDAL DEBUG: [Wed Jun 10 20:43:12 2026].6540, 1440.7740: GPKG: GeoPackage v1.2.0
ℹ GDAL DEBUG: [Wed Jun 10 20:43:12 2026].6590, 1440.7790: GDAL: GDALOpen(C:/GEODATA/LR_PARCEL_NATIONWIDE_FILE_US_2026_Q1.gpkg, this=0000008001B20D60) succeeds as GPKG.
> gpkg_input_args
$input
[1] "C:/GEODATA/LR_PARCEL_NATIONWIDE_FILE_US_2026_Q1.gpkg"

$input_format
[1] "GPKG"

$input_layer
[1] "lr_parcel_us"

$open_option
$open_option[[1]]
[1] "LIST_ALL_TABLES=NO"

$open_option[[2]]
[1] "PRELUDE_STATEMENTS=PRAGMA cache_size=-4000000;PRAGMA temp_store=MEMORY;PRAGMA mmap_size=8589934592;PRAGMA journal_mode=WAL;"


> gpkg_input_args <- list(input = gpkg_path, input_format = gpkg_driver, input_layer = gpkg_layer, gpkg_open_opts)
> gpkg_input_args
$input
[1] "C:/GEODATA/LR_PARCEL_NATIONWIDE_FILE_US_2026_Q1.gpkg"

$input_format
[1] "GPKG"

$input_layer
[1] "lr_parcel_us"

[[4]]
[[4]][[1]]
[1] "LIST_ALL_TABLES=NO"

[[4]][[2]]
[1] "PRELUDE_STATEMENTS=PRAGMA cache_size=-4000000;PRAGMA temp_store=MEMORY;PRAGMA mmap_size=8589934592;PRAGMA journal_mode=WAL;"


> gpkg_input_args <- list(input = gpkg_path, input_format = gpkg_driver, input_layer = gpkg_layer)
> gpkg_input_args[["open_option"]] <- gpkg_open_opts
> gpkg_input_args
$input
[1] "C:/GEODATA/LR_PARCEL_NATIONWIDE_FILE_US_2026_Q1.gpkg"

$input_format
[1] "GPKG"

$input_layer
[1] "lr_parcel_us"

$open_option
$open_option[[1]]
[1] "LIST_ALL_TABLES=NO"

$open_option[[2]]
[1] "PRELUDE_STATEMENTS=PRAGMA cache_size=-4000000;PRAGMA temp_store=MEMORY;PRAGMA mmap_size=8589934592;PRAGMA journal_mode=WAL;"


> gpkg_schema <- gdalraster::gdal_run("vector export-schema", args = gpkg_input_args)$output() |> yyjsonr::read_json_str()
! an element of the input list is not a dataset object
! an element of the input list is not a dataset object
✖ unhandled list input for: open-option
ℹ GDAL DEBUG: [Wed Jun 10 20:43:48 2026].4390, 1476.5590: GPKG: GeoPackage v1.2.0
ℹ GDAL DEBUG: [Wed Jun 10 20:43:48 2026].4430, 1476.5630: GDAL: GDALOpen(C:/GEODATA/LR_PARCEL_NATIONWIDE_FILE_US_2026_Q1.gpkg, this=0000008001B25900) succeeds as GPKG.
> gpkg_input_args <- list(input = gpkg_path, input_format = gpkg_driver, input_layer = gpkg_layer)
ℹ GDAL DEBUG: [Wed Jun 10 20:44:19 2026].3490, 1507.4690: GDAL: GDALClose(C:/GEODATA/LR_PARCEL_NATIONWIDE_FILE_US_2026_Q1.gpkg, this=0000008001B25900)
ℹ GDAL DEBUG: [Wed Jun 10 20:44:19 2026].3560, 1507.4760: GDAL: GDALClose(C:/GEODATA/LR_PARCEL_NATIONWIDE_FILE_US_2026_Q1.gpkg, this=0000008001B20D60)
ℹ GDAL DEBUG: [Wed Jun 10 20:44:19 2026].3620, 1507.4820: GDAL: GDALClose(C:/GEODATA/LR_PARCEL_NATIONWIDE_FILE_US_2026_Q1.gpkg, this=0000008001B24250)
ℹ GDAL DEBUG: [Wed Jun 10 20:44:19 2026].3690, 1507.4890: GDAL: GDALClose(C:/GEODATA/LR_PARCEL_NATIONWIDE_FILE_US_2026_Q1.gpkg, this=0000008001B214F0)
> gpkg_open_opts <- c(
+   "LIST_ALL_TABLES=NO",
+   "PRELUDE_STATEMENTS=PRAGMA cache_size=-4000000;PRAGMA temp_store=MEMORY;PRAGMA mmap_size=8589934592;PRAGMA journal_mode=WAL;"
+ )
> gpkg_open_opts <- c(
+   "LIST_ALL_TABLES=NO",
+   "PRELUDE_STATEMENTS=PRAGMA cache_size=-4000000;PRAGMA temp_store=MEMORY;PRAGMA mmap_size=8589934592;PRAGMA journal_mode=WAL;"
+ )
> gpkg_input_args <- list(input = gpkg_path, input_format = gpkg_driver, input_layer = gpkg_layer, open_option = stringr::str_c(gpkg_open_opts, collapse = ","))
> gpkg_input_args
$input
[1] "C:/GEODATA/LR_PARCEL_NATIONWIDE_FILE_US_2026_Q1.gpkg"

$input_format
[1] "GPKG"

$input_layer
[1] "lr_parcel_us"

$open_option
[1] "LIST_ALL_TABLES=NO,PRELUDE_STATEMENTS=PRAGMA cache_size=-4000000;PRAGMA temp_store=MEMORY;PRAGMA mmap_size=8589934592;PRAGMA journal_mode=WAL;"

> gpkg_schema <- gdalraster::gdal_run("vector export-schema", args = gpkg_input_args)$output() |> yyjsonr::read_json_str()
ℹ GDAL DEBUG: [Wed Jun 10 20:47:22 2026].4560, 1690.5760: CPLError: 'NO,PRELUDE_STATEMENTS=PRAGMA cache_size=-4000000;PRAGMA temp_store=MEMORY;PRAGMA mmap_size=8589934592;PRAGMA journal_mode=WAL;' is an unexpected value for LIST_ALL_TABLES open option of type string-select.
! GDAL WARNING 6: 'NO,PRELUDE_STATEMENTS=PRAGMA cache_size=-4000000;PRAGMA temp_store=MEMORY;PRAGMA mmap_size=8589934592;PRAGMA journal_mode=WAL;' is an unexpected value for LIST_ALL_TABLES open option of type string-select.
ℹ GDAL DEBUG: [Wed Jun 10 20:47:22 2026].4700, 1690.5900: GPKG: GeoPackage v1.2.0
ℹ GDAL DEBUG: [Wed Jun 10 20:47:22 2026].4770, 1690.5970: GDAL: GDALOpen(C:/GEODATA/LR_PARCEL_NATIONWIDE_FILE_US_2026_Q1.gpkg, this=0000008001B20D60) succeeds as GPKG.
> gpkg_schema
$layers
          name schemaType                       geometryFields fidColumnName
1 lr_parcel_us       Full geom, MultiPolygon, FALSE, EPSG:4326          lrid
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            fields
1 parcelid, parcelid2, geoid, statefp, countyfp, taxacctnum, taxyear, usecode, usedesc, zoningcode, zoningdesc, numbldgs, numunits, yearbuilt, numfloors, bldgsqft, bedrooms, halfbaths, fullbaths, imprvalue, landvalue, agvalue, totalvalue, assdacres, saleamt, saledate, ownername, owneraddr, ownercity, ownerstate, ownerzip, parceladdr, parcelcity, parcelstate, parcelzip, legaldesc, township, section, qtrsection, range, plssdesc, book, page, block, lot, updated, lrversion, centroidx, centroidy, surfpointx, surfpointy, String, String, String, String, String, String, Integer, String, String, String, String, Integer, Integer, Integer, Integer, Integer, Integer, Integer, Integer, Integer64, Integer64, Integer64, Integer64, Real, Integer64, Date, String, String, String, String, String, String, String, String, String, String, String, String, String, String, String, String, String, String, String, String, String, Real, Real, Real, Real, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE

> gpkg_open_opts <- c(
+   "LIST_ALL_TABLES=NO",
+   "PRELUDE_STATEMENTS=PRAGMA cache_size=-4000000;PRAGMA temp_store=MEMORY;PRAGMA mmap_size=8589934592;PRAGMA journal_mode=WAL;"
+ )
> gpkg_input_args <- list(input = gpkg_path, input_format = gpkg_driver, input_layer = gpkg_layer, open_option = gpkg_open_opts)
> gpkg_schema <- gdalraster::gdal_run("vector export-schema", args = gpkg_input_args)$output() |> yyjsonr::read_json_str()
ℹ GDAL DEBUG: [Wed Jun 10 20:48:50 2026].0250, 1778.1450: CPLError: 'NO,PRELUDE_STATEMENTS=PRAGMA cache_size=-4000000;PRAGMA temp_store=MEMORY;PRAGMA mmap_size=8589934592;PRAGMA journal_mode=WAL;' is an unexpected value for LIST_ALL_TABLES open option of type string-select.
! GDAL WARNING 6: 'NO,PRELUDE_STATEMENTS=PRAGMA cache_size=-4000000;PRAGMA temp_store=MEMORY;PRAGMA mmap_size=8589934592;PRAGMA journal_mode=WAL;' is an unexpected value for LIST_ALL_TABLES open option of type string-select.
ℹ GDAL DEBUG: [Wed Jun 10 20:48:50 2026].0510, 1778.1710: GPKG: GeoPackage v1.2.0
ℹ GDAL DEBUG: [Wed Jun 10 20:48:50 2026].0610, 1778.1810: GDAL: GDALOpen(C:/GEODATA/LR_PARCEL_NATIONWIDE_FILE_US_2026_Q1.gpkg, this=0000008001B214F0) succeeds as GPKG.
> gpkg_open_opts <- c(
+   "--open-option" = "LIST_ALL_TABLES=NO",
+   "--open-option" = "PRELUDE_STATEMENTS=PRAGMA cache_size=-4000000;PRAGMA temp_store=MEMORY;PRAGMA mmap_size=8589934592;PRAGMA journal_mode=WAL;"
+ )
> gpkg_input_args <- list(input = gpkg_path, input_format = gpkg_driver, input_layer = gpkg_layer, open_option = gpkg_open_opts)
> gpkg_schema <- gdalraster::gdal_run("vector export-schema", args = gpkg_input_args)$output() |> yyjsonr::read_json_str()
ℹ GDAL DEBUG: [Wed Jun 10 20:49:41 2026].2600, 1829.3800: CPLError: 'NO,PRELUDE_STATEMENTS=PRAGMA cache_size=-4000000;PRAGMA temp_store=MEMORY;PRAGMA mmap_size=8589934592;PRAGMA journal_mode=WAL;' is an unexpected value for LIST_ALL_TABLES open option of type string-select.
! GDAL WARNING 6: 'NO,PRELUDE_STATEMENTS=PRAGMA cache_size=-4000000;PRAGMA temp_store=MEMORY;PRAGMA mmap_size=8589934592;PRAGMA journal_mode=WAL;' is an unexpected value for LIST_ALL_TABLES open option of type string-select.
ℹ GDAL DEBUG: [Wed Jun 10 20:49:41 2026].2720, 1829.3920: GPKG: GeoPackage v1.2.0
ℹ GDAL DEBUG: [Wed Jun 10 20:49:41 2026].2770, 1829.3970: GDAL: GDALOpen(C:/GEODATA/LR_PARCEL_NATIONWIDE_FILE_US_2026_Q1.gpkg, this=0000008001B249E0) succeeds as GPKG.
> gpkg_input_args
$input
[1] "C:/GEODATA/LR_PARCEL_NATIONWIDE_FILE_US_2026_Q1.gpkg"

$input_format
[1] "GPKG"

$input_layer
[1] "lr_parcel_us"

$open_option
                                                                                                                --open-option 
                                                                                                         "LIST_ALL_TABLES=NO" 
                                                                                                                --open-option 
"PRELUDE_STATEMENTS=PRAGMA cache_size=-4000000;PRAGMA temp_store=MEMORY;PRAGMA mmap_size=8589934592;PRAGMA journal_mode=WAL;" 

> gpkg_open_opts <- c(
+   "--open-option" = "LIST_ALL_TABLES=NO",
+   "--open-option" = "PRELUDE_STATEMENTS=PRAGMA cache_size=-4000000;PRAGMA temp_store=MEMORY;PRAGMA mmap_size=8589934592;PRAGMA journal_mode=WAL"
+ )
> gpkg_input_args <- list(input = gpkg_path, input_format = gpkg_driver, input_layer = gpkg_layer, open_option = gpkg_open_opts)
> gpkg_schema <- gdalraster::gdal_run("vector export-schema", args = gpkg_input_args)$output() |> yyjsonr::read_json_str()
ℹ GDAL DEBUG: [Wed Jun 10 20:50:10 2026].0100, 1858.1300: CPLError: 'NO,PRELUDE_STATEMENTS=PRAGMA cache_size=-4000000;PRAGMA temp_store=MEMORY;PRAGMA mmap_size=8589934592;PRAGMA journal_mode=WAL' is an unexpected value for LIST_ALL_TABLES open option of type string-select.
! GDAL WARNING 6: 'NO,PRELUDE_STATEMENTS=PRAGMA cache_size=-4000000;PRAGMA temp_store=MEMORY;PRAGMA mmap_size=8589934592;PRAGMA journal_mode=WAL' is an unexpected value for LIST_ALL_TABLES open option of type string-select.
ℹ GDAL DEBUG: [Wed Jun 10 20:50:10 2026].0210, 1858.1410: GPKG: GeoPackage v1.2.0
ℹ GDAL DEBUG: [Wed Jun 10 20:50:10 2026].0260, 1858.1460: GDAL: GDALOpen(C:/GEODATA/LR_PARCEL_NATIONWIDE_FILE_US_2026_Q1.gpkg, this=0000008001B25170) succeeds as GPKG.
> gpkg_open_opts <- list(
+   "LIST_ALL_TABLES" = FALSE,
+   "PRELUDE_STATEMENTS" = "PRAGMA cache_size=-4000000;PRAGMA temp_store=MEMORY;PRAGMA mmap_size=8589934592;PRAGMA journal_mode=WAL;"
+ )
> gpkg_open_opts <- c(
+   "LIST_ALL_TABLES" = FALSE,
+   "PRELUDE_STATEMENTS" = "PRAGMA cache_size=-4000000;PRAGMA temp_store=MEMORY;PRAGMA mmap_size=8589934592;PRAGMA journal_mode=WAL;"
+ )
> gpkg_input_args <- list(input = gpkg_path, input_format = gpkg_driver, input_layer = gpkg_layer, open_option = gpkg_open_opts)
> gpkg_input_args
$input
[1] "C:/GEODATA/LR_PARCEL_NATIONWIDE_FILE_US_2026_Q1.gpkg"

$input_format
[1] "GPKG"

$input_layer
[1] "lr_parcel_us"

$open_option
                                                                                           LIST_ALL_TABLES 
                                                                                                   "FALSE" 
                                                                                        PRELUDE_STATEMENTS 
"PRAGMA cache_size=-4000000;PRAGMA temp_store=MEMORY;PRAGMA mmap_size=8589934592;PRAGMA journal_mode=WAL;" 

> gpkg_open_opts <- c(
+   "LIST_ALL_TABLES" = "NO",
+   "PRELUDE_STATEMENTS" = "PRAGMA cache_size=-4000000;PRAGMA temp_store=MEMORY;PRAGMA mmap_size=8589934592;PRAGMA journal_mode=WAL;"
+ )
> gpkg_input_args <- list(input = gpkg_path, input_format = gpkg_driver, input_layer = gpkg_layer, open_option = gpkg_open_opts)
> gpkg_input_args
$input
[1] "C:/GEODATA/LR_PARCEL_NATIONWIDE_FILE_US_2026_Q1.gpkg"

$input_format
[1] "GPKG"

$input_layer
[1] "lr_parcel_us"

$open_option
                                                                                           LIST_ALL_TABLES 
                                                                                                      "NO" 
                                                                                        PRELUDE_STATEMENTS 
"PRAGMA cache_size=-4000000;PRAGMA temp_store=MEMORY;PRAGMA mmap_size=8589934592;PRAGMA journal_mode=WAL;" 

> gpkg_schema <- gdalraster::gdal_run("vector export-schema", args = gpkg_input_args)$output() |> yyjsonr::read_json_str()
ℹ GDAL DEBUG: [Wed Jun 10 20:51:09 2026].4660, 1917.5860: CPLError: driver GPKG does not support open option NO,PRAGMA cache_size
! GDAL WARNING 6: driver GPKG does not support open option NO,PRAGMA cache_size
ℹ GDAL DEBUG: [Wed Jun 10 20:51:09 2026].4780, 1917.5980: GPKG: GeoPackage v1.2.0
ℹ GDAL DEBUG: [Wed Jun 10 20:51:09 2026].4840, 1917.6040: GDAL: GDALOpen(C:/GEODATA/LR_PARCEL_NATIONWIDE_FILE_US_2026_Q1.gpkg, this=0000008011322D00) succeeds as GPKG.
ℹ GDAL DEBUG: [Wed Jun 10 20:51:09 2026].5120, 1917.6320: GDAL: GDALClose(C:/GEODATA/LR_PARCEL_NATIONWIDE_FILE_US_2026_Q1.gpkg, this=0000008011322D00)
ℹ GDAL DEBUG: [Wed Jun 10 20:51:09 2026].5210, 1917.6410: GDAL: GDALClose(C:/GEODATA/LR_PARCEL_NATIONWIDE_FILE_US_2026_Q1.gpkg, this=0000008001B25170)
ℹ GDAL DEBUG: [Wed Jun 10 20:51:09 2026].5270, 1917.6470: GDAL: GDALClose(C:/GEODATA/LR_PARCEL_NATIONWIDE_FILE_US_2026_Q1.gpkg, this=0000008001B249E0)
ℹ GDAL DEBUG: [Wed Jun 10 20:51:09 2026].5340, 1917.6540: GDAL: GDALClose(C:/GEODATA/LR_PARCEL_NATIONWIDE_FILE_US_2026_Q1.gpkg, this=0000008001B214F0)
ℹ GDAL DEBUG: [Wed Jun 10 20:51:09 2026].5420, 1917.6620: GDAL: GDALClose(C:/GEODATA/LR_PARCEL_NATIONWIDE_FILE_US_2026_Q1.gpkg, this=0000008001B20D60)
> gpkg_open_opts <- c(
+   "LIST_ALL_TABLES" = FALSE,
+   "PRELUDE_STATEMENTS" = "PRAGMA cache_size=-4000000;PRAGMA temp_store=MEMORY;PRAGMA mmap_size=8589934592;PRAGMA journal_mode=WAL;"
+ )
> gpkg_input_args <- list(input = gpkg_path, input_format = gpkg_driver, input_layer = gpkg_layer, open_option = gpkg_open_opts)
> gpkg_schema <- gdalraster::gdal_run("vector export-schema", args = gpkg_input_args)$output() |> yyjsonr::read_json_str()
ℹ GDAL DEBUG: [Wed Jun 10 20:51:35 2026].4110, 1943.5310: CPLError: driver GPKG does not support open option FALSE,PRAGMA cache_size
! GDAL WARNING 6: driver GPKG does not support open option FALSE,PRAGMA cache_size
ℹ GDAL DEBUG: [Wed Jun 10 20:51:35 2026].4280, 1943.5480: GPKG: GeoPackage v1.2.0
ℹ GDAL DEBUG: [Wed Jun 10 20:51:35 2026].4350, 1943.5550: GDAL: GDALOpen(C:/GEODATA/LR_PARCEL_NATIONWIDE_FILE_US_2026_Q1.gpkg, this=0000008011327110) succeeds as GPKG.
```

The root cause of your problem is clear from the docs. The key insight is in this sentence from the `Algorithm Argument Syntax` section:

> **"arguments given in named list format must use argument long names as the list element names, and the packed format for the values"**

When you pass `open_option = c("LIST_ALL_TABLES=NO", "PRELUDE_STATEMENTS=...")` in a named list, `gdalraster` internally packs all values of that single named element by joining them with commas — giving GDAL `LIST_ALL_TABLES=NO,PRELUDE_STATEMENTS=...` as if it were one option value for the `LIST_ALL_TABLES` key. That's exactly the warning you're seeing every time.[^1_1]

## Why Every Attempt Fails

The core issue is a conflict between R's list semantics and how `gdal_run()` handles multi-valued arguments in list format. R lists cannot have **duplicate keys**, which is what the character vector format exploits for `[may be repeated]` arguments:[^1_1]


| Approach | What GDAL receives | Result |
| :-- | :-- | :-- |
| `open_option = c("LIST_ALL_TABLES=NO", "PRELUDE_STATEMENTS=...")` | `NO,PRELUDE_STATEMENTS=...` (comma-joined) as the value of `LIST_ALL_TABLES` | ❌ Wrong — treats it as one packed value |
| `open_option = list("LIST_ALL_TABLES=NO", "PRELUDE_STATEMENTS=...")` | Unnamed list → "unhandled list input" | ❌ Wrong — unnamed elements rejected |
| `open_option = c("LIST_ALL_TABLES"="NO", "PRELUDE_STATEMENTS"="...")` | `NO,PRAGMA cache_size...` as one key | ❌ Same packing problem |
| `stringr::str_c(gpkg_open_opts, collapse=",")` | `LIST_ALL_TABLES=NO,PRELUDE_STATEMENTS=...` | ❌ Same packing problem |

The documentation for `creation_option` shows this same multi-valued pattern working with `c("TILED=YES", "COMPRESS=DEFLATE")` — but that works because those two values happen to not conflict with each other as a comma-packed string. `open_option` (alias `--oo`) is an `[may be repeated]` argument, and the issue is that your `PRELUDE_STATEMENTS` value **contains semicolons**, while `LIST_ALL_TABLES` is a `string-select` type, so GDAL validates its value before the second option is parsed.[^1_1]

## The Correct Solution: Character Vector with Repeated Argument Names

The fix is to use the **character vector format** with repeated `--open-option` mentions, which is the only way to pass truly independent multi-valued `[may be repeated]` arguments without the packing ambiguity:

```r
gpkg_input_args <- c(
  "--input", gpkg_path,
  "--input-format", gpkg_driver,
  "--input-layer", gpkg_layer,
  "--open-option", "LIST_ALL_TABLES=NO",
  "--open-option", "PRELUDE_STATEMENTS=PRAGMA cache_size=-4000000;PRAGMA temp_store=MEMORY;PRAGMA mmap_size=8589934592;PRAGMA journal_mode=WAL;"
)

gpkg_schema <- gdalraster::gdal_run("vector export-schema", args = gpkg_input_args)$output() |>
  yyjsonr::read_json_str()
```

This mirrors the command-line syntax directly — each `--open-option` mention followed by its own `KEY=VALUE` pair is treated as a separate, independent open option by GDAL's argument parser.[^1_1]

## Why This Works But `list` Doesn't

The documentation explicitly states:[^1_1]

> *"repeated mentions of an argument are possible in the character vector format for argument input, whereas arguments given in named list format must use argument long names as the list element names, **and the packed format for the values**"*

The packed format (comma-joining) is inherently incompatible with `PRELUDE_STATEMENTS` because the value itself can't be cleanly delimited from the next option. The character vector path bypasses this entirely by letting `gdalraster`'s C++ argument parser see each token as a separate CLI element, exactly as if you'd typed them on a shell command line.[^1_1]

## If You Prefer List Format

If you must use a named list (e.g., because you're also passing `GDALRaster`/`GDALVector` objects as input), the only workaround is to pass just one open option at a time, or to open the dataset separately first as a `GDALVector` object with open options set directly on the constructor, then pass that object as the `input` argument:

```r
# Open with open options via GDALVector constructor
lyr <- new(gdalraster::GDALVector,
  gpkg_path,
  gpkg_layer,
  read_only = TRUE,
  open_options = c(
    "LIST_ALL_TABLES=NO",
    "PRELUDE_STATEMENTS=PRAGMA cache_size=-4000000;PRAGMA temp_store=MEMORY;PRAGMA mmap_size=8589934592;PRAGMA journal_mode=WAL;"
  )
)

# Pass the already-opened GDALVector as input (no open_option needed)
gpkg_schema <- gdalraster::gdal_run(
  "vector export-schema",
  args = list(input = lyr)
)$output() |> yyjsonr::read_json_str()
```

This works because `GDALVector`'s constructor accepts `open_options` as a plain character vector of `NAME=VALUE` pairs (each element is one option, no packing), and the already-opened dataset is handed directly to the algorithm without needing to re-open it with open options.[^1_2][^1_1]
<span style="display:none">[^1_10][^1_11][^1_12][^1_13][^1_14][^1_3][^1_4][^1_5][^1_6][^1_7][^1_8][^1_9]</span>

<div align="center">⁂</div>

[^1_1]: https://firelab.github.io/gdalraster/articles/use-gdal-cli-from-r.html

[^1_2]: https://cran.r-project.org/web/packages/gdalraster/refman/gdalraster.html

[^1_3]: https://firelab.github.io/gdalraster/reference/gdal_cli.html

[^1_4]: https://github.com/cran/gdalraster/blob/master/NEWS.md

[^1_5]: https://gdal.org/en/stable/development/rfc/rfc104_gdal_cli.html

[^1_6]: https://firelab.r-universe.dev/gdalraster

[^1_7]: https://rdrr.io/cran/gdalraster/man/rasterize.html

[^1_8]: http://rspatial.r-universe.dev/raster/doc/manual.html

[^1_9]: https://firelab.github.io/gdalraster/reference/GDALRaster-class.html

[^1_10]: https://courses.spatialthoughts.com/gdal-tools.html

[^1_11]: https://cran.r-project.org/web/packages/gdalraster/gdalraster.pdf

[^1_12]: https://firelab.github.io/gdalraster/reference/GDALVector-class.html

[^1_13]: https://archlinux.nic.cz/R/web/packages/gdalraster/vignettes/vector-api-overview.html

[^1_14]: https://www.rdocumentation.org/packages/sf/versions/1.1-1/topics/gdal


---

# the open options can be a character vector, but i need list syntax for the arguments all together for sure. but pretty sure I tried that, i.e. a list w/ open_option = c(...)

You're right — you did try `open_option = c(...)` in list format. Looking at the actual source docs confirms the exact problem.

The documentation example for `creation_option` shows this working:

```r
creation_option = c("TILED=YES", "COMPRESS=DEFLATE")
```

But that works **only because neither of those values contain commas**. The packed format rule is this:[^2_1]

> *"the packed format for the values (which can be a character vector or numeric vector of values)"*

When `gdalraster` processes a named list element whose value is a character vector, it **collapses the vector into a single comma-joined string** before handing it to GDAL's argument parser. So `c("LIST_ALL_TABLES=NO", "PRELUDE_STATEMENTS=...")` becomes `LIST_ALL_TABLES=NO,PRELUDE_STATEMENTS=...` — and GDAL then tries to parse the entire concatenated string as the value for `LIST_ALL_TABLES`, which fails immediately.[^2_1]

## The Fundamental Constraint

In list format, **there is no way to pass two separate `--open-option` values** when one of them contains a comma or semicolon in its value. This is not a bug in your syntax — it is a structural limitation of the list input path. The docs explicitly say repeated mentions of an argument name are only possible in the **character vector format**.[^2_1]

## The Hybrid Approach

Since you need list format for object-passing but character vector format for multi-valued open options, use `c()` to merge both:

```r
# Named list for the args that need object/typed values
base_args <- list(
  input         = gpkg_path,
  input_format  = gpkg_driver,
  input_layer   = gpkg_layer
)

# Convert list to named character vector, then append open-option tokens
args_vec <- c(
  rbind(paste0("--", gsub("_", "-", names(base_args))), unlist(base_args)),
  "--open-option", "LIST_ALL_TABLES=NO",
  "--open-option", "PRELUDE_STATEMENTS=PRAGMA cache_size=-4000000;PRAGMA temp_store=MEMORY;PRAGMA mmap_size=8589934592;PRAGMA journal_mode=WAL;"
)

gpkg_schema <- gdalraster::gdal_run("vector export-schema", args = args_vec)$output() |>
  yyjsonr::read_json_str()
```

However, if your `input` is a `GDALVector` **object** (not a string), you can't pass it through a character vector. In that case, the cleanest real solution remains opening the dataset separately with open options baked in at construction, then handing the object to `gdal_run()`:[^2_1]

```r
lyr <- new(
  gdalraster::GDALVector,
  gpkg_path,
  gpkg_layer,
  read_only = TRUE,
  open_options = c(
    "LIST_ALL_TABLES=NO",
    "PRELUDE_STATEMENTS=PRAGMA cache_size=-4000000;PRAGMA temp_store=MEMORY;PRAGMA mmap_size=8589934592;PRAGMA journal_mode=WAL;"
  )
)

# Now the list has the GDALVector object as input — open options already applied
gpkg_schema <- gdalraster::gdal_run(
  "vector export-schema",
  args = list(input = lyr)
)$output() |>
  yyjsonr::read_json_str()

lyr$close()
```

The `GDALVector` constructor's `open_options` parameter accepts a plain `c(...)` of `NAME=VALUE` strings and applies each one individually (not packed), so this sidesteps the issue entirely. The dataset is already open with the correct options when the algorithm receives it.[^2_1]
<span style="display:none">[^2_2][^2_3][^2_4][^2_5][^2_6][^2_7][^2_8]</span>

<div align="center">⁂</div>

[^2_1]: https://firelab.github.io/gdalraster/reference/gdal_cli.html

[^2_2]: https://gdal.org/en/stable/programs/gdal_cli_from_python.html

[^2_3]: https://cran.r-project.org/web/packages/gdalraster/gdalraster.pdf

[^2_4]: https://github.com/cran/gdalraster/blob/master/NEWS.md

[^2_5]: https://firelab.github.io/gdalraster/articles/use-gdal-cli-from-r.html

[^2_6]: https://grass.osgeo.org/grass-stable/manuals/r.in.gdal.html

[^2_7]: https://firelab.r-universe.dev/gdalraster

[^2_8]: https://rdrr.io/cran/gdalraster/


---

# i tried setting args against the alg directly also and seems like they overwrite each other:

```R
> gpkg_input_args <- list(input = gpkg_path, input_format = gpkg_driver, input_layer = gpkg_layer)
ℹ GDAL DEBUG: [Wed Jun 10 21:00:22 2026].8640, 2470.9840: GDAL: GDALClose(C:/GEODATA/LR_PARCEL_NATIONWIDE_FILE_US_2026_Q1.gpkg, this=0000008011327110)
> gpkg_info_alg <- gdalraster::gdal_alg("vector info", args = gpkg_input_args, parse = FALSE)
> gpkg_info_alg$getExplicitlySetArgs()
list()
> gpkg_info_alg$usage()

Usage: vector info [OPTIONS] <INPUT>...

Return information on a vector dataset. 

Positional arguments:
  -i, --dataset, --input <INPUT>
    Input vector datasets
    [0 or more values]
    [packed values not allowed, repeated arg allowed]
    [required]

Options:
  -f, --of, --format, --output-format <OUTPUT-FORMAT>
    Output format
    [json|text]
  -l, --layer, --input-layer <INPUT-LAYER>
    Input layer name
    [0 or more values]
    [packed values allowed, repeated arg allowed]
    [mutually exclusive with --sql, --fid]
  --features
    List all features (beware of RAM consumption on large layers)
    [mutually exclusive with --summary]
  --summary
    List the layer names and the geometry type
    [mutually exclusive with --features]
  --limit <FEATURE-COUNT>
    Limit the number of features per layer (implies --features)
  --sql <statement>|@<filename>
    Execute the indicated SQL statement and return the result
    [mutually exclusive with --input-layer, --fid]
  --where <WHERE>|@<filename>
    Attribute query in a restricted form of the queries used in the SQL WHERE statement
  --fid <FID>
    Feature identifier
    [mutually exclusive with --input-layer, --sql]
  --dialect <DIALECT>
    SQL dialect
  --output-string <OUTPUT-STRING>
    Output string, in which the result is placed

Advanced options:
  --oo, --open-option <KEY>=<VALUE>
    Open options
    [0 or more values]
    [packed values not allowed, repeated arg allowed]
  --if, --input-format <INPUT-FORMAT>
    Input formats
    [0 or more values]
    [packed values allowed, repeated arg allowed]

Esoteric options:
  --crs-format <CRS-FORMAT>
    Which format to use to report CRS
    [AUTO|WKT2|PROJJSON]
    [default: AUTO]

For more details: <https://gdal.org/programs/gdal_vector_info.html>
> gpkg_open_opts <- c(
+   "LIST_ALL_TABLES=NO",
+   "PRELUDE_STATEMENTS=PRAGMA cache_size=-4000000;PRAGMA temp_store=MEMORY;PRAGMA mmap_size=8589934592;PRAGMA journal_mode=WAL;"
+ )
> gpkg_open_opts[[1]]
[1] "LIST_ALL_TABLES=NO"
> gpkg_info_alg$setArg("open-option", gpkg_open_opts[[1]])
[1] TRUE
> gpkg_info_alg$setArg("open-option", gpkg_open_opts[[2]])
[1] TRUE
> gpkg_info_alg$getExplicitlySetArgs()
$open_option
[1] "PRELUDE_STATEMENTS=PRAGMA cache_size=-4000000;PRAGMA temp_store=MEMORY;PRAGMA mmap_size=8589934592;PRAGMA journal_mode=WAL;"
```

This is a confirmed bug/limitation in the `setArg()` method. The docs describe `$setArg()` as setting **the value** of an argument — it doesn't have any mechanism to accumulate values for `STRING_LIST` type arguments across repeated calls. Each call simply overwrites the previous value.[^3_1]

## Why `setArg()` Overwrites

Looking at `$argInfo()` output for `open-option`, you can confirm it's a `STRING_LIST` type with `repeated_arg_allowed: TRUE` and `packed_values_allowed: FALSE`. The `setArg()` binding maps to a single `GDALAlgorithmArg::Set()` call in C++, which replaces the current value entirely — it has no "append" mode. So your second `setArg("open-option", ...)` call just stomps the first.[^3_1]

## The Actual Working Solution

Given all of this, **character vector format is genuinely the only working path** for multiple open options in `gdal_run()`. The good news is you don't have to sacrifice your other structured args — just mix them via `c()` with the vector:

```r
# Build base args as a named character vector
base_args <- c(
  "--input",        gpkg_path,
  "--input-format", gpkg_driver,
  "--input-layer",  gpkg_layer,
  "--open-option",  "LIST_ALL_TABLES=NO",
  "--open-option",  "PRELUDE_STATEMENTS=PRAGMA cache_size=-4000000;PRAGMA temp_store=MEMORY;PRAGMA mmap_size=8589934592;PRAGMA journal_mode=WAL;"
)

gpkg_schema <- gdalraster::gdal_run(
  "vector export-schema",
  args = base_args
)$output() |>
  yyjsonr::read_json_str()
```

If you need to build args programmatically from a mix of sources, a helper like this keeps it clean:

```r
build_gdal_args <- function(..., open_options = NULL) {
  named_args <- list(...)
  # Convert named list → flat --key value tokens
  tokens <- unlist(lapply(names(named_args), function(k) {
    c(paste0("--", gsub("_", "-", k)), named_args[[k]])
  }))
  # Append each open option with its own --open-option flag
  if (!is.null(open_options)) {
    oo_tokens <- unlist(lapply(open_options, \(v) c("--open-option", v)))
    tokens <- c(tokens, oo_tokens)
  }
  tokens
}

gpkg_input_args <- build_gdal_args(
  input        = gpkg_path,
  input_format = gpkg_driver,
  input_layer  = gpkg_layer,
  open_options = c(
    "LIST_ALL_TABLES=NO",
    "PRELUDE_STATEMENTS=PRAGMA cache_size=-4000000;PRAGMA temp_store=MEMORY;PRAGMA mmap_size=8589934592;PRAGMA journal_mode=WAL;"
  )
)
```

This pattern is safe regardless of how many open options you have, and the semicolons in `PRELUDE_STATEMENTS` are never touched because each option is its own independent token in the character vector — not packed or joined with anything.[^3_1]
<span style="display:none">[^3_10][^3_2][^3_3][^3_4][^3_5][^3_6][^3_7][^3_8][^3_9]</span>

<div align="center">⁂</div>

[^3_1]: https://firelab.github.io/gdalraster/reference/GDALAlg-class.html

[^3_2]: https://lists.osgeo.org/pipermail/gdal-dev/2026-January/061358.html

[^3_3]: https://gdal.org/en/stable/api/python/utilities.html

[^3_4]: https://gdal.org/en/stable/programs/gdal_raster_pipeline.html

[^3_5]: https://cran.r-project.org/web/packages/gdalUtilities/readme/README.html

[^3_6]: https://www.youtube.com/watch?v=M0OS2TN4qLA

[^3_7]: https://github.com/rspatial/terra/issues/518

[^3_8]: https://github.com/qgis/QGIS/issues/26635

[^3_9]: https://issues.qgis.org/journals/diff/93481?detail_id=82203

[^3_10]: https://cloud.r-project.org/web/packages/gpkg/gpkg.pdf


---

# this is not a single thing. I must understand the inner workings to ensure my abstracted systems follow suit. if I have a function for gdal_vector_info() or gdal_vector_export_schema() or any gdal_vector_*() command, i need to know exactly how to provide the open options if provided, and the underlying systems i have in place for declaring open options and creation options etc. are list based and typed, i.e. `gdal_open_opts(list_all_tables = FALSE, prelude_statement = gpkg_prelude_pragmas(cache_size = -4000000, temp_store = "MEMORY", ...), driver = "GPKG")`  or `gpkg_open_opts(list_all_tables = FALSE, ...)` etc. where everything is driven by the underlying metadata parsed from XML for allowed values etc.

You've hit the core architectural tension: your system builds arguments as typed R lists (with metadata-driven validation, typed open options, etc.), but `gdal_run()` / `gdal_alg` with named list format collapses multi-valued `[packed values not allowed, repeated arg allowed]` arguments into a single comma-joined string — which is wrong for `--open-option` since GDAL parses it left-to-right and assigns the whole comma-joined blob to the first key it sees.

Here is the complete mental model and the right design pattern for your abstraction layer.

## Why the Collapse Happens

The docs say:[^4_1]

> *"arguments given in named list format must use argument long names as the list element names, **and the packed format for the values**"*

When `gdal_run()` sees `open_option = c("A=1", "B=2")` in a named list, it treats the entire character vector as one packed-value multi-value: it joins with a comma → `A=1,B=2` → passes that as the value string for the `--open-option` argument. The GDAL argument parser then sees `--open-option A=1,B=2` and interprets `A=1,B=2` as the full `KEY=VALUE` for the first open option. GDAL rejects it because `A=1,B=2` is not a valid value for `LIST_ALL_TABLES`.[^4_1]

The `usage()` output from your session confirmed this definitively:

```
--oo, --open-option <KEY>=<VALUE>
  Open options
  [0 or more values]
  [packed values not allowed, repeated arg allowed]   ← this is the crux
```

`packed values not allowed` means the list input path is fundamentally broken for this argument. There is no named-list syntax that works.

## The Correct Output of Your Abstraction Layer

Your typed option builders (`gpkg_open_opts(...)`, `gdal_open_opts(...)`) should produce a **named character vector** with repeated names, not a list element:

```r
# What your builder must ultimately produce for gdal_run():
c(
  "--open-option", "LIST_ALL_TABLES=NO",
  "--open-option", "PRELUDE_STATEMENTS=PRAGMA cache_size=-4000000;..."
)
```

This maps to the CLI token stream: each `--open-option KEY=VALUE` pair is its own independent token, so GDAL never needs to unpack anything.[^4_1]

## Designing the Abstraction Layer

The key insight is that your builders should have two separate output stages:

1. **Typed/validated R representation** (what your system works with internally)
2. **Serialized character vector** (what gets handed to `gdal_run()`)
```r
# Stage 1: your typed builder — unchanged, clean, metadata-driven
open_opts <- gpkg_open_opts(
  list_all_tables = FALSE,
  prelude_statements = gpkg_prelude_pragmas(
    cache_size = -4000000,
    temp_store = "MEMORY",
    mmap_size  = 8589934592,
    journal_mode = "WAL"
  )
)

# Stage 2: a serializer that knows about the argument's repeat behavior
as_gdal_arg_tokens <- function(arg_name, values) {
  # Each value gets its own --arg-name prefix — handles [repeated arg allowed] args
  flag <- paste0("--", gsub("_", "-", arg_name))
  unlist(lapply(values, \(v) c(flag, v)))
}

# Your open_opts builder produces KEY=VALUE strings internally:
# open_opts$to_kv() → c("LIST_ALL_TABLES=NO", "PRELUDE_STATEMENTS=...")

as_gdal_arg_tokens("open-option", open_opts$to_kv())
# [^4_1] "--open-option"  "LIST_ALL_TABLES=NO"
# [^4_3] "--open-option"  "PRELUDE_STATEMENTS=PRAGMA cache_size=..."
```


## Assembling Mixed Args for `gdal_run()`

Since you need list format for object inputs (a `GDALVector` or `GDALRaster` object can't go in a character vector), use a **two-pass assembly** function:

```r
gdal_build_args <- function(object_args = list(), char_args = list()) {
  # object_args: named list — items that must stay as R objects (GDALVector, GDALRaster)
  # char_args:   named list — serializable args (strings, option vectors)

  # Serialize non-object args into flat --key value token stream
  tokens <- character(0)
  for (nm in names(char_args)) {
    flag   <- paste0("--", gsub("_", "-", nm))
    values <- as.character(char_args[[nm]])
    if (length(values) == 1) {
      tokens <- c(tokens, flag, values)
    } else {
      # [repeated arg allowed] — emit one flag per value
      tokens <- c(tokens, unlist(lapply(values, \(v) c(flag, v))))
    }
  }

  # If there are no object args, just return the token vector (list not needed)
  if (length(object_args) == 0) return(tokens)

  # Mixed case: cannot combine objects + char tokens in one vector.
  # Use the GDALVector constructor pattern instead — open with opts baked in,
  # pass the object, supply remaining tokens as separate args.
  list(
    objects = object_args,
    tokens  = tokens
  )
}
```

In practice, for your workflow, the cleanest split is:

- **Open options** → always bake into `GDALVector`/`GDALRaster` constructor, since those constructors accept `open_options = c(...)` as proper per-element vectors
- **Algorithm args** (layer, format, bbox, creation options, etc.) → your char_args serializer above

```r
# Open the dataset with options — constructor handles them correctly
lyr <- new(
  gdalraster::GDALVector,
  gpkg_path,
  gpkg_layer,
  read_only    = TRUE,
  open_options = open_opts$to_kv()  # c("LIST_ALL_TABLES=NO", "PRELUDE_STATEMENTS=...")
)

# All other algorithm arguments go as a flat token vector
alg_tokens <- gdal_build_args(char_args = list(
  input_format  = gpkg_driver,
  # creation_option is also [repeated arg allowed, packed not allowed]
  # your serializer handles it the same way
  creation_option = c("COMPRESS=LZW", "TILED=YES")
))

result <- gdalraster::gdal_run(
  "vector export-schema",
  args = c(list(input = lyr), as.list(alg_tokens))
)$output() |> yyjsonr::read_json_str()

lyr$close()
```


## Which Arguments Need the Repeat Pattern

From `vector info` usage (and consistent across all GDAL CLI subcommands), any argument with `[packed values not allowed, repeated arg allowed]` requires the multi-token treatment from your serializer. The ones you'll hit most often:[^4_2]


| Argument | Flag | Packed allowed? |
| :-- | :-- | :-- |
| Open options | `--open-option` / `--oo` | ❌ No |
| Input datasets | `--input` / `-i` | ❌ No |
| Creation options | `--co` / `--creation-option` | ✅ Yes (comma-safe values only) |
| Input layer | `--input-layer` / `-l` | ✅ Yes |
| Input format | `--input-format` / `--if` | ✅ Yes |

Your serializer should check the argument's metadata (which you already have from XML parsing) for the `packed_values_allowed` flag, and only use repeated-token emission when it's false.

<div align="center">⁂</div>

[^4_1]: https://firelab.github.io/gdalraster/reference/gdal_cli.html

[^4_2]: https://firelab.github.io/gdalraster/reference/GDALAlg-class.html


---

# yeah ill just stick with vectors then...

# config setup ----------------------------------------------------------------------------------------------------

set_gdal_cfg <- function(key, value) {
old <- gdalraster::get_config_option(key)
gdalraster::set_config_option(key, value)
cli::cli_alert_info("Set GDAL configuration option {.field {key}} to {.field {value}} ({.field {ifelse(old == '', '<unset>', old)} --> {value}})")
invisible(old)
}

unset_gdal_cfg <- function(key) {
old <- gdalraster::get_config_option(key)
if (old == "") {
cli::cli_alert_info("GDAL configuration option {.field {key}} was already unset")
return(invisible(NULL))
} else {
gdalraster::set_config_option(key, "")
cli::cli_alert_info("Unset GDAL configuration option {.field {key}} ({.field {old} --> <unset>})")
return(invisible(old))
}
}

setup_gdal_configs <- function(log_file = NULL) {
set_gdal_cfg("CPL_DEBUG", "ON")
set_gdal_cfg("CPL_LOG_ERRORS", "ON")
set_gdal_cfg("CPL_TIMESTAMP", "ON")
set_gdal_cfg("GDAL_NUM_THREADS", "ALL_CPUS")
if (!is.null(log_file)) {
set_gdal_cfg("CPL_LOG", log_file)
}
invisible(TRUE)
}

reset_gdal_configs <- function() {
unset_gdal_cfg("CPL_DEBUG")
unset_gdal_cfg("CPL_LOG_ERRORS")
unset_gdal_cfg("CPL_TIMESTAMP")
unset_gdal_cfg("GDAL_NUM_THREADS")
unset_gdal_cfg("CPL_LOG")
invisible(TRUE)
}

# gpkg inputs -----------------------------------------------------------------------------------------------------

gpkg_path <- "C:/GEODATA/LR_PARCEL_NATIONWIDE_FILE_US_2026_Q1.gpkg"
gpkg_driver <- gdalraster::ogr_ds_format(gpkg_path)
gpkg_layer <- gdalraster::ogr_ds_layer_names(gpkg_path)[[1]]
gpkg_open_opts <- c(
"LIST_ALL_TABLES=NO",
"PRELUDE_STATEMENTS=PRAGMA cache_size=-4000000;PRAGMA temp_store=MEMORY;PRAGMA mmap_size=8589934592;PRAGMA journal_mode=WAL;"
)

gpkg_open_opts <- c(
"--open-option", "LIST_ALL_TABLES=NO",
"--open-option", "PRELUDE_STATEMENTS=PRAGMA cache_size=-4000000;PRAGMA temp_store=MEMORY;PRAGMA mmap_size=8589934592;PRAGMA journal_mode=WAL;"
)

selected_state_fips <- "13"

# schema / info analysis ------------------------------------------------------------------------------------------

setup_gdal_configs(log_file = "dev/gdal.log")

# alg > run > output() > close/release

gpkg_input_args <- c("--input", gpkg_path, "--input-format", gpkg_driver, "--input-layer", gpkg_layer, gpkg_open_opts)
gpkg_info_alg <- gdalraster::gdal_alg("vector info", args = gpkg_input_args)
gpkg_info_alg$getExplicitlySetArgs()
gpkg_info_alg$run()
gpkg_info_json <- gpkg_info_alg$output() |> jsonlite::fromJSON(simplifyVector = FALSE)
gpkg_info_alg$close()
gpkg_info_alg\$release()

# or directly run > output() > close/release

gdalraster::gdal_run("vector info", gpkg_input_args)\$output() |> jsonlite::fromJSON(simplifyVector = FALSE)

This looks clean and correct. A few notes worth knowing as you build out your abstraction layer:

## What You Have Now Is Right

The vector format with interleaved `--open-option` tokens is the canonical approach for any `[packed values not allowed, repeated arg allowed]` argument. Your `gpkg_open_opts` vector is exactly the right shape — each flag/value pair is independent, GDAL parses them sequentially with no ambiguity.[^5_1]

## Minor Optimization: Skip Redundant `--input-format`

`gdalraster::ogr_ds_format()` drives a full format probe anyway, and GDAL auto-detects GPKG reliably. Specifying `--input-format` is fine for explicitness, but note that when you pass an `--input-format` that triggers strict validation, any mismatch between what you pass and what GDAL auto-detects can produce noisy warnings. For a well-known extension like `.gpkg` it's a non-issue, but in your abstraction layer you may want to make `input_format` optional (omit the tokens entirely when `NULL`) rather than always emitting it.[^5_1]

## `gdal_alg()` vs `gdal_run()` — When Each Makes Sense

Given you're building typed wrapper functions, the distinction matters:

```r
# gdal_alg() — useful when you need to:
# 1. Inspect argument metadata before running ($argInfo(), $usage())
# 2. Run the same algorithm multiple times with different args
# 3. Access outputs as objects (not just serialized strings)
gpkg_info_alg <- gdalraster::gdal_alg("vector info", args = gpkg_input_args)
gpkg_info_alg$run()
out <- gpkg_info_alg$output()
gpkg_info_alg$close()
gpkg_info_alg$release()   # <-- don't forget this, releases the C++ object

# gdal_run() — useful when you just need the output in one shot
# Handles close/release internally
out <- gdalraster::gdal_run("vector info", gpkg_input_args)$output()
```

For your `gdal_vector_info()`, `gdal_vector_export_schema()` etc. wrappers, `gdal_run()` is the right inner call — it's cleaner and handles lifecycle automatically. Reserve `gdal_alg()` for cases where you need to interrogate the algorithm object itself (e.g., a debug/introspection utility).[^5_2]

## Suggested Wrapper Pattern

```r
gdal_vector_info <- function(
  input,
  layer       = NULL,
  input_fmt   = NULL,
  open_opts   = NULL,   # c("LIST_ALL_TABLES=NO", "PRELUDE_STATEMENTS=...")
  summary     = FALSE,
  parse       = TRUE
) {
  args <- c("--input", input)
  if (!is.null(input_fmt))  args <- c(args, "--input-format", input_fmt)
  if (!is.null(layer))      args <- c(args, "--input-layer",  layer)
  if (isTRUE(summary))      args <- c(args, "--summary")

  # Repeated-arg emission for open options
  if (!is.null(open_opts)) {
    args <- c(args, unlist(lapply(open_opts, \(v) c("--open-option", v))))
  }

  out <- gdalraster::gdal_run("vector info", args)$output()
  if (parse) jsonlite::fromJSON(out, simplifyVector = FALSE) else out
}
```

This keeps the `open_opts` argument as a plain `c("KEY=VALUE", ...)` character vector (the natural form your metadata-driven builders produce), and the `lapply` in the body handles the repeated-token emission. When you add `creation_option` support for write operations, the same `lapply` pattern handles `--co` identically since it's also `[repeated arg allowed]`.[^5_1]

<div align="center">⁂</div>

[^5_1]: https://firelab.github.io/gdalraster/reference/gdal_cli.html

[^5_2]: https://firelab.github.io/gdalraster/reference/GDALAlg-class.html


---

# THIS IS NOT A SINGLE THING. I NEED TO ENSURE ALL ARGUMENTS WORK AS EXPECTED.

Fair — you want a comprehensive picture of every argument category in the GDAL CLI vector commands and exactly how each serializes from R. Let me lay this out systematically using the `vector info` usage you showed as a reference, covering every argument type and its correct character vector form.

## The Two Fundamental Argument Classes

From `$usage()` output, every argument falls into one of two repeat modes — and that's the **only** thing that determines how you emit tokens:


| Mode | Flag | How to emit |
| :-- | :-- | :-- |
| `[packed values not allowed, repeated arg allowed]` | `--open-option`, `--input` | One `c("--flag", "value")` pair **per value** |
| `[packed values allowed, repeated arg allowed]` | `--input-layer`, `--input-format`, `--co` | Either repeated pairs **or** one `c("--flag", "v1,v2,v3")` — both work |
| Single value | `--limit`, `--sql`, `--where`, `--dialect` | One `c("--flag", "value")` pair |
| Boolean (no value) | `--features`, `--summary` | Just `"--flag"` — no following value |

## Every Argument Type, Correctly Serialized

### Boolean (flag-only) arguments

```r
# --summary, --features, --overwrite, etc.
args <- c("--summary")

# In your builder:
if (summary) args <- c(args, "--summary")
```


### Single-value arguments

```r
# --limit, --sql, --where, --dialect, --output-format
args <- c(args, "--limit", "1000")
args <- c(args, "--where", "statefp = '13'")
args <- c(args, "--sql", "SELECT * FROM lr_parcel_us WHERE statefp = '13'")
args <- c(args, "--output-format", "json")
```


### Multi-value, packed allowed (`--input-layer`, `--input-format`, `--co`)

```r
# Both forms are valid — prefer the repeated-pair form for safety,
# since it works even if a value accidentally contains a comma
args <- c(args, "--input-layer", "layer_a", "--input-layer", "layer_b")
# OR (comma-packed, only safe when values have no commas):
args <- c(args, "--input-layer", "layer_a,layer_b")

# Creation options — values never contain commas so packed is fine:
args <- c(args, "--co", "COMPRESS=LZW", "--co", "TILED=YES")
# OR:
args <- c(args, "--co", "COMPRESS=LZW,TILED=YES")
```


### Multi-value, packed NOT allowed (`--open-option`, `--input`)

```r
# Must always be repeated pairs — the lapply pattern:
open_opts <- c(
  "LIST_ALL_TABLES=NO",
  "PRELUDE_STATEMENTS=PRAGMA cache_size=-4000000;PRAGMA temp_store=MEMORY;..."
)
args <- c(args, unlist(lapply(open_opts, \(v) c("--open-option", v))))

# Multiple inputs (pipeline commands):
inputs <- c("file_a.gpkg", "file_b.gpkg")
args <- c(args, unlist(lapply(inputs, \(v) c("--input", v))))
```


### Positional arguments

```r
# Positional = no flag prefix, order matters (inputs first, output last)
# For single input + single output you can omit flags entirely:
args <- c(gpkg_path, output_path)

# But named form is safer and what you want in an abstraction:
args <- c("--input", gpkg_path, "--output", output_path)
```


## The Universal Builder

Given all of the above, one helper covers your entire abstraction layer correctly:

```r
gdal_args <- function(...) {
  pairs <- list(...)
  tokens <- character(0)

  for (nm in names(pairs)) {
    flag <- paste0("--", gsub("_", "-", nm))
    val  <- pairs[[nm]]

    if (isTRUE(val) || identical(val, "")) {
      # Boolean flag — emit name only
      tokens <- c(tokens, flag)
    } else if (isFALSE(val) || is.null(val)) {
      # Skip entirely
    } else {
      # Always use repeated pairs — safe for both packed-allowed and packed-not-allowed
      tokens <- c(tokens, unlist(lapply(as.character(val), \(v) c(flag, v))))
    }
  }

  tokens
}
```

This handles every case:

```r
gdal_args(
  input          = gpkg_path,
  input_format   = gpkg_driver,
  input_layer    = gpkg_layer,
  open_option    = c("LIST_ALL_TABLES=NO", "PRELUDE_STATEMENTS=PRAGMA ...;"),
  where          = "statefp = '13'",
  summary        = TRUE,       # → "--summary" only
  features       = FALSE,      # → omitted
  output_format  = NULL        # → omitted
)
# [^6_1] "--input"         "C:/GEODATA/..."
# [^6_3] "--input-format"  "GPKG"
# [^6_5] "--input-layer"   "lr_parcel_us"
# [^6_7] "--open-option"   "LIST_ALL_TABLES=NO"
# [^6_9] "--open-option"   "PRELUDE_STATEMENTS=PRAGMA ...;"
# [^6_11] "--where"        "statefp = '13'"
# [^6_13] "--summary"
```

Using repeated pairs everywhere — even for `packed values allowed` args — is safe because GDAL accepts repeated args for all multi-value arguments. You gain uniformity and never have to track which args allow packing. The only reason to ever use packed form is for user-facing brevity, which your abstraction doesn't need.
<span style="display:none">[^6_2][^6_4][^6_6][^6_8]</span>

<div align="center">⁂</div>

[^6_1]: https://bugzmanov.github.io/cleancode-critique/chapter_35

[^6_2]: https://www.reddit.com/r/datingoverthirty/comments/vudtou/how_do_you_decide_what_situations_qualities_or/

[^6_3]: https://heysigmund.com/fighting-fair/

[^6_4]: https://stackoverflow.com/questions/6471946/verifying-variable-arguments-are-of-expected-type

[^6_5]: https://discuss.hashicorp.com/t/how-to-conditionally-use-different-arguments/49154

[^6_6]: https://github.com/devlooped/moq/issues/560

[^6_7]: https://www.alignmentforum.org/posts/NxF5G6CJiof6cemTw/coherence-arguments-do-not-entail-goal-directed-behavior

[^6_8]: https://www.facebook.com/groups/maxmspjitter/posts/10162434760864392/

[^6_9]: https://ziggit.dev/t/optional-generic-argument/10684

