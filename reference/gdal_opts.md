# GDAL Options

GDAL options control how the GDAL/OGR library reads, writes, and
otherwise processes geospatial data. This package models the distinct
GDAL option *channels* as a small family of S3 classes, each backed by a
named list of `NAME = "VALUE"` pairs (values stored as their coerced
GDAL strings) plus a `driver` attribute, so a set of options is an
inert, composable value that can be rendered on demand to whichever form
a given consumer needs.

In the GDAL CLI, an option is supplied via one of these argument flags:

## Classes

All four classes share the `gdal_opts` base (a named `list`) and differ
only by channel:

- [`gdal_config_opts()`](http://docs.jimbrig.com/gdalvector/reference/gdal_config_opts.md):
  global, stateful configuration options. Applied to the process/session
  (via
  [`gdalraster::set_config_option()`](https://firelab.github.io/gdalraster/reference/set_config_option.html)),
  not as an algorithm argument.

- [`gdal_open_opts()`](http://docs.jimbrig.com/gdalvector/reference/gdal_open_opts.md):
  driver open options.

- [`gdal_creation_opts()`](http://docs.jimbrig.com/gdalvector/reference/gdal_creation_opts.md):
  driver dataset- or layer-creation options, selected by `level`.

- [`gdal_vsi_opts()`](http://docs.jimbrig.com/gdalvector/reference/gdal_vsi_opts.md):
  virtual file system (VSI) path-scoped options (config-like).

## Rendering

A `gdal_opts` value is rendered with
[`as_gdal_args()`](http://docs.jimbrig.com/gdalvector/reference/as_gdal_args.md)
(CLI token vector for
[`gdalraster::gdal_alg()`](https://firelab.github.io/gdalraster/reference/gdal_cli.html)
/
[`gdalraster::gdal_run()`](https://firelab.github.io/gdalraster/reference/gdal_cli.html)),
[`as_config_option()`](http://docs.jimbrig.com/gdalvector/reference/as_config_option.md)
(a `NAME = VALUE` character vector for
[`gdalraster::set_config_option()`](https://firelab.github.io/gdalraster/reference/set_config_option.html),
config/VSI only), or
[`gdal_render()`](http://docs.jimbrig.com/gdalvector/reference/gdal_render.md)
(a copy-pasteable shell snippet).

## See also

[`as_gdal_args()`](http://docs.jimbrig.com/gdalvector/reference/as_gdal_args.md),
[`as_config_option()`](http://docs.jimbrig.com/gdalvector/reference/as_config_option.md),
[`gdal_render()`](http://docs.jimbrig.com/gdalvector/reference/gdal_render.md);
and the typed per-driver builders
[`gpkg_open_opts()`](http://docs.jimbrig.com/gdalvector/reference/gpkg_open_opts.md),
[`gpq_creation_opts()`](http://docs.jimbrig.com/gdalvector/reference/gpq_creation_opts.md),
[`shp_open_opts()`](http://docs.jimbrig.com/gdalvector/reference/shp_open_opts.md),
[`fgb_creation_opts()`](http://docs.jimbrig.com/gdalvector/reference/fgb_creation_opts.md),
[`gdb_open_opts()`](http://docs.jimbrig.com/gdalvector/reference/gdb_open_opts.md).
