
# gdalvector

<!-- badges: start -->
[![R CMD CHECK](https://github.com/jimbrig/gdalvector/actions/workflows/check.yml/badge.svg)](https://github.com/jimbrig/gdalvector/actions/workflows/check.yml)
[![Automate Changelog](https://github.com/jimbrig/gdalvector/actions/workflows/changelog.yml/badge.svg)](https://github.com/jimbrig/gdalvector/actions/workflows/changelog.yml)
[![Format Check](https://github.com/jimbrig/gdalvector/actions/workflows/format-check.yml/badge.svg)](https://github.com/jimbrig/gdalvector/actions/workflows/format-check.yml)
[![pkgdown](https://github.com/jimbrig/gdalvector/actions/workflows/pkgdown.yml/badge.svg)](https://github.com/jimbrig/gdalvector/actions/workflows/pkgdown.yml)
[![pages-build-deployment](https://github.com/jimbrig/gdalvector/actions/workflows/pages/pages-build-deployment/badge.svg)](https://github.com/jimbrig/gdalvector/actions/workflows/pages/pages-build-deployment)
[![R-universe version](https://jimbrig.r-universe.dev/gdalvector/badges/version)](https://jimbrig.r-universe.dev/gdalvector)
<!-- badges: end -->

## Overview

> [!NOTE]
> `gdalvector` is a modern-focused R package for working with cloud native geospatial vector data via bindings to GDAL 
> from the exceptional `[gdalraster](https://github.com/firelab/gdalraster)` package. This package offers a more focused
> intent on the vector side of what the underlying GDAL bindings provide and can be thought of as an extension of `gdalraster`
> that is also orthogonal and focused on vector specific data operations and modern GDAL algorithmic api focused workflows.

The goal of `gdalvector` is to .....

## Installation

You can install the development version of `gdalvector` from GitHub with `pak`:

```R
pak::pak("jimbrig/gdalvector")
```

> [!WARNING]
> Note that on Windows, you should look into the [`gdalraster.windows`](https://github.com/jimbrig/gdalraster.windows) 
> package I have created to provide the ability to work with `gdalraster`'s `GDALAlg` C++ binding reference class 
> to the core GDAL Algorithmix C API. For these same reasons, and due to the fragility of the underlying C/C++ ABIs 
> in general for GDAL, and the cross-platform nuances at play (especially for Windows), this package is likely not 
> one that will ever be distributed on CRAN officially, or its at least not a goal of mine.

To get `gdalraster.windows` up and running and verify proper bindings to the algorithmic APIs you can run:

```R
pak::pak("jimbrig/gdalraster.windows")
gdalraster.windows::install_gdal_runtime()
gdalraster.windows::install_gdalraster()
library(gdalraster.windows)
gdalraster::gdal_global_reg_names()
```

## Examples

## Resources


