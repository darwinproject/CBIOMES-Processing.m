This document outlines how the `gcmfaces` toolbox can can be used to analyze `MITgcm` output. It is associated with the `diags_set_gudA.m` file found in the same repository.

### 1) Install Software As Needed

User who may have already obtained, and maybe re-organized, the needed software should skip this part. Otherwise, you may proceed as follows. First, go to your model output directory and install software:  

- Install `gcmfaces` and `m_map` as explained in [this documentation](http://gcmfaces.readthedocs.io/en/latest/prep_install.html#install-software/).
- Download codes from the `MIT Darwin Project` and `MatPlotLib` as follows.

```
git clone https://github.com/darwinproject/tmp_code_devel
git clone https://github.com/DrosteEffect/Colormaps-from-MatPlotLib2.0
```

Hereafter, the `dirModel` directory is expected to contain the grid output and the `diags/` output subdirectory. For the ECCO v4 configuration, grid output is available for download in netcdf format (e.g., [see here](http://gcmfaces.readthedocs.io/en/latest/prep_install.html)). The various `MITgcm` grids that have been used within `gcmfaces` are additionally available for download in binary format, e.g., via [this server](http://mit.ecco-group.org/opendap/ecco_for_las/version_4/grids/grids_output/).

### 2) Interactively Analyze Output

Here, you will first load and display model output for Primary Production (units: `mmolC/m^3/s`) using the `gcmfaces` toolbox. To this end, launch `Matlab` (or `Octave`) and execute the following commands:

```
  %add software to path:
  p = genpath('gcmfaces/'); addpath(p);

  %load data:
  grid_load;
  dirModel='./';
  dirDiags=[dirModel 'diags/'];
  fld=rdmds2gcmfaces([dirDiags 'gud_3d_set1*'],NaN,'rec',1);

  %Display gcmfaces object structure:
  display(fld);

```

Then, select a vertical level and depict time mean maps using `qwckplot.m` or the `m_map` toolbox:

```
  %add software to path:
  p = genpath('m_map/'); addpath(p);
  p = genpath('Colormaps-from-MatPlotLib2.0/'); addpath(p);

  %apply land mask and plot:
  gcmfaces_global;
  kk=1; m=mygrid.mskC(:,:,kk); 
  figureL; qwckplot(m.*mean(fld(:,:,kk,:),4));
  figureL; m_map_gcmfaces(fld,1.2,{'myCmap','inferno'}); 

```

### 3) The Standard Analysis Framework

The `gcmfaces` standard analysis framework offers a slightly more advanced, systematic approach to handle model diagnostics ([documented here](http://gcmfaces.readthedocs.io/en/latest/)). For pre-defined diagnostic sets (e.g., `diags_set_gudA.m` below), `diags_driver.m` can be called to process, e.g., monthly records, one at a time, and save results to a `dirMat` subdirectory (e.g., 12 files will be created in `mat/diags_set_gudA/` in the case below).


```
  %add software to path:
  p = genpath('gcmfaces/'); addpath(p);
  p = genpath('tmp_code_devel/'); addpath(p);
    
  %computational loop:
  dirModel='./';
  dirMat=[dirModel 'mat/'];
  setDiags='gudA';
  diags_driver(dirModel,dirMat,'climatology',setDiags);
```

Once the computational phase has completed, results can then be displayed using either `diags_display.m` or `diags_driver_tex.m`. The latter stores plots and create a compilable `tex` file in a `dirTex` directory (e.g., `tex/` in the case below).


```
  %add software to path:
  p = genpath('m_map/'); addpath(p);
  p = genpath('Colormaps-from-MatPlotLib2.0/'); addpath(p);
    
  %display loop:
  dirModel='./';
  dirMat=[dirModel 'mat/']; setDiags='gudA';
  dirTex=[dirModel 'tex/']; nameTex='gudA_plots';
  diags_driver_tex(dirMat,{setDiags},dirTex,nameTex);
```

### 4) Develop New Diagnostic Sets:

In the following `XYZ` serves as a placeholder -- make sure to choose a more descriptive name for your new set of diagnostics. In a terminal window, start as follows:

```
cp gcmfaces/gcmfaces_diags/diags_set_user.m tmp_code_devel/
mv tmp_code_devel/diags_set_user.m tmp_code_devel/diags_set_XYZ.m
```

Edit `diags_set_XYZ.m` to replace `user` with `XYZ` throughout. At this point, `diags_set_XYZ.m` can be invoked via `diags_driver.m` and `diags_driver_tex.m` as before but with `setDiags` set to `XYZ` instead of `gudA`. Along the way, user will be prompted to edit `diags_set_XYZ.m` for each of four `userStep` -- look at `diags_set_gudA.m` for working examples. Once `diags_set_XYZ.m` is at least partly implemented, uploading it to GitHub will make it available to collaborators (see next section).

### 5) Develop And Share Codes Via GitHub:

There are several advantages to using a system such as `GitHub` to archive, share, develop, and maintain codes. If you are new to `GitHub`, the following link may be a [a good place to start](https://guides.github.com/activities/hello-world/). To upload a new routine to GitHub, you may for example proceed as follows, at the command line of a terminal window:

```
cd tmp_code_devel/
git add diags_set_XYZ.m
git commit diags_set_XYZ.m
git push origin master
```

