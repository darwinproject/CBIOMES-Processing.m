function [fldsum]=calcSum(dirName,prefix,iStep,fldList)
%calcSum calculates sum of a set of fields
%   Calculates sum of fields in fldList 

filIsDir = 0;

fnames = dir(fullfile(dirName,[prefix '*']));

if exist(fullfile(dirName,fnames(1).name),'dir')
    filIsDir = 1;
else
    fil = sprintf([prefix '.%010d.data'],iStep);
end

%load grid
gcmfaces_global;

if ~iscell(fldList)
    if filIsDir
        fldsum = cs510readtiles_rangeandsum(dirName,'_',iStep,fldList);
    else
        fldsum = read_bin(fullfile(dirName,fil),fldList(1));
        for itr = 2:length(fldList)
            fld = read_bin(fullfile(dirName,fil),itr);
            fldsum=fldsum+fld;
        end
    end
else
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
    

end

