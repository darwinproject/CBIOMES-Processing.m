function [fld,fldName]=extract_variable_155W(iFld,iFile);
% [fld,fldName]=extract_variable_155W(iFile,iFld);
% Extracts one variable (iFld) from one set of files (iFile between 1 and 4).
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
  variable_names=variables_ptr_3d_set1;
  fldName=deblank(variable_names{iFld});
elseif iFile==4;
  dirIn=[pwd '/diags_trsp_155W/']; listIn=dir([dirIn 'trsp_3d_set1*']);
  variable_names={'NVELMASS','EVELMASS'};
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

%%

function [PTRACERS_names]=variables_ptr_3d_set1();

PTRACERS_names={};
PTRACERS_names{  1}= 'DIC';
PTRACERS_names{  2}= 'NH4';
PTRACERS_names{  3}= 'NO2';
PTRACERS_names{  4}= 'NO3';
PTRACERS_names{  5}= 'PO4';
PTRACERS_names{  6}= 'SiO2';
PTRACERS_names{  7}= 'FeT';
PTRACERS_names{  8}= 'DOC';
PTRACERS_names{  9}= 'DON';
PTRACERS_names{ 10}= 'DOP';
PTRACERS_names{ 11}= 'DOFe';
PTRACERS_names{ 12}= 'POC';
PTRACERS_names{ 13}= 'PON';
PTRACERS_names{ 14}= 'POP';
PTRACERS_names{ 15}= 'POSi';
PTRACERS_names{ 16}= 'POFe';
PTRACERS_names{ 17}= 'PIC';
PTRACERS_names{ 18}= 'ALK';
PTRACERS_names{ 19}= 'O2';
PTRACERS_names{ 20}= 'CDOM';
PTRACERS_names{ 21}= 'c01';
PTRACERS_names{ 22}= 'c02';
PTRACERS_names{ 23}= 'c03';
PTRACERS_names{ 24}= 'c04';
PTRACERS_names{ 25}= 'c05';
PTRACERS_names{ 26}= 'c06';
PTRACERS_names{ 27}= 'c07';
PTRACERS_names{ 28}= 'c08';
PTRACERS_names{ 29}= 'c09';
PTRACERS_names{ 30}= 'c10';
PTRACERS_names{ 31}= 'c11';
PTRACERS_names{ 32}= 'c12';
PTRACERS_names{ 33}= 'c13';
PTRACERS_names{ 34}= 'c14';
PTRACERS_names{ 35}= 'c15';
PTRACERS_names{ 36}= 'c16';
PTRACERS_names{ 37}= 'c17';
PTRACERS_names{ 38}= 'c18';
PTRACERS_names{ 39}= 'c19';
PTRACERS_names{ 40}= 'c20';
PTRACERS_names{ 41}= 'c21';
PTRACERS_names{ 42}= 'c22';
PTRACERS_names{ 43}= 'c23';
PTRACERS_names{ 44}= 'c24';
PTRACERS_names{ 45}= 'c25';
PTRACERS_names{ 46}= 'c26';
PTRACERS_names{ 47}= 'c27';
PTRACERS_names{ 48}= 'c28';
PTRACERS_names{ 49}= 'c29';
PTRACERS_names{ 50}= 'c30';
PTRACERS_names{ 51}= 'c31';
PTRACERS_names{ 52}= 'c32';
PTRACERS_names{ 53}= 'c33';
PTRACERS_names{ 54}= 'c34';
PTRACERS_names{ 55}= 'c35';
PTRACERS_names{ 56}= 'c36';
PTRACERS_names{ 57}= 'c37';
PTRACERS_names{ 58}= 'c38';
PTRACERS_names{ 59}= 'c39';
PTRACERS_names{ 60}= 'c40';
PTRACERS_names{ 61}= 'c41';
PTRACERS_names{ 62}= 'c42';
PTRACERS_names{ 63}= 'c43';
PTRACERS_names{ 64}= 'c44';
PTRACERS_names{ 65}= 'c45';
PTRACERS_names{ 66}= 'c46';
PTRACERS_names{ 67}= 'c47';
PTRACERS_names{ 68}= 'c48';
PTRACERS_names{ 69}= 'c49';
PTRACERS_names{ 70}= 'c50';
PTRACERS_names{ 71}= 'c51';
PTRACERS_names{ 72}= 'Chl01';
PTRACERS_names{ 73}= 'Chl02';
PTRACERS_names{ 74}= 'Chl03';
PTRACERS_names{ 75}= 'Chl04';
PTRACERS_names{ 76}= 'Chl05';
PTRACERS_names{ 77}= 'Chl06';
PTRACERS_names{ 78}= 'Chl07';
PTRACERS_names{ 79}= 'Chl08';
PTRACERS_names{ 80}= 'Chl09';
PTRACERS_names{ 81}= 'Chl10';
PTRACERS_names{ 82}= 'Chl11';
PTRACERS_names{ 83}= 'Chl12';
PTRACERS_names{ 84}= 'Chl13';
PTRACERS_names{ 85}= 'Chl14';
PTRACERS_names{ 86}= 'Chl15';
PTRACERS_names{ 87}= 'Chl16';
PTRACERS_names{ 88}= 'Chl17';
PTRACERS_names{ 89}= 'Chl18';
PTRACERS_names{ 90}= 'Chl19';
PTRACERS_names{ 91}= 'Chl20';
PTRACERS_names{ 92}= 'Chl21';
PTRACERS_names{ 93}= 'Chl22';
PTRACERS_names{ 94}= 'Chl23';
PTRACERS_names{ 95}= 'Chl24';
PTRACERS_names{ 96}= 'Chl25';
PTRACERS_names{ 97}= 'Chl26';
PTRACERS_names{ 98}= 'Chl27';
PTRACERS_names{ 99}= 'Chl28';
PTRACERS_names{100}= 'Chl29';
PTRACERS_names{101}= 'Chl30';
PTRACERS_names{102}= 'Chl31';
PTRACERS_names{103}= 'Chl32';
PTRACERS_names{104}= 'Chl33';
PTRACERS_names{105}= 'Chl34';
PTRACERS_names{106}= 'Chl35';

