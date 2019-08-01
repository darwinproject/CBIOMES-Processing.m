function [biomass0to50ave,chl0to50ave] = calcTop50AveBiomass(dirName,prefix,iStep,itr_plankton,itr_zooplankton)
%calcTop50AveBiomass Summary of this function goes here
%   Detailed explanation goes here

filIsDir = 0;

if ~exist('itr_plankton','var'); itr_plankton = 21:71; end
if ~exist('itr_zooplankton','var'); itr_zooplankton = 72:106; end

fnames = dir(fullfile(dirName,[prefix '*']));

if exist(fullfile(dirName,fnames(1).name),'dir')
    filIsDir = 1;
else
    fil = sprintf([prefix '.%010d.data'],iStep);
end

%load grid
gcmfaces_global;
%grid_load;

%compute weights to perform 0-50m average
nr=max(find(mygrid.RC>-50));
w50m=mk3D(mygrid.DRF(1:nr),mygrid.mskC(:,:,1:nr));
w50m=w50m.*mygrid.hFacC(:,:,1:nr);
tmp1=nansum(w50m,3); 
w50m=w50m./repmat(tmp1,[1 1 nr]);

%select a file / record
%fil='diags_ptr/ptr_3d_set1.0000000732.data';

%read one field at a time and sum over all plankton types
biomass0to50ave=0*mygrid.RAC;
for itr=itr_plankton
    if filIsDir
        fld = cs510readtiles(dirName,'_',iStep,itr);
    else
        fld = read_bin(fullfile(dirName,fil),itr);
    end
    biomass0to50ave=biomass0to50ave+nansum(fld(:,:,1:nr).*w50m,3);
end

%read one field at a time and sum over all zooplankton types
chl0to50ave=0*mygrid.RAC;
for itr=itr_zooplankton
    if filIsDir
        fld = cs510readtiles(dirName,'_',iStep,itr);
    else
        fld = read_bin(fullfile(dirName,fil),itr);
    end
    chl0to50ave=chl0to50ave+nansum(fld(:,:,1:nr).*w50m,3);
end


end

