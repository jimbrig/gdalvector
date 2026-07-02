# Design note: vector introspection layer & FID handling

Status: **design decision / captured for later** (not implemented). The full system is too large to
tackle at once; this records the direction and the hard-won FID nuances so they don't have to be
re-derived.

## Intent of the `gdal_vector_*()` family

These functions are an **introspection layer**. Their job is to surface every relevant fact about a
data source/layer *once, up front* so that downstream **declarative specs** can be crafted from facts
rather than rediscovered by trial and error:

- field selection / renames
- field type pinning (casts)
- CRS alignment
- ignored fields
- filtering (attribute / spatial / empty-geometry)
- custom SQL (dialect-aware)
- GDAL `vector pipeline` steps

The goal is to **avoid circular rabbit holes** (the FID saga below being the canonical example).

## Proposed shape (deferred)

A single **layer profile** snapshot, gathered in one open, consumed by pure spec-builder functions
(no re-introspection):

- **Source**: driver/format, dsn, layer, capabilities (`$testCapability()` — random read, fast feature
  count, fast spatial filter, ignore-fields, Arrow stream, etc.).
- **Fields**: name, OGR type + subtype, width/precision, nullable, unique, default, domain.
- **Geometry**: column name, geom type, CRS (WKT / authority / EPSG, lon-lat flag).
- **FID**: `getFIDColumn()`, named-vs-implicit, the carry SQL, and how to query it (see below).
- **Read-path defaults**: `$fetch()` omits FID; `$getArrowStream()` includes it by default.

A type map (`ogr_type` -> `sql_type` / `arrow_type` / `r_type`) drives casts/pins. (An earlier
`gdal_vector_schema_spec` engine did some of this; it was removed and would be rebuilt on top of a
solid profile rather than on assumptions.)

## FID nuances (researched against GDAL docs)

### OGR model

- The FID is a special 64-bit feature property, **not** an attribute field.
- `OGRLayer::GetFIDColumn()` returns the name of the backing column used as the FID, or `""` if the
  FID is implicit (no backing column). GDAL never fabricates a *named* FID on read.
- Therefore `nzchar(GetFIDColumn())` is the discriminator:
  - **non-empty** -> a real, named source column is used as the FID (e.g. GeoPackage PK `fid`/`lrid`,
    OpenFileGDB `OBJECTID`). OGR **always drops it from `getFieldNames()`** because it is consumed as
    the FID, so it is *not directly queryable* as a regular field.
  - **`""`** -> implicit/synthetic FID (Shapefile record number, GeoJSON sequential id, FlatGeobuf
    feature id, FID-less Parquet).
- `%in% getFieldNames()` is **not** a useful test — a named FID is always absent from the field list
  (this was the original bug in `gdal_vector_layer_fid_col()`).
- What OGR cannot tell you: the column's deeper semantics (physical SQL type, auto-increment surrogate
  like `fid` vs meaningful key like `lrid`). That requires source-specific inspection
  (e.g. `PRAGMA table_info(<layer>)` for a GeoPackage).

### Per-format

| Format            | `GetFIDColumn()`                | Notes |
| ----------------- | ------------------------------- | ----- |
| GeoPackage        | the `INTEGER PRIMARY KEY` (default `fid`, `FID=` open option) | real column, consumed as FID; for views, alias the PK to `OGC_FID` |
| (Geo)Parquet/Arrow| `""` unless written with `FID=` | no FID column created unless requested; Arrow schema default name `OGC_FID` |
| FlatGeobuf        | `""`                            | per-feature id round-trips, but no named column |
| Shapefile         | `""`                            | implicit 0-based record number; `-preserve_fid` uses that, not `OBJECTID` |
| GeoJSON           | `""`                            | FID from feature-level `id`, else `id`/`ID` attribute |
| OpenFileGDB       | `OBJECTID`                      | named FID column |

### Per-dialect querying

- **OGR SQL**: reference the FID as `FID`. `SELECT *` excludes it -> `SELECT FID, *`.
- **SQLite**: reference it as `rowid` (since GDAL 3.8 the named FID column also works). `SELECT *`
  excludes it -> `SELECT rowid, *` / `SELECT rowid AS fid, *`. For SQLite-backed sources
  (GPKG/SpatiaLite) the SQLite dialect is the native engine.
- To **carry the FID value through as a regular attribute**, rename it so OGR doesn't re-consume it as
  the FID: `CAST(rowid AS INTEGER) AS source_fid` (SQLite) or `SELECT FID AS source_fid, *` (OGR SQL).
  For GPKG views, alias the PK to `OGC_FID`.
- `-preserve_fid` only preserves the FID *as the FID* (and only when the source reports a non-empty
  FID column name); it does not turn it into an attribute.

### GDALVector read-path asymmetry (`?gdalraster::GDALVector`)

- **`$fetch(n)`** (incl. `n = -1`): data frame has only attribute + geometry fields. The FID is **not**
  included by default; expose it via a custom SQL layer or by selecting the FID special field.
- **`$getArrowStream()`**: governed by `$arrowStreamOptions`, where **`INCLUDE_FID=YES/NO` defaults to
  `YES`** -> the FID column **is** included by default (`FID=name` sets the column name, defaulting to
  `GetFIDColumn()`).
- Net: `fetch()` omits the FID by default; the Arrow stream includes it by default.

## Current state

- `gdal_vector_layer_fid_col()` returns `getFIDColumn()` and emits a suppressible, case-specific
  `gdal_inform` (named -> "consumed/not queryable, rename to carry"; implicit -> "use `FID`/`rowid`").
- Everything above is otherwise **deferred** pending a holistic introspection/spec design.
