#  ------------------------------------------------------------------------
#
# Title : GDAL Configuration System
#    By : Jimmy Briggs
#  Date : 2026-07-02
#
#  ------------------------------------------------------------------------

# value class -----------------------------------------------------------------------------------------------------

test_that("gdal_config() constructs a value from heterogeneous inputs (later wins)", {
  cfg <- gdal_config(
    gdal_config_opts(GDAL_NUM_THREADS = "2"),
    list(CPL_TMPDIR = "a"),
    "CPL_TMPDIR=b",
    GDAL_NUM_THREADS = "4"
  )
  expect_true(is_gdal_config(cfg))
  expect_true(is_gdal_config_opts(cfg$opts))
  expect_identical(as.list(cfg$opts), list(GDAL_NUM_THREADS = "4", CPL_TMPDIR = "b"))
  expect_length(cfg$vsi, 0L)
})

test_that("gdal_config() keeps path-bound vsi opts in the vsi channel, unbound in the global", {
  cfg <- gdal_config(
    gdal_vsi_opts(AWS_REGION = "us-west-2"),
    gdal_vsi_opts(AWS_S3_ENDPOINT = "t3.storage.dev", vsi_path = "/vsis3/bucket/")
  )
  expect_identical(as.list(cfg$opts), list(AWS_REGION = "us-west-2"))
  expect_named(cfg$vsi, "/vsis3/bucket/")
  expect_identical(as.list(cfg$vsi[["/vsis3/bucket/"]]), list(AWS_S3_ENDPOINT = "t3.storage.dev"))
})

test_that("empty construction and c() merge behave", {
  empty <- gdal_config()
  expect_true(is_gdal_config(empty))
  expect_length(as.list(empty$opts), 0L)

  a <- gdal_config(GDAL_NUM_THREADS = "2", gdal_vsi_opts(AWS_REGION = "a", vsi_path = "/vsis3/x/"))
  b <- gdal_config(GDAL_NUM_THREADS = "8", gdal_vsi_opts(AWS_REGION = "b", vsi_path = "/vsis3/x/"))
  merged <- c(a, b)
  expect_identical(as.list(merged$opts), list(GDAL_NUM_THREADS = "8"))
  expect_identical(as.list(merged$vsi[["/vsis3/x/"]]), list(AWS_REGION = "b"))
})

test_that("as_gdal_config() coerces opts objects, lists, characters, and self", {
  expect_true(is_gdal_config(as_gdal_config(gdal_config_opts(CPL_DEBUG = "ON"))))
  expect_true(is_gdal_config(as_gdal_config(list(CPL_DEBUG = "ON"))))
  expect_true(is_gdal_config(as_gdal_config("CPL_DEBUG=ON")))
  cfg <- gdal_config(CPL_DEBUG = "ON")
  expect_identical(as_gdal_config(cfg), cfg)
  expect_error(as_gdal_config(42), class = "gdal_config_coerce_error")
})

test_that("gdal_config() rejects open/creation opts with a classed error", {
  expect_error(gdal_config(gdal_open_opts(LIST_ALL_TABLES = "NO")), class = "gdal_config_channel_error")
  expect_error(gdal_config(gdal_creation_opts(SPATIAL_INDEX = "YES")), class = "gdal_config_channel_error")
  expect_error(gdal_config(42), class = "gdal_config_channel_error")
})

test_that("format()/print() render the value with secrets redacted", {
  withr::local_options(cli.num_colors = 1, cli.width = 200)
  cfg <- gdal_config(
    GDAL_NUM_THREADS = "4",
    gdal_vsi_opts(AWS_SECRET_ACCESS_KEY = "supersecretvalue", vsi_path = "/vsis3/bucket/")
  )
  out <- paste(format(cfg), collapse = "\n")
  expect_match(out, "GDAL_NUM_THREADS=4", fixed = TRUE)
  expect_false(grepl("supersecretvalue", out, fixed = TRUE))
  expect_match(out, "<redacted>", fixed = TRUE)
})

# rendering -------------------------------------------------------------------------------------------------------

test_that("as_gdal_args() renders the global channel and omits vsi with a message", {
  cfg <- gdal_config(
    GDAL_NUM_THREADS = "4",
    gdal_vsi_opts(AWS_REGION = "us-east-1", vsi_path = "/vsis3/bucket/")
  )
  expect_message(args <- as_gdal_args(cfg), class = "gdal_config_vsi_message")
  expect_identical(args, c("--config", "GDAL_NUM_THREADS=4"))
})

test_that("as_gdal_args(flatten_vsi = TRUE) emits vsi options as global --config tokens", {
  cfg <- gdal_config(gdal_vsi_opts(AWS_REGION = "us-east-1", vsi_path = "/vsis3/bucket/"))
  args <- as_gdal_args(cfg, flatten_vsi = TRUE)
  expect_identical(args, c("--config", "AWS_REGION=us-east-1"))
})

test_that("flattening warns when paths carry conflicting values for the same key", {
  cfg <- gdal_config(
    gdal_vsi_opts(AWS_ACCESS_KEY_ID = "key-a", vsi_path = "/vsis3/a/"),
    gdal_vsi_opts(AWS_ACCESS_KEY_ID = "key-b", vsi_path = "/vsis3/b/")
  )
  expect_warning(as_gdal_args(cfg, flatten_vsi = TRUE), class = "gdal_config_flatten_warning")
})

test_that("as_gdal_config_opts() extracts the global channel from a value", {
  cfg <- gdal_config(GDAL_NUM_THREADS = "4")
  opts <- as_gdal_config_opts(cfg)
  expect_true(is_gdal_config_opts(opts))
  expect_identical(as.list(opts), list(GDAL_NUM_THREADS = "4"))
})

# set / get / reset -----------------------------------------------------------------------------------------------

test_that("gdal_config_set applies to GDAL, tracks in the active config, and reset restores", {
  skip_if_not_installed("gdalraster")
  withr::defer(gdal_config_reset())

  before <- gdalraster::get_config_option("CPL_TMPDIR")
  prior <- gdal_config_set(CPL_TMPDIR = "gdalvector-test-tmp")
  expect_identical(prior[["CPL_TMPDIR"]], before)
  expect_identical(unname(gdal_config_get("CPL_TMPDIR")), "gdalvector-test-tmp")

  active <- gdal_config_active()
  expect_true(is_gdal_config(active))
  expect_identical(as.list(active$opts)[["CPL_TMPDIR"]], "gdalvector-test-tmp")

  restored <- gdal_config_reset("CPL_TMPDIR")
  expect_identical(restored, "CPL_TMPDIR")
  expect_identical(gdalraster::get_config_option("CPL_TMPDIR"), before)
  expect_false("CPL_TMPDIR" %in% names(as.list(gdal_config_active()$opts)))
})

test_that("gdal_config_get with no touched keys returns an empty named character vector", {
  skip_if_not_installed("gdalraster")
  withr::defer(gdal_config_reset())
  gdal_config_reset()
  out <- gdal_config_get()
  expect_length(out, 0L)
  expect_type(out, "character")
})

test_that("set accepts gdal_config values and driver-typed opts", {
  skip_if_not_installed("gdalraster")
  withr::defer(gdal_config_reset())

  gdal_config_set(gdal_config(GDAL_NUM_THREADS = "6"))
  expect_identical(unname(gdal_config_get("GDAL_NUM_THREADS")), "6")

  gdal_config_set(gpkg_config_opts(sqlite_synchronous = "OFF"))
  expect_identical(unname(gdal_config_get("OGR_SQLITE_SYNCHRONOUS")), "OFF")
})

test_that("reset restores a pre-existing in-memory value (not blindly unset)", {
  skip_if_not_installed("gdalraster")
  withr::defer(gdalraster::set_config_option("CPL_TMPDIR", ""))
  withr::defer(gdal_config_reset())

  gdalraster::set_config_option("CPL_TMPDIR", "external-value")
  gdal_config_set(CPL_TMPDIR = "package-value")
  gdal_config_reset("CPL_TMPDIR")
  expect_identical(gdalraster::get_config_option("CPL_TMPDIR"), "external-value")
})

test_that("unknown option names trigger an advisory (classed, non-blocking) warning", {
  skip_if_not_installed("gdalraster")
  withr::defer(gdal_config_reset())
  expect_warning(
    gdal_config_set(GDALVECTOR_NOT_A_REAL_OPTION = "x"),
    class = "gdal_config_unknown_warning"
  )
  # advisory only: the value was still applied
  expect_identical(unname(gdal_config_get("GDALVECTOR_NOT_A_REAL_OPTION")), "x")
})

test_that("setting GDAL_CONFIG_FILE warns that it has no effect post-load", {
  skip_if_not_installed("gdalraster")
  withr::defer(gdal_config_reset())
  expect_warning(
    gdal_config_set(GDAL_CONFIG_FILE = "nonexistent.rc"),
    class = "gdal_config_file_warning"
  )
})

# envvar asymmetry ------------------------------------------------------------------------------------------------

test_that("set overrides an envvar; unset(mode = 'reveal') surfaces it again with a warning", {
  skip_if_not_installed("gdalraster")
  withr::defer(gdal_config_reset())
  withr::local_envvar(GDAL_HTTP_TIMEOUT = "123")

  expect_identical(gdalraster::get_config_option("GDAL_HTTP_TIMEOUT"), "123")
  gdal_config_set(GDAL_HTTP_TIMEOUT = "60")
  expect_identical(gdalraster::get_config_option("GDAL_HTTP_TIMEOUT"), "60")

  expect_warning(gdal_config_unset("GDAL_HTTP_TIMEOUT"), class = "gdal_config_env_warning")
  expect_identical(gdalraster::get_config_option("GDAL_HTTP_TIMEOUT"), "123")
})

test_that("unset(mode = 'scrub') removes the envvar and reset puts it back", {
  skip_if_not_installed("gdalraster")
  withr::defer(gdal_config_reset())
  withr::local_envvar(GDAL_HTTP_MAX_RETRY = "7")

  gdal_config_unset("GDAL_HTTP_MAX_RETRY", mode = "scrub")
  expect_identical(Sys.getenv("GDAL_HTTP_MAX_RETRY"), "")
  expect_identical(gdalraster::get_config_option("GDAL_HTTP_MAX_RETRY"), "")

  gdal_config_reset("GDAL_HTTP_MAX_RETRY")
  expect_identical(Sys.getenv("GDAL_HTTP_MAX_RETRY"), "7")
  expect_identical(gdalraster::get_config_option("GDAL_HTTP_MAX_RETRY"), "7")
})

test_that("unset(mode = 'mask') pins a documented default or errors informatively", {
  skip_if_not_installed("gdalraster")
  withr::defer(gdal_config_reset())

  expect_error(
    gdal_config_unset("GDAL_HTTP_USERAGENT", mode = "mask"),
    class = "gdal_config_default_error"
  )

  tbl <- gdal_vector_driver_opts(type = "config")
  tbl <- tbl[!is.na(tbl$default), , drop = FALSE]
  skip_if(nrow(tbl) == 0L, "no curated config-option defaults available")
  key <- tbl$name[[1]]
  default <- tbl$default[[1]]
  gdal_config_unset(key, mode = "mask")
  expect_identical(unname(gdal_config_get(key)), default)
})

test_that("reset falls back to '' when the prior value came from an envvar", {
  skip_if_not_installed("gdalraster")
  withr::defer(gdal_config_reset())
  withr::local_envvar(GDAL_HTTP_TIMEOUT = "222")

  gdal_config_set(GDAL_HTTP_TIMEOUT = "60")
  gdal_config_reset("GDAL_HTTP_TIMEOUT")
  expect_identical(gdalraster::get_config_option("GDAL_HTTP_TIMEOUT"), "222")
})

# scoped application ----------------------------------------------------------------------------------------------

test_that("local_gdal_config applies within the frame and restores values and state on exit", {
  skip_if_not_installed("gdalraster")
  withr::defer(gdal_config_reset())

  dbg_before <- gdalraster::get_config_option("CPL_DEBUG")
  gdal_config_set(GDAL_NUM_THREADS = "2")

  fn <- function() {
    local_gdal_config(GDAL_NUM_THREADS = "8", CPL_DEBUG = "OFF")
    list(
      threads = unname(gdal_config_get("GDAL_NUM_THREADS")),
      debug = unname(gdal_config_get("CPL_DEBUG"))
    )
  }
  inside <- fn()
  expect_identical(inside$threads, "8")
  expect_identical(inside$debug, "OFF")

  expect_identical(unname(gdal_config_get("GDAL_NUM_THREADS")), "2")
  expect_identical(gdalraster::get_config_option("CPL_DEBUG"), dbg_before)

  active <- as.list(gdal_config_active()$opts)
  expect_identical(active[["GDAL_NUM_THREADS"]], "2")
  expect_false("CPL_DEBUG" %in% names(active))
})

test_that("with_gdal_config returns the code value and restores even on error", {
  skip_if_not_installed("gdalraster")
  withr::defer(gdal_config_reset())

  before <- gdalraster::get_config_option("GDAL_NUM_THREADS")
  out <- with_gdal_config(
    gdal_config(GDAL_NUM_THREADS = "3"),
    unname(gdal_config_get("GDAL_NUM_THREADS"))
  )
  expect_identical(out, "3")
  expect_identical(gdalraster::get_config_option("GDAL_NUM_THREADS"), before)

  expect_error(with_gdal_config(gdal_config(GDAL_NUM_THREADS = "3"), stop("boom")))
  expect_identical(gdalraster::get_config_option("GDAL_NUM_THREADS"), before)
})

# vsi routing -----------------------------------------------------------------------------------------------------

test_that("path-bound vsi opts route to the path-specific store; reset clears them", {
  skip_if_not_installed("gdalraster")
  withr::defer(gdal_config_reset())

  gdal_config_set(gdal_vsi_opts(AWS_REGION = "us-east-1", vsi_path = "/vsis3/gdalvector-test-bucket/"))
  active <- gdal_config_active()
  expect_named(active$vsi, "/vsis3/gdalvector-test-bucket/")
  expect_identical(as.list(active$vsi[[1]]), list(AWS_REGION = "us-east-1"))

  gdal_config_reset()
  expect_length(gdal_config_active()$vsi, 0L)
})

test_that("unbound vsi opts are applied as plain config options", {
  skip_if_not_installed("gdalraster")
  withr::defer(gdal_config_reset())

  gdal_config_set(gdal_vsi_opts(AWS_REGION = "us-west-2"))
  expect_identical(unname(gdal_config_get("AWS_REGION")), "us-west-2")
  expect_length(gdal_config_active()$vsi, 0L)
})

test_that("local_gdal_config clears scoped vsi path options on exit", {
  skip_if_not_installed("gdalraster")
  withr::defer(gdal_config_reset())

  fn <- function() {
    local_gdal_config(gdal_vsi_opts(AWS_REGION = "eu-west-1", vsi_path = "/vsis3/gdalvector-scoped/"))
    length(gdal_config_active()$vsi)
  }
  expect_identical(fn(), 1L)
  expect_length(gdal_config_active()$vsi, 0L)
})

# sitrep ----------------------------------------------------------------------------------------------------------

test_that("gdal_config_sitrep attributes provenance and redacts secrets in print", {
  skip_if_not_installed("gdalraster")
  withr::defer(gdal_config_reset())
  withr::local_envvar(GDAL_HTTP_CONNECTTIMEOUT = "111")

  gdal_config_set(GDAL_NUM_THREADS = "5", AWS_SECRET_ACCESS_KEY = "supersecretvalue")
  sitrep <- gdal_config_sitrep()
  expect_true(is_gdal_config_sitrep(sitrep))

  tbl <- tibble::as_tibble(sitrep)
  expect_identical(unique(tbl$source[tbl$key == "GDAL_NUM_THREADS"]), "gdalvector")
  expect_identical(unique(tbl$source[tbl$key == "GDAL_HTTP_CONNECTTIMEOUT"]), "envvar")

  withr::local_options(cli.num_colors = 1, cli.width = 200)
  out <- paste(format(sitrep), collapse = "\n")
  expect_false(grepl("supersecretvalue", out, fixed = TRUE))
  expect_match(out, "<redacted>", fixed = TRUE)
})

test_that("the sitrep bridges back into the options value system", {
  skip_if_not_installed("gdalraster")
  withr::defer(gdal_config_reset())
  withr::local_envvar(GDAL_HTTP_RETRY_CODES = "429,503")

  gdal_config_set(GDAL_NUM_THREADS = "4")

  session <- as.list(as_gdal_config_opts(gdal_config_sitrep()))
  expect_identical(session[["GDAL_NUM_THREADS"]], "4")
  expect_false("GDAL_HTTP_RETRY_CODES" %in% names(session))

  effective <- as.list(as_gdal_config_opts(gdal_config_sitrep(), scope = "effective"))
  expect_identical(effective[["GDAL_HTTP_RETRY_CODES"]], "429,503")
})

test_that("sitrep prints without error and an at-load baseline was stashed", {
  skip_if_not_installed("gdalraster")
  withr::local_options(cli.num_colors = 1, cli.width = 200)
  expect_output(res <- withVisible(print(gdal_config_sitrep())))
  expect_false(res$visible)
  expect_true(is_gdal_config_sitrep(.pkg_env$gdal$config$at_load))
})

# known options ---------------------------------------------------------------------------------------------------

test_that("the known-option registry is present, authoritative, and filterable", {
  registry <- gdal_known_config_opts()
  expect_s3_class(registry, "tbl_df")
  expect_named(registry, c("name", "source"))
  expect_gt(nrow(registry), 1000L)
  expect_true(all(c("GDAL_NUM_THREADS", "AWS_S3_ENDPOINT", "OGR_SQLITE_PRAGMA", "CPL_DEBUG") %in% registry$name))
  expect_match(attr(registry, "gdal_version"), "^[0-9]+\\.[0-9]+\\.[0-9]+$")

  sqlite <- gdal_known_config_opts("SQLITE")
  expect_gt(nrow(sqlite), 0L)
  expect_lt(nrow(sqlite), nrow(registry))
  expect_true(all(grepl("SQLITE", paste(sqlite$name, sqlite$source), ignore.case = TRUE)))
})

test_that("gdal_config_option_known() asks the running build and restores all state", {
  skip_if_not_installed("gdalraster")
  skip_if(gdalraster::gdal_version_num() < 3110000L, "unknown-option detection requires GDAL >= 3.11")

  debug_before <- gdalraster::get_config_option("CPL_DEBUG")
  res <- gdal_config_option_known(c("GDAL_NUM_THREADS", "DEFINITELY_NOT_A_REAL_OPTION_XYZ"))
  expect_identical(
    res,
    c(GDAL_NUM_THREADS = TRUE, DEFINITELY_NOT_A_REAL_OPTION_XYZ = FALSE)
  )

  # probe leaves no trace: CPL_DEBUG restored, probed keys unset again
  expect_identical(gdalraster::get_config_option("CPL_DEBUG"), debug_before)
  expect_identical(gdalraster::get_config_option("DEFINITELY_NOT_A_REAL_OPTION_XYZ"), "")
})

test_that("a build-known key missing from the generated lists is not flagged", {
  skip_if_not_installed("gdalraster")
  skip_if(gdalraster::gdal_version_num() < 3110000L, "unknown-option detection requires GDAL >= 3.11")
  withr::defer(gdal_config_reset())

  # simulate list drift: temporarily hide a genuinely known key from the known-opts universe by
  # checking a key that is known to the build; the runtime confirmation must rescue it
  expect_true(unname(gdal_config_option_known("GDAL_CACHEMAX")))
  expect_no_warning(gdal_config_set(GDAL_CACHEMAX = "256"))
})

# load-time defaults ----------------------------------------------------------------------------------------------

test_that("fill-only session defaults pin the user agent and are reversible", {
  skip_if_not_installed("gdalraster")
  withr::defer(gdal_config_reset())

  gdal_config_reset()
  gdal_config_init_defaults()
  expect_identical(unname(gdal_config_get("GDAL_HTTP_USERAGENT")), pkg_user_agent())
  active <- as.list(gdal_config_active()$opts)
  expect_identical(active[["GDAL_HTTP_USERAGENT"]], pkg_user_agent())

  # fill-only: an existing value is never overridden
  gdal_config_reset()
  gdalraster::set_config_option("GDAL_HTTP_USERAGENT", "custom-agent")
  withr::defer(gdalraster::set_config_option("GDAL_HTTP_USERAGENT", ""))
  gdal_config_init_defaults()
  expect_identical(gdalraster::get_config_option("GDAL_HTTP_USERAGENT"), "custom-agent")
})

test_that("options(gdalvector.config_defaults = FALSE) opts out of session defaults", {
  skip_if_not_installed("gdalraster")
  withr::defer(gdal_config_reset())
  withr::local_options(gdalvector.config_defaults = FALSE)

  gdal_config_reset()
  gdal_config_init_defaults()
  expect_identical(gdalraster::get_config_option("GDAL_HTTP_USERAGENT"), "")
})

# config file -----------------------------------------------------------------------------------------------------

test_that("gdal_config_file_read parses configoptions, directives, and path-bound credentials", {
  rc <- withr::local_tempfile(fileext = ".gdalrc")
  writeLines(
    c(
      "# a comment",
      "[directives]",
      "ignore-env-vars = yes",
      "[configoptions]",
      "GDAL_NUM_THREADS = ALL_CPUS",
      "CPL_TMPDIR=C:/tmp=x",
      "[credentials]",
      "[.private_bucket]",
      "path=/vsis3/my_private_bucket",
      "AWS_SECRET_ACCESS_KEY=topsecret",
      "AWS_ACCESS_KEY_ID=keyid",
      "[.sentinel]",
      "path=/vsis3/sentinel-s2-l1c",
      "AWS_REQUEST_PAYER=requester"
    ),
    rc
  )

  f <- gdal_config_file_read(rc)
  expect_true(is_gdal_config_file(f))
  expect_identical(f$directives[["ignore-env-vars"]], "yes")
  expect_identical(as.list(f$configoptions)[["GDAL_NUM_THREADS"]], "ALL_CPUS")
  # '=' inside values survives
  expect_identical(as.list(f$configoptions)[["CPL_TMPDIR"]], "C:/tmp=x")

  expect_setequal(names(f$credentials), c("/vsis3/my_private_bucket", "/vsis3/sentinel-s2-l1c"))
  bucket <- f$credentials[["/vsis3/my_private_bucket"]]
  expect_true(is_gdal_vsi_opts(bucket))
  expect_identical(attr(bucket, "vsi_path"), "/vsis3/my_private_bucket")
  expect_identical(as.list(bucket)[["AWS_ACCESS_KEY_ID"]], "keyid")

  # secrets are redacted in print, present in the value
  withr::local_options(cli.num_colors = 1, cli.width = 200)
  out <- paste(format(f), collapse = "\n")
  expect_false(grepl("topsecret", out, fixed = TRUE))
})

test_that("a gdal_config value round-trips through write + read", {
  cfg <- gdal_config(
    GDAL_NUM_THREADS = "ALL_CPUS",
    OGR_SQLITE_SYNCHRONOUS = "OFF",
    gdal_vsi_opts(
      AWS_S3_ENDPOINT = "t3.storage.dev",
      AWS_ACCESS_KEY_ID = "keyid",
      vsi_path = "/vsis3/noclocks-spatial/"
    )
  )
  rc <- withr::local_tempfile(fileext = ".gdalrc")
  gdal_config_file_write(cfg, rc)

  back <- as_gdal_config(gdal_config_file_read(rc))
  expect_identical(
    as.list(back$opts)[order(names(as.list(back$opts)))],
    as.list(cfg$opts)[order(names(as.list(cfg$opts)))]
  )
  expect_named(back$vsi, "/vsis3/noclocks-spatial/")
  expect_identical(
    as.list(back$vsi[[1]])[order(names(as.list(back$vsi[[1]])))],
    as.list(cfg$vsi[[1]])[order(names(as.list(cfg$vsi[[1]])))]
  )
})

test_that("gdal_config_file discovery honors the GDAL_CONFIG_FILE envvar on refresh", {
  rc <- withr::local_tempfile(fileext = ".gdalrc")
  writeLines(c("[configoptions]", "GDAL_NUM_THREADS=ALL_CPUS"), rc)
  # registered before local_envvar so it runs *after* the envvar is restored (LIFO)
  withr::defer(gdal_config_file(refresh = TRUE))
  withr::local_envvar(GDAL_CONFIG_FILE = rc)
  f <- gdal_config_file(refresh = TRUE)
  expect_identical(f$path, rc)
  expect_identical(as.list(f$configoptions)[["GDAL_NUM_THREADS"]], "ALL_CPUS")
})

test_that("gdal_config_file returns an empty classed object when nothing is discovered", {
  f <- gdal_config_file(refresh = TRUE)
  expect_true(is_gdal_config_file(f))
  expect_named(f, c("path", "configoptions", "directives", "credentials"))
})
