# CBIOMES-Processing.m
This repository contains prototype workflows, written in Matlab, having to do with CBIOMES model inputs and outputs. A listing, hopefully up to date, of the scripts and their respective purposes is provided below. 

#### standard diagnostics

- `README_set_gudA.md` documents method to systematically depict model output, including `diags_set_drwn3.m` and `diags_set_gudA.m`.
- `diags_set_drwn3.m` is a standard set of biomass and plankton distribution diagnostics.
- `diags_set_gudA.m` is a standard set of biochemistry diagnostics with relevance to primary production.
- `diags_plot_lightfields.m` is a standard set of irradiance reflectance diagnostics.
- `diags_plot_planktongroups.m` is a standard set of plnakton group diagnostics.

#### 155W section diagnostics

- `read_slice_155W.m` is a Matlab / Octave function that reads in a variable once it has been interpolated to 155W using ` interp_to_155W.m`
- ` interp_to_155W.m` interpolates from model grid to 155W.
- `interp_to_155W_uv.m` interpolates velocity to 155W (see C-grid docs).
- `read_surf_maps.m`, `interp_surf_maps.m`, and `interp_surf_maps_uv.m` generate maps of top layer fields (e.g., 0-10m or 5m depth average).

### OC-CCI processing, model-data comparison, etc.

- `cci_Rrs_tests.m` converts irradiance reflectance output to remotely sensed reflectances and interpolate to `CCI` wavelengths (0D and 2D tests).
- `cci_Rrs_remap.m` reads in OC-CCI data (netcdf files, sinusoidal grid), remaps it to llc90 grid (using bin-average, binary file).
- `cci_Rrs_vs_model.m` compares regridded OC-CCI data from `cci_Rrs_remap.m` with model as in `cci_Rrs_tests.m`.
- `cci_PostProcessModelOutput.m` converts monthly model output to daily OC-CCI Rrs (6 wavebands).
- `cci_CompareModelData.m` plot maps of model and CCI sample averages, model-data difference maps, and time series of model vs dara stats.


### other basic diagnostics

- `eccov4_climplot.m` generates maps and sections of the physical ocean state variables (MLD, T, S, U, V,...).
- `llc90drwn3_ptravrg.m` time averages tracer model output.
- `llc90drwn3_ptrplot.m` plots time-averaged tracer output.

### utilities

- `PTRACERS_names.m` lookup table for tracer actual names.
- `PTRACERS_varnames.m` lookup table for tracer internal code names.
- `PTRACERS_units.m` lookup table for tracer variable units.
- `PTRACERS_ranges.m` lookup table for tracer variable ranges.
- `cs510readsample.m` reads cs510 grid and sample output. 
- `cs510readmeta.m` reads cs510 sample output format.
- `cs510readtiles.m` reads cs510 tiled output format.

