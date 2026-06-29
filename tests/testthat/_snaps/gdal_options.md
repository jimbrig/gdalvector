# format()/print() render the expected cli lines (inline)

    Code
      print(oo)
    Output
      <gdal_open_opts/gdal_opts>
      i Driver: GPKG
      i Open Options: LIST_ALL_TABLES=NO
      i Command Line: --input-format 'GPKG' --open-option 'LIST_ALL_TABLES=NO'

# format()/print() switch to block style beyond four options

    Code
      print(co)
    Output
      <gdal_creation_opts/gdal_opts>
      i Driver: Parquet
      i Creation Options (5):
      A = 1
      B = 2
      C = 3
      D = 4
      E = 5
      i Command Line: --output-format 'Parquet' --layer-creation-option 'A=1' --layer-creation-option 'B=2' --layer-creation-option 'C=3' --layer-creation-option 'D=4' --layer-creation-option 'E=5'

