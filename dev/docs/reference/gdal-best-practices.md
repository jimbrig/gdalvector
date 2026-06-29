# GDAL Vector I/O Best Practices for `gdalvector`

> Per-driver, actionable guidance for the package's goals: high-performance **reading** of
> traditional formats (Shapefile, OpenFileGDB, GPKG, GeoJSON) both local and remote, and
> **reading + writing** the cloud-native formats (FlatGeobuf, GeoParquet, PMTiles).
>
> Target GDAL **>= 3.11** (latest 3.13). Options below are the driver's documented **open
> options** (`--oo`), **layer/dataset creation options** (`--lco`/`--dsco`), and SQL/PRAGMA knobs;
> the global CPL **configuration options** they pair with are documented in
> **`gdal-config-options.md`**.

---

## 1. GeoParquet — writing for distribution (sink)

The package's primary modern write target. Defaults from most Parquet libraries are *not* tuned
for geospatial distribution. Follow the community "Best Practices for Distributing GeoParquet".

### Recommended layer creation options (GDAL >= 3.12)

| `-lco` | Recommended | Default | Rationale |
|---|---|---|---|
| `COMPRESSION` | `ZSTD` | `SNAPPY` | better ratio at snappy-like speed; constant decompress time |
| `COMPRESSION_LEVEL` | `15` | codec default (Arrow uses ~1) | distribution: spend write time once, fast downloads. Official doc body says **11–16** is the sweet spot; **17+ costs far more for <1% gain**. `15` is the common default (geoparquet.io). (GDAL >= 3.12) |
| `ROW_GROUP_SIZE` | `50000`–`150000` | `65536` | row-group pruning granularity; aim ~50–100 MB *compressed* per group |
| `WRITE_COVERING_BBOX` | `YES` (or leave `AUTO`) | `AUTO` | writes `xmin/ymin/xmax/ymax` struct → fast spatial filtering (GDAL >= 3.9) |
| `GEOMETRY_ENCODING` | `WKB` | `WKB` | maximal interoperability (GeoArrow not yet broadly supported — see below) |
| `USE_PARQUET_GEO_TYPES` | `NO` (interop) / `YES` (modern) | `NO` | `YES` writes Parquet Geometry logical type + GeoParquet metadata (needs libarrow >= 21; readable by older GDAL). `ONLY` drops file-level metadata → GDAL >= 3.12 + libarrow >= 21 only (GDAL >= 3.12) |
| `SORT_BY_BBOX` | `YES` for distribution | `NO` | spatial ordering for row-group locality — **tradeoffs below** (GDAL >= 3.9) |
| `POLYGON_ORIENTATION` | `COUNTERCLOCKWISE` | `COUNTERCLOCKWISE` | matches GeoParquet convention |
| `FID` | set explicitly if you need stable ids | none | required for stable FIDs across the in-place update rewrite path (GDAL >= 3.12) |

### `SORT_BY_BBOX` tradeoffs (important)

`SORT_BY_BBOX=YES` groups spatially-close features so readers can skip row groups. **But** GDAL
implements it by writing a **temporary GeoPackage** alongside the output (extra disk: possibly
several × the final size, plus time), and it **forces the generic Arrow writer**, which **drops
support for advanced Arrow types** (lists, maps, nested). Decision for the package:
- Prefer sorting **upstream** when the source already has a spatial index (GPKG R-tree, FGB Hilbert
  R-tree) — then a plain copy preserves order and you can skip `SORT_BY_BBOX`.
- Use `gdal vector sort --method=hilbert` or `ORDER BY ST_Hilbert(geom,'layer')` (GPKG SQL,
  GDAL >= 3.13) as an explicit pre-step instead of `SORT_BY_BBOX` when you need control or have
  nested fields to preserve.

### Effectiveness depends on `ROW_GROUP_SIZE`

bbox covering + spatial ordering only help if row groups are right-sized: too large → unrelated
features grouped together (less skipping); too small → metadata bloat + more seeks. Target
**50–100 MB compressed** per group (≈ 50k–150k rows for typical feature widths). For
**frontend/range-read** use cases, bias **smaller** (less irrelevant data per fetched group); for
**analytics** (full scans, aggregates), bias **larger**.

### Spatial partitioning (> ~2 GB)

For datasets larger than ~2 GB, split into multiple Parquet files (a reader pointed at a directory
treats them as one layer and prunes by row-group/file stats, reading files in parallel). Leading
approach: **KD-tree** partitioning (balanced sizes + spatial separation); S2/GeoHash/admin-boundary
partitioning also works. GDAL itself has no built-in spatial partitioner — this is a DuckDB/Sedona
or downstream-package concern.

### GeoArrow encoding — not yet

`GEOMETRY_ENCODING=GEOARROW` (GeoParquet 1.1 struct encoding) gives the same speedups as bbox
covering with smaller point storage and usable native column stats, **but tool support is not yet
broad** — keep `WKB` for distributed files for now. (`GEOARROW_INTERLEAVED` is non-spec; avoid.)

### Canonical commands

```bash
# already spatially ordered source (FGB/GPKG with index) — fastest, preserves nesting
gdal vector convert in.fgb out.parquet --lco COMPRESSION=ZSTD --lco COMPRESSION_LEVEL=15

# unordered source, let GDAL spatially order (temp GPKG; drops nested types)
ogr2ogr out.parquet -lco SORT_BY_BBOX=YES -lco COMPRESSION=ZSTD -lco COMPRESSION_LEVEL=15 in.geojson
```

Sources: [Distributing GeoParquet](https://github.com/opengeospatial/geoparquet/blob/main/format-specs/distributing-geoparquet.md) ·
[geoparquet.io best practices](https://geoparquet.io/concepts/best-practices/) ·
[(Geo)Parquet driver](https://gdal.org/en/stable/drivers/vector/parquet.html) ·
[GeoParquet 1.1 spec](https://geoparquet.org/releases/v1.1.0/).

> **Discrepancy flagged:** the distribution doc's ogr2ogr example uses `-lco MAX_ROW_GROUP_SIZE`,
> but the **GDAL Parquet driver option is `ROW_GROUP_SIZE`** (default 65536). Use `ROW_GROUP_SIZE`.

---

## 2. GeoParquet — remote reading (source)

GeoParquet is well-suited to cloud-native reads because Parquet supports **HTTP range requests**,
**row-group/page statistics**, and (with 1.1) a **bbox covering column** — enabling readers to
prune row groups without downloading the whole file.

Best practices:
- Read via `/vsicurl/https://...` (random access). GDAL uses up to 4 threads for Parquet reads;
  raise with `GDAL_NUM_THREADS=ALL_CPUS` for wide files.
- Push spatial filters down: supply a bbox/spatial filter so GDAL can use the `bbox` covering
  column + row-group stats (`OGR_PARQUET_USE_BBOX`, `OGR_PARQUET_USE_STATISTICS` default on).
- For files with no GeoParquet metadata, use open options `GEOM_POSSIBLE_NAMES` and `CRS`.
- For **directory/partitioned** datasets, GDAL needs the `arrowdataset` build; optimized spatial +
  attribute filtering on Arrow datasets exists since GDAL 3.10. Force single-file dataset mode with
  a `PARQUET:` filename prefix.
- Tune the curl layer (see config doc §4): `GDAL_HTTP_VERSION=2TLS` + `GDAL_HTTP_MULTIPLEX=YES` for
  parallel ranges; raise `CPL_VSIL_CURL_CHUNK_SIZE` and match `CPL_VSIL_CURL_CACHE_SIZE` to 128×;
  `GDAL_DISABLE_READDIR_ON_OPEN=EMPTY_DIR`.

**GDAL vs DuckDB**: GDAL is the right choice for CRS-aware I/O, format breadth, and pipeline
integration. **DuckDB** (spatial extension) is often faster for ad-hoc analytical/range queries
over partitioned GeoParquet and can write row-group-byte-sized output — but it **does not reproject
and drops CRS metadata on round-trip**. Strategy: use GDAL for the package's read/profile/convert
surface; consider routing heavy analytical scans to DuckDB/ADBC where CRS is fixed, then re-stamp
CRS via GDAL if needed.

Sources: [(Geo)Parquet driver](https://gdal.org/en/stable/drivers/vector/parquet.html) ·
[Distributing GeoParquet · frontend usage](https://github.com/opengeospatial/geoparquet/blob/main/format-specs/distributing-geoparquet.md).

---

## 3. FlatGeobuf (FGB) — read + write (sink + remote source)

Performant binary single-layer format with a **packed Hilbert R-tree** spatial index. Built-in by
default (no Arrow/SQLite dependency), supports VirtualIO → excellent for `/vsicurl/` remote reads.

### Reading

| `-oo` | Recommended | Default | Rationale |
|---|---|---|---|
| `VERIFY_BUFFERS` | `YES` for untrusted/remote, `NO` for trusted local | `YES` | buffer validation guards against corrupt data at a performance cost; flip to `NO` to speed trusted local reads |

- **Remote**: FGB is one of the best `/vsicurl/` read formats — its header + Hilbert R-tree let
  GDAL issue targeted range requests for a bbox query instead of reading the whole file. Pair with
  `GDAL_DISABLE_READDIR_ON_OPEN=EMPTY_DIR` and the curl tuning in config doc §4.
- A single `.fgb` = one layer. A **directory** of `.fgb` files = multiple layers (use the directory
  as the connection string).

### Writing

| `-lco` | Recommended | Default | Rationale |
|---|---|---|---|
| `SPATIAL_INDEX` | `YES` | `YES` | builds the Hilbert R-tree → fast bbox queries (incl. remote). Set `NO` only for append-heavy/streaming or when index RAM is prohibitive |
| `TEMPORARY_DIR` | a fast/large dir (or `/vsimem/`) | output dir | index build scratch space; only used when `SPATIAL_INDEX=YES` |
| `TITLE` / `DESCRIPTION` | set for published datasets | — | stored in FGB header (GDAL >= 3.9) |

Gotchas:
- With `SPATIAL_INDEX=YES`, **NULL geometries are not supported**, and index construction needs
  RAM ≈ **num_features × 83 bytes** — size `TEMPORARY_DIR`/RAM accordingly for big writes.
- There are **no dataset creation options**.
- **No remote write**: write locally to a temp FGB, then upload (the package's
  CNF-sink-with-local-temp decision). Pass a name without `.fgb` to create a *directory* of layers.

Source: [FlatGeobuf driver](https://gdal.org/en/stable/drivers/vector/flatgeobuf.html).

---

## 4. GeoPackage (GPKG) — large & remote reads, plus write side

### 4a. Read performance (large / remote)

GPKG is SQLite under the hood, so reads benefit from SQLite tuning. Two layers of control: **open
options** (per source) and **PRAGMAs** (injected via the `PRELUDE_STATEMENTS` open option, or
globally via `OGR_SQLITE_PRAGMA`).

Open options (read):

| `-oo` | Use when | Notes |
|---|---|---|
| `NOLOCK=YES` | read-only, non-WAL file | skips file locking (`nolock=1` URI). Honored only in read-only + non-WAL |
| `IMMUTABLE=YES` | file can't change under you (read-only media, WAL on read-only storage) | skips change detection; GDAL auto-tries this for WAL files it can't open read-only |
| `LIST_ALL_TABLES=NO` | only want registered feature/attribute tables | faster, fewer surprises |
| `PRELUDE_STATEMENTS="PRAGMA ..."` | tune the connection before any query | the canonical place to set per-open PRAGMAs |

Recommended read PRAGMAs (via `PRELUDE_STATEMENTS` or `OGR_SQLITE_PRAGMA`), sized to the file/host:

| PRAGMA | Recommended | Effect |
|---|---|---|
| `cache_size` | `-262144` (≈256 MB; negative = KiB) or via `OGR_SQLITE_CACHE=512` | larger page cache = fewer re-reads |
| `mmap_size` | e.g. `268435456` (256 MB) | memory-map DB pages → fewer syscalls on local reads |
| `temp_store` | `MEMORY` | temp B-trees/sorts in RAM |
| `page_size` | leave as-is on existing files (set only at create) | |
| `synchronous` | `OFF`/`NORMAL` for read-only sessions | irrelevant to pure reads but harmless |
| `journal_mode` | `OFF` (read-only) | avoid journal churn (use `OGR_SQLITE_JOURNAL`) |

Config options that pair with reads (see config doc §1): `OGR_SQLITE_CACHE` (MB),
`SQLITE_USE_OGR_VFS=YES` (extra buffering — **no locking**, read-only safe),
`OGR_GPKG_NUM_THREADS` (ArrowArray reads; `4` ≈ optimal). For **remote** GPKG over `/vsicurl/`,
GPKG is *not* an ideal cloud format (random SQLite page access = many small ranges); prefer FGB /
GeoParquet for remote. If you must, set `IMMUTABLE=YES`, raise `CPL_VSIL_CURL_CHUNK_SIZE`, and
`GDAL_DISABLE_READDIR_ON_OPEN=EMPTY_DIR`. `.gpkg.zip` is read-only and only performant if the inner
file is stored uncompressed or SOZip-optimized.

### 4b. Write performance

- **Wrap inserts in transactions.** SQLite autocommits per statement otherwise (very slow); GDAL's
  ogr2ogr commits every 100000 rows by default (`-gt` to tune). Use
  `OGR_L_StartTransaction()`/`CommitTransaction()` from the API.
- **`OGR_SQLITE_SYNCHRONOUS=OFF`** speeds creation (accept crash risk).
- **Spatial index**: default `SPATIAL_INDEX=YES` (layer creation). For bulk appends from many
  sources, create **without** the index, append all, then build it once
  (`SELECT CreateSpatialIndex('table','geom')`) — much faster.
- **`ADD_GPKG_OGR_CONTENTS=YES`** (default, dataset creation) keeps a fast feature-count table +
  triggers; set `NO` only if trigger overhead on heavy edits matters.
- **`VERSION`** (dataset creation) defaults to `1.4` since GDAL 3.11 (`1.2` earlier). Pin
  explicitly (`1.4`) for predictable application_id/user_version, or lower for older-consumer
  compatibility.
- **Reproducible output**: set `OGR_CURRENT_DATE` to a fixed value to freeze the `last_change`
  timestamp.
- After heavy edits/deletes, run `VACUUM` to reclaim space (full rewrite).

Sources: [GPKG driver](https://gdal.org/en/stable/drivers/vector/gpkg.html) ·
[SQLite driver · Performance hints](https://gdal.org/en/stable/drivers/vector/sqlite.html) ·
[SQLite PRAGMA reference](https://www.sqlite.org/pragma.html).

---

## 5. Shapefile & OpenFileGDB — read-mostly sources

### 5a. ESRI Shapefile

Legacy but ubiquitous (TIGER, etc.). Treat as a **read source**; writing is constrained
(10-char field names, single geometry type per layer, 2 GB practical limit, limited types).

Reading:
- **Encoding**: GDAL auto-detects from `.cpg`/LDID. Override with the `ENCODING` open option or
  `SHAPE_ENCODING` config option (`""` disables recoding). Inspect the `SHAPEFILE` metadata domain
  (`SOURCE_ENCODING`, `ENCODING_FROM_CPG`, `ENCODING_FROM_LDID`) to diagnose mojibake.
- **Missing `.shx`**: set `SHAPE_RESTORE_SHX=YES` (config) to rebuild it from the `.shp` at open.
- **Broken multipart polygons**: set `OGR_ORGANIZE_POLYGONS=DEFAULT` for full topological ring
  classification (slower) when a file violates the CW-outer/CCW-inner rule.
- **Spatial index**: build a `.qix` quadtree (`CREATE SPATIAL INDEX ON tablename`) to accelerate
  bbox-filtered reads of large shapefiles. `.sbn/.sbx` ESRI indexes are read (not written).
- **Geometry-type ambiguity** (M values): `ADJUST_GEOM_TYPE` open option (`FIRST_SHAPE` default /
  `ALL_SHAPES`); `ADJUST_TYPE=YES` scans the `.dbf` to narrow Real→Integer field types.
- **Remote `/vsicurl/`**: a shapefile is a multi-file set; set
  `CPL_VSIL_CURL_ALLOWED_EXTENSIONS=".shp,.shx,.dbf,.prj,.cpg"` to stop GDAL probing for absent
  sidecars, and `GDAL_DISABLE_READDIR_ON_OPEN`. `.shz`/`.shp.zip` via `/vsizip/` are supported.

### 5b. OpenFileGDB

**Prefer OpenFileGDB over the proprietary FileGDB driver** for the package's read goals. Documented
advantages:
- Reads **ArcGIS 9.x** geodatabases (not just 10+).
- Opens layers with **any** spatial reference system.
- **Thread-safe** (datasources processable in parallel).
- Uses the **VSI Virtual File API** → can read a `.gdb` inside a ZIP (`.gdb.zip`) or on an HTTP
  server (`/vsicurl/`).
- Faster on databases with many fields; robust against corrupted files; **no third-party SDK**.

Reading:
- **Spatial filtering** uses native `.spx` indices (since GDAL 3.2). The on-the-fly in-memory index
  built on first sequential read can be disabled with `OPENFILEGDB_IN_MEMORY_SPI=NO` to cap RAM.
- **Attribute filtering** uses `.atx` attribute indexes when present.
- `LIST_ALL_TABLES=YES` open option exposes `GDB_*` system tables when needed.
- **Limitations**: SDC/CDF-compressed data not readable (use FileGDB driver for CDF); sparse 64-bit
  OBJECTID support is read-only/incomplete (warns).

Writing (less central, GDAL >= 3.6): use `TARGET_ARCGIS_VERSION=ARCGIS_PRO_3_2_OR_LATER` if you
need Integer64/Date/Time types; `OPENFILEGDB_DEFAULT_STRING_WIDTH` controls width-0 string fields
(default 65536).

Sources: [Shapefile driver](https://gdal.org/en/stable/drivers/vector/shapefile.html) ·
[OpenFileGDB driver](https://gdal.org/en/stable/drivers/vector/openfilegdb.html).

---

## 6. Remote / cloud tuning (applies across FGB / GeoParquet / PMTiles / remote SHP·GDB·GPKG)

### 6a. Pick the right VSI handler

| Handler | When | Why |
|---|---|---|
| `/vsicurl/` | random access to a static remote file (FGB, GeoParquet, COG-like) | relies on **HTTP range requests**; piecewise reads with in-memory caching |
| `/vsicurl_streaming/` | strictly sequential, no seeking (e.g. stream a CSV) | downloads in background; **no range requests** — bad for ZIP/footer-first formats |
| HTTP pseudo-driver (no `/vsi` prefix) | small files that fit in RAM, or dynamically-generated (query-string) URLs | single GET, no range support needed |
| `/vsizip//vsicurl/...` (chained) | a remote ZIP archive | read inner files without full download; footer read first (don't use streaming) |

GDAL cannot reliably auto-detect range support from `Accept-Ranges`, so choose deliberately.

### 6b. Core tuning (set before open; see config doc §4)

- `GDAL_DISABLE_READDIR_ON_OPEN=EMPTY_DIR` — avoid directory-listing round-trips and sidecar probing
  (biggest single win for remote opens).
- `CPL_VSIL_CURL_ALLOWED_EXTENSIONS` — tell GDAL which extensions exist so it stops probing.
- `CPL_VSIL_CURL_USE_HEAD=YES` (default) — one HEAD to size the file; set `NO` if the server lacks
  HEAD.
- `GDAL_INGESTED_BYTES_AT_OPEN` — prefetch a larger header in the first GET (helps formats with a
  big header block).
- Sequential/large reads: raise `CPL_VSIL_CURL_CHUNK_SIZE` (default 16 KB; auto-grows to 2 MB) and
  set `CPL_VSIL_CURL_CACHE_SIZE` ≈ **128 ×** the chunk size.
- HTTP/2: `GDAL_HTTP_VERSION=2TLS` + `GDAL_HTTP_MULTIPLEX=YES` → parallel range fetches.
- Resilience: `GDAL_HTTP_MAX_RETRY=3`, `GDAL_HTTP_RETRY_DELAY=1`, `GDAL_HTTP_TIMEOUT`,
  `GDAL_HTTP_RETRY_CODES` (defaults cover 429/500/502/503/504).
- Per-URL overrides: `/vsicurl?use_head=no&max_retry=3&header.Accept=...&url=<encoded>` when only
  one source needs special handling.
- Reuse downloaded bytes within a process; call `gdalraster::vsi_curl_clear_cache()` when remote
  content may have changed mid-session.

### 6c. ZIP archives
- `.zip`/`.shz`/`.gpkg.zip`/`.gdb.zip` via `/vsizip/`. For good remote read performance the inner
  payload must be **stored (uncompressed) or SOZip-optimized**; otherwise the whole member must be
  decompressed.
- `CPL_VSIL_ZIP_ALLOWED_EXTENSIONS` to treat custom extensions as ZIP.

Sources: [Virtual File Systems](https://gdal.org/en/stable/user/virtual_file_systems.html) ·
[Configuration options · Networking](https://gdal.org/en/stable/user/configoptions.html).

---

## 7. Format selection cheat-sheet

| Goal | Best format | Why |
|---|---|---|
| Remote random/bbox read, modern | **GeoParquet (1.1, bbox covering, ZSTD)** or **FlatGeobuf** | range requests + row-group/Hilbert pruning |
| Remote read, simplest/no deps | **FlatGeobuf** | built-in, Hilbert R-tree, great over `/vsicurl/` |
| Analytics / columnar / partitioned | **GeoParquet** | column pruning, stats, partition pruning, DuckDB-friendly |
| Local OLTP-ish, multi-layer, SQL | **GPKG** | SQLite SQL, R-tree, relationships |
| Legacy source | **Shapefile** / **OpenFileGDB** | read-mostly; OpenFileGDB > FileGDB |
| Remote GPKG | (avoid) prefer FGB/GeoParquet | SQLite page access = many small ranges |

---

### Cross-references
- Global CPL/OGR config options (env vars / `--config` / gdalrc): **`gdal-config-options.md`**.
- Package opts model + driver module split (`fgb_`, `gpq_`, `gpkg_`, `shp_`, `gdb_`): **`LANGUAGE.md`**.
