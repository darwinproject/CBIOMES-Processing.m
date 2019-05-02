function [fldsum]=sumflds(dirName,prefix,iStep,fldList)
%[fld]=cs510readtiles(dirIn,filIn,iStep,iFld);
%e.g. [fld]=cs510readtiles('ptr/','_',72,21);    

filIsDir = 0;

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
% nr=max(find(mygrid.RC>-50));
% w50m=mk3D(mygrid.DRF(1:nr),mygrid.mskC(:,:,1:nr));
% w50m=w50m.*mygrid.hFacC(:,:,1:nr);
% tmp1=nansum(w50m,3); 
% w50m=w50m./repmat(tmp1,[1 1 nr]);

%select a file / record
%fil='diags_ptr/ptr_3d_set1.0000000732.data';

%Sum Fields
if filIsDir
    if iscell(fldList)
        fldsum=cs510readtiles(dirName,'_',iStep,fldList{1});
    else
        fldsum=cs510readtiles(dirName,'_',iStep,fldList(1));
    end
else
    fldsum = read_bin(fullfile(dirName,fil),fldList(1));
end
for itr=2:length(fldList)
    if filIsDir
        if iscell(fldList)
            fld = cs510readtiles(dirName,'_',iStep,fldList{itr});
        else
            fld=cs510readtiles(dirName,'_',iStep,fldList(itr));
        end
    else
        fld = read_bin(fullfile(dirName,fil),itr);
    end
    fldsum=fldsum+fld;
end

end

