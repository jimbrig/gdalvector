#  ------------------------------------------------------------------------
#
# Title : Pacakge Initialization Script
#    By : Jimmy Briggs
#  Date : 2026-05-31
#
#  ------------------------------------------------------------------------

# libraries ---------------------------------------------------------------

require(devtools)
require(usethis)
require(roxygen2)
require(testthat)
require(rmarkdown)
require(knitr)
require(attachment)
require(pak)
require(purrr)
require(lifecycle)
require(rlang)
require(cli)
require(pkgload)
require(pkgbuild)
require(rcmdcheck)
require(fs)
require(targets)
require(tarchetypes)
require(withr)
require(this.path)

# create ----------------------------------------------------------------------------------------------------------

if (FALSE) {
  usethis::create_package("gdalvector")
  usethis::use_namespace()
  usethis::use_roxygen_md()
  usethis::use_readme_md()
}

# dev -------------------------------------------------------------------------------------------------------------

if (FALSE) {
  usethis::use_directory("dev", ignore = TRUE)
  fs::file_create("dev/README.md")
  c("scripts", "check", "docs", "scratch") |>
    purrr::walk(~ fs::dir_create(file.path("dev", .x), recurse = TRUE))
  fs::file_create("dev/README.md")
  attachment::att_amend_desc()
  fs::file_create("AGENTS.md")
  fs::file_create("CHANGELOG.md")
}


# mcps ------------------------------------------------------------------------------------------------------------

if (FALSE) {
  fs::file_create(".cursor/README.md")
  fs::file_create(".cursor/mcp.json")
  fs::file_create(".cursor/mcp.env")
  usethis::use_git_ignore(c("mcp.env"), ".cursor")

  tigris_mcp_cfg <- list(
    "tigris" = list(
      "type" = "http",
      "url" = "https://mcp.storage.dev/mcp",
      "headers" = c(),
      "envFile" = "${workspaceFolder}/.cursor/mcp.env",
      "env" = list(
        "TIGRIS_STORAGE_ACCESS_KEY_ID" = "${env:TIGRIS_STORAGE_ACCESS_KEY_ID}",
        "TIGRIS_STORAGE_SECRET_ACCESS_KEY" = "${env:TIGRIS_STORAGE_SECRET_ACCESS_KEY}"
      )
    )
  )

  mcp_cfg <- list("mcpServers" = tigris_mcp_cfg)
  yyjsonr::write_json_file(
    mcp_cfg,
    ".cursor/mcp.json",
    opts = list(pretty = TRUE, auto_unbox = TRUE, null = "empty_array")
  )
}

# buildignore -----------------------------------------------------------------------------------------------------

if (FALSE) {
  usethis::use_directory(".cursor", ignore = TRUE)
  c(
    "dev",
    "data-raw",
    ".cursor",
    ".github",
    ".vscode",
    ".positai",
    ".claude",
    ".gitattributes",
    ".editorconfig",
    ".cursorignore",
    ".dockerignore",
    ".repomixignore",
    "repomix.config.json",
    "Makefile",
    ".Renviron",
    ".Rprofile",
    ".build",
    "renv",
    "renv.lock",
    "config.yml",
    ".env",
    ".env.example",
    "codemeta.json",
    ".lintr",
    "README.Rmd",
    "Dockerfile",
    "compose.yml",
    "gdalvector.code-workspace",
    "AGENTS.md",
    "CHANGELOG.md",
    "LICENSE.md",
    "cran-comments.md"
  ) |>
    purrr::walk(usethis::use_build_ignore)
}

# git/github ------------------------------------------------------------------------------------------------------

if (FALSE) {
  usethis::use_git()
  usethis::use_github()
  usethis::use_github_links()
}

if (FALSE) {
  gh_labels <- tibble::tibble(
    name = c("feature", "release", "refactor", "tests", "data", "infra", "database"),
    description = c(
      feature = "New feature or request",
      release = "Release related tasks",
      refactor = "Code change that neither fixes a bug nor adds a feature",
      tests = "Adding or updating tests",
      data = "Data related tasks",
      infra = "Infrastructure related tasks",
      database = "Database Schemas and DDL"
    ),
    color = c(
      feature = "0e8a16",
      release = "fbca04",
      refactor = "1d76db",
      tests = "bfe5bf",
      data = "5319e7",
      infra = "f9d0c4",
      database = "c2e0c6"
    )
  )
  usethis::use_github_labels(
    labels = gh_labels$name,
    colours = gh_labels$color,
    descriptions = gh_labels$description,
    delete_default = FALSE
  )
}

if (FALSE) {
  usethis::use_pkgdown_github_pages()
  fs::file_move(".github/workflows/pkgdown.yaml", ".github/workflows/pkgdown.yml")
  fs::file_create(".github/workflows/changelog.yml")
  usethis::use_github_action("check-standard", save_as = "check.yml")
  usethis::use_github_action(
    url = "https://github.com/posit-dev/setup-air/blob/main/examples/format-suggest.yaml",
    save_as = "format-suggest.yml"
  )
  usethis::use_github_action(
    url = "https://github.com/posit-dev/setup-air/blob/main/examples/format-check.yaml",
    save_as = "format-check.yml"
  )
  fs::file_create(".github/README.md")
  fs::file_create(".github/dependabot.yml")
  # fs::file_create(".github/FUNDING.yml")
}

# inst ------------------------------------------------------------------------------------------------------------

if (FALSE) {
  fs::dir_create("inst")
  fs::file_create("inst/README.md")
  c("inst/extdata", "inst/config", "inst/schemas") |>
    purrr::walk(fs::dir_create)
}


# R ---------------------------------------------------------------------------------------------------------------

if (FALSE) {
  # R/gdalvector-package.R
  usethis::use_package_doc()
  usethis::use_import_from("rlang", c(".data", ".env", "%||%", "!!", ":=", "!!!"))
  usethis::use_import_from("rlang", c("caller_arg", "caller_env"))
  usethis::use_import_from(
    "rlang",
    c("abort", "warn", "inform", "try_fetch", "cnd", "error_cnd", "warning_cnd", "message_cnd")
  )
  usethis::use_import_from("rlang", c("new_environment", "on_load", "run_on_load", "local_use_cli"))
  usethis::use_import_from("cli", c("cli_abort", "cli_warn", "cli_inform"))
  usethis::use_import_from("stats", c("setNames"))
  usethis::use_import_from("utils", c("globalVariables", "modifyList", "packageVersion"))

  # initial package scaffolding:
  c("aaa.R", "zzz.R") |> purrr::walk(usethis::use_r, open = FALSE)
  c("gdalvector-conditions.R", "gdalvector-options.R") |> purrr::walk(usethis::use_r, open = FALSE)

  # initial utilities
  c("utils_pkg", "utils_checks", "utils_predicates", "utils_system", "utils_xml", "utils_sql", "utils_remote") |>
    purrr::walk(usethis::use_r, open = FALSE)

  # gdal:
  c(
    "gdal_config",
    "gdal_opts",
    "gdal_drivers",
    "gdal_vsi",
    "gdal_sitrep" #,
    #   "gdal_algorithm",
    #   "gdal_pipeline",
    #   "gdal_vector",
    #   "gdal_dsn",
  ) |>
    purrr::walk(usethis::use_r, open = FALSE)

  # driver modules:
  # c(
  #   "fgb_driver",
  #   "fgb_opts",
  #   "fgb_validation",
  #   "gpkg_driver",
  #   "gpkg_opts",
  #   "gpkg_validation",
  #   "gpkg_connect",
  #   "gpq_driver",
  #   "gpq_opts",
  #   "gpq_validation",
  #   "shp_driver",
  #   "shp_opts",
  #   "pmtiles_driver",
  #   "pmtiles_opts",
  #   "pmtiles_validation",
  #   "gdb_driver",
  #   "gdb_opts",
  #   "gdb_validation"
  # ) |>
  #   purrr::walk(usethis::use_r, open = FALSE)

  # db
  # c(
  #   "db_duckdb",
  #   "db_postgis",
  #   "db_sqlite",
  #   "db_adbc"
  # ) |>
  #   purrr::walk(usethis::use_r, open = FALSE)
}


# tests -----------------------------------------------------------------------------------------------------------

if (FALSE) {
  usethis::use_testthat()
  usethis::use_spell_check()
  cat(
    "if (requireNamespace(\"spelling\", quietly = TRUE)) {",
    "  spelling::spell_check_test(",
    "    vignettes = TRUE,",
    "    error = FALSE,",
    "    skip_on_cran = TRUE",
    "  )",
    "}",
    "",
    file = "tests/spelling.R",
    sep = "\n",
    append = FALSE
  )
  spelling::update_wordlist()
  fs::file_create("tests/testthat/README.md")
}

if (FALSE) {
  fs::file_create("tests/testthat/setup-config.R")
  fs::file_create("tests/testthat/helper-mocks.R")

  c(
    "gdalvector-conditions",
    "gdalvector-options",
    "utils_checks",
    "utils_predicates",
    "utils_system",
    "utils_xml",
    "utils_sql",
    "utils_remote",
    "gdal_config",
    "gdal_opts",
    "gdal_drivers"
  ) |>
    purrr::walk(usethis::use_test, open = FALSE)
}


# data ------------------------------------------------------------------------------------------------------------

if (FALSE) {
  usethis::use_data_raw("internal")
  usethis::use_data_raw("exported")
  fs::file_create("data-raw/README.md")
  fs::dir_create("data-raw/cache")
  usethis::use_git_ignore(c("*", "!.gitignore", "!*.md"), "data-raw/cache")
  fs::dir_create("data-raw/scripts")
  fs::file_create("data-raw/scripts/gdal_drivers_metadata.R")
}

# vignettes / articles --------------------------------------------------------------------------------------------

if (FALSE) {
  # main package vignette
  usethis::use_vignette("gdalvector")
  # vignettes
  usethis::use_vignette("gdal-vector-drivers", title = "GDAL Vector Drivers")
  usethis::use_vignette("gdal-pipelines", title = "Pipelines")
  # driver article qmds
  usethis::use_article(name = "driver-geopackage.qmd", title = "GeoPackage")
  usethis::use_article(name = "driver-flatgeobuf.qmd", title = "FlatGeoBuf")
  usethis::use_article(name = "driver-geoparquet.qmd", title = "GeoParquet")
  usethis::use_article(name = "driver-pmtiles.qmd", title = "PMTiles")
  usethis::use_article(name = "driver-openfilegdb.qmd", title = "OpenFileGDB")
  # other
  usethis::use_article(name = "duckdb-spatial.qmd", title = "DuckDB Spatial")
}


# logos -----------------------------------------------------------------------------------------------------------

if (FALSE) {
  gdal_logo <- "https://raw.githubusercontent.com/OSGeo/gdal/refs/heads/master/gdal-logo.svg"
  fgb_logo <- "https://raw.githubusercontent.com/flatgeobuf/flatgeobuf/refs/heads/master/logo.svg"
}
