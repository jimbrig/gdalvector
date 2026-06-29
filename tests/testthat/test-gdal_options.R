#  ------------------------------------------------------------------------
#
# Title : GDAL Options - Core S3 System
#    By : Jimmy Briggs
#  Date : 2026-06-29
#
#  ------------------------------------------------------------------------

# construction invariants -----------------------------------------------------------------------------------------

test_that("constructors build named-list payloads with the right class and attributes", {
  oo <- gdal_open_opts(LIST_ALL_TABLES = FALSE, driver = "GPKG")
  expect_gdal_opts(oo, "gdal_open_opts", driver = "GPKG")
  expect_opt_value(oo, "LIST_ALL_TABLES", "NO")
  expect_true(is_gdal_open_opts(oo))
  expect_true(is_gdal_opts(oo))

  co <- gdal_creation_opts(COMPRESSION = "ZSTD", driver = "Parquet", level = "dataset")
  expect_gdal_opts(co, "gdal_creation_opts", driver = "Parquet", level = "dataset")

  cfg <- gdal_config_opts(CPL_DEBUG = "ON")
  expect_true(is_gdal_config_opts(cfg))

  vsi <- gdal_vsi_opts(AWS_REGION = "us-east-1", vsi_path = "/vsis3/bucket")
  expect_true(is_gdal_vsi_opts(vsi))
  expect_identical(attr(vsi, "vsi_path"), "/vsis3/bucket")
})

test_that("creation constructor defaults to layer level and rejects unknown levels", {
  expect_identical(attr(gdal_creation_opts(A = "1"), "level"), "layer")
  expect_error(gdal_creation_opts(A = "1", level = "nope"))
})

# normalization ---------------------------------------------------------------------------------------------------

test_that("normalization uppercases names, coerces values, and drops NULL/NA", {
  x <- .gdal_opts_normalize(list(verify_buffers = TRUE, temporary_dir = NULL, title = NA, n = 100000))
  expect_named(x, c("VERIFY_BUFFERS", "N"))
  expect_identical(x[["VERIFY_BUFFERS"]], "YES")
  # numeric values must not become scientific notation
  expect_identical(x[["N"]], "100000")
})

test_that("normalization coerces logical, numeric, and character values to GDAL strings", {
  x <- .gdal_opts_normalize(list(a = FALSE, b = 1.5, c = "raw", d = 8589934592))
  expect_identical(x[["A"]], "NO")
  expect_identical(x[["B"]], "1.5")
  expect_identical(x[["C"]], "raw")
  expect_identical(x[["D"]], "8589934592")
})

test_that("duplicate names keep the last value", {
  x <- .gdal_opts_normalize(list(A = "1", a = "2"))
  expect_identical(x, list(A = "2"))
})

test_that("normalization of an empty or all-empty list yields an empty named list", {
  expect_identical(.gdal_opts_normalize(list()), stats::setNames(list(), character()))
  expect_identical(.gdal_opts_normalize(NULL), stats::setNames(list(), character()))
  expect_identical(.gdal_opts_normalize(list(a = NULL, b = NA)), stats::setNames(list(), character()))
})

test_that("normalization rejects non-scalar values and unnamed input with classed errors", {
  expect_error(.gdal_opts_normalize(list(A = c("1", "2"))), class = "gdal_opts_value_error")
  expect_error(.gdal_opts_normalize(list("1")), class = "gdal_check_error")
})

test_that("empty constructors yield an empty named list payload", {
  oo <- gdal_open_opts()
  expect_length(unclass(oo), 0L)
  expect_identical(as.list(oo), stats::setNames(list(), character()))
})

# input-form equivalence ------------------------------------------------------------------------------------------

test_that("option NAMES canonicalize to upper-case regardless of the input case", {
  upper <- gdal_config_opts(GDAL_NUM_THREADS = "ALL_CPUS", CPL_DEBUG = "ON")
  lower <- gdal_config_opts(gdal_num_threads = "ALL_CPUS", cpl_debug = "ON")
  mixed <- gdal_config_opts(Gdal_Num_Threads = "ALL_CPUS", Cpl_Debug = "ON")
  expect_identical(lower, upper)
  expect_identical(mixed, upper)
})

test_that("scalar values coerce by type: integer, double, and string render identically", {
  expect_identical(
    as.list(gdal_config_opts(GDAL_NUM_THREADS = 4L)),
    as.list(gdal_config_opts(GDAL_NUM_THREADS = "4"))
  )
  expect_identical(
    as.list(gdal_config_opts(GDAL_NUM_THREADS = 4)),
    as.list(gdal_config_opts(GDAL_NUM_THREADS = "4"))
  )
  # large numerics never fall back to scientific notation
  expect_identical(unclass(gdal_config_opts(GDAL_CACHEMAX = 4e9))[["GDAL_CACHEMAX"]], "4000000000")
})

test_that("logical values render to YES/NO (note: this is distinct from the ON/OFF string form)", {
  # locks in the documented coercion; TRUE -> 'YES' is *not* the same payload as the literal 'ON'
  expect_identical(unclass(gdal_config_opts(CPL_DEBUG = TRUE))[["CPL_DEBUG"]], "YES")
  expect_identical(unclass(gdal_config_opts(CPL_DEBUG = FALSE))[["CPL_DEBUG"]], "NO")
  expect_false(identical(
    unclass(gdal_config_opts(CPL_DEBUG = TRUE))[["CPL_DEBUG"]],
    unclass(gdal_config_opts(CPL_DEBUG = "ON"))[["CPL_DEBUG"]]
  ))
})

test_that("a list, a KEY=VALUE character vector, and dots produce equivalent open opts", {
  from_dots <- gdal_open_opts(LIST_ALL_TABLES = "NO", NOLOCK = "YES", driver = "GPKG")
  from_list <- as_gdal_open_opts(list(LIST_ALL_TABLES = "NO", NOLOCK = "YES"), driver = "GPKG")
  from_chr <- as_gdal_open_opts(c("LIST_ALL_TABLES=NO", "NOLOCK=YES"), driver = "GPKG")
  expect_opts_equivalent(from_list, from_dots)
  expect_opts_equivalent(from_chr, from_dots)
})

# as_gdal_boolean -------------------------------------------------------------------------------------------------

test_that("as_gdal_boolean coerces logicals and drops empty-ish values", {
  expect_identical(as_gdal_boolean(TRUE), "YES")
  expect_identical(as_gdal_boolean(FALSE), "NO")
  expect_null(as_gdal_boolean(NULL))
  expect_null(as_gdal_boolean(NA))
  expect_null(as_gdal_boolean(""))
  # already-stringified GDAL values pass through unchanged
  expect_identical(as_gdal_boolean("AUTO"), "AUTO")
})

# coercion --------------------------------------------------------------------------------------------------------

test_that("as_gdal_*_opts coerces lists, KEY=VALUE characters, and self", {
  from_list <- as_gdal_open_opts(list(LIST_ALL_TABLES = "NO"))
  from_chr <- as_gdal_open_opts("LIST_ALL_TABLES=NO")
  expect_opt_value(from_list, "LIST_ALL_TABLES", "NO")
  expect_opt_value(from_chr, "LIST_ALL_TABLES", "NO")

  # self-coercion can re-tag the driver
  retagged <- as_gdal_open_opts(from_list, driver = "GPKG")
  expect_identical(attr(retagged, "driver"), "GPKG")
})

test_that("as_gdal_*_opts coerces a driver-metadata tibble to its declared defaults", {
  md <- gdal_vector_driver_open_opts("GPKG")
  oo <- as_gdal_open_opts(md, driver = "GPKG")
  expect_gdal_opts(oo, "gdal_open_opts", driver = "GPKG")
  # only options that declare a default survive, with the default as the value
  expect_opt_value(oo, "LIST_ALL_TABLES", "AUTO")
})

test_that(".gdal_opts_from_md keeps only rows with a declared default", {
  md <- gdal_vector_driver_open_opts("GPKG")
  defaults <- .gdal_opts_from_md(md)
  expect_type(defaults, "list")
  expect_true(all(!is.na(unlist(defaults))))
  expect_identical(defaults[["LIST_ALL_TABLES"]], "AUTO")
})

test_that("creation coercion threads the level through", {
  co <- as_gdal_creation_opts(list(COMPRESSION = "ZSTD"), driver = "Parquet", level = "dataset")
  expect_identical(attr(co, "level"), "dataset")
})

test_that("KEY=VALUE parsing preserves '=' inside the value", {
  expect_identical(.gdal_opts_parse_kv("CRS=EPSG:4326"), list(CRS = "EPSG:4326"))
  expect_identical(.gdal_opts_parse_kv("PRELUDE=PRAGMA a=1;"), list(PRELUDE = "PRAGMA a=1;"))
})

test_that("coercion of unsupported input or bad KEY=VALUE errors with a classed condition", {
  expect_error(as_gdal_open_opts(42), class = "gdal_opts_coerce_error")
  expect_error(as_gdal_config_opts(42), class = "gdal_opts_coerce_error")
  expect_error(as_gdal_creation_opts(42), class = "gdal_opts_coerce_error")
  expect_error(as_gdal_open_opts("LIST_ALL_TABLES"), class = "gdal_opts_coerce_error")
})

# methods ---------------------------------------------------------------------------------------------------------

test_that("as.character and as.list round-trip the payload", {
  oo <- gdal_open_opts(LIST_ALL_TABLES = "NO", NOLOCK = TRUE, driver = "GPKG")
  expect_identical(as.character(oo), c("LIST_ALL_TABLES=NO", "NOLOCK=YES"))
  expect_identical(as.list(oo), list(LIST_ALL_TABLES = "NO", NOLOCK = "YES"))
})

test_that("c() merges payloads with later values winning", {
  a <- gdal_open_opts(LIST_ALL_TABLES = "NO", driver = "GPKG")
  b <- gdal_open_opts(LIST_ALL_TABLES = "YES", NOLOCK = TRUE, driver = "GPKG")
  merged <- c(a, b)
  expect_opt_value(merged, "LIST_ALL_TABLES", "YES")
  expect_named(unclass(merged), c("LIST_ALL_TABLES", "NOLOCK"))
  # the prototype's driver/level attributes are preserved
  expect_identical(attr(merged, "driver"), "GPKG")
})

test_that("c() warns when combining multiple drivers", {
  a <- gdal_open_opts(LIST_ALL_TABLES = "NO", driver = "GPKG")
  b <- gdal_open_opts(VERIFY_BUFFERS = "NO", driver = "FlatGeobuf")
  expect_warning(c(a, b), class = "gdal_opts_merge_warning")
})

test_that("c() warns when combining creation options of multiple levels", {
  a <- gdal_creation_opts(A = "1", driver = "GPKG", level = "layer")
  b <- gdal_creation_opts(B = "2", driver = "GPKG", level = "dataset")
  expect_warning(c(a, b), class = "gdal_opts_merge_warning")
})

test_that("c() drops NULL arguments and returns NULL when everything is NULL", {
  a <- gdal_open_opts(LIST_ALL_TABLES = "NO", driver = "GPKG")
  expect_opt_value(c(a, NULL), "LIST_ALL_TABLES", "NO")
  expect_null(c(NULL, NULL))
})

test_that("format()/print() render the expected cli lines (inline)", {
  withr::local_options(cli.num_colors = 1, cli.width = 200)
  oo <- gdal_open_opts(LIST_ALL_TABLES = FALSE, driver = "GPKG")
  expect_snapshot(print(oo))
})

test_that("format()/print() switch to block style beyond four options", {
  withr::local_options(cli.num_colors = 1, cli.width = 200)
  co <- gdal_creation_opts(A = 1, B = 2, C = 3, D = 4, E = 5, driver = "Parquet")
  expect_snapshot(print(co))
})

# as_gdal_args ----------------------------------------------------------------------------------------------------

test_that("as_gdal_args emits repeated-flag CLI tokens (never packed)", {
  oo <- gdal_open_opts(LIST_ALL_TABLES = "NO", NOLOCK = "YES", driver = "GPKG")
  expect_identical(
    as_gdal_args(oo),
    c("--oo", "LIST_ALL_TABLES=NO", "--oo", "NOLOCK=YES")
  )
  expect_identical(
    as_gdal_args(oo, long = TRUE),
    c("--open-option", "LIST_ALL_TABLES=NO", "--open-option", "NOLOCK=YES")
  )
})

test_that("as_gdal_args(cli = FALSE) yields a bare unnamed KEY=VALUE vector", {
  oo <- gdal_open_opts(LIST_ALL_TABLES = "NO", NOLOCK = "YES", driver = "GPKG")
  out <- as_gdal_args(oo, cli = FALSE)
  expect_identical(out, c("LIST_ALL_TABLES=NO", "NOLOCK=YES"))
  expect_null(names(out))
})

test_that("with_format prepends the input/output format flag and driver", {
  oo <- gdal_open_opts(LIST_ALL_TABLES = "NO", driver = "GPKG")
  expect_identical(
    as_gdal_args(oo, with_format = TRUE),
    c("--input-format", "GPKG", "--oo", "LIST_ALL_TABLES=NO")
  )
  co <- gdal_creation_opts(COMPRESSION = "ZSTD", driver = "Parquet")
  expect_identical(
    as_gdal_args(co, with_format = TRUE),
    c("--output-format", "Parquet", "--lco", "COMPRESSION=ZSTD")
  )
})

test_that("with_format is a no-op when the driver is unknown", {
  oo <- gdal_open_opts(LIST_ALL_TABLES = "NO")
  expect_identical(as_gdal_args(oo, with_format = TRUE), c("--oo", "LIST_ALL_TABLES=NO"))
})

test_that("config options render to --config tokens (never a format flag)", {
  cfg <- gdal_config_opts(CPL_DEBUG = "ON", driver = "GPKG")
  expect_identical(as_gdal_args(cfg, with_format = TRUE), c("--config", "CPL_DEBUG=ON"))
})

test_that("creation level selects the right flag", {
  expect_identical(gdal_opts_cli_flag(gdal_creation_opts(A = "1", level = "layer")), "--lco")
  expect_identical(gdal_opts_cli_flag(gdal_creation_opts(A = "1", level = "dataset")), "--co")
  expect_identical(
    gdal_opts_cli_flag(gdal_creation_opts(A = "1", level = "layer"), long = TRUE),
    "--layer-creation-option"
  )
  expect_identical(gdal_opts_cli_flag(gdal_creation_opts(A = "1", level = "dataset"), long = TRUE), "--creation-option")
})

test_that("empty opts produce empty args", {
  expect_identical(as_gdal_args(gdal_open_opts()), character())
})

test_that("as_gdal_args passes through character vectors and flattens lists", {
  expect_identical(as_gdal_args(c("--oo", "A=1")), c("--oo", "A=1"))
  opts_list <- list(
    gdal_open_opts(LIST_ALL_TABLES = "NO", driver = "GPKG"),
    gdal_creation_opts(COMPRESSION = "ZSTD", driver = "Parquet")
  )
  expect_identical(
    as_gdal_args(opts_list),
    c("--oo", "LIST_ALL_TABLES=NO", "--lco", "COMPRESSION=ZSTD")
  )
})

test_that("as_gdal_args errors on an unsupported object", {
  expect_error(as_gdal_args(42), class = "gdal_opts_coerce_error")
})

test_that("gdal_opts_cli_flag errors on a bare base gdal_opts object", {
  base <- structure(list(A = "1"), class = c("gdal_opts", "list"))
  expect_error(gdal_opts_cli_flag(base), class = "gdal_opts_error")
})

# as_config_option ------------------------------------------------------------------------------------------------

test_that("as_config_option returns a NAME=VALUE named vector for set_config_option", {
  cfg <- gdal_config_opts(CPL_DEBUG = "ON", GDAL_NUM_THREADS = "ALL_CPUS")
  expect_identical(
    as_config_option(cfg),
    c(CPL_DEBUG = "ON", GDAL_NUM_THREADS = "ALL_CPUS")
  )
  # config also renders to --config CLI tokens
  expect_identical(
    as_gdal_args(cfg),
    c("--config", "CPL_DEBUG=ON", "--config", "GDAL_NUM_THREADS=ALL_CPUS")
  )
})

test_that("as_config_option handles vsi opts and rejects non-config objects", {
  vsi <- gdal_vsi_opts(AWS_REGION = "us-east-1")
  expect_identical(as_config_option(vsi), c(AWS_REGION = "us-east-1"))
  expect_error(as_config_option(gdal_open_opts(LIST_ALL_TABLES = "NO")), class = "gdal_opts_coerce_error")
})

test_that("as_config_option on empty config opts yields an empty named vector", {
  out <- as_config_option(gdal_config_opts())
  expect_length(out, 0L)
  expect_type(out, "character")
})

test_that("config round-trips through set_config_option / get_config_option", {
  skip_if_not_installed("gdalraster")
  old <- gdalraster::get_config_option("CPL_DEBUG")
  withr::defer(gdalraster::set_config_option("CPL_DEBUG", old))
  cfg <- gdal_config_opts(CPL_DEBUG = "OFF")
  vec <- as_config_option(cfg)
  gdalraster::set_config_option(names(vec)[[1]], vec[[1]])
  expect_identical(gdalraster::get_config_option("CPL_DEBUG"), "OFF")
})

# gdal_render -----------------------------------------------------------------------------------------------------

test_that("gdal_render produces shell-specific continuations and quoting", {
  co <- gdal_creation_opts(COMPRESSION = "ZSTD", driver = "Parquet")

  bash <- gdal_render(co, shell = "bash")
  expect_match(bash, "--output-format 'Parquet'", fixed = TRUE)
  expect_match(bash, " \\\n", fixed = TRUE)

  sh <- gdal_render(co, shell = "sh")
  expect_match(sh, " \\\n", fixed = TRUE)

  pwsh <- gdal_render(co, shell = "pwsh")
  expect_match(pwsh, " `\n", fixed = TRUE)

  cmd <- gdal_render(co, shell = "cmd")
  expect_match(cmd, " ^\n", fixed = TRUE)
  # cmd uses double quotes
  expect_match(cmd, '--output-format "Parquet"', fixed = TRUE)
})

test_that("gdal_render is empty for empty opts and rejects bad shells / objects", {
  expect_identical(gdal_render(gdal_open_opts()), "")
  expect_error(gdal_render(gdal_creation_opts(A = "1"), shell = "fish"))
  expect_error(gdal_render(42))
})

# validation ------------------------------------------------------------------------------------------------------

test_that("validate_gdal_opts returns TRUE for valid open/creation/config options", {
  expect_true(validate_gdal_opts(gdal_open_opts(LIST_ALL_TABLES = "NO", driver = "GPKG")))
  expect_true(validate_gdal_opts(gdal_creation_opts(SPATIAL_INDEX = "YES", driver = "GPKG", level = "layer")))
  expect_true(validate_gdal_opts(gdal_config_opts(SQLITE_USE_OGR_VFS = "YES", driver = "GPKG")))
})

test_that("validate_gdal_opts returns TRUE for an empty payload", {
  expect_true(validate_gdal_opts(gdal_open_opts(driver = "GPKG")))
})

test_that("validate_gdal_opts returns NA (with a warning) when no driver is known", {
  expect_warning(
    res <- validate_gdal_opts(gdal_open_opts(LIST_ALL_TABLES = "NO")),
    class = "gdal_opts_warning"
  )
  expect_true(is.na(res))
})

test_that("validate_gdal_opts errors on a non-gdal_opts object or unknown driver", {
  expect_error(validate_gdal_opts(list(a = 1)), class = "gdal_check_error")
  expect_error(
    validate_gdal_opts(gdal_open_opts(LIST_ALL_TABLES = "NO"), driver = "NOPE"),
    class = "gdal_check_error"
  )
})

test_that("validate_gdal_opts warns on unknown option names", {
  expect_warning(
    res <- validate_gdal_opts(gdal_open_opts(NOT_A_REAL_OPTION = "x", driver = "GPKG")),
    class = "gdal_opts_unknown_warning"
  )
  expect_false(res)
})

test_that("validate_gdal_opts warns on invalid enumerated values", {
  expect_warning(
    res <- validate_gdal_opts(gdal_open_opts(LIST_ALL_TABLES = "MAYBE", driver = "GPKG")),
    class = "gdal_opts_value_warning"
  )
  expect_false(res)
})

test_that("free-string options (no enumerated set) are not flagged", {
  oo <- gdal_open_opts(
    LIST_ALL_TABLES = "NO",
    PRELUDE_STATEMENTS = "PRAGMA cache_size=-2000;",
    driver = "GPKG"
  )
  expect_true(validate_gdal_opts(oo))
})

test_that("validation matches option names and values case-insensitively", {
  expect_true(validate_gdal_opts(gdal_open_opts(list_all_tables = "no", driver = "GPKG")))
})

# vsi options -----------------------------------------------------------------------------------------------------

test_that("gdal_vsi_opts carries a vsi_path attribute and is config-like", {
  vsi <- gdal_vsi_opts(AWS_REGION = "us-east-1", AWS_S3_ENDPOINT = "s3.amazonaws.com", vsi_path = "/vsis3/bucket")
  expect_gdal_opts(vsi, "gdal_vsi_opts")
  expect_identical(attr(vsi, "vsi_path"), "/vsis3/bucket")
  expect_true(is_gdal_vsi_opts(vsi))
})

test_that("vsi opts render as --config tokens and a config-option vector", {
  vsi <- gdal_vsi_opts(AWS_REGION = "us-east-1")
  expect_identical(as_gdal_args(vsi), c("--config", "AWS_REGION=us-east-1"))
  expect_identical(as_config_option(vsi), c(AWS_REGION = "us-east-1"))
})

test_that("vsi opts coerce from lists and KEY=VALUE characters, and re-tag the path", {
  from_list <- as_gdal_vsi_opts(list(AWS_REGION = "us-east-1"), vsi_path = "/vsis3/bucket")
  from_chr <- as_gdal_vsi_opts("AWS_REGION=us-east-1")
  expect_opt_value(from_list, "AWS_REGION", "us-east-1")
  expect_opt_value(from_chr, "AWS_REGION", "us-east-1")
  expect_identical(attr(from_list, "vsi_path"), "/vsis3/bucket")

  retagged <- as_gdal_vsi_opts(from_chr, vsi_path = "/vsigs/bucket")
  expect_identical(attr(retagged, "vsi_path"), "/vsigs/bucket")
})

test_that("an empty vsi opts object renders to nothing and coercion errors on bad input", {
  vsi <- gdal_vsi_opts()
  expect_identical(as_gdal_args(vsi), character())
  expect_length(as_config_option(vsi), 0L)
  expect_error(as_gdal_vsi_opts(42), class = "gdal_opts_coerce_error")
})

# rendering integration -------------------------------------------------------------------------------------------

test_that("a full workload separates session config from per-step open/creation args", {
  # config options are session/process state (never algorithm args)
  cfg <- gdal_config_opts(GDAL_NUM_THREADS = "ALL_CPUS", OGR_SQLITE_SYNCHRONOUS = "OFF")
  expect_identical(as_config_option(cfg), c(GDAL_NUM_THREADS = "ALL_CPUS", OGR_SQLITE_SYNCHRONOUS = "OFF"))

  # open + creation options are per-step algorithm args; a PRELUDE payload with ';' must survive
  # as a single token
  prelude <- "PRAGMA cache_size=-4000000;PRAGMA temp_store=MEMORY;"
  oo <- gdal_open_opts(LIST_ALL_TABLES = "NO", PRELUDE_STATEMENTS = prelude, driver = "GPKG")
  co <- gdal_creation_opts(COMPRESSION = "ZSTD", GEOMETRY_ENCODING = "WKB", driver = "Parquet")

  read_args <- c("read", "--input", "parcels.gpkg", as_gdal_args(oo, with_format = TRUE))
  write_args <- c("write", "--output", "parcels.parquet", as_gdal_args(co, with_format = TRUE), "--overwrite")

  expect_true(all(c("--input-format", "GPKG") %in% read_args))
  expect_identical(sum(read_args == "--oo"), 2L)
  expect_true(any(read_args == paste0("PRELUDE_STATEMENTS=", prelude)))
  expect_true(all(c("--output-format", "Parquet", "--lco") %in% write_args))
})
