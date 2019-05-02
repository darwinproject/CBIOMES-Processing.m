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

%Sum Fields
if filIsDir
    if iscell(fldList)
        fld=cs510readtiles(dirName,'_',iStep,fldList{1});
    else
        fld=cs510readtiles(dirName,'_',iStep,fldList(1));
    end
else
    fld = read_bin(fullfile(dirName,fil),fldList(1));
end
for itr=2:length(fldList)
    if filIsDir
        if iscell(fldList)
            fld = fld + cs510readtiles(dirName,'_',iStep,fldList{itr});
        else
            fld = fld + cs510readtiles(dirName,'_',iStep,fldList(itr));
        end
    else
        fld = fld + read_bin(fullfile(dirName,fil),itr);
    end
end

fldOut = nansum(fld,3);

