function [out]=llc90drwn3_ptrplot(iPtr,plotName,doPrint);
%LLC90DRWN3_PTRPLOT(iPtr,plotName,doPrint);
%  map the log of concentration for a phytoplankton type
%  - iPtr is expected to be in the 21..71 range (21 by default)
%  - plotName can be '' (default), 'top50map', or 'sec158W'
%  - doPrint is either 0 (default) or 1. If set to 1 then figures
%    will be printed as pjg to a subdirectory called diags_plot/.
%
%requirements:
%  gcmfaces/       (matlab codes)
%  grid output     (netcdf or binary files)
%  diags/          (binary files)

%%

if isempty(whos('iPtr')); iPtr=35; end;
if isempty(whos('plotName')); plotName=''; end;
if isempty(whos('doPrint')); doPrint=0; end;

%%

if isempty(which('gcmfaces')); p = genpath('gcmfaces/'); addpath(p); end;

gcmfaces_global;

if isempty(mygrid); grid_load; end;

lon=[-179.75:0.5:179.75]; lat=[-89.75:0.5:89.75]; [lat,lon] = meshgrid(lat,lon);

global glo_interp;
if isempty(glo_interp)&~isempty(strfind(plotName,'map'));
  fprintf('one-time initialization of gcmfaces_interp_coeffs: begin\n');
  glo_interp=gcmfaces_interp_coeffs(lon(:),lat(:));
  fprintf('one-time initialization of gcmfaces_interp_coeffs: end\n');
end;

if isempty(whos('iPtr'));
   iPtr=21;
end;

%% load time-mean 3D field

dirIn='./';

if 0; %either using 3-daily output directly
  fld=mean(rdmds([dirIn 'diags/ptr'],NaN,'rec',iPtr),4);
  fld=mygrid.mskC.*convert2gcmfaces(fld);
else; %or using time mean computed earlier by llc90drwn3_ptravrg.m 
  fld=read_bin([dirIn 'diags_mean/' sprintf('ptr%03d.bin',iPtr)]);
  fld=mygrid.mskC.*fld;
end;

%% compute top 50m average

w=mk3D(mygrid.DRF,mygrid.mskC).*repmat(mygrid.RAC,[1 1 50]);
w=w.*mygrid.hFacC; w(:,:,6:end)=NaN;
fldTop50=nansum(w.*fld,3)./nansum(w,3);

%% interpolate and plot map

if strcmp(plotName,'top50map');
  tmp1=convert2vector(fldTop50); tmp0=1*~isnan(tmp1); tmp1(isnan(tmp1))=0;
  %
  tmp0=glo_interp.SPM*tmp0; tmp1=glo_interp.SPM*tmp1;
  %
  fld_interp=reshape(tmp1./tmp0,size(lon));
  %
  fld_log=fld_interp; fld_log(fld_log<0)=NaN; fld_log=log10(fld_log);
  %
  figure; pcolor(lon,lat,fld_log); caxis([-3 0.5]); colorbar; shading flat;
  %
  if doPrint; 
    eval(['print -djpeg90 ' dirIn 'diags_plot/' sprintf('top50map_%03d.bin',iPtr) '.jpg;']); 
  end;
end;

%% compute and plot section

if strcmp(plotName,'sec158W');
  [LO,LA,fld_section,X,Y]=gcmfaces_section([-158 -158],[-89 90],fld);
  log_section=fld_section; log_section(log_section<0)=NaN; 
  log_section=log10(log_section);
  %  
  figureL; pcolor(X,Y,log_section); shading flat; 
  axis([20 55 -300 0]); caxis([-2 1.2]); colorbar;
  %
  if doPrint;
    eval(['print -djpeg90 ' dirIn 'diags_plot/' sprintf('sec158W_%03d.bin',iPtr) '.jpg;']);
  end;
end;
 
