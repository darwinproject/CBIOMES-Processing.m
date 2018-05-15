# tmp\_code\_devel
a repository to share codes that are under development


#### standard diagnostics

- `README_set_gudA.md` documents method to systematically depict model output, including `diags_set_drwn3.m` and `diags_set_gudA.m`.
- `diags_set_drwn3.m` is a standard set of biomass and plankton distribution diagnostics.
- `diags_set_gudA.m` is a standard set of biochemistry diagnostics with relevance to primary production.

#### 155W section diagnostics

- `read_slice_155W.m` is a Matlab / Octave function that reads in a variable once it has been interpolated to 155W using ` interp_to_155W.m`
- ` interp_to_155W.m` interpolates from model grid to 155W.
- `interp_to_155W_uv.m` interpolates velocity to 155W (see C-grid docs).
- `read_surf_maps.m`, `interp_surf_maps.m`, and `interp_surf_maps_uv.m` generate maps of top layer fields (e.g., 0-10m or 5m depth average).

### other basic diagnostics

- `eccov4_climplot.m` generates maps and sections of the physical ocean state variables (MLD, T, S, U, V,...).
- `llc90drwn3_ptravrg.m` time averages tracer model output.
- `llc90drwn3_ptrplot.m` plots time-averaged tracer output.

