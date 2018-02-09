function []=llc90drwn3_ptravrg(iList);
%LLC90DRWN3_PTRAVRG(iList);
%  read time series from diags/ subdirectory and write the corresponding
%  time average to diags_mean/ subdirectory for tracers listed in
%  iList ([1:106] by default).
%
%requirements:
%  gcmfaces/       (matlab codes)
%  grid output     (netcdf or binary files)
%  diags/          (binary files)

%% setup gcmfaces and load mygrid

if isempty(which('gcmfaces'));
   p = genpath('gcmfaces/'); addpath(p);
end;

gcmfaces_global;

if isempty(mygrid);
   grid_load;
end;

if isempty(whos('iList'));
  iList=[1:106];
end;

%% read time series, compute time mean, and write to disk

dirIn='./';

for iPtr=iList;
  fld=mean(rdmds([dirIn 'diags/ptr'],NaN,'rec',iPtr),4); 
  nmOut=sprintf('ptr%03d',iPtr); disp(nmOut);
  write2file([dirIn 'diags_mean/' nmOut '.bin'],fld);
end;

%%

