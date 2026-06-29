# GDAL Vector Driver Options Reference

> Ground-truth option metadata for the focus drivers, generated from the installed GDAL build 
> (GDAL 3.13.0 "Iowa City", released 2026/05/04) via the package metadata accessors 
> (`gdal_driver_get_open_opts()` / `gdal_driver_get_creation_opts()`). 
> Regenerate with `Rscript dev/scratch/gen_driver_options.R`.

Config options (global CPL/OGR `--config` options) are documented separately in `gdal-config-options.md`; they are not part of driver open/creation metadata.

## GPKG

- long name: GeoPackage
- extensions: gpkg, gpkg.zip
- read/write: rw+u
- vsi: TRUE
- multi-layer: TRUE
- sql dialects: NATIVE, OGRSQL, SQLITE

### Open options (`--oo`)

| Option | Type | Default | Allowed values | Description |
|---|---|---|---|---|
| `LIST_ALL_TABLES` | string-select | AUTO | `AUTO`, `YES`, `NO` | Whether all tables, including those non listed in gpkg_contents, should be listed |
| `PRELUDE_STATEMENTS` | string |  |  | SQL statement(s) to send on the SQLite connection before any other ones |
| `NOLOCK` | boolean |  |  | Whether the database should be opened in nolock mode |
| `IMMUTABLE` | boolean |  |  | Whether the database should be opened in immutable mode |

### Creation options (`--co` dataset / `--lco` layer)

| Option | Type | Level | Default | Allowed values | Description |
|---|---|---|---|---|---|
| `VERSION` | string-select | dataset | AUTO | `AUTO`, `1.0`, `1.1`, `1.2`, `1.3`, `1.4` | Set GeoPackage version (for application_id and user_version fields) |
| `DATETIME_FORMAT` | string-select | dataset | WITH_TZ | `WITH_TZ`, `UTC` | How to encode DateTime not in UTC |
| `ADD_GPKG_OGR_CONTENTS` | boolean | dataset | YES |  | Whether to add a gpkg_ogr_contents table to keep feature count |
| `CRS_WKT_EXTENSION` | boolean | dataset |  |  | Whether to create the database with the crs_wkt extension |
| `METADATA_TABLES` | boolean | dataset |  |  | Whether to create the metadata related system tables |
| `LAUNDER` | boolean | layer | NO |  | Whether layer and field names will be laundered. |
| `GEOMETRY_NAME` | string | layer | geom |  | Name of geometry column. |
| `GEOMETRY_NULLABLE` | boolean | layer | YES |  | Whether the values of the geometry column can be NULL |
| `SRID` | integer | layer |  |  | Forced srs_id of the entry in the gpkg_spatial_ref_sys table to point to |
| `DISCARD_COORD_LSB` | boolean | layer | NO |  | Whether the geometry coordinate precision should be used to set to zero non-significant least-significant bits of geometries. Helps when further compression is used |
| `UNDO_DISCARD_COORD_LSB_ON_READING` | boolean | layer | NO |  | Whether to ask GDAL to take into coordinate precision to undo the effects of DISCARD_COORD_LSB |
| `FID` | string | layer | fid |  | Name of the FID column to create |
| `OVERWRITE` | boolean | layer | NO |  | Whether to overwrite an existing table with the layer name to be created |
| `PRECISION` | boolean | layer | YES |  | Whether text fields created should keep the width |
| `TRUNCATE_FIELDS` | boolean | layer | NO |  | Whether to truncate text content that exceeds maximum width |
| `SPATIAL_INDEX` | boolean | layer | YES |  | Whether to create a spatial index |
| `IDENTIFIER` | string | layer |  |  | Identifier of the layer, as put in the contents table |
| `DESCRIPTION` | string | layer |  |  | Description of the layer, as put in the contents table |
| `ASPATIAL_VARIANT` | string-select | layer | GPKG_ATTRIBUTES | `GPKG_ATTRIBUTES`, `NOT_REGISTERED` | How to register non spatial tables |
| `DATETIME_PRECISION` | string-select | layer | AUTO | `AUTO`, `MILLISECOND`, `SECOND`, `MINUTE` | Number of components of datetime fields |

## FlatGeobuf

- long name: FlatGeobuf
- extensions: fgb
- read/write: rw+
- vsi: TRUE
- multi-layer: FALSE
- sql dialects: OGRSQL, SQLITE

### Open options (`--oo`)

| Option | Type | Default | Allowed values | Description |
|---|---|---|---|---|
| `VERIFY_BUFFERS` | boolean | YES |  | Verify flatbuffers integrity |

### Creation options (`--co` dataset / `--lco` layer)

| Option | Type | Level | Default | Allowed values | Description |
|---|---|---|---|---|---|
| `SPATIAL_INDEX` | boolean | layer | YES |  | Whether to create a spatial index |
| `TEMPORARY_DIR` | string | layer |  |  | Directory where temporary file should be created |
| `TITLE` | string | layer |  |  | Layer title |
| `DESCRIPTION` | string | layer |  |  | Layer description |

## Parquet

- long name: (Geo)Parquet
- extensions: parquet
- read/write: rw+u
- vsi: TRUE
- multi-layer: FALSE
- sql dialects: OGRSQL, SQLITE

### Open options (`--oo`)

| Option | Type | Default | Allowed values | Description |
|---|---|---|---|---|
| `GEOM_POSSIBLE_NAMES` | string | geometry,wkb_geometry,wkt_geometry |  | Comma separated list of possible names for geometry column(s). |
| `CRS` | string |  |  | Set/override CRS, typically defined as AUTH:CODE (e.g EPSG:4326), of geometry column(s) |
| `LISTS_AS_STRING_JSON` | boolean | NO |  | Whether lists of strings/integers/reals should be reported as String(JSON) fields rather than String/Integer[64]/RealList. Useful when null values in such lists must be exactly mapped as such. |

### Creation options (`--co` dataset / `--lco` layer)

| Option | Type | Level | Default | Allowed values | Description |
|---|---|---|---|---|---|
| `COMPRESSION` | string-select | layer | SNAPPY | `NONE`, `SNAPPY`, `GZIP`, `BROTLI`, `ZSTD`, `LZ4_RAW`, `LZ4_HADOOP` | Compression method |
| `COMPRESSION_LEVEL` | int | layer | -1 |  | Compression level, codec dependent. GZIP: [1,9], default=9. BROTLI: [0,11], default=8. ZSTD: [-131072,22], default=9. LZ4_RAW: [1,12], default=1. |
| `GEOMETRY_ENCODING` | string-select | layer | WKB | `WKB`, `WKT`, `GEOARROW`, `GEOARROW_INTERLEAVED` | Encoding of geometry columns |
| `ROW_GROUP_SIZE` | integer | layer | 65536 |  | Maximum number of rows per group |
| `GEOMETRY_NAME` | string | layer | geometry |  | Name of geometry column |
| `COORDINATE_PRECISION` | float | layer |  |  | Number of decimals for coordinates (only for GEOMETRY_ENCODING=WKT) |
| `FID` | string | layer |  |  | Name of the FID column to create |
| `POLYGON_ORIENTATION` | string-select | layer | COUNTERCLOCKWISE | `COUNTERCLOCKWISE`, `UNMODIFIED` | Which ring orientation to use for polygons |
| `EDGES` | string-select | layer | PLANAR | `PLANAR`, `SPHERICAL` | Name of the coordinate system for the edges |
| `CREATOR` | string | layer |  |  | Name of creating application |
| `WRITE_COVERING_BBOX` | string-select | layer | AUTO | `AUTO`, `YES`, `NO` | Whether to write xmin/ymin/xmax/ymax columns with the bounding box of geometries |
| `COVERING_BBOX_NAME` | string | layer |  |  | Name of the bounding box of geometries. If not same, equals to {'GEOMETRY_NAME}_bbox' |
| `USE_PARQUET_GEO_TYPES` | string-select | layer | NO | `YES`, `NO`, `ONLY` | Whether to use Parquet Geometry/Geography logical types (introduced in libarrow 21), when using GEOMETRY_ENCODING=WKB encoding |
| `SORT_BY_BBOX` | boolean | layer | NO |  | Whether features should be sorted based on the bounding box of their geometries |
| `TIMESTAMP_WITH_OFFSET` | string-select | layer | AUTO | `AUTO`, `YES`, `NO` | Whether timestamp with offset fields should be used |

## ESRI Shapefile

- long name: ESRI Shapefile
- extensions: shp, dbf, shz, shp.zip
- read/write: rw+u
- vsi: TRUE
- multi-layer: FALSE
- sql dialects: OGRSQL, SQLITE

### Open options (`--oo`)

| Option | Type | Default | Allowed values | Description |
|---|---|---|---|---|
| `ENCODING` | string |  |  | to override the encoding interpretation of the DBF with any encoding supported by CPLRecode or to "" to avoid any recoding |
| `DBF_DATE_LAST_UPDATE` | string |  |  | Modification date to write in DBF header with YYYY-MM-DD format |
| `ADJUST_TYPE` | boolean | NO |  | Whether to read whole .dbf to adjust Real->Integer/Integer64 or Integer64->Integer field types if possible |
| `ADJUST_GEOM_TYPE` | string-select | FIRST_SHAPE | `NO`, `FIRST_SHAPE`, `ALL_SHAPES` | Whether and how to adjust layer geometry type from actual shapes |
| `AUTO_REPACK` | boolean | YES |  | Whether the shapefile should be automatically repacked when needed |
| `DBF_EOF_CHAR` | boolean | YES |  | Whether to write the 0x1A end-of-file character in DBF files |

### Creation options (`--co` dataset / `--lco` layer)

| Option | Type | Level | Default | Allowed values | Description |
|---|---|---|---|---|---|
| `SHPT` | string-select | layer | automatically detected | `POINT`, `ARC`, `POLYGON`, `MULTIPOINT`, `POINTZ`, `ARCZ`, `POLYGONZ`, `MULTIPOINTZ`, `POINTM`, `ARCM`, `POLYGONM`, `MULTIPOINTM`, `POINTZM`, `ARCZM`, `POLYGONZM`, `MULTIPOINTZM`, `MULTIPATCH`, `NONE`, `NULL` | type of shape |
| `2GB_LIMIT` | boolean | layer | NO |  | Restrict .shp and .dbf to 2GB |
| `ENCODING` | string | layer | LDID/87 |  | DBF encoding |
| `RESIZE` | boolean | layer | NO |  | To resize fields to their optimal size. |
| `SPATIAL_INDEX` | boolean | layer | NO |  | To create a spatial index. |
| `DBF_DATE_LAST_UPDATE` | string | layer |  |  | Modification date to write in DBF header with YYYY-MM-DD format |
| `AUTO_REPACK` | boolean | layer | YES |  | Whether the shapefile should be automatically repacked when needed |
| `DBF_EOF_CHAR` | boolean | layer | YES |  | Whether to write the 0x1A end-of-file character in DBF files |

## OpenFileGDB

- long name: ESRI FileGeodatabase (using OpenFileGDB)
- extensions: gdb
- read/write: rw+u
- vsi: TRUE
- multi-layer: TRUE
- sql dialects: OGRSQL, SQLITE

### Open options (`--oo`)

| Option | Type | Default | Allowed values | Description |
|---|---|---|---|---|
| `LIST_ALL_TABLES` | string-select | NO | `YES`, `NO` | Whether all tables, including system and internal tables (such as GDB_* tables) should be listed |

### Creation options (`--co` dataset / `--lco` layer)

| Option | Type | Level | Default | Allowed values | Description |
|---|---|---|---|---|---|
| `TARGET_ARCGIS_VERSION` | string-select | layer | ALL | `ALL`, `ARCGIS_PRO_3_2_OR_LATER` |  |
| `FEATURE_DATASET` | string | layer |  |  | FeatureDataset folder into which to put the new layer |
| `LAYER_ALIAS` | string | layer |  |  | Alias of layer name |
| `GEOMETRY_NAME` | string | layer | SHAPE |  | Name of geometry column |
| `GEOMETRY_NULLABLE` | boolean | layer | YES |  | Whether the values of the geometry column can be NULL |
| `FID` | string | layer | OBJECTID |  | Name of OID column |
| `XYTOLERANCE` | float | layer |  |  | Snapping tolerance, used for advanced ArcGIS features like network and topology rules, on 2D coordinates, in the units of the CRS |
| `ZTOLERANCE` | float | layer |  |  | Snapping tolerance, used for advanced ArcGIS features like network and topology rules, on Z coordinates, in the units of the CRS |
| `MTOLERANCE` | float | layer |  |  | Snapping tolerance, used for advanced ArcGIS features like network and topology rules, on M coordinates |
| `XORIGIN` | float | layer |  |  | X origin of the coordinate precision grid |
| `YORIGIN` | float | layer |  |  | Y origin of the coordinate precision grid |
| `ZORIGIN` | float | layer |  |  | Z origin of the coordinate precision grid |
| `MORIGIN` | float | layer |  |  | M origin of the coordinate precision grid |
| `XYSCALE` | float | layer |  |  | X,Y scale of the coordinate precision grid |
| `ZSCALE` | float | layer |  |  | Z scale of the coordinate precision grid |
| `MSCALE` | float | layer |  |  | M scale of the coordinate precision grid |
| `CREATE_MULTIPATCH` | boolean | layer | NO |  | Whether to write geometries of layers of type MultiPolygon as MultiPatch |
| `COLUMN_TYPES` | string | layer |  |  | A list of strings of format field_name=fgdb_field_type (separated by comma) to force the FileGDB column type of fields to be created |
| `DOCUMENTATION` | string | layer |  |  | XML documentation |
| `CONFIGURATION_KEYWORD` | string-select | layer | DEFAULTS | `DEFAULTS`, `MAX_FILE_SIZE_4GB`, `MAX_FILE_SIZE_256TB`, `TEXT_UTF16` | Customize how data is stored. By default text in UTF-8 and data up to 1TB |
| `TIME_IN_UTC` | boolean | layer | NO |  | Whether datetime fields should be considered to be in UTC |
| `CREATE_SHAPE_AREA_AND_LENGTH_FIELDS` | boolean | layer | NO |  | Whether to create special Shape_Length and Shape_Area fields |

## PMTiles

- long name: ProtoMap Tiles
- extensions: pmtiles
- read/write: rw+
- vsi: TRUE
- multi-layer: FALSE
- sql dialects: 

### Open options (`--oo`)

| Option | Type | Default | Allowed values | Description |
|---|---|---|---|---|
| `ZOOM_LEVEL` | integer |  |  | Zoom level of full resolution. If not specified, maximum non-empty zoom level |
| `CLIP` | boolean | YES |  | Whether to clip geometries to tile extent |
| `ZOOM_LEVEL_AUTO` | boolean | NO |  | Whether to auto-select the zoom level for vector layers according to spatial filter extent. Only for display purpose |
| `JSON_FIELD` | boolean |  |  | For vector layers, whether to put all attributes as a serialized JSon dictionary |

### Creation options (`--co` dataset / `--lco` layer)

| Option | Type | Level | Default | Allowed values | Description |
|---|---|---|---|---|---|
| `MINZOOM` | int | dataset | 0 |  | Minimum zoom level |
| `MAXZOOM` | int | dataset | 5 |  | Maximum zoom level |
| `CONF` | string | dataset |  |  | Layer configuration as a JSon serialized string, or a filename pointing to a JSon file |
| `SIMPLIFICATION` | float | dataset |  |  | Simplification factor |
| `SIMPLIFICATION_MAX_ZOOM` | float | dataset |  |  | Simplification factor at max zoom |
| `EXTENT` | unsigned int | dataset | 4096 |  | Number of units in a tile |
| `BUFFER` | unsigned int | dataset | 80 |  | Number of units for geometry buffering |
| `MAX_SIZE` | unsigned int | dataset | 500000 |  | Maximum size of a tile in bytes |
| `MAX_FEATURES` | unsigned int | dataset | 200000 |  | Maximum number of features per tile |
| `MINZOOM` | int | layer |  |  | Minimum zoom level |
| `MAXZOOM` | int | layer |  |  | Maximum zoom level |
| `NAME` | string | layer |  |  | Target layer name |
| `DESCRIPTION` | string | layer |  |  | A description of the layer |

## GeoJSON

- long name: GeoJSON
- extensions: json, geojson
- read/write: rw+u
- vsi: TRUE
- multi-layer: FALSE
- sql dialects: OGRSQL, SQLITE

### Open options (`--oo`)

| Option | Type | Default | Allowed values | Description |
|---|---|---|---|---|
| `FLATTEN_NESTED_ATTRIBUTES` | boolean | NO |  | Whether to recursively explore nested objects and produce flatten OGR attributes |
| `NESTED_ATTRIBUTE_SEPARATOR` | string | _ |  | Separator between components of nested attributes |
| `FEATURE_SERVER_PAGING` | boolean |  |  | Whether to automatically scroll through results with a ArcGIS Feature Service endpoint |
| `NATIVE_DATA` | boolean | NO |  | Whether to store the native JSon representation at FeatureCollection and Feature level |
| `ARRAY_AS_STRING` | boolean | NO |  | Whether to expose JSon arrays of strings, integers or reals as a OGR String |
| `DATE_AS_STRING` | boolean | NO |  | Whether to expose date/time/date-time content using dedicated OGR date/time/date-time types or as a OGR String |
| `FOREIGN_MEMBERS` | string-select | AUTO | `AUTO`, `ALL`, `NONE`, `STAC` | Whether and how foreign members at the feature level should be processed as OGR fields |
| `OGR_SCHEMA` | string |  |  | Partially or totally overrides the auto-detected schema to use for creating the layer. The overrides are defined as a JSON list of field definitions. This can be a filename or a JSON string or a URL. |

### Creation options (`--co` dataset / `--lco` layer)

| Option | Type | Level | Default | Allowed values | Description |
|---|---|---|---|---|---|
| `WRITE_BBOX` | boolean | layer | NO |  | whether to write a bbox property with the bounding box of the geometries at the feature and feature collection level |
| `COORDINATE_PRECISION` | int | layer |  |  | Number of decimal for coordinates. Default is 15 for GJ2008 and 7 for RFC7946 |
| `SIGNIFICANT_FIGURES` | int | layer | 17 |  | Number of significant figures for floating-point values |
| `NATIVE_DATA` | string | layer |  |  | FeatureCollection level elements. |
| `NATIVE_MEDIA_TYPE` | string | layer |  |  | Format of NATIVE_DATA. Must be "application/vnd.geo+json", otherwise NATIVE_DATA will be ignored. |
| `RFC7946` | boolean | layer | NO |  | Whether to use RFC 7946 standard. Otherwise GeoJSON 2008 initial version will be used |
| `WRAPDATELINE` | boolean | layer | YES |  | Whether to apply heuristics to split geometries that cross dateline. |
| `WRITE_NAME` | boolean | layer | YES |  | Whether to write a "name" property at feature collection level with layer name |
| `DESCRIPTION` | string | layer |  |  | (Long) description to write in a "description" property at feature collection level |
| `ID_FIELD` | string | layer |  |  | Name of the source field that must be used as the id member of Feature features |
| `ID_TYPE` | string-select | layer |  | `AUTO`, `String`, `Integer` | Type of the id member of Feature features |
| `ID_GENERATE` | boolean | layer |  |  | Auto-generate feature ids |
| `WRITE_NON_FINITE_VALUES` | boolean | layer | NO |  | Whether to write NaN / Infinity values |
| `AUTODETECT_JSON_STRINGS` | boolean | layer | YES |  | Whether to try to interpret string fields as JSON arrays or objects |
| `FOREIGN_MEMBERS_FEATURE` | string | layer |  |  | Extra JSON content to add in each feature as a foreign members |
| `FOREIGN_MEMBERS_COLLECTION` | string | layer |  |  | Extra JSON content to add to the feature collection as a foreign members |

