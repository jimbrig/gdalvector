# gdalvector — Ubiquitous Language & API Surface

> Living reference for the package's vocabulary, **module prefixes**, file boundaries,
> naming/argument conventions, the **ideal/target** function surface, and how the layers
> (generic <-> driver <-> predicate/check) wire together.
>
> File name note: started as `ARCHITECTURE.md`; this is really the *ubiquitous language*
> + API-surface reference. Rename freely (`CONVENTIONS.md` / `API.md`) if a better fit
> emerges.
>
> Status legend: (no mark) = target/ideal; `[stub]` exists empty; `[bug]` broken now;
> `[new]` not yet created; `[planned]` later scope.

---

## 1. Mental model

The core of `gdalvector` is the construction of **lazy specifications of entire
geospatial workloads** — runtime environment, data sources and their details, GDAL
configuration and options, and pipeline I/O + vector steps — expressed as classed
character vectors mirroring the modern (GDAL >= 3.13) CLI / Algorithm API.

`GDALVector` is primarily the **introspection engine** (discover layers, schema,
capabilities up front) used to produce a declarative spec. The two serialized,
backend-portable artifacts are a **GDALG** (pipeline/algorithm spec) and a **gdalrc**
(config/runtime environment). Execution backends (in-process `GDALAlg`, or `processx`
CLI) are downstream concerns.

### Facts vs. decisions

- **Facts** are introspectable and abstractable now, derived from GDAL itself (never
  hardcoded tables): driver metadata (`gdal_get_driver_md()` -> `DCAP_*`, option lists),
  open-handle runtime caps (`GDALVector$testCapability()`), path handlers
  (`vsi_handlers()`).
- **Decisions** are NOT abstractable up front (GPKG FID carry-over, spatial-index/full-
  scan avoidance, SQLite tuning, remote VSI tuning, Arrow capability, FGB local-temp +
  no-remote-write, GPQ row-group/compression/partitioning, ADBC/Arrow/DuckDB routing).
  They accrete as explicit, named, tested functions inside the `{driver}_` modules,
  consuming the facts.

---

## 2. Module prefixes (the "modules")

A **module = a filename prefix**. There are three tiers:

| Prefix | Tier | Role |
|--------|------|------|
| `gdal_` | generic | driver-parameterized GDAL abstraction layer (takes `driver` as data) |
| `gpkg_` `shp_` `fgb_` `gpq_` `gdb_` `pmtiles_` `arrow_` `mem_` | driver | typed, documented sugar over `gdal_*(driver=...)` + driver-adjacent logic |
| `utils_` `vsi_` (+ package files) | support | cross-cutting helpers: predicates, checks, sql, db, binary, xml, remote, conditions |

Driver tier split by I/O role:
- **source / read drivers**: `gpkg_`, `shp_`, `gdb_` (and GPKG also a sink)
- **CNF write / sink drivers**: `fgb_`, `gpq_`, `pmtiles_`, `arrow_`, `mem_`

### Layer delegation contract (the key relationship)

`{driver}_` builders are thin, typed wrappers that **delegate down** to the generic
`as_gdal_*_opts(..., driver=)` coercers, which call the internal `new_*` constructors:

```
gpkg_open_opts(list_all_tables = FALSE)                         # driver tier: typed + validated + roxygen
  -> as_gdal_open_opts(list(LIST_ALL_TABLES = "NO"), driver = "GPKG")   # generic coercer
       -> new_gdal_open_opts(c("LIST_ALL_TABLES=NO"), driver = "GPKG")  # internal constructor
            -> structure(., class = c("gdal_open_opts","gdal_opts","character"), driver = "GPKG")
```

Consumption is also generic:

```
as_gdal_args(x)        -> c("--oo", "LIST_ALL_TABLES=NO")              # boundary flag interleave
validate_gdal_opts(x)  -> checks names/values vs gdal_driver_show_open_opts("GPKG")
```

So a driver builder only encodes *which options exist, their R-typed args, defaults, and
driver quirks*; everything structural (class, combine, validate, render) is inherited
from `gdal_*`.

---

## 3. Conventions

### Argument conventions

- Source argument is `dsn` (path / URL / VSI path) — never `path` / `gpkg_path` / `fgb_dsn`.
- Layer argument is `layer`.
- Options arguments are `open_opts`, `creation_opts`, `config_opts` (never `open_options`).
- `gdal_driver_*()` functions lead with `driver`, then `opts`: `gdal_driver_*(driver, opts)`.
- Opts objects are pure `KEY=VALUE` value objects; `--oo`/`--lco`/`--dsco`/`--config`
  interleaving happens only at the boundary via `as_gdal_args()`.

### Opts scoping (why the classes differ + which artifact they land in)

| Class | Scope | Delivery | Artifact |
|-------|-------|----------|----------|
| `gdal_config_opts` | session/process | gdalrc / `set_config_option()` / (CLI) `--config` | **gdalrc** (kept OUT of in-process GDALG) |
| `gdal_open_opts` (`--oo`) | per source | pipeline `read` step | GDALG |
| `gdal_creation_opts` (`--lco`/`--dsco`) | per output | pipeline `write` step | GDALG |
| pragmas | nested in `PRELUDE_STATEMENTS` (a GPKG open opt) | ride inside an open opt | GDALG |

`gdal_creation_opts` is a **single class** with a `scope` attribute
(`"layer"` -> `--lco`, `"dataset"` -> `--dsco`); `as_gdal_args()` reads it.

---

## 4. Cross-cutting registry: class <-> builder <-> coercer <-> predicate <-> check

Every domain class is defined in its `gdal_*` module, but its **predicate lives in
`utils_predicates.R`** and its **check lives in `utils_checks.R`** (centralized,
discoverable; they reference classes from the domain modules and are only evaluated at
runtime, so load order is a non-issue).

| Class / concept | Constructor (internal) | Generic builder | Coercer | Driver builders | Predicate (`utils_predicates.R`) | Check (`utils_checks.R`) | Class defined in |
|---|---|---|---|---|---|---|---|
| `gdal_open_opts` | `new_gdal_open_opts` | `gdal_open_opts(driver=)` | `as_gdal_open_opts` | `gpkg_/shp_/fgb_/gpq_/gdb_open_opts` | `is_gdal_open_opts` | `check_open_opts` | `gdal_opts.R` |
| `gdal_creation_opts` (scope) | `new_gdal_creation_opts` | `gdal_creation_opts(driver, scope)` | `as_gdal_creation_opts` | `*_layer_creation_opts` / `*_dataset_creation_opts` | `is_gdal_creation_opts` | `check_creation_opts` | `gdal_opts.R` |
| `gdal_config_opts` | `new_gdal_config_opts` | `gdal_config_opts(...)` | `as_gdal_config_opts` | `shp_config_opts` / `gpkg_config_opts` / `gdal_vsi_opts` / `gdal_curl_opts` | `is_gdal_config_opts` | `check_config_opts` | `gdal_opts.R` |
| `gdal_config` | `new_gdal_config` | `gdal_config(...)` | `as_gdal_config` | — | `is_gdal_config` | `check_gdal_config` | `gdal_config.R` |
| `gdal_dsn` | `new_gdal_dsn` | `gdal_dsn(...)` | `as_gdal_dsn` | `tiger_dsn` / `fema_dsn` (downstream pkgs) | `is_gdal_dsn` | `check_gdal_dsn` | `gdal_dsn.R` |
| `gdal_pipeline` | `new_gdal_pipeline` | `gdal_vector_pipeline(...)` | — | — | `is_gdal_pipeline` | `check_gdal_pipeline` | `gdal_pipeline.R` |
| `gdalg` | `new_gdalg` | — | `as_gdalg` | — | `is_gdalg` | `check_gdalg` | `gdal_pipeline.R` |
| `GDALVector` (gdalraster) | — | `gdal_vector(...)` | — | — | `is_gdal_vector` | `check_gdal_vector` | (gdalraster) |
| `GDALAlg` (gdalraster) | — | `gdal_alg(...)` | — | — | `is_gdal_alg` | `check_gdal_algorithm` | (gdalraster) |
| driver (string) | — | — | — | — | `is_gdal_driver` | `check_gdal_driver` | (n/a) |

Conventions implied by the table:
- Predicate naming: `is_<class>` (drop the `gdal_` only for the gdalraster externs? no —
  keep `is_gdal_*` for our classes; `is_gdal_vector`/`is_gdal_alg` for externs).
- Check naming: `check_<thing>` returning invisibly or aborting via cli/rlang. Open/creation
  checks are unprefixed shorthands (`check_open_opts`) since they're ours; driver/dsn/vector
  use the `gdal_` token to disambiguate from generic types.
- Errors/conditions for all of the above are raised through `gdalvector-conditions.R`
  helpers (`gdalvector_abort` / `gdal_abort_*` / `check_abort`).

---

## 5. Ideal function surface by module

### Generic `gdal_*` layer

**`gdal_opts.R`** — option value-objects + machinery
```r
new_gdal_opts(x, type, driver = NULL)                                          # internal
new_gdal_config_opts(x, driver = NULL)                                          # internal
new_gdal_open_opts(x, driver = NULL)                                            # internal
new_gdal_creation_opts(x, driver = NULL, scope = c("layer", "dataset"))         # internal
gdal_open_opts(..., driver = NULL)
gdal_creation_opts(..., driver = NULL, scope = c("layer", "dataset"))
as_gdal_config_opts(x, ..., driver = NULL)        # + .default/.list/.character/.tbl_df
as_gdal_open_opts(x, ..., driver = NULL)          # + .default/.list/.character/.tbl_df
as_gdal_creation_opts(x, ..., driver = NULL, scope = c("layer", "dataset"))  # + methods
validate_gdal_opts(x, driver = attr(x, "driver"))
as_gdal_args(x, ...)                              # + per-subclass + .character/.list/.gdal_pipeline
format.gdal_opts(x, ...); print.gdal_opts(x, ...); c.gdal_opts(...)
```

**`gdal_config.R`** — config object, typed builders, gdalrc, derivation
```r
gdal_config_opts(..., num_threads = NULL, progress = NULL, debug = NULL,
                 log_errors = NULL, log_file = NULL, timestamp = NULL,
                 tmpdir = NULL, alg_allow_writes_in_stream = NULL)
gdal_vsi_opts(..., cache = NULL, cache_size = NULL, disable_readdir_on_open = NULL)
gdal_curl_opts(..., connect_timeout = NULL, timeout = NULL, max_retry = NULL,
               retry_delay = NULL, headers = NULL, http_version = NULL, allowed_extensions = NULL)
gdal_config(...); new_gdal_config(opts = NULL, ...); as_gdal_config(x, ...)
gdal_config_apply(config); gdal_config_with(config, code)
gdal_config_get(key); gdal_config_unset(key)
gdal_config_read_rc(path); gdal_config_write_rc(config, path); set_gdal_config_file(path)
gdal_config_derive(dsn, ...)        # facts -> config (vsi handlers + driver + size)
gdal_config_init()
```

**`gdal_drivers.R`** — driver metadata + static caps
```r
gdal_driver_info(driver)
gdal_driver_identify(dsn, vector = TRUE, raster = FALSE, ...)
gdal_vector_driver(dsn); gdal_vector_driver_info(dsn, ...); gdal_vector_driver_format(dsn)
gdal_list_drivers(filter = NULL, vector_only = TRUE)
gdal_show_drivers(vector_only = FALSE, raster_only = FALSE, filter = NULL)
gdal_driver_show_open_opts(driver)
gdal_driver_show_creation_opts(driver, scope = c("layer", "dataset"))
gdal_driver_open_opts(driver, opts = list())
gdal_driver_creation_opts(driver, opts = list(), scope = c("layer", "dataset"))
gdal_driver_validate_open_opts(driver, opts)                  # arg order: driver first
gdal_driver_validate_creation_opts(driver, opts, scope = c("layer", "dataset"))
gdal_driver_caps(driver)            # static facts: role/open/lco/dsco/virtual_io/extensions/sql_dialects
gdal_driver_role(driver)            # "source"/"sink"/"both"
gdal_drivers_init()
```

**`gdal_vsi.R`** — stable
```r
vsi_path(path, ...); vsi_from_uri(uri); vsi_strip(path); vsi_handlers(path)
vsi_zip(path); vsi_curl(url); vsi_zip_curl(url, inner = NULL); vsi_azure(container, blob)
vsi_exists(path); vsi_size(path); vsi_type(path); vsi_meta(path, domain = "HEADERS")
vsi_ls(x, ...); vsi_glob(x, pattern = NULL); vsi_list_available(); vsi_list_options(dsn)
vsi_sync(src, dst, ...)
```

**`gdal_vector.R`** — `GDALVector` factory + introspection + runtime caps
```r
gdal_vector(dsn, layer = NULL, read_only = TRUE, open_opts = NULL,
            spatial_filter = NULL, dialect = NULL)
gdal_vector_layers(dsn)
gdal_vector_layer(dsn, index = 1L, filter = NULL)
gdal_vector_layer_select(dsn, prompt = "Select layer(s):",
                         type = c("select", "checkbox"), selected = NULL, return_index = FALSE)
gdal_vector_info(dsn, layer = gdal_vector_layer(dsn), open_opts = NULL, ...)
gdal_vector_schema(dsn, layer = gdal_vector_layer(dsn), open_opts = NULL, ...)
gdal_vector_geom_col(dsn, layer = gdal_vector_layer(dsn), fallback = "OGR_GEOMETRY")
gdal_vector_fid_col(dsn, layer = gdal_vector_layer(dsn), fallback = "")     # decision
gdal_vector_geom_col_type(dsn, layer = gdal_vector_layer(dsn))
gdal_vector_crs(dsn, layer = gdal_vector_layer(dsn))                        # [new]
gdal_vector_extent(dsn, layer = gdal_vector_layer(dsn))                     # [new]
gdal_vector_feature_count(dsn, layer = gdal_vector_layer(dsn), force = FALSE)  # [new]
gdal_vector_default_open_opts(dsn); gdal_vector_show_open_opts(dsn)
gdal_vector_caps(dsn, layer = gdal_vector_layer(dsn))                       # runtime testCapability()
```

**`gdal_dsn.R`** — read-profile object
```r
gdal_dsn(x, layer = NULL, ..., profile = TRUE)
new_gdal_dsn(uri, driver, layers = list(), open_opts = NULL,
             config_opts = NULL, caps = NULL, ...)
as_gdal_dsn(x, ...)
gdal_dsn_driver(dsn); gdal_dsn_layers(dsn); gdal_dsn_layer(dsn, index = 1L, filter = NULL)
gdal_dsn_open_opts(dsn); gdal_dsn_config_opts(dsn); gdal_dsn_caps(dsn)
gdal_dsn_profile(dsn, layer = NULL)
format.gdal_dsn(x, ...); print.gdal_dsn(x, ...)
```

**`gdal_pipeline.R`** — step AST + GDALG + execute
```r
gdal_vector_pipeline(source = NULL, config = NULL)
gdal_vector_read(pipeline, dsn, layer = NULL, open_opts = NULL, ...)
gdal_vector_filter(pipeline, where = NULL, bbox = NULL, ...)
gdal_vector_sql(pipeline, sql, dialect = c("SQLITE", "OGRSQL"))
gdal_vector_select(pipeline, fields = NULL, geom = NULL, exclude = NULL)
gdal_vector_reproject(pipeline, crs)
gdal_vector_make_valid(pipeline, method = c("linework", "structure"), keep_lower_dim = FALSE)
gdal_vector_set_geom_type(pipeline, geometry_type, multi = NULL, skip = FALSE)
gdal_vector_simplify(pipeline, tolerance)
gdal_vector_sort(pipeline, method = "hilbert")
gdal_vector_check_geometry(pipeline, geometry_field = NULL, include_fields = "ALL")
gdal_vector_tee(pipeline, branch)
gdal_vector_materialize(pipeline)
gdal_vector_write(pipeline, output, format = NULL, creation_opts = NULL, overwrite = FALSE, ...)
as_gdal_args(pipeline)
format.gdal_pipeline(x, ...); print.gdal_pipeline(x, ...)
new_gdalg(command_line, gdal_version = gdalraster::gdal_version_num(), relative_paths = TRUE)
gdalg_write(x, path); gdalg_read(path); validate_gdalg(gdalg, ...)
gdal_vector_execute(pipeline, config = NULL, backend = c("gdalraster", "cli"), dry_run = FALSE, ...)
```

**`gdal_sitrep.R`**
```r
gdal_sitrep(); gdal_check_alg_support(quiet = FALSE); gdal_version()
```

### Driver `{driver}_` layer

**`gpkg_opts.R` / `gpkg_pragmas.R` / `gpkg_validation.R` / `gpkg_connect.R`**
```r
gpkg_open_opts(list_all_tables = NULL, prelude_statements = NULL, nolock = NULL, immutable = NULL)
gpkg_layer_creation_opts(...)          # [new] -> as_gdal_creation_opts(driver="GPKG", scope="layer")
gpkg_dataset_creation_opts(...)        # [new] -> ... scope="dataset"
gpkg_config_opts(...)                  # [new] OGR_SQLITE_* / OGR_GPKG_*
gpkg_prelude_pragmas(cache_size = NULL, temp_store = NULL, mmap_size = NULL, journal_mode = NULL,
                     synchronous = NULL, busy_timeout = NULL, page_size = NULL, ...)
gpkg_pragma(dsn, pragma); gpkg_pragma_application_id(dsn)
gpkg_validate(dsn, ..., quiet = FALSE, call = rlang::caller_env())
gpkg_validate_magic_header(dsn, quiet = FALSE, call = rlang::caller_env())
gpkg_validate_application_id(dsn, quiet = FALSE, call = rlang::caller_env())
gpkg_magic_header(dsn); sqlite_magic_header(dsn)
gpkg_connect(dsn, read_only = TRUE, ...)
gpkg_caps()                            # [new] quirk overlay extending gdal_driver_caps("GPKG")
```

**`fgb_opts.R` / `fgb_validation.R`**
```r
fgb_open_opts(verify_buffers = TRUE)
fgb_layer_creation_opts(spatial_index = TRUE, temporary_dir = NULL, title = NULL, description = NULL)  # renamed
fgb_validate(dsn, ...); fgb_validate_magic_header(dsn, quiet = FALSE); fgb_magic_header(dsn)
fgb_caps()                             # [new] quirk overlay: no remote write, overwrite semantics
```

**`gpq_opts.R`**  (Parquet creation opts are layer-scoped)
```r
gpq_open_opts(geom_possible_names = "geometry,wkb_geometry,wkt_geometry",
              crs = "EPSG:4326", lists_as_string_json = "NO")
gpq_layer_creation_opts(compression = c("ZSTD","SNAPPY","GZIP","BROTLI","LZ4_RAW","NONE"),
                        compression_level = NULL, geometry_encoding = c("WKB","WKT","GEOARROW"),
                        row_group_size = 65536L, ...)   # [bug-fix of gpq_creation_opts]
gpq_caps()                             # [new]
```

**`shp_opts.R`**
```r
shp_config_opts(shape_rewind_on_write = c("NO","YES"), shape_restore_shx = c("NO","YES"),
                shape_2gb_limit = c("YES","NO"), shape_encoding = NULL)
shp_open_opts(encoding = NULL, dbf_date_last_update = NULL, adjust_type = c("NO","YES"),
              adjust_geom_type = c("FIRST_SHAPE","NO","ALL_SHAPES"),
              auto_repack = c("YES","NO"), dbf_eof_char = c("YES","NO"))
```

**`gdb_opts.R`** [new] (OpenFileGDB — FEMA source), **`pmtiles_opts.R` / `arrow_opts.R` / `mem_opts.R`** [planned sinks]
```r
gdb_open_opts(list_all_tables = NULL, ...)
# pmtiles_layer_creation_opts(...); arrow_layer_creation_opts(...); mem helpers
```

### Support `utils_*` / package layer

```r
# utils_predicates.R  -> all is_*  (class predicates from the registry above + path/url/fips/driver)
# utils_checks.R      -> all check_* (type checks, class checks, conn checks)
# utils_sql.R         -> new_sql, sql_quote_value, sql_in, sql_where_valid_geom,
#                        sql_spatial_index, sql_pragma            (SQL builders)
# utils_db.R          -> sqlite_*, adbc_connect*, duckdb_connect  (executors / connections)
# utils_binary.R      -> char_to_raw/hex, hex_to_raw, *_magic_header readers, strip_gpkg_wkb_header
# utils_xml.R         -> xml_parse_gdal_options(xml_str)          (driver md XML -> tibble)
# utils_strings.R     -> as_gdal_boolean(x)
# utils_system.R      -> sys_which, sys_platform
# utils_remote.R      -> ping, remote_*, local_*                  (httr2 remote-file workflow)
# utils_pkg.R         -> pkg_*, pkg_env_*                         (package metadata + .pkg_env)
# gdalvector-conditions.R -> gdalvector_abort/warn/inform, check_abort/warn/inform, gdal_abort_*
# aaa.R / zzz.R       -> constants, .pkg_env, on_load chain
```

> Boundary rules for the fuzzy bits:
> - **SQL**: `sql_*` (in `utils_sql.R`) **build** strings; `sqlite_*`/`gpkg_pragma` (in
>   `utils_db.R` / `gpkg_pragmas.R`) **execute** against a connection. Never mix.
> - **Driver-ID vs vector ops**: `gdal_driver_*` = format metadata (string in); `gdal_vector_*`
>   = operates on a vector dsn/handle. Both may sit in `gdal_drivers.R` only for the
>   identify helpers; everything else stays in `gdal_vector.R`.
> - **Predicates/checks are centralized** in `utils_predicates.R` / `utils_checks.R`, one per
>   registry row.

---

## 6. Gaps & TODO (delta from current -> ideal)

**Normalize**: `open_options`->`open_opts` in `gdal_vector()`; `gdal_driver_validate_open_opts`
arg order -> `(driver, opts)`; first-arg `gpkg_path`/`fgb_dsn` -> `dsn`; strip-list
inconsistency in `as_gdal_*_opts.character`.

**Bugs**: `gpq_creation_opts` (typo `compresion_level`, empty default, wrong `as_gdal_open_opts`
coercer) -> `gpq_layer_creation_opts`; `gpkg_prelude_pragmas` `journal_mode` arg_match discarded;
`vsi_azure` -> undefined `check_gdal_azure_config`.

**Add**: creation-opts `scope` attr + `--dsco` in `as_gdal_args`; `gdal_driver_caps` +
`gdal_vector_caps`; `format.gdal_opts`; `gpkg_layer/dataset_creation_opts` + `gpkg_config_opts`;
`gdb_*` module; build out `gdal_dsn` / `gdal_config` / `gdal_pipeline` (currently `[stub]`/empty)
and align the `is_*`/`check_*` registry rows that reference them.

---

## 7. Read-profile -> `gdal_dsn` (target flow)

`gdal_dsn()` is the profiler; given a URL/path it runs discovery -> derivation:

1. **Resolve (vsi)**: scheme `https`->`/vsicurl/`, `.zip`->`/vsizip/`, glob archives for
   `*.shp`/`*.gdb` -> concrete layer-bearing DSN(s).
2. **Identify driver** -> `gdal_driver_caps()` (role + caps).
3. **Introspect each layer** via short-lived `GDALVector`: layer, geom/fid col, geom type,
   crs, schema, feature count (if fast), extent, spatial-index presence, `gdal_vector_caps()`.
4. **Derive `open_opts`** driver-tuned from facts (GPKG prelude pragmas sized to file; SHP
   encoding).
5. **Derive `config_opts`** via `gdal_config_derive()` from vsi handlers + driver + size
   (remote -> readdir/cache; remote SHP -> allowed extensions; `/vsizip/` -> deflate chunk;
   `/vsis3/` -> AWS group) — introspection-driven, not hardcoded.

Result: `gdal_dsn` = `{uri, vsi_handlers, driver, role, caps, layers[profile], open_opts,
config_opts}` — the complete read profile.

Minimal user interactions are the **write-side spec**, not the read profile: schema overrides
-> `sql`/`select`; target CRS -> `reproject` (auto-elided if profiled SRS matches); make-valid /
simplify -> steps; write format -> sink driver module + creation opts + capability validation.
From `gdal_dsn` + those knobs the pipeline assembles and emits the config-free GDALG + the gdalrc.

Downstream, `tiger_dsn` / `fema_dsn` subclass `gdal_dsn` to pre-bake URL grammar and per-source opts.
