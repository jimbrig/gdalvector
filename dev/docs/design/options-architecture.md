# gdalvector Options Architecture & GDAL Mapping

How the package models GDAL vector options, how that maps onto the underlying GDAL/OGR
APIs and the `gdal` CLI, and where the implementation currently stands vs. the GDAL
ground truth. Companion docs:

- `gdal-vector-driver-options.md` — generated per-driver option metadata (ground truth).
- `gdal-config-options.md` — global CPL/OGR configuration options for the focus drivers.
- `gdal-best-practices.md` — per-driver read/write performance best practices.

## 1. The four kinds of "options" (and where they come from)

GDAL exposes several distinct option channels. The package models each as an S3 subclass
of `gdal_opts` (a classed `character` vector of `"KEY=VALUE"` strings + a `driver` attribute):

| Package class | GDAL channel | CLI flag(s) | C/C++ API | Metadata key |
|---|---|---|---|---|
| `gdal_config_opts` | global configuration | `--config KEY=VALUE` | `CPLSetConfigOption()` / env vars | *(none — not in driver metadata)* |
| `gdal_open_opts` | dataset open options | `--oo` / `--open-option` | `GDALOpenEx(papszOpenOptions=)` | `DMD_OPENOPTIONLIST` |
| `gdal_creation_opts` (`level = "dataset"`) | dataset creation options | `--co` / `--creation-option` (legacy `-dsco`) | `GDALCreate()` / dataset create | `DMD_CREATIONOPTIONLIST` |
| `gdal_creation_opts` (`level = "layer"`) | layer creation options | `--lco` / `--layer-creation-option` | `GDALDatasetCreateLayer()` | `DS_LAYER_CREATIONOPTIONLIST` |

Key consequences:

- **Open + creation options are fully metadata-described** by the driver (`gdal_get_driver_md()`),
  so the package derives allowed values, types, defaults, and enumerations directly from GDAL —
  nothing is hardcoded.
- **Config options are NOT in driver metadata.** They live in the GDAL docs (per-driver
  "Configuration options" sections) and the CPL API. This is the one channel that cannot be
  metadata-driven; see §6.
- The dataset-vs-layer creation split is collapsed into a single `gdal_creation_opts` class
  carrying a **`level`** attribute (`"layer"` default, or `"dataset"`), which selects the CLI
  flag and the metadata list. (`level` is distinct from the metadata `scope` field, which is the
  raster-vs-vector axis.)

## 2. Driver metadata is the source of truth

`R/gdal_drivers.R` + `R/utils_xml.R` parse the registered driver metadata into tibbles
(`name`, `description`, `scope`, `type`, `default`, `values`):

- `gdal_driver_get_open_opts(driver)` ← `DMD_OPENOPTIONLIST` (vector-scoped).
- `gdal_driver_get_creation_opts(driver)` ← `DMD_CREATIONOPTIONLIST` **+** `DS_LAYER_CREATIONOPTIONLIST`
  (vector-scoped), tagged with a `level` column. *(GDAL/`gdalraster::getCreationOptions()` only
  reads the DMD list, which is `NULL` for layer-only drivers like FlatGeobuf — hence the package
  always reads both lists itself.)*
- Derived accessors (used by the builders): `_defaults()` (name→default for options with a
  default) and `_values()` (name→allowed values; booleans expanded to `YES`/`NO`).
- `gdal_driver_meta()` rolls capabilities + both option tibbles into one row per driver.

`xml_parse_gdal_options()` handles all three metadata XML shapes and the `scope` filter
(`vector`/`raster`); the `scope` attribute is only populated for dual raster+vector drivers
(GPKG is the notable case).

## 3. The uniform builder pattern

Every driver-specific builder (`fgb_*`, `gpq_*`, `gpkg_*`, `shp_*`) is a thin, metadata-driven
interface with an identical shape and the same shared systems:

```r
<fmt>_<kind>_opts <- function(<R-friendly args> = NULL, .set_defaults = FALSE) {
  opts <- purrr::compact(list(OPT = as_gdal_boolean(arg) | arg, ...))   # 1. coerce (logical -> YES/NO)
  if (length(opts) > 0L)
    check_gdal_opts(opts, gdal_driver_get_<kind>_opts_values("<driver>")) # 2. validate vs metadata (abort)
  if (.set_defaults)
    opts <- utils::modifyList(as.list(gdal_driver_get_<kind>_opts_defaults("<driver>")), opts) # 3. fill defaults
  new_gdal_<kind>_opts(opts, driver = "<driver>"[, level = ...])         # 4. construct
}
```

Principles baked in:

- **NULL defaults everywhere** — a builder with no args yields an empty opts object; only
  explicitly-set options are emitted (never redundantly emit GDAL's own defaults).
- **Coercion is the single `TRUE/FALSE -> YES/NO` case** (`as_gdal_boolean()`); everything else is
  passthrough.
- **Validation is metadata-driven and aborts** at construction (`check_gdal_opt`/`check_gdal_opts`
  → `check_abort`), with error messages listing the allowed values pulled from metadata. Bad input
  never produces a half-built object (defensive: the cost of a late pipeline failure is high).
- **`.set_defaults`** materializes the driver's GDAL metadata defaults for unset options
  (user values still win). Uniform across all open/creation builders.

Two construction tiers:

- **Generic / power-user**: `gdal_open_opts()`, `gdal_creation_opts()`, `gdal_config_opts()`,
  and the `as_gdal_*_opts()` coercers. When a driver is supplied these **drop unknown option
  names with a warning**; without a driver they are permissive.
- **Curated / typed**: `<fmt>_*_opts()` — named R args, hard `check`/abort on bad values, plus a
  home for deeper semantic checks (see §6).

## 4. Rendering & args

- `as_gdal_args(x)` → interleaved CLI tokens (`--oo`/`--co`/`--lco`/`--config`) for `gdalraster`'s
  `gdal_alg()` (the `gdal` CLI algorithmic API) and `gdalg` pipelines.
- `gdal_render(x, shell = bash|sh|pwsh|cmd)` → copy-pasteable shell snippet (dialect-aware quoting
  and line continuations).
- `print.*` shows the class, driver, options (aligned vertically when many), and the rendered
  command line.

## 5. Conditions & validation system

`R/gdalvector-conditions.R` is the package-wide, purpose-agnostic emission layer:

- Signalers: `gdal_abort()/warn()/inform()` (base, class hierarchy `gdal_error`/`gdal_warning`/
  `gdal_message`/`gdal_condition`), specialized `gdal_abort_{driver,open,layer,vsi,opts}()`,
  and `check_abort()/warn()/inform()`.
- A reusable validation-result spine (`new_validation()`, `validation_step()`,
  `validation_require/warn/note()`, `validation_signal()`, `gdal_abort_validation()`,
  `print.gdal_validation`) for multi-step validations (option conformance, format-spec checks,
  sitrep/ABI checks) — graded per-step, escalated by the caller.

Two cost tiers (orthogonal to severity): cheap `check_*` assertions (`utils_checks.R`) vs.
heavier `*_validate` validations (driver/format/sitrep) built on the spine.

## 6. Gaps & recommendations (codebase vs. GDAL ground truth)

1. **Config options have no metadata source.** `shp_config_opts()` exists; `gpkg_config_opts()`
   is referenced in `ABSTRACTIONS.md` but not implemented. Options cannot be derived from
   `gdal_get_driver_md()`. Recommendation: a small curated `sysdata` table of the focus-driver
   config options (name/type/values/default/scope, sourced from `gdal-config-options.md`) fronted
   by `gdal_*_config_opts_values()/_defaults()` so config builders join the same uniform system.
   Until then config builders are NULL-default + `as_gdal_boolean` only (no metadata validation,
   no `.set_defaults`).
2. **Deeper GPKG semantic checks (PRAGMAs subsystem).** `PRELUDE_STATEMENTS` is a SQLite PRAGMA
   payload with cross-option implications (e.g. write-oriented PRAGMAs with `IMMUTABLE`/read-only;
   invalid `page_size`/`cache_size`). Currently a `# TODO` in `gpkg_open_opts()`. Recommend a
   dedicated `gpkg_prelude_pragmas()`-backed validation step.
3. **Missing curated builders for two focus drivers.** No `pmtiles_*` (a modern CNF write target)
   or `gdb_*`/OpenFileGDB builders yet. The generic `gdal_*_opts(driver=)` path already works for
   them via metadata; curated typed builders can be added on demand.
4. **`gdalraster` is the engine.** All metadata, the `GDALVector` object, and the `gdal` CLI
   algorithmic API come from `gdalraster`. The dataset/pipeline wrappers (`gdal_vector*`, `gdalg`)
   are still WIP (staged in `dev/R/`).
5. **Format-spec validators** (`gpkg_validate`/`fgb_validate`) are partial — they should be ported
   onto the validation spine (§5) to emit consistent `gdal_validation` reports.

## 7. References

- GDAL vector drivers: <https://gdal.org/en/stable/drivers/vector/index.html>
- GDAL configuration options: <https://gdal.org/en/stable/user/configoptions.html>
- `gdal` CLI (migration from ogr2ogr): <https://gdal.org/en/stable/programs/migration_guide_to_gdal_cli.html>
- GDAL Vector Data Model: <https://gdal.org/en/stable/user/vector_data_model.html>
- gdalraster Vector API overview: <https://firelab.github.io/gdalraster/articles/vector-api-overview.html>
- GeoParquet distribution best practices:
  <https://github.com/opengeospatial/geoparquet/blob/main/format-specs/distributing-geoparquet.md>
