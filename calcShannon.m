function shannon = calcShannon(dirName,totalDir,totalName,prefix,iStep,fldList)
%calcShannon Calculates Shannon Index
%   Calculates Shannon Index: sum_j[(Bj/Btot)*ln(Bj/Btot)] for j = 1:N
%   Assumes you've already calculated the sum Btot saved in totalDir as totalName

filIsDir = 0;

fnames = dir(fullfile(dirName,[prefix '*']));

if exist(fullfile(dirName,fnames(1).name),'dir')
    filIsDir = 1;
else
    fil = sprintf([prefix '.%010d.data'],iStep);
end

%load grid
gcmfaces_global;

fldsum = read_bin(fullfile(totalDir,sprintf(['_.%010d.' totalName '.data'],iStep)));

if filIsDir
    if iscell(fldList)
        p = cs510readtiles(dirName,'_',iStep,fldList{1})./fldsum;
    else
        p=cs510readtiles(dirName,'_',iStep,fldList(1))./fldsum;
    end
else
    p = read_bin(fullfile(dirName,fil),fldList(1))./fldsum;
end

for i = 1:p.nFaces
    p{i} = p{i}.*log(p{i});
end
shannon = -p;
for itr=2:length(fldList)
    if filIsDir
        if iscell(fldList)
            p = cs510readtiles(dirName,'_',iStep,fldList{itr})./fldsum;
            
        else
            p = cs510readtiles(dirName,'_',iStep,fldList(itr))./fldsum;
        end
        
    else
        p = read_bin(fullfile(dirName,fil),itr)./fldsum;
    end
    for i = 1:p.nFaces
        p{i} = p{i}.*log(p{i});
    end
    shannon = shannon - p;
end

