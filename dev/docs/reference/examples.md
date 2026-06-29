# Grounding Examples (real option usage)

Canonical option/pipeline usage distilled from real workflows in `dev/` and the sibling
`gdaltargets` project. These ground the package's streamlining goals: fast reads of large/remote
traditional formats (GPKG/SHP/GDB) and read+write of cloud-native formats (FlatGeobuf/GeoParquet/
PMTiles). All are expressed against the modern `gdal vector` CLI (the `gdalraster::gdal_alg()` /
GDALG algorithmic API), which is what `as_gdal_args()` / `gdal_render()` feed.

## 1. Reading a large local GeoPackage with SQLite tuning

GPKG is a SQLite DB; for large reads the big wins are SQLite PRAGMAs via `PRELUDE_STATEMENTS`
plus `LIST_ALL_TABLES=NO`:

```r
gpkg_open_opts(
  list_all_tables = FALSE,
  prelude_statements = gpkg_prelude_pragmas(
    cache_size  = -4000000,      # ~4 GB page cache (negative = KiB)
    temp_store  = "MEMORY",
    mmap_size   = 8589934592,    # 8 GiB memory-mapped I/O
    journal_mode = "WAL"
  )
)
#> --open-option 'LIST_ALL_TABLES=NO'
#> --open-option 'PRELUDE_STATEMENTS=PRAGMA cache_size=-4000000;PRAGMA temp_store=MEMORY;PRAGMA mmap_size=8589934592;PRAGMA journal_mode=WAL;'
```

Pair with config options when driving the CLI (see `gdal-config-options.md`):
`GDAL_NUM_THREADS=ALL_CPUS`, `OGR_SQLITE_*`, and logging (`CPL_DEBUG`, `CPL_LOG`, `CPL_TIMESTAMP`).

## 2. GPKG -> FlatGeobuf streaming pipeline (validate / clean / order)

A real `GDALG` pipeline (`dev/state_fips=13.gpkg_to_fgb.gdalg.json`) reads a nationwide parcel
GPKG with the tuning above, filters by attribute, splits out empty/invalid geometries via `tee`,
makes geometries valid, normalizes geometry type, reprojects to EPSG:4326, and **spatially orders
with a Hilbert sort** before writing — exactly the ordering GeoParquet/FGB distribution wants:

```text
gdal vector pipeline \
  read --open-option LIST_ALL_TABLES=NO \
       --open-option "PRELUDE_STATEMENTS=PRAGMA cache_size=-4000000;PRAGMA temp_store=MEMORY;PRAGMA mmap_size=8589934592;PRAGMA journal_mode=WAL;" \
       --input parcels.gpkg --input-layer lr_parcel_us \
  ! filter --where "statefp = '13'" \
  ! make-valid \
  ! set-geom-type --geometry-type MultiPolygon --skip \
  ! reproject --output-crs EPSG:4326 \
  ! sort --method hilbert \
  ! write --output parcels_13.fgb
```

Notes: `sort --method hilbert` is the CLI-native equivalent of GeoParquet's `SORT_BY_BBOX=YES`
(no temporary GeoPackage needed); `check-geometry` + `tee` route invalid features to a side
output (Arrow) for QA.

## 3. Writing GeoParquet for distribution (recommended settings)

```r
gpq_creation_opts(
  compression = "ZSTD",
  compression_level = 15,
  row_group_size = 100000,
  write_covering_bbox = "YES",   # GeoParquet 1.1 bbox covering
  sort_by_bbox = TRUE            # skip if the source is already spatially ordered
)
```

For an already-ordered source (e.g. the FGB from §2), drop `sort_by_bbox` and order upstream.
See `gdal-best-practices.md` for the full rationale.

## 4. Writing FlatGeobuf with a spatial index

```r
fgb_creation_opts(spatial_index = TRUE)   # SPATIAL_INDEX=YES (default in GDAL)
```

FGB carries its own packed R-tree, making it an ideal already-indexed, range-readable source for
remote reads and for feeding GeoParquet conversion.

## 5. Remote reads (cloud-native formats over HTTP)

FlatGeobuf, GeoParquet and PMTiles support HTTP range requests via `/vsicurl/`. The relevant
tuning lives in config options (`CPL_VSIL_CURL_*`, `GDAL_HTTP_*`, `VSI_CACHE*`) — see
`gdal-config-options.md`. Open options remain driver-specific (e.g. `gpq_open_opts(crs=, ...)`).

## 6. Config options for CLI runs

```r
gdal_config_opts(
  GDAL_NUM_THREADS = "ALL_CPUS",
  GDAL_ALGORITHM_ALLOW_WRITES_IN_STREAM = "YES",
  CPL_DEBUG = "ON",
  CPL_TIMESTAMP = "ON"
)
```

> Config options apply at the session/CLI level (`CPLSetConfigOption()` / `--config`). When
> calling GDAL via the API rather than the CLI, prefer `gdalraster::set_config_option()` or
> environment variables; the `--optfile` mechanism is CLI-only.
