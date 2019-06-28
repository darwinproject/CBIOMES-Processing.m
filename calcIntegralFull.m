function fldOut = calcIntegralFull(dirName,prefix,iStep,fldList)
%calcIntegralFull calculates full depth integral of a given field
%   Calculates full depth integral for fields in fldList, combined into one output

filIsDir = 0;

fnames = dir(fullfile(dirName,[prefix '*']));

if exist(fullfile(dirName,fnames(1).name),'dir')
    filIsDir = 1;
else
    fil = sprintf([prefix '.%010d.data'],iStep);
end

%load grid
gcmfaces_global;

nr = 50;
w50m=mk3D(mygrid.DRF(1:nr),mygrid.mskC(:,:,1:nr));
w50m=w50m.*mygrid.hFacC(:,:,1:nr);
tmp1=nansum(w50m,3); 
w50m=w50m./repmat(tmp1,[1 1 nr]);

%Sum Fields
fldOut=0*mygrid.RAC;
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

