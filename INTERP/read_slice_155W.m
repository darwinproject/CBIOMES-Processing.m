function [fld,fldName]=read_slice_155W(iFld,iFile);
% [fld,fldName]=read_slice_155W(iFile,iFld);
% Reads one variable (iFld) from one set of files (iFile between 1 and 4).
%   state_3d_set1_155W/  <-> iFile=1
%   gud_3d_set1_155W/    <-> iFile=2
%   ptr_3d_set_155W/1    <-> iFile=3		
%   trsp_3d_set1_155W/   <-> iFile=4
% The result is a 3D slice (latitude,depth,month) and the corresponding 
% variable name (fldName). Additional detail about e.g. units can be 
% obtained by matching fldName with a line in the file called
% available_diagnostics.log

if iFile==1;
  dirIn=[pwd '/diags_state_155W/']; listIn=dir([dirIn 'state_3d_set1*']);
  variable_names={'THETA   ','SALT    ','DRHODR  '};
  fldName=deblank(variable_names{iFld});
elseif iFile==2;
  dirIn=[pwd '/diags_gud_155W/']; listIn=dir([dirIn 'gud_3d_set1*']);
  variable_names={'PP      ','Nfix    ','Denit   ','PAR     ','PARF    '};
  fldName=deblank(variable_names{iFld});
elseif iFile==3;
  dirIn=[pwd '/diags_ptr_155W/']; listIn=dir([dirIn 'ptr_3d_set1*']);
  variable_names=PTRACERS_names;
  fldName=deblank(variable_names{iFld});
elseif iFile==4;
  dirIn=[pwd '/diags_trsp_155W/']; listIn=dir([dirIn 'trsp_3d_set1*']);
  variable_names={'NVELMASS','EVELMASS','WVELMASS','NVELBOLUS','EVELBOLUS','WVELBOLUS'};
  fldName=deblank(variable_names{iFld});
else;
  error('unknow file collection');
end;

fld=NaN*zeros(60,50,239);
for ii=1:length(listIn);
  tmp1=load([dirIn listIn(ii).name]);
  fld(:,:,ii)=tmp1.sections(:,:,iFld);
end;

figureL; imagesc(squeeze(fld(:,1,:))); colorbar; 
title(fldName,'Interpreter','none');

