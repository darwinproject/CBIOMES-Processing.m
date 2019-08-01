function []=cci_Rrs_vs_model(yy,mm,vv);
% cci_Rrs_vs_model loads model output (irradiance reflectance), converts
%    it to remotely sensed reflectance, loads corresponding OC-CCI data 
%    (from cci_Rrs_remap.m output; on llc90 grid), and plots both. side
%    by side (using m_map and the inferno color map).
%
%example: for month 1 of year 2000 and the third wave band (ie 'Rrs_490')
% cci_Rrs_vs_model(2000,1,3);

if isempty(which('gcmfaces')); 
  p = genpath('gcmfaces/'); addpath(p); grid_load; 
  addpath m_map; addpath Colormaps;
end;

gcmfaces_global;

%%

dirModel='monthly_model/';
listModel=dir([dirModel 'surf_2d_set1*data']); listModel={listModel(:).name};

dirData='monthly_llc90/';
listData={'Rrs_412','Rrs_443','Rrs_490','Rrs_510','Rrs_555','Rrs_670'};

dirPlot='monthly_plots/';
if isempty(dir(dirPlot)); mkdir(dirPlot); end;
filPlot=['dataVSmodel_' listData{vv} '_' sprintf('%04d%02d',yy,mm)];
ccPlots=[25 17 8.2 8.2 8.0 2.3]*1e-3;

%%

fld_data=read_bin([dirData 'OC_CCI_L3S_' listData{vv} '_' num2str(yy)]);
fld_data=fld_data(:,:,mm);

fld_model=read_bin([dirModel listModel{(yy-1991)*12+mm}]);
fld_model=fld_model(:,:,2:14);

ttmp=fld_model/3;
fld_model=(0.52*ttmp)./(1-1.7*ttmp);
%RRS_INPUT = ((0.52*RRS_INPUT)/(1.-1.7*RRS_INPUT))/Q

wv_cci=[412, 443, 490, 510, 555, 670];
wv_drwn3=[400,425,450,475,500,525,550,575,600,625,650,675,700];
% gud_waveband_centers = [400.,425.,450.,475.,500,525,550,575,600,625,650,675,700.]
% New_wavebands        = [412.,443.,490.,510.,555.,670.]

tmp1=interp1(wv_drwn3,[1:13],wv_cci);
jj=floor(tmp1); ww=tmp1-jj;
%wv_drwn3(jj).*(1-ww)+wv_drwn3(jj+1).*ww

tmp0=fld_model(:,:,jj(vv)); tmp1=fld_model(:,:,jj(vv)+1);
fld_model=tmp0.*(1-ww(vv))+tmp1.*ww(vv);

fld_model(isnan(fld_data))=NaN;

%figure;
%subplot(2,1,1); qwckplot(fld_data); caxis([0 ccPlots(vv)]); colorbar; title('data');
%subplot(2,1,2); qwckplot(fld_model); caxis([0 ccPlots(vv)]); colorbar; title('model');
%colormap(jet(10)); print(gcf,'-dpng',[dirPlot filPlot '.png']);

figure; cc=ccPlots(vv);
subplot(2,1,1); m_map_gcmfaces(fld_data,1.2,{'myCaxis',cc*[0:0.1:1]},{'myCmap','inferno'});
subplot(2,1,2); m_map_gcmfaces(fld_model,1.2,{'myCaxis',cc*[0:0.1:1]},{'myCmap','inferno'});
print(gcf,'-dpng',[dirPlot filPlot '.png']);

