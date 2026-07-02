# Changelog

> All notable changes to this project will be documented in this file.
> The format is based on [Keep a Changelog](http://keepachangelog.com/)
> and this project adheres to [Semantic Versioning](http://semver.org/).

## \[Unreleased\]

## Bug Fixes

- Support known GDAL drivers even if unregistered
  ([2e4a86a](https://github.com/jimbrig/gdalvector/commit/2e4a86a128e27b9c5890e4fe7901884e251a5ebf)) -
  (Jimmy Briggs)
- **drivers:** Fix issues when missing drivers
  ([b5230ac](https://github.com/jimbrig/gdalvector/commit/b5230ac20f552f31ed68797f4b8d8250f402b6b1)) -
  (Jimmy Briggs)

## Configuration

- **config:** Add ‘context/’ to gitignore
  ([4b20a29](https://github.com/jimbrig/gdalvector/commit/4b20a29d904e785fe94c747aea8d72f7c8a34f39)) -
  (Jimmy Briggs)

## Documentation

- **gdal-vector:** Correct grammar in FID column informational message
  ([66a5988](https://github.com/jimbrig/gdalvector/commit/66a5988389a014ece9e236b267b549014d2e872b)) -
  (Jimmy Briggs)

## Features

- **cli:** Improve output legibility and theme application
  ([7e5d7ea](https://github.com/jimbrig/gdalvector/commit/7e5d7ea13061a91664a571778e0e7cd198493317)) -
  (Jimmy Briggs)
- **gpq:** Improve GeoParquet CRS resolution
  ([361ba1a](https://github.com/jimbrig/gdalvector/commit/361ba1a3d922bb3e7331c22370768cb3807d54a8)) -
  (Jimmy Briggs)
- **data:** Add Atlanta sample geospatial data
  ([eac241c](https://github.com/jimbrig/gdalvector/commit/eac241cecc645fc40c190e8e378c1d95b3a5d435)) -
  (Jimmy Briggs)
- Add GDAL vector schema transformation and GeoParquet introspection
  capabilities
  ([de91c73](https://github.com/jimbrig/gdalvector/commit/de91c73f1e1e0000a8a598854bc595bbd2a9f811)) -
  (Jimmy Briggs)
- **gpq:** Add comprehensive metadata introspection
  ([b17c0d4](https://github.com/jimbrig/gdalvector/commit/b17c0d46870b7ba5908c69802d8fdce35b833e0d)) -
  (Jimmy Briggs)
- **cli:** Integrate custom inline styles into global theme
  ([ae8c00f](https://github.com/jimbrig/gdalvector/commit/ae8c00fbcbc4863f5f7e810ad96be2ff97e37a71)) -
  (Jimmy Briggs)
- Add utility to read .Renviron files
  ([946f316](https://github.com/jimbrig/gdalvector/commit/946f3164764cf95de134dcdf67a00a19d62969c0)) -
  (Jimmy Briggs)
- **cli:** Add utilities for rendering structured data
  ([0c2da70](https://github.com/jimbrig/gdalvector/commit/0c2da701475925954e5171a49c3f96f29dfcd3de)) -
  (Jimmy Briggs)
- **vector:** Add schema specification and transformation pipeline
  ([d28e75b](https://github.com/jimbrig/gdalvector/commit/d28e75bf119e880d8870ac856b2cc0190531b48a)) -
  (Jimmy Briggs)
- **vector:** Warn when GDAL FID column is virtual
  ([cd23611](https://github.com/jimbrig/gdalvector/commit/cd236114a739a626f7cb647c2c0842b911a825ff)) -
  (Jimmy Briggs)

## Refactoring

- **gdal-vector:** Improve FID column reporting and messaging
  ([27b2a8d](https://github.com/jimbrig/gdalvector/commit/27b2a8dc34e26226fe27e6830aa308cd2abf1668)) -
  (Jimmy Briggs)
- **gpq_meta:** Refactor GeoParquet schema inspection and remove Arrow
  dependency
  ([ad153b9](https://github.com/jimbrig/gdalvector/commit/ad153b9ac3c13fd4c18a241c1b67bf374e426cc8)) -
  (Jimmy Briggs)
  - **BREAKING CHANGE:** The `gpq_arrow_schema()` function has been
    removed.
- **cli:** Refactor output formatting and theme application
  ([8c4ef37](https://github.com/jimbrig/gdalvector/commit/8c4ef37a015bde273abeb3619cf2f17b32ae9c1b)) -
  (Jimmy Briggs)
- **utils:** Improve 64-bit integer decoding and remove blank predicate
  ([c5b79b7](https://github.com/jimbrig/gdalvector/commit/c5b79b7d17e71f19918e7ba0b83c32306110325f)) -
  (Jimmy Briggs)
- **gdal-vector-schema:** Remove vector schema transformation utilities
  ([99b1455](https://github.com/jimbrig/gdalvector/commit/99b145568538ba7ea7343dae367a26edccf867d3)) -
  (Jimmy Briggs)
  - **BREAKING CHANGE:** Functions for GDAL vector schema specification
    and pipeline argument generation have been removed and are no longer
    available.

## Testing

- **gpq_meta:** Improve print() method invisibility and output tests
  ([84a0c57](https://github.com/jimbrig/gdalvector/commit/84a0c577f6d74676a8e856f5a627083a3eefcc84)) -
  (Jimmy Briggs)
- **gpq:** Add comprehensive tests for metadata introspection
  ([507163b](https://github.com/jimbrig/gdalvector/commit/507163be7f05f8993050427d3e41f78740f13d11)) -
  (Jimmy Briggs)

## [0.0.3](https://github.com/jimbrig/gdalvector/tree/v0.0.3)- (2026-06-29)

## Bug Fixes

- **opts:** Address review feedback on PR \#5
  ([\#2](https://github.com/jimbrig/gdalvector/issues/2))
  ([438eaa6](https://github.com/jimbrig/gdalvector/commit/438eaa6521ef968e19d1013a9130c9cf0f108334)) -
  (Jimmy Briggs)
- Fix initialization
  ([20f2bad](https://github.com/jimbrig/gdalvector/commit/20f2badfea891c446083d34177841ccb288318b4)) -
  (Jimmy Briggs)

## Configuration

- **ci:** Standardize and streamline GitHub Actions workflows
  ([40b431f](https://github.com/jimbrig/gdalvector/commit/40b431fed3b4086752d8d985574a8d11b3f30408)) -
  (Jimmy Briggs)
- **dev:** Automate changelog generation and ignore during build
  ([1f444a4](https://github.com/jimbrig/gdalvector/commit/1f444a424e56ceec0a695d4a6e829bd3d04cc67c)) -
  (Jimmy Briggs)
- **dev:** Ensure .gitignore ends with a newline
  ([dbcd5e0](https://github.com/jimbrig/gdalvector/commit/dbcd5e0790d97962ac9d5430791070990fe8396d)) -
  (Jimmy Briggs)
- **vscode:** Configure workspace for R and Quarto formatting
  ([8cdf74d](https://github.com/jimbrig/gdalvector/commit/8cdf74de8fe78317a4c0f3bb5ef27173266f3b64)) -
  (Jimmy Briggs)
- Add Cursor IDE configuration for Tigris storage
  ([10157bb](https://github.com/jimbrig/gdalvector/commit/10157bb9f9d64d83337b332028fe1591c49610af)) -
  (Jimmy Briggs)

## DevOps

- Remove Windows from R CMD CHECK matrix
  ([b771416](https://github.com/jimbrig/gdalvector/commit/b77141643f5226e22269e4f158a82bddfbaee243)) -
  (Jimmy Briggs)
- **github-actions:** Add core workflows for R package CI
  ([d76bd6a](https://github.com/jimbrig/gdalvector/commit/d76bd6aa8302df93bd62f1d9fbf113362e719a6f)) -
  (Jimmy Briggs)

## Documentation

- **design:** Add comprehensive architecture and usage documentation
  ([d12a5da](https://github.com/jimbrig/gdalvector/commit/d12a5da293afdd5ddb15460ce90714e6eedb0766)) -
  (Jimmy Briggs)
- **opts:** Align builder roxygen with GDAL driver docs
  ([\#3](https://github.com/jimbrig/gdalvector/issues/3))
  ([4d7fd3a](https://github.com/jimbrig/gdalvector/commit/4d7fd3a3c29773c80bff6215316f19904a9a6ecc)) -
  (Jimmy Briggs)
- **opts:** Add OpenFileGDB links fragment to gdb builders
  ([\#3](https://github.com/jimbrig/gdalvector/issues/3))
  ([2327a42](https://github.com/jimbrig/gdalvector/commit/2327a420a1cd0d2b46a189d5cbff8a618c4ad073)) -
  (Jimmy Briggs)
- **articles:** Remove driver and concept documentation
  ([1a4330a](https://github.com/jimbrig/gdalvector/commit/1a4330aa0178c87f20e3be7807b291cda2611f98)) -
  (Jimmy Briggs)
- Improve link formatting in README
  ([c653244](https://github.com/jimbrig/gdalvector/commit/c6532448e4dbbf4bf5291d39d2b72762ea94ec15)) -
  (Jimmy Briggs)
- Add project banner to README
  ([c0c8c48](https://github.com/jimbrig/gdalvector/commit/c0c8c4833af93d60fb21dfb48d1274a25e70ddd5)) -
  (Jimmy Briggs)
- Remove .github/README.md
  ([64c9973](https://github.com/jimbrig/gdalvector/commit/64c99739eba43c8307f2f02395a6a15b14dccedd)) -
  (Jimmy Briggs)
- Add and update project badges
  ([fe1d158](https://github.com/jimbrig/gdalvector/commit/fe1d15890acb84afe94e973925707cc76b13d5cb)) -
  (Jimmy Briggs)

## Features

- **dev:** Add development scripts and package infrastructure setup
  ([f31275a](https://github.com/jimbrig/gdalvector/commit/f31275a5c3ad20e1b7713ff450ab75b7da6a149b)) -
  (Jimmy Briggs)

## Refactoring

- Streamline utility functions and update documentation
  ([e9667da](https://github.com/jimbrig/gdalvector/commit/e9667dabf3129c2b4934f527a5f68275ec0d287d)) -
  (Jimmy Briggs)
- **opts:** Add consistent ... pass-through to all typed builders
  ([\#2](https://github.com/jimbrig/gdalvector/issues/2))
  ([fa3ac9c](https://github.com/jimbrig/gdalvector/commit/fa3ac9c88bcef0fae56c8875934cfd0282172c23)) -
  (Jimmy Briggs)
- **opts:** Route option builders through shared .build_gdal_opts()
  ([\#1](https://github.com/jimbrig/gdalvector/issues/1))
  ([1a7f4a5](https://github.com/jimbrig/gdalvector/commit/1a7f4a5c18dd858a98c745caf08be8da75f621f4)) -
  (Jimmy Briggs)
- **gdal_opts:** Remove obsolete as_gdal_boolean helper
  ([37aed58](https://github.com/jimbrig/gdalvector/commit/37aed58121e8ce23914caf4ac2461d33ae0a87c6)) -
  (Jimmy Briggs)
- **gdal_opts:** Remove redundant boolean conversion
  ([785b11e](https://github.com/jimbrig/gdalvector/commit/785b11ee5af2c91c49fcc85a1037182d0ac4229c)) -
  (Jimmy Briggs)
- **gdal_drivers:** Consolidate option lookup logic
  ([2f6c33c](https://github.com/jimbrig/gdalvector/commit/2f6c33ca41dfac16f5074ed13d2287b386da2b63)) -
  (Jimmy Briggs)
- **gdal:** Standardize object formatting and streamline internal
  utilities
  ([cdfa33b](https://github.com/jimbrig/gdalvector/commit/cdfa33b5f7cdd629f09d728ea298553b379bab22)) -
  (Jimmy Briggs)
- **gdal-options:** Standardize option normalization and boolean
  coercion
  ([8c00bf5](https://github.com/jimbrig/gdalvector/commit/8c00bf5716ae2ac473d7abbe7619f391066ba5ff)) -
  (Jimmy Briggs)

## Styling

- Standardize code formatting and improve readability
  ([6af5f13](https://github.com/jimbrig/gdalvector/commit/6af5f13f4b32c4366f7186e316a5df561aaf2d92)) -
  (Jimmy Briggs)

## Testing

- **opts:** Require testthat (\>= 3.1.0) and use expect_no_error()
  ([\#2](https://github.com/jimbrig/gdalvector/issues/2))
  ([1216bd4](https://github.com/jimbrig/gdalvector/commit/1216bd47af6c925b2a2a689303480326f3c546bb)) -
  (Jimmy Briggs)
- **options:** Refactor and expand GDAL options test suite
  ([aa7cbd9](https://github.com/jimbrig/gdalvector/commit/aa7cbd9d56cd9141563fa33fd53e174427b25d68)) -
  (Jimmy Briggs)

------------------------------------------------------------------------

*Changelog generated by
[git-cliff](https://github.com/orhun/git-cliff).* \*\*\*
