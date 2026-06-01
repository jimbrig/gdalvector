
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
  usethis::use_package_doc()
}

# dev -------------------------------------------------------------------------------------------------------------

if (FALSE) {
  usethis::use_directory("dev", ignore = TRUE)
  fs::file_create("dev/README.md")
  c("R", "scripts", "check", "docs", "scratch") |>
    purrr::walk(~ fs::dir_create(file.path("dev", .x), recurse = TRUE))
  attachment::att_amend_desc()
  fs::file_create("AGENTS.md")
  fs::file_create("CHANGELOG.md")
  fs::file_create(".cursor/mcp.json")
  fs::file_create(".cursor/mcp.env")
  usethis::use_git_ignore(c("mcp.env"), ".cursor")
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
}

# inst ------------------------------------------------------------------------------------------------------------

if (FALSE) {
  c("inst/extdata", "inst/config", "inst/schemas") |>
    purrr::walk(fs::dir_create)
}


# R ---------------------------------------------------------------------------------------------------------------

if (FALSE) {

  usethis::use_import_from("rlang", ".data")
  usethis::use_import_from("rlang", ".env")
  usethis::use_import_from("rlang", "%||%")

  c(
    "aaa.R", "zzz.R", "gdaltargets-conditions.R", "gdaltargets-options.R",
    "utils_pkg", "utils_checks", "utils_predicates", "utils_xml", "utils_schemas",
    "gdal_vsi", "gdal_config", "gdal_algorithm", "gdal_pipeline",
    "gdal_vector","gdal_opts", "gdal_drivers", "gdal_dsn", "gdal_sitrep",
    "dsn_fema", "dsn_tiger", "dsn_ssurgo", "dsn_usgs", "dsn_osm",
    "tar_formats", "tar_gdal_vector", "tar_gdal_vsi", "tar_gdal_gpkg", "tar_gdal_fgb",
    "db_duckdb", "db_postgis", "db_sqlite", "db_adbc",

  ) |>
    purrr::walk(usethis::use_r, open = FALSE)
}


# tests -----------------------------------------------------------------------------------------------------------

usethis::use_testthat()


# data ------------------------------------------------------------------------------------------------------------

usethis::use_data_raw("internal")
usethis::use_data_raw("exported")

fs::dir_create("data-raw/cache")
usethis::use_git_ignore(c("*", "!.gitignore", "!*.md"), "data-raw/cache")

# targets ---------------------------------------------------------------------------------------------------------

if (FALSE) {
  targets::use_targets()
}
