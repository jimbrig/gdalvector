# format()/print() render the expected cli lines

    Code
      print(oo)
    Output
      <gdal_open_opts/gdal_opts>
      i Driver: GPKG
      i Open Options: LIST_ALL_TABLES=NO
      i Command Line: --input-format 'GPKG' --open-option 'LIST_ALL_TABLES=NO'

# empty opts print, render, and convert without error

    Code
      print(empty)
    Output
      <gdal_open_opts/gdal_opts>
      i Driver: GPKG
      i No open options set.

