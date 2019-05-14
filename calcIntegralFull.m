function fldOut = integralFull(dirName,prefix,iStep,fldList)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

filIsDir = 0;

fnames = dir(fullfile(dirName,[prefix '*']));

if exist(fullfile(dirName,fnames(1).name),'dir')
    filIsDir = 1;
else
    fil = sprintf([prefix '.%010d.data'],iStep);
end

%load grid
gcmfaces_global;

%% THIS
nr = 50;%=max(find(mygrid.RC>-50));
w50m=mk3D(mygrid.DRF(1:nr),mygrid.mskC(:,:,1:nr));
w50m=w50m.*mygrid.hFacC(:,:,1:nr);
tmp1=nansum(w50m,3); 
w50m=w50m./repmat(tmp1,[1 1 nr]);
 
% Later
%nansum(fld(:,:,1:nr).*w50m,3);

%Sum Fields
fldOut=0*mygrid.RAC;
% if filIsDir
%     if iscell(fldList)
%         fld=cs510readtiles(dirName,'_',iStep,fldList{1});
%     else
%         fld=cs510readtiles(dirName,'_',iStep,fldList(1));
%     end
% else
%     fld = read_bin(fullfile(dirName,fil),fldList(1));
% end
for itr=1:length(fldList)
    if filIsDir
        if iscell(fldList)
            fld = cs510readtiles(dirName,'_',iStep,fldList{itr});
        else
            fld = cs510readtiles(dirName,'_',iStep,fldList(itr));
        end
    else
        fld = read_bin(fullfile(dirName,fil),itr);
    end
    fldOut=fldOut+nansum(fld(:,:,1:nr).*w50m,3);
end

