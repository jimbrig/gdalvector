# GDAL/CPL Configuration Options for `gdalvector`

> Scope: the GDAL/CPL/OGR **configuration options** (global "knobs", set via environment
> variables, `--config KEY=VALUE`, a `gdalrc` file, or the CPL API) that are relevant to the
> five focus drivers: **GPKG**, **FlatGeobuf**, **(Geo)Parquet**, **ESRI Shapefile**, and
> **OpenFileGDB** — plus the VSI / networking layer used for remote reads of FGB / GeoParquet /
> PMTiles.
>
> Verified against GDAL **stable** docs (target GDAL >= 3.11, latest 3.13). Each value below
> carries a one-line description, scope, valid values, default, and the driver(s) affected.
> Options not found in the live driver/config docs but confirmed from GDAL source are flagged
> **[source-only]**; genuinely uncertain ones are flagged **[uncertain]**.

## 0. What a "configuration option" is (and is not)

Configuration options are **global variables that alter GDAL/OGR behavior**, distinct from
build-time options. They are *not* the same as driver **open options** (`--oo`, per source) or
**creation options** (`--lco` layer / `--dsco` dataset, per output), which come from driver
metadata. See the package `LANGUAGE.md` opts-scoping table — config opts land in the **gdalrc**
artifact, never inside an in-process GDALG.

Source: [Configuration options](https://gdal.org/en/stable/user/configoptions.html)

### How they are set (and when they take effect)

| Mechanism | API / syntax | Notes |
|---|---|---|
| Environment variable | `export OGR_SQLITE_CACHE=512` (Unix), `set ...` (Windows) | Read at runtime; wins over `gdalrc` unless `[directives] ignore-env-vars=yes` |
| CLI switch | `--config KEY=VALUE` (single string since GDAL 3.9) or `--config KEY VALUE` | A few options "are not evaluated in time to affect behavior" |
| CPL API (global) | `CPLSetConfigOption(key, val)` → R: `gdalraster::set_config_option(key, val)` | Applies to all threads |
| CPL API (thread-local) | `CPLSetThreadLocalConfigOption(key, val)` | Current thread only |
| Config file | `gdalrc` `[configoptions]` section; path via `GDAL_CONFIG_FILE` | Loaded at driver registration |

Booleans accept `YES`/`TRUE`/`ON` and `NO`/`FALSE`/`OFF`.

**Runtime-settable in R**: virtually all of these can be set with
`gdalraster::set_config_option(key, value)` / read with `get_config_option(key)` *before* the
relevant `GDALOpenEx`/`CreateLayer` call. The practical caveat is **timing**, not API support:
options consulted only at open time (SQLite PRAGMAs, VSI readdir behavior, curl HEAD) must be set
*before* the dataset is opened; cache sizes consulted once (e.g. `GDAL_CACHEMAX`) are best set via
their dedicated setters (`gdalraster::set_cache_max()`) once the process is running.

**Detecting typos**: since GDAL 3.11, setting `CPL_DEBUG=ON` makes GDAL warn on unknown config
option names (`CPLSetConfigOption() called with key=..., which is unknown to GDAL`). Useful in the
package test suite.

---

## 1. GPKG / SQLite

These affect the **GPKG** driver (and the sibling **SQLite/Spatialite** driver, which shares the
performance machinery). Documented under the GPKG and SQLite driver "Configuration options"
sections.

| Option | Description | Valid values | Default | Affects |
|---|---|---|---|---|
| `OGR_SQLITE_SYNCHRONOUS` | Issues `PRAGMA synchronous`; `OFF` speeds writes at the cost of crash safety | `OFF` / `NORMAL` / `FULL` / `ON` | (SQLite default `FULL`) | GPKG, SQLite |
| `OGR_SQLITE_JOURNAL` | Sets the SQLite journal mode (see PRAGMA `journal_mode`) | `DELETE`/`TRUNCATE`/`PERSIST`/`MEMORY`/`WAL`/`OFF` | (SQLite default `DELETE`) | GPKG, SQLite |
| `OGR_SQLITE_CACHE` | SQLite page-cache size **in MB**; 512–1024 can greatly help large DBs | integer (MB) | ~2000 pages (~20 MB) | GPKG, SQLite |
| `OGR_SQLITE_PRAGMA` | Pass-through for **any** PRAGMA(s): `"name=val[,name2=val2]*"` | PRAGMA list | — | GPKG, SQLite |
| `OGR_SQLITE_LOAD_EXTENSIONS` | Comma-list of shared libs to load at open; or `ENABLE_SQL_LOAD_EXTENSION` to allow SQL `load_extension()` | lib names / `ENABLE_SQL_LOAD_EXTENSION` | — (disabled) | GPKG, SQLite (GDAL >= 3.5) |
| `SQLITE_USE_OGR_VFS` | Enables extra GDAL/OGR buffering/caching VFS; speeds I/O **but disables file locking** | `YES`/`NO` | `NO` | GPKG, SQLite |
| `OGR_GPKG_NUM_THREADS` | Threads for ArrowArray reads (no filter, consecutive FIDs); `4` is near-optimal | integer / `ALL_CPUS` | `min(4, numCPUs)` | GPKG (GDAL >= 3.8.3) |
| `OGR_CURRENT_DATE` | Forces the GeoPackage `last_change` timestamp (reproducible output) | GPKG-format datetime string | actual now | GPKG |
| `OGR_GPKG_FOREIGN_KEY_CHECK` | Set `NO` to skip the `PRAGMA foreign_key_check` GDAL runs at open of a GPKG | `YES`/`NO` | `YES` | GPKG **[source-only]** |
| `OGR_APPLY_GEOM_SET_PRECISION` | Apply `OGRGeometry::SetPrecision()` on write to honor coord precision | `YES`/`NO` | `NO` | GPKG + any driver honoring geom coord precision (GDAL >= 3.9) |
| `SQLITE_LIST_ALL_TABLES` | List all tables, not just those in `geometry_columns` (SQLite driver) | `YES`/`NO` | `NO` | SQLite |
| `OGR_SQLITE_LIST_VIRTUAL_OGR` | List VirtualOGR layers (security implications) | `YES`/`NO` | `NO` | SQLite |
| `OGR_PROMOTE_TO_INTEGER64` | Read `INTEGER` fields as 64-bit | `YES`/`NO` | `NO` | SQLite |

Notes / verification:
- `OGR_SQLITE_SYNCHRONOUS`, `OGR_SQLITE_CACHE`: described in the SQLite **Performance hints**
  section — page-cache "value measured in MB", `OFF` for synchronous.
- `OGR_GPKG_FOREIGN_KEY_CHECK` is **not** listed in the GPKG driver's config-options table, but is
  a real, long-standing option (GDAL emits its name in the error message when a FK check fails;
  confirmed by GDAL maintainer). Mark it **[source-only]** in code comments.
- `SECURE_DELETE` (since GDAL 3.10 secure deletion is always on unless overridden via
  `OGR_SQLITE_PRAGMA`) is exposed only through `OGR_SQLITE_PRAGMA`, not a dedicated config option.

Sources: [GPKG driver](https://gdal.org/en/stable/drivers/vector/gpkg.html) ·
[SQLite driver](https://gdal.org/en/stable/drivers/vector/sqlite.html) ·
`OGR_GPKG_FOREIGN_KEY_CHECK` per GDAL maintainer
([osgeo list](https://lists.osgeo.org/pipermail/qgis-developer/2018-August/054128.html)).

> Related **open options** (not config opts — listed for contrast): `LIST_ALL_TABLES`,
> `PRELUDE_STATEMENTS` (inject PRAGMAs here), `NOLOCK`, `IMMUTABLE`. Related **dataset creation
> options**: `VERSION` (defaults to `1.4` since GDAL 3.11), `ADD_GPKG_OGR_CONTENTS`,
> `DATETIME_FORMAT`, `CRS_WKT_EXTENSION`. Related **layer creation options**: `SPATIAL_INDEX`
> (default `YES`), `GEOMETRY_NAME` (`geom`), `FID` (`fid`), `DISCARD_COORD_LSB`.

---

## 2. ESRI Shapefile

All four are true configuration options (documented in the Shapefile "Configuration options"
section). They mostly mirror open/layer-creation options for the **update** path.

| Option | Description | Valid values | Default | Affects |
|---|---|---|---|---|
| `SHAPE_ENCODING` | Override encoding interpretation of the `.dbf`; `""` disables recoding | any `CPLRecode` encoding / `""` | from `.cpg`/LDID | Shapefile |
| `SHAPE_RESTORE_SHX` | Rebuild a missing/broken `.shx` from the `.shp` at open | `YES`/`NO` | `NO` | Shapefile |
| `SHAPE_REWIND_ON_WRITE` | Correct ring winding order on write; `NO` preserves input rings | `YES`/`NO` | `NO` (Polygon/MultiPolygon, since GDAL 3.7) | Shapefile |
| `SHAPE_2GB_LIMIT` | Strictly enforce the 2 GB `.shp`/`.dbf` limit when updating | `YES`/`NO` | warn-only | Shapefile |
| `OGR_ORGANIZE_POLYGONS` | Ring shell/hole classification method (vector-wide) | `DEFAULT`/`SKIP`/`ONLY_CCW`/`CCW_INNER_JUST_AFTER_CW_OUTER` | driver-dependent (SHP defaults to `ONLY_CCW`) | Shapefile + all polygon-reading drivers |

Notes:
- `OGR_ORGANIZE_POLYGONS` is a **global vector** option (listed under "Vector related options"),
  but is most relevant to Shapefile reads — set to `DEFAULT` to repair broken multipart polygons
  that don't follow the CW-outer/CCW-inner rule.
- `SHAPE_ENCODING` is the config-option twin of the `ENCODING` **open option**; the resolved value
  is surfaced as `SOURCE_ENCODING` in the `SHAPEFILE` metadata domain.

Sources: [Shapefile driver](https://gdal.org/en/stable/drivers/vector/shapefile.html) ·
[Configuration options · Vector related](https://gdal.org/en/stable/user/configoptions.html).

---

## 3. OpenFileGDB (ESRI `.gdb`)

| Option | Description | Valid values | Default | Affects |
|---|---|---|---|---|
| `OPENFILEGDB_IN_MEMORY_SPI` | Build an in-memory spatial index on first sequential read; `NO` uses native `.spx` only | `YES`/`NO` | `YES` | OpenFileGDB |
| `OPENFILEGDB_DEFAULT_STRING_WIDTH` | Width for string fields created with unspecified width (0) | integer | `65536` | OpenFileGDB (write) |

Notes:
- Native `.spx` spatial indexing is used since GDAL 3.2; `OPENFILEGDB_IN_MEMORY_SPI=NO` disables
  the additional on-the-fly in-memory index (useful to cap RAM on huge layers).
- `OGR_OPENFILEGDB_WRITE_EMPTY_GEOMETRY` exists in GDAL source but is internal/undocumented —
  **[source-only]**, not recommended for package surface.

Source: [OpenFileGDB driver](https://gdal.org/en/stable/drivers/vector/openfilegdb.html).

> Related **open option**: `LIST_ALL_TABLES` (expose `GDB_*` system tables). OpenFileGDB is the
> preferred read path vs the proprietary FileGDB driver (thread-safe, VSI-capable, no SDK, reads
> ArcGIS 9.x) — see best-practices doc.

---

## 4. VSI / Networking (remote reads of FGB / GeoParquet / PMTiles / remote GPKG/SHP/GDB)

This is the most important group for the package's remote-read goals. These govern `/vsicurl/`,
`/vsizip/`, and the cloud sub-filesystems. All are runtime-settable via
`gdalraster::set_config_option()` **before opening** the remote dataset.

### 4a. Directory listing / open behavior

| Option | Description | Valid values | Default | Affects |
|---|---|---|---|---|
| `GDAL_DISABLE_READDIR_ON_OPEN` | Skip directory listing at open; `EMPTY_DIR` also suppresses sidecar probing | `TRUE`/`FALSE`/`EMPTY_DIR` | `FALSE` | all (huge win on `/vsicurl/`) |
| `GDAL_READDIR_LIMIT_ON_OPEN` | Max files scanned for sidecars at open | integer | `1000` | all |
| `CPL_VSIL_CURL_ALLOWED_EXTENSIONS` | Assume only files with these extensions exist (skip existence probing) | e.g. `".fgb,.parquet"` | — | `/vsicurl/` and derivatives |
| `GDAL_INGESTED_BYTES_AT_OPEN` | Bytes read in the first GET at open (prefetch a header) | integer (bytes) | — | `/vsicurl/` |

### 4b. Range-request / chunking / caching

| Option | Description | Valid values | Default | Affects |
|---|---|---|---|---|
| `CPL_VSIL_CURL_USE_HEAD` | Emit an HTTP HEAD at open (to size the file) | `YES`/`NO` | `YES` | `/vsicurl/` |
| `CPL_VSIL_CURL_CHUNK_SIZE` | Range-request granularity; auto-grows up to 128× on sequential reads | bytes (units since 3.11) | `16 KB` (max 2 MB) | `/vsicurl/` |
| `CPL_VSIL_CURL_CACHE_SIZE` | Global LRU cache shared across downloads; set to 128× chunk size if chunk raised | bytes (units since 3.11) | `16 MB` | `/vsicurl/` |
| `CPL_VSIL_CURL_NON_CACHED` | Colon-separated paths whose cached content is dropped on close | path list | — | `/vsicurl/` |
| `VSI_CACHE` | Per-file RAM cache for *all* VSI I/O (incl. local) | `TRUE`/`FALSE` | `FALSE` | all VSI |
| `VSI_CACHE_SIZE` | Per-file VSI cache size (per cached file) | bytes (units since 3.11) | `25 MB` | all VSI |

### 4c. HTTP transport (`GDAL_HTTP_*` and curl)

| Option | Description | Valid values | Default | Affects |
|---|---|---|---|---|
| `GDAL_HTTP_TIMEOUT` | Overall HTTP timeout (seconds) | integer (s) | — | curl-based VSI |
| `GDAL_HTTP_CONNECTTIMEOUT` | Connection-establish timeout | integer (s) | — | curl-based VSI |
| `GDAL_HTTP_MAX_RETRY` | Number of retry attempts on retryable codes | integer | `0` | curl-based VSI |
| `GDAL_HTTP_RETRY_DELAY` | Delay between retries (seconds) | integer (s) | `30` | curl-based VSI |
| `GDAL_HTTP_RETRY_CODES` | Which HTTP codes trigger retry | `ALL` / code list | `429,500,502,503,504` (+ curl errors) (GDAL >= 3.10) | curl-based VSI |
| `GDAL_HTTP_VERSION` | HTTP protocol version; `2`/`2TLS` enables multiplexing | `1.0`/`1.1`/`2`/`2TLS`/`2PRIOR_KNOWLEDGE` | `1.1` (usually) | curl-based VSI |
| `GDAL_HTTP_MULTIPLEX` | Use HTTP/2 multiplexing for parallel ranges (needs HTTP/2) | `YES`/`NO` | `YES` | curl-based VSI |
| `GDAL_HTTP_MULTIRANGE` | How `ReadMultiRange` is satisfied | `SINGLE_GET`/`SERIAL`/`YES` | `YES` | curl-based VSI |
| `GDAL_HTTP_MERGE_CONSECUTIVE_RANGES` | Merge adjacent ranges into one request | `YES`/`NO` | `YES` | curl-based VSI |
| `GDAL_HTTP_HEADERS` | Comma-list of `key: value` request headers (GDAL >= 3.6) | header string | — | curl-based VSI |
| `GDAL_HTTP_USERAGENT` | User-Agent header | string | `GDAL/x.y.z` | curl-based VSI |
| `GDAL_HTTP_MAX_TOTAL_CONNECTIONS` | Max simultaneous open connections (GDAL >= 3.11) | integer | — | curl-based VSI |
| `CPL_CURL_VERBOSE` | Verbose libcurl logging (debugging) | `YES`/`NO` | `NO` | curl-based VSI |

> `/vsicurl?...` filename options mirror several of these per-path (`use_head`, `max_retry`,
> `retry_delay`, `retry_codes`, `header.<name>=`, ...), overriding the global config for that one
> URL. Prefer per-path options when only one source needs tuning.

### 4d. ZIP / archive

| Option | Description | Valid values | Default | Affects |
|---|---|---|---|---|
| `CPL_VSIL_ZIP_ALLOWED_EXTENSIONS` | Extra extensions treated as ZIP by `/vsizip/` | ext list | `zip,kmz,dwf,ods,xlsx` | `/vsizip/` |
| `CPL_VSIL_DEFLATE_CHUNK_SIZE` | Deflate chunk size for `/vsigzip/` & SOZip multithreaded compression | e.g. `1M` | `1M` | `/vsigzip/`, `/vsizip/` |

### 4e. Cloud credentials (briefly — set before open)

S3 uses `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `AWS_SESSION_TOKEN`, `AWS_REGION` /
`AWS_DEFAULT_REGION`, `AWS_NO_SIGN_REQUEST=YES` (public buckets), `AWS_REQUEST_PAYER=requester`,
`AWS_S3_ENDPOINT`. GS uses `GOOGLE_APPLICATION_CREDENTIALS` / `CPL_GS_*`. Azure uses
`AZURE_STORAGE_CONNECTION_STRING` / `AZURE_STORAGE_ACCOUNT` + `AZURE_STORAGE_ACCESS_KEY` /
`AZURE_STORAGE_SAS_TOKEN` / `AZURE_NO_SIGN_REQUEST`. These can also be scoped per path-prefix via a
`gdalrc` `[credentials]` section or `VSISetPathSpecificOption()`.

Sources: [Configuration options · Networking](https://gdal.org/en/stable/user/configoptions.html) ·
[Virtual File Systems · /vsicurl/](https://gdal.org/en/stable/user/virtual_file_systems.html).

---

## 5. (Geo)Parquet & Arrow

The Parquet driver exposes **few documented config options** — most tuning is via **layer
creation options** (see best-practices doc). The one documented config option is the shared
threading control:

| Option | Description | Valid values | Default | Affects |
|---|---|---|---|---|
| `GDAL_NUM_THREADS` | Worker threads for Parquet reading (and many other ops) | integer / `ALL_CPUS` | up to 4 (or numCPUs if < 4) | Parquet, GPKG-Arrow, raster, ... |

Additional `OGR_PARQUET_*` options exist in GDAL source (`port/cpl_known_config_options.h`) but are
**not in the driver doc page** — treat as **[source-only]**, internal/advanced:

| Option | Likely effect | Default | Flag |
|---|---|---|---|
| `OGR_PARQUET_USE_BBOX` | Use bbox covering column for spatial filter pushdown on read | `YES` (when present) | [source-only] |
| `OGR_PARQUET_USE_STATISTICS` | Use row-group min/max stats to prune on read | `YES` | [source-only] |
| `OGR_PARQUET_COMPUTE_GEOMETRY_TYPE` | Full scan to determine geom type if metadata absent; `NO` to skip | `YES` | [source-only] |
| `OGR_PARQUET_BATCH_SIZE` | Arrow read batch size | — | [source-only] |
| `OGR_PARQUET_USE_THREADS` | Enable Arrow multithreaded read | auto (`YES` if >1 CPU) | [source-only] |
| `OGR_PARQUET_USE_VSI` | Force reads through the GDAL VSI layer (vs Arrow's own FS) | `NO` (auto-`YES` for `/vsi`) | [source-only] |
| `OGR_PARQUET_CRS_ENCODING`, `OGR_PARQUET_WRITE_BBOX`, `OGR_PARQUET_GEO_METADATA`, ... | write-side CRS/bbox/metadata toggles | — | [source-only] |

> The preferred, **documented** way to influence Parquet read behavior is open options
> (`GEOM_POSSIBLE_NAMES`, `CRS`, `LISTS_AS_STRING_JSON`) and write behavior is layer creation
> options (`COMPRESSION`, `COMPRESSION_LEVEL`, `ROW_GROUP_SIZE`, `WRITE_COVERING_BBOX`,
> `SORT_BY_BBOX`, `USE_PARQUET_GEO_TYPES`, `GEOMETRY_ENCODING`). Reserve `OGR_PARQUET_*` config
> opts for advanced/experimental paths and mark them clearly.

Sources: [(Geo)Parquet driver](https://gdal.org/en/stable/drivers/vector/parquet.html) ·
GDAL source `cpl_known_config_options.h`.

---

## 6. General performance / caching (apply broadly)

| Option | Description | Valid values | Default | Affects |
|---|---|---|---|---|
| `GDAL_CACHEMAX` | Raster block-cache size; consulted **once** — prefer `set_cache_max()` after start | `<MB>`/`<bytes>`/`X%`/`500MB` (units since 3.11) | `5%` | mostly raster |
| `GDAL_NUM_THREADS` | Global worker-thread count | integer / `ALL_CPUS` | context-dependent | many drivers |
| `CPL_TMPDIR` | Directory for temp files (e.g. FGB index build, Parquet `SORT_BY_BBOX`) | path | CWD | all |
| `CPL_DEBUG` | Debug output; `ON` also warns on unknown config keys (GDAL >= 3.11) | `ON`/`OFF`/`<prefix>` | `OFF` | all |
| `GDAL_CONFIG_FILE` | Path to the `gdalrc` config file | path | platform default | all |

> Note the existing package buckets in `R/gdal_config.R` (`.gdal_configs_performance`,
> `.gdal_configs_logging`) already track most of these; this doc is the authoritative reference for
> their semantics and the driver groupings to derive in `gdal_config_derive()`.

---

## 7. Quick decision table — which options to set when

| Situation | Set | Why |
|---|---|---|
| Remote read any format over HTTP | `GDAL_DISABLE_READDIR_ON_OPEN=EMPTY_DIR`, `GDAL_HTTP_MAX_RETRY=3`, `GDAL_HTTP_RETRY_DELAY=1` | avoid dir-listing round-trips; survive transient 5xx |
| Remote read FGB / GeoParquet (range-heavy) | `GDAL_HTTP_VERSION=2TLS`, `GDAL_HTTP_MULTIPLEX=YES`, raise `CPL_VSIL_CURL_CHUNK_SIZE` + match `CPL_VSIL_CURL_CACHE_SIZE` (128×) | parallel ranges, fewer/larger fetches |
| Remote read Shapefile (`/vsicurl/`) | `CPL_VSIL_CURL_ALLOWED_EXTENSIONS=".shp,.shx,.dbf,.prj,.cpg"` | skip probing for absent sidecars |
| Large local GPKG read | `OGR_SQLITE_CACHE=512`, PRAGMAs via open-opt `PRELUDE_STATEMENTS` | bigger page cache; mmap/temp tuning |
| Read-only WAL GPKG on read-only media | open-opts `IMMUTABLE=YES` / `NOLOCK=YES` (open options, not config) | skip change detection / locking |
| Reproducible GPKG output | `OGR_CURRENT_DATE=<fixed>` | stable `last_change` |
| Bulk GPKG/SQLite write throughput | `OGR_SQLITE_SYNCHRONOUS=OFF` (+ explicit transactions) | fewer fsyncs (accept crash risk) |
| Reproducible FK-tolerant GPKG open | `OGR_GPKG_FOREIGN_KEY_CHECK=NO` | open files with broken FKs |

---

### Cross-references
- Driver-specific open/creation-option tuning and write-side recipes: **`gdal-best-practices.md`**.
- Package opts-scoping model (config vs open vs creation vs PRAGMA): **`LANGUAGE.md` §3**.
- Existing config buckets / gdalraster helpers: **`R/gdal_config.R`**.
