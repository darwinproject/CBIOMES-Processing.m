
if 0;

gcmfaces_global; if isempty(mygrid); grid_load; end;

load([pwd '/mat/diags_grid_parms.mat']);

gud_radtrans_kmax=22;
gud_waveband_edges=[400,412.5,437.5,462.5,487.5,512.5,537.5,562.5,587.5,612.5,637.5,662.5,687.5,700];
gud_waveband_centers=[400,425,450,475,500,525,550,575,600,625,650,675,700];
gud_waveband_ccMax_surf=[0.16 0.14 0.1 0.08 0.06 0.04 0.03 2.5e-2 1.2e-2 1e-2 8e-3 6e-3 4e-3 4e-3];

  %records that correspond to each season
  nrec=1+diff(myparms.recInAve);
  rec0=myparms.recInAve(1)-1;
  DJF=rec0+[[12:12:nrec] [1:12:nrec] [2:12:nrec]];
  MMA=rec0+[[3:12:nrec] [4:12:nrec] [5:12:nrec]];
  JJA=rec0+[[6:12:nrec] [7:12:nrec] [8:12:nrec]];
  SON=rec0+[[9:12:nrec] [10:12:nrec] [11:12:nrec]];
  ssnNrec=[length(DJF) length(MMA) length(JJA) length(SON)];

listFiles=dir([pwd '/diags_rest/surf_2d_set1*.meta']); fileTex=[pwd '/tex_light/standardAnalysisLight.tex'];
%listFiles=dir([pwd '/diags_rest/rt_3d_set1*.meta']); fileTex=[pwd '/tex_light/standardAnalysisPAR.tex'];

fil=listFiles(1).name(1:end-5);
fld=rdmds2gcmfaces([pwd '/diags_rest/' fil]);
nd=length(size(fld{1}));
clim=0*repmat(fld,[ones(1,nd) 4]);

  %assemble seasonal averages or time series
  tic;
  fprintf('Reading files: started ... \n');
  for jj=myparms.recInAve(1):myparms.recInAve(2);
    ssn=find([sum(DJF==jj) sum(MMA==jj) sum(JJA==jj) sum(SON==jj)]);
    fil=listFiles(jj).name(1:end-5);
    fld=rdmds2gcmfaces([pwd '/diags_rest/' fil]);
    if nd==3;
      clim(:,:,:,ssn)=clim(:,:,:,ssn)+fld/ssnNrec(ssn);
    else;
      clim(:,:,:,:,ssn)=clim(:,:,:,:,ssn)+fld/ssnNrec(ssn);
    end;
  end;
  fprintf('Reading files: ... ended \n');
  toc;

clim_surf=clim;
%clim_rt=clim;

end;%if 0;

doTex=1
if doTex==1; addToTex=1; else; addToTex=0; end;
myTitle={'Depiction of the 201805-CBIOMES global state estimate (alpha version).','Source: Gael Forget'};
rdm=[];

if 1;

if doTex; write2tex(fileTex,0,myTitle,rdm); end;
if doTex; write2tex(fileTex,1,'Annual Mean Irradiance Reflectance',1); end;
for iband=1:13;
  wband=gud_waveband_centers(iband);
  cc=100*[0:0.1:1]*gud_waveband_ccMax_surf(iband);
  figureL; m_map_gcmfaces(100*mean(clim(:,:,iband+1,:),4).*mygrid.mskC(:,:,1),1.2,{'myCaxis',cc},{'myCmap','inferno'});
  myCaption={['Modeled irradiance reflectance at ' num2str(wband) 'nm (in $\\%%$).']};
  if addToTex; write2tex(fileTex,2,myCaption,gcf); else; gcmfaces_caption(myCaption); end;
end;
if doTex; write2tex(fileTex,4); end;

end;%if 0;




