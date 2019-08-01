
if 0;

gcmfaces_global; if isempty(mygrid); grid_load; end;

load([pwd '/mat/diags_grid_parms.mat']);

fileTex=[pwd '/tex_ecol/standardAnalysisPlanktonGroups.tex'];
dirMat=[pwd '/mat/diags_set_drwn3/']; fileMat='diags_set_drwn3';

userStep=0; diags_set_drwn3;
%alldiag=diags_read_from_mat(dirMat,[fileMat '_*.mat']);

%autotrophs(1:25), mixo(26:35), zoo(36:51)
%pico(1:4), nano(5:19 26:28), micro(20:25 29:35)
groupName={'Autotrophs','Mixotrophs','Zooplankton','Pico-Phytoplankton','Nano-Phytoplankton','Micro-Phytoplankton'};
groupInds={[1:25],[26:35],[36:51],[1:4],[5:19 26:28],[20:25 29:35]};%note: add 20 later
groupMax=[0.2 0.2 0.4 0.2 0.2 0.2];
%groupMax=[0.15 0.15 0.40 0.25 0.15 0.1];

end;%if 0;

doTex=1
if doTex==1; addToTex=1; else; addToTex=0; end;
myTitle={'Depiction of the 201805-CBIOMES global state estimate (alpha version).','Source: Gael Forget'};
rdm=[];

if 1;

if doTex; write2tex(fileTex,0,myTitle,rdm); end;
if doTex; write2tex(fileTex,1,'Annual Mean Biomass In Plankton Groups',1); end;
for igroup=1:length(groupName);
  ii=groupInds{igroup};
  fld=mean(sum(alldiag.ptrTop50m(:,:,20+ii),4),3);
  cc=[0:0.1:1]*groupMax(igroup);
  figureL; m_map_gcmfaces(fld.*mygrid.mskC(:,:,1),1.2,{'myCaxis',cc},{'myCmap','inferno'});
  myCaption={[groupName{igroup} ' -- log10(C) where C is the annual mean, top 50m average (in mgC/m3)']};
  if addToTex; write2tex(fileTex,2,myCaption,gcf); else; gcmfaces_caption(myCaption); end;
end;
if doTex; write2tex(fileTex,4); end;

end;%if 0;




