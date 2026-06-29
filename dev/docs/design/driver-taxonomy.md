# GDAL Vector Driver — Taxonomy & Ubiquitous Language

The complete, source-mapped vocabulary for "everything about a (vector) driver" as the
package models it. Scope is **driver-level** (static, registry knowledge — no dataset/file
needed). Per-file facts (layers, schema, SRS, extent, `testCapability()`) are dataset-level
and belong to `gdal_dsn`/`GDALVector`, not here.

This is the ubiquitous-language reference; the mechanics of caching/init live in
`driver-options-integration.md`, the option-channel mapping in `options-architecture.md`.

## Source legend & refinement tiers

Every field below is tagged with its source and how much we refine it:

| Tag | Source | Refinement |
|---|---|---|
| **F** | `gdalraster::gdal_formats()` — one tidy row/driver (17 cols) | tier 1: tidied (GDAL pre-digested it) |
| **M** | `gdalraster::gdal_get_driver_md(driver)` — raw `DCAP_*`/`DMD_*` dict | tier 1-2: raw flag, or XML we **extract/parse** |
| **C** | curated by us (scraped docs, encoded domain knowledge) | tier 3-4: **not in GDAL at all** |
| **D** | derived/computed by us from F/M/C | — |

Rule: each fact has **one home** — the most-digested source that already has it (F before M);
M is used only for the option XML + the capability long-tail; C is the value-add GDAL lacks.

### What `gdal_formats()` (F) actually gives — 17 columns

`short_name`, `long_name`, `extensions`, `raster`, `vector`, `multidim_raster`,
`geography_network`, `rw_flag`, `virtual_io`, `subdatasets`, `sql_dialects`,
`creation_datatypes`, `creation_field_types`, `creation_field_subtypes`,
`multiple_vec_layers`, `read_field_domains`, `creation_fld_dom_types`.

These are GDAL pre-digesting `DCAP_*`/`DMD_*` into a tidy row. **Prefer F for all of these** —
do not re-read them from M. The large remainder of `DCAP_*` (relationships, upsert, geometry
kinds, field constraints, …) is **M-only** and is the real reason to expose M at all.

## 1. Names & identity

| Our field | Source | Raw key | Nuance |
|---|---|---|---|
| `short_name` | F | driver short name | GDAL treats it case-**sensitively** (`"GPKG"`); we **resolve case-insensitively** + via aliases, but store the canonical GDAL casing |
| `long_name` | F | `DMD_LONGNAME` | human description, not an identifier |
| `aliases` | **C** | — | our alt-name set for resolution (`"gpkg"`, `"geopackage"`, `"shp"`, `"geoparquet"`); includes legacy↔modern and common abbreviations |
| `slug` | **C** | — | our function-naming token (`gpkg`, `shp`, `fgb`, `gpq`) — drives `<slug>_*_opts()` and dispatch-sugar subclass |
| `related` | **C** | — | sibling/competing drivers (e.g. `OpenFileGDB`↔`FileGDB`; `Parquet`↔`Arrow`) — optional |

Note: GDAL has no notion of aliases/slug/related — all C.

## 2. Classification ("kind", not "scope")

The driver's **data domain**. Deliberately **not** called "scope" to avoid collision with the
option-level `scope` field (which is the raster-vs-vector axis *of an option*).

| Our field | Source | Raw key |
|---|---|---|
| `is_vector` | F | `DCAP_VECTOR` |
| `is_raster` | F | `DCAP_RASTER` |
| `is_multidim` | F | `DCAP_MULTIDIM_RASTER` |
| `is_geography_network` | F | `DCAP_GNM` |

We focus on vector; a driver can declare several (GPKG is raster+vector).

## 3. Extensions & MIME types

| Our field | Source | Raw key | Nuance |
|---|---|---|---|
| `extensions` | F | `DMD_EXTENSIONS` | space-split to a vector; **includes zip variants** (`"gpkg gpkg.zip"`) |
| `primary_extension` | M (exact `[[`) | `DMD_EXTENSION` | singular; **`$`-partial-match trap**: `md$DMD_EXTENSION` silently returns `DMD_EXTENSIONS` — always exact `[[`. Falls back to `extensions[1]` |
| `mime_types` | **C** | (`DMD_MIMETYPE` is **raster-only**) | curated for vector drivers; include `+zip`/`application/...` variants |

## 4. Capabilities

Two layers: a small set of **named booleans** we branch on (sourced from F where possible),
plus the **full `DCAP_*` long-tail** queryable on demand via `gdal_driver_supports(driver, cap)`
(M, missing → `FALSE`, never error). We do **not** pre-promote all ~40 flags.

### Promoted (named) capabilities

| Our field | Source | Raw key | Rename nuance |
|---|---|---|---|
| `supports_vsi` | F | `DCAP_VIRTUALIO` | renamed VIRTUALIO → vsi |
| `multiple_layers` | F | `DCAP_MULTIPLE_VECTOR_LAYERS` (+ `GDAL_DCAP_MULTIPLE_VECTOR_LAYERS_IN_DIRECTORY`) | two raw keys **converge** to one (shapefile/FGB dir vs GPKG) |
| `subdatasets` | F | `DMD_SUBDATASETS` | |
| `read_field_domains` | F | `DCAP_FIELD_DOMAINS` (read aspect) | |
| read/write/update | D | decoded from `rw_flag` | see §5 |

### Full `DCAP_*` inventory (M, query-only unless promoted)

Authoritative from the GDAL C API; **bold = vector-relevant** and worth querying:

- I/O & lifecycle: **`DCAP_OPEN`**, **`DCAP_CREATE`**, `DCAP_CREATECOPY`, **`DCAP_UPDATE`**,
  **`DCAP_APPEND`**, **`DCAP_UPSERT`**, `DCAP_CREATE_ONLY_VISIBLE_AT_CLOSE_TIME`,
  **`DCAP_REOPEN_AFTER_WRITE_REQUIRED`**, **`DCAP_CAN_READ_AFTER_DELETE`**,
  `DCAP_FLUSHCACHE_CONSISTENT_STATE`, `DCAP_VECTOR_TRANSLATE_FROM`
- layers/fields: **`DCAP_CREATE_LAYER`**, **`DCAP_DELETE_LAYER`**, **`DCAP_RENAME_LAYERS`**,
  **`DCAP_CREATE_FIELD`**, **`DCAP_DELETE_FIELD`**, **`DCAP_REORDER_FIELDS`**,
  **`DCAP_NOTNULL_FIELDS`**, **`DCAP_UNIQUE_FIELDS`**, **`DCAP_DEFAULT_FIELDS`**,
  **`DCAP_NOTNULL_GEOMFIELDS`**, **`DCAP_NONSPATIAL`**
- geometry: **`DCAP_CURVE_GEOMETRIES`**, **`DCAP_MEASURED_GEOMETRIES`**, **`DCAP_Z_GEOMETRIES`**,
  **`DCAP_COORDINATE_EPOCH`**, **`DCAP_HONOR_GEOM_COORDINATE_PRECISION`**
- relationships: **`DCAP_RELATIONSHIPS`**, **`DCAP_CREATE_RELATIONSHIP`**,
  **`DCAP_DELETE_RELATIONSHIP`**, **`DCAP_UPDATE_RELATIONSHIP`**
- styles: `DCAP_FEATURE_STYLES`(`_READ`/`_WRITE`)
- domain flags (F mirrors): **`DCAP_FIELD_DOMAINS`**, **`DCAP_VIRTUALIO`**,
  **`DCAP_MULTIPLE_VECTOR_LAYERS`**
- raster/multidim (out of vector scope): `DCAP_RASTER`, `DCAP_MULTIDIM_RASTER`,
  `DCAP_CREATE_MULTIDIMENSIONAL`, `DCAP_CREATECOPY_MULTIDIMENSIONAL`, `DCAP_SUBCREATECOPY`,
  `DCAP_CREATE_SUBDATASETS`, `DCAP_GNM`

## 5. Read/write/update flags

| Our field | Source | Nuance |
|---|---|---|
| `rw_flag` | F | compact GDAL token (`"rw+u"`, `"ro"`, `"rw+v"`…) encoding open/create/update/virtualio/subdataset |
| `can_read`/`can_write`/`can_update` | D | we **re-expand** the token into booleans (mirrors `DCAP_OPEN`/`DCAP_CREATE`/`DCAP_UPDATE`) |

## 6. Data model details

| Our field | Source | Raw key | Nuance |
|---|---|---|---|
| `sql_dialects` | F | `DMD_SUPPORTED_SQL_DIALECTS` | space-split; we also derive a **default dialect** (NATIVE→OGRSQL→first) [D] |
| `creation_field_types` | F | `DMD_CREATIONFIELDDATATYPES` | OGR field types writable on create |
| `creation_field_subtypes` | F | `DMD_CREATIONFIELDDATASUBTYPES` | |
| `creation_field_domain_types` | F | `DMD_CREATION_FIELD_DOMAIN_TYPES` (`creation_fld_dom_types`) | Coded/Range/Glob |
| `creation_datatypes` | F | `DMD_CREATIONDATATYPES` | **raster** band types — out of vector scope, ignore |
| field/geom defn flags | M (escape hatch) | `DMD_CREATION_FIELD_DEFN_FLAGS`, `DMD_ALTER_GEOM_FIELD_DEFN_FLAGS`, `GDAL_DMD_ILLEGAL_FIELD_NAMES`, `DMD_MAX_STRING_LENGTH`, `DMD_NUMERIC_FIELD_WIDTH_*` | rarely needed; query from raw when so |

## 7. Options — the central facet

One canonical schema across all channels: `driver | opt_type | name | description | scope | type | default | values`.

| Channel (`opt_type`) | Source | Raw key | CLI / API | Nuance |
|---|---|---|---|---|
| `open` | **M, parsed** | `DMD_OPENOPTIONLIST` (XML) | `--oo` / `GDALOpenEx` | tier-2 extraction: XML blob → typed tibble |
| `dataset` (creation) | **M, parsed** | `DMD_CREATIONOPTIONLIST` (XML) | `--co` | `NULL` for layer-only drivers |
| `layer` (creation) | **M, parsed** | `DS_LAYER_CREATIONOPTIONLIST` (XML) | `--lco` | **must read both** creation lists ourselves — `getCreationOptions()` reads only the DMD one |
| `config` | **C** | *(none — not in metadata)* | `--config` / `CPLSetConfigOption()` | scraped from per-driver doc "Configuration options"; the headline C contribution |

Parsing nuances (`xml_parse_gdal_options()`): boolean `type` → `values = c("YES","NO")`;
`scope` NA → `"all"`, raster-only rows dropped for vector; dataset-vs-layer collapsed into one
class with a `level`/`opt_type` tag.

Out-of-scope option lists (raster/multidim, ignored): `DMD_OVERVIEW_CREATIONOPTIONLIST`,
`DMD_MULTIDIM_*_CREATIONOPTIONLIST`, `DMD_MULTIDIM_ARRAY_OPENOPTIONLIST`.

## 8. Downstream / nested option semantics (tier 4, C)

Knowledge that hangs **off** an option but is pure domain encoding, not metadata:

| Sub-model | Carrier (GDAL gives) | We add (C) |
|---|---|---|
| SQLite/GPKG PRAGMAs | `PRELUDE_STATEMENTS` open option | pragma vocabulary, valid ranges, perf/safety semantics, `IMMUTABLE`/`NOLOCK` interactions (`gpkg_prelude_pragmas()`) |
| GPQ distribution presets | `COMPRESSION`/`ROW_GROUP_SIZE`/… layer opts | OGC best-practice recommended values |
| FGB write constraints | — | no-remote-write, local-temp behavior |

These live as **functions in the driver modules** (`gpkg_*`, `gpq_*`, `fgb_*`), *referenced
from* the option rows — not serialized into the tibble.

## 9. Configuration intersection (global vs. local)

A nuance worth naming explicitly: driver config options are **global session state**
(`--config`, applied via `gdal_config`, honored process-wide) yet **scoped to a driver** by a
`driver` attribute — distinct from open/creation options which are **local to a single
dataset/layer** operation. Some config options also mirror an open option
(e.g. `SQLITE_LIST_ALL_TABLES` ↔ `LIST_ALL_TABLES`); we note the correspondence.

## 10. Dependencies & availability

| Our field | Source | Nuance |
|---|---|---|
| `is_available` | D (M present?) | a driver compiled into the user's GDAL appears in `gdal_formats()`; absence ⇒ not built |
| `build_requirements` | **C** | curated lib deps (libsqlite3, libarrow/adbc, libcurl, libkml, libpq, libspatialite, FileGDB API, libnetcdf, ODBC, OCI, parquet…) — from the GDAL driver index "Build Requirements" column |

GDAL exposes no machine-readable dep list per driver, so this is C; `is_available` is the only
runtime-derivable part.

## 11. Underlying technologies (C)

Curated note of the tech a format is built on (SQLite/SpatiaLite for GPKG & SQLite; the OpenFileGDB
format for GDB; Protobuf/flatbuffers for FGB; Apache Arrow/Parquet for GPQ/Arrow; PMTiles spec).
Informational; powers docs and best-practice reasoning.

## 12. Informational metadata / documentation (M + C)

| Our field | Source | Raw key / nuance |
|---|---|---|
| `help_topic` | M | `DMD_HELPTOPIC` (e.g. `drivers/vector/gpkg.html`) |
| `gdal_doc_url` | D | `https://gdal.org/en/stable/` + help_topic |
| `gdal_doc_section_urls` | **C** | per-section anchors: open-options / dataset-creation / layer-creation / configuration-options / names / dependencies / capabilities / creation-issues / performance / security / encoding / examples / credits / links |
| `spec_url` | **C** | standard/spec/homepage (GeoPackage spec, RFC 7946, FlatGeobuf, GeoParquet, PMTiles spec) |
| `repo_url` | **C** | official GitHub repo(s) |
| `standards_urls` | **C** | OGC specs, RFCs, additional standards docs |

## 13. Raw escape hatch (M + F, retained)

`raw$formats` (the F row, untouched) and `raw$md` (the full M dict, untouched). Guarantees the
profile is a **strict superset of what GDAL says**: any `DCAP_*`/`DMD_*` we don't promote stays
reachable. Driver-specific stray keys seen in the wild: `ARROW_VERSION`/`ARROW_DATASET` (Arrow),
`SQLITE_HAS_COLUMN_METADATA` (GPKG/SQLite), `GDAL_DMD_*` duplicate-prefixed variants.

## 14. The profile, assembled (a view, not stored)

`gdal_driver_meta(driver)` returns these facets fused on demand (F-row ⋈ C-registry, filtered
`opts_tbl`, optional live M), with provenance recoverable per field. Facets 1-13 organize the
knowledge; facet shapes by cardinality:

- **1 row/driver** (facets 1-6, 9-12): the driver row = F ⋈ C.
- **N rows/driver** (facet 7): the options tibble.
- **behavioral** (facet 8): driver-module functions, referenced.
- **bag/driver** (facet 13): raw, retained.

## 15. Deliberately open

- Which `DCAP_*` graduate from query-only into named promoted fields.
- Exact curated registry columns shipped first (mime/zip, related, repo, build_requirements).
- Whether `help_topic`-derived `gdal_doc_url` plus C section-anchors fully replace hand URLs.
- Default SQL dialect derivation rule edge cases.
