# CMAP 2019

This directory contains a number of scripts that were used to create interoplated data to be added in CMAP. Then end goal of this pipeline are NetCDF files each containing multiple fields (these are the "groups") that have been interpolated to a half-degree grid. These files also may contain sums of fields, the Shannon Index of a group of fields, and the full depth integral of a set of fields. The final write to NetCDF is done in Julia using the NCTiles.jl package. See CbiomesProcess.jl for that script.

The full Pipeline is:

1. Edit `setup_pathsflds_cs510.m` to reflect which fields should be interpolated, calculated, and grouped. This is also where you indicate paths to where the data sits and where the output should be written.
2. Run `runGroups_cs510.m` (see below for notes on how to run).
3. Run `makeNCtiles.jl` from CbiomesProcessing.jl.

## Directory Structure

The starting directory structure used for this run is as follows:

- run_cs510 (top level directory)
  - setup_pathsflds_cs510.m (file)
  - runGroups_cs510.m (file)
  - makeNCfiles.jl (file)
  - submit_interp.sh (if you are using a Slurm cluster)
  - submit_ncfiles.sh (if you are using a Slurm cluster)
  - data (directory)
    - available_diagnostics.log (file)
    - data_cs510 (directory)
      - README (file)
      - grid (directory containing grid- can be a symlink)
      - ptr (directory- same setup for gud and surf)
        - ptr (symlink to directory containing ptr data)
      - precomp_interp (directory)
        - halfdeg (directory)
          - interp_precomputed.mat (file of interpolation coefficients)

After running `runGroups_cs510.m` the directory "diags_interp" is added under "data_cs510" with the following structure (here xxx is the roughly the timestep):

- diags_interp
  - Group1
    - Group1Field1
      - Group1Field1.xxx.data (binary interpolated data- one for each timestep)
      - Group1Field1.xxx.meta (metadataa file- one for each timestep)
      - ...
    - Group1Field2
    - ...
  - Group2
    - Group2Field1
    - Group2Field2
    - ...

This is the structure that `makeNCfiles.jl` expects when it runs.

Any newly calculated fields are put with their type at the same level as the symlinks to the original data. For example the upper level `ptr` directory looks like this after `runGroups_cs510.m` is run (here xxx is the roughly the timestep):

- ptr (directory)
  - newflds (directory)
    - _.xxx.newField1.data
    - _.xxx.newField1.meta
    - ...
  - ptr (symlink to original data)

## Editing `setup_pathsflds_cs510.m`

There are three sections that can be edited. Avoid editing the final section of this script.

### Dirs

The first thing to do is edit the paths in the "Dirs" section to reflect your setup and directory names. If the directory structure above is used nothing needs to be changed here.

### Time Units

This section contains the units used for time. This only needs to be changed if the start date is different.

### Groups

This is where you set up the groups. This is done with nested structs. Each group contains its name, the list of fields to interpolate, which set of fields it belongs to (`source`), and all new fields. Each new field contains the original fields going into the new field (either their indices or their names), their source, what operation they are combined with (`operation`), the name of the new field (`rename`), and the information that is needed to add a new line to `available_diagnostics.log`. Look at the `setup_pathsflds_cs510.m` for examples.

## Running `runGroups_cs510.m`

The `runGroups_cs510.m` script is written in such a way that it can be run in serial or as part of a Job Array on a Slurm cluster.  As such, it has checkpointing built in so it can pick up where it left off if terminated early.

You may need to edit the tools path at the top of the script to reflect where this repository and `gcmfaces` are located.
