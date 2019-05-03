%% Running Pipeline on sample* directories
clear all


% Put tools on path
p = genpath([pwd '/../../tools/']);
addpath(p);

setup_pathsflds_cs510

switch sampleType
    case 'sample1'
        outputPrefix = 'ptr_3d_set1';
        nfaces = 5;
        fileformat = 'compact';
        timeInterval = 30;
    case 'sample2'
        outputPrefix = '3d';
        nfaces = 1;
        fileformat = 'straight';
    case 'cs510'
        outputPrefix = '_';
        nfaces = 6;
        fileformat = 'cube';
        subdirPrefix = 'res_';
        timeInterval = 3;
    otherwise
        disp('Not a valid sample type')
end

selectFld = {};
%% Read in the Grid
disp('Reading in the grid')

%dirGrid = [fullfile(sampledir,sample,'grid') filesep];

gcmfaces_global;
if isempty(mygrid)
    fprintf(['loading grid from ' dirGrid '\n']);
    grid_load(dirGrid,nfaces,fileformat);
end

%% Interpolate Groups

% get filenames from one directory to determine time steps
dirOutput = strrep(dirOutput_pat,'sample',fldTbl.source{1});
linkDir = strrep(linkDir_pat,'sample',fldTbl.source{1});
if strcmp(sampleType,'cs510')
    fnames = dir(fullfile(linkDir,[subdirPrefix '0000'],[outputPrefix '*.data'])); 
    prefix = subdirPrefix;
    nsteps = length(fnames);
else
    fnames = dir(fullfile(linkDir,[outputPrefix '*.data']));
    prefix = outputPrefix;
end

if ~isempty(getenv('SLURM_ARRAY_TASK_ID')) % In slurm job array to parallelize selectFld
        taskID = str2num(getenv('SLURM_ARRAY_TASK_ID'));
        numTasks = str2num(getenv('SLURM_ARRAY_TASK_COUNT'));

        myidx = taskID:numTasks:nsteps;
	dirOutput_pat = strrep(dirOutput_pat,'sample',['sample_' num2str(taskID)]);
    else
        myidx = 1:nsteps;
    end

% Move inter_precomputed.mat into diags_interp_tmp
interptmpdir = fullfile(dirOutput,'diags_interp_tmp');
if ~exist(interptmpdir,'dir'); mkdir(interptmpdir); end
if ~exist(fullfile(interptmpdir,'interp_precomputed.mat'))
    interpPrecomp = fullfile(precomp_interp_dir,'interp_precomputed.mat');
    if exist(interpPrecomp,'file')
        copyfile(interpPrecomp,[interptmpdir filesep]);
    end
end

for i = 1:height(fldTbl)
    linkDir = strrep(linkDir_pat,'sample',fldTbl.source{i});
    dirOutput = strrep(dirOutput_pat,'sample',fldTbl.source{i});
    if ~exist(dirOutput,'dir')
       mkdir(dirOutput)
       system(['ln -l ' linkDir ' ' dirOutput filesep fldTbl.source{i}])
    end
    system(['cp ' linkDir '/*.meta ' dirOutput])
    interpDir = strrep(interpDir_pat,'group',fldTbl.group_name{i});
    fldname = fldTbl.field{i};
    disp(['Processing ' fldname])
    % Interpolate any regular fields
    if strcmp(sampleType,'cs510') || strcmp(sampleType,'sample3')
        
        % Do the interpolation
        fnames = dir(fullfile(linkDir,[subdirPrefix '0000'],[outputPrefix '*.data']));
        
        if ~isempty(fldTbl.sourcefields{i})
            sourcefields = fldTbl.sourcefields{i};
            levs = fldTbl.levs{i};
            mate = fldTbl.mate{i};
            code = fldTbl.code{i};
            units = fldTbl.units{i};
            title = fldTbl.title{i};
            
            % Add to Diags
            fldname = addLineAvailDiag(diagnosticFile, fldname, levs, mate, code, units, title);
            selectFld = [selectFld fldname];
        else
            selectFld = [selectFld fldname];
        end
        
        if ~exist(fullfile(interpDir,fldname),'dir')
            mkdir(fullfile(interpDir,fldname));
        end
        
        for t = myidx
            
            fparts = strsplit(fnames(t).name,'.');
            iStep = str2double(fparts{2});
            
            if isempty(dir([interpDir fldname filesep '*' fparts{2} '.meta'])) || doInterpForce % Skip if already interpolated
                
                fldfname = strjoin(fparts(1:2),'.');
                if isempty(fldTbl.sourcefields{i})
                    fld = cs510readtiles(linkDir,outputPrefix,iStep,fldname);
                else
                    disp(['Creating ' fldname])
                    savename = strjoin(fparts(1:2),'.');
                    
                    % Calculate new field
                    if strcmp(lower(fldTbl.operation{i}),'sum')
                        fld = calcSum(linkDir,prefix,iStep,sourcefields);
                    elseif strcmp(lower(fldTbl.operation{i}),'shannon')
                        fld = calcShannon(linkDir,prefix,iStep,sourcefields);
                    elseif strcmp(lower(fldTbl.operation{i}),'top50avebiomass')
                        [biomass0to50ave,chl0to50ave] = calcTop50AveBiomass(linkDir,prefix,iStep);
                    elseif strcmp(lower(fldTbl.operation{i}),'integral-full')
                        fld = calcIntegralFull(linkDir,prefix,iStep,sourcefields);
                    else
                        disp(['Unsupported operation ' fldTbl.operation{i}])
                    end
                    
                    % Save to Output
                    dirNewFld = strrep(dirNewFld_pat,'sample',group(1).source);
                    if ~isdir(dirNewFld); mkdir(dirNewFld); end
                    [dims,prec,tiles]=cs510readmeta(linkDir);
                    
                    %write binary field (masked)
                    write2file(fullfile(dirNewFld,[savename '.' fldname '.data']),convert2vector(fld),32,0);
                    
                    %create meta file
                    write2meta(fullfile(dirNewFld,[savename '.' fldname '.data']),dims(1:length(size(fld.f1))),32,{fldname});
                    
                end
                disp(['Interpolating ' fldname])
                process2interp(dirOutput,outputPrefix,{fldname},fld,fldfname);
                
                system(['mv ' dirOutput filesep 'diags_interp_tmp/' fldname '/* ' fullfile(interpDir,fldname)]);
            else
                disp(['skipping ' fnames(t).name])
            end
            
        end
    end
    
end
% 
% 
% 
% %% Calculate Additional Fields
% 
% if doInterp
%     if strcmp(sampleType,'sample3')
%         fnames = dir(fullfile(dirOutput,[subdirPrefix '0000'],[outputPrefix '*.data'])); % get filenames from one directory to determine time steps
%         prefix = subdirPrefix;
%     else
%         fnames = dir(fullfile(dirOutput,[outputPrefix '*.data']));
%         prefix = outputPrefix;
%     end
%     
%     interptmpdir = fullfile(dirOutput,'diags_interp_tmp');
%     if ~exist(interptmpdir,'dir'); mkdir(interptmpdir); end
%     if ~exist(fullfile(interptmpdir,'interp_precomputed.mat'))
%         interpPrecomp = fullfile(precomp_interp_dir,'interp_precomputed.mat');
%         if exist(interpPrecomp,'file')
%             copyfile(interpPrecomp,[interptmpdir filesep]);
%         end
%     end
%     selectFld = {};
%     for j = 1:length(newfld)
%         rename = newfld(j).rename;
%         sumFlds = newfld(j).sumFlds;
%         levs = newfld(j).levs;
%         mate = newfld(j).mate;
%         code = newfld(j).code;
%         units = newfld(j).units;
%         title = newfld(j).title;
%         
%         % Add to Diags
%         fldname = addLineAvailDiag(diagnosticFile, rename, levs, mate, code, units, title);
%         selectFld = [selectFld fldname];
%         
%         disp(['Calculating and interpolating ' fldname])
%         
%         nsteps = length(fnames);
%         
%         if ~isempty(getenv('SLURM_ARRAY_TASK_ID')) % In slurm job array to parallelize selectFld
%             taskID = getenv('SLURM_ARRAY_TASK_ID');
%             numTasks = getenv('SLURM_ARRAY_TASK_COUNT');
%             
%             myidx = taskID:numTasks:nsteps;
%         else
%             myidx = 1:nsteps;
%         end
%         
%         for i = myidx
%             
%             fparts = strsplit(fnames(i).name,'.');
%             
%             if isempty(dir([interpDir rename filesep '*' fparts{2} '.meta'])) || doInterpForce % Skip if already interpolated
%                 
%                 iStep = str2double(fparts{2});
%                 savename = strjoin(fparts(1:2),'.');
%                 %fldsum = sumflds(dirOutput,prefix,iStep,sumFlds);
%                 fldsum = calcShannon(dirOutput,prefix,iStep,sumFlds);
%                 %[biomass0to50ave,chl0to50ave] = calcTop50AveBiomass(dirOutput,prefix,iStep);
%                 
%                 % Save to Output
%                 if ~isdir(dirNewFld); mkdir(dirNewFld); end;
%                 [dims,prec,tiles]=cs510readmeta(dirOutput);
%                 
%                 %write binary field (masked)
%                 write2file(fullfile(dirNewFld,[savename '.' rename '.data']),convert2vector(fldsum),32,0);
%                 
%                 %create meta file
%                 write2meta(fullfile(dirNewFld,[savename '.' rename '.data']),dims(1:3),32,{rename});
%                 
%                 % Interpolate
%                 fldfname = strjoin(fparts(1:2),'.');
%                 process2interp(dirOutput,outputPrefix,{rename},fldsum,fldfname);
%                 
%                 if ~exist(fullfile(interpDir,rename),'dir'); mkdir(fullfile(interpDir,rename)); end
%                 
%                 system(['mv ' dirOutput filesep 'diags_interp_tmp/' rename '/* ' fullfile(interpDir,rename)]);
%             else
%                 disp(['skipping ' fnames(i).name])
%             end
%         end
%     end
%     
%     clear fldsum
%     
%     % Rename completed interpolated files directory
%     movefile(fullfile(dirOutput,'diags_interp_tmp'),interpDir)
%     
% else
%     
%     fldname = addLineAvailDiag(diagnosticFile, rename, levs, mate, code, units, title);
%     selectFld = {fldname};
% end

%% Determine time series

if timeInterval == 30 %monthly
    tim=[dateStart(1)*ones(nsteps,1) dateStart(2)+[0:nsteps-1]' 15*ones(nsteps,1)];
    timeVec=datenum(tim)-datenum(dateStart);
else
    %timeVec = 1:nsteps;
    timeVec = timeInterval*(1:nsteps);
end

addTime(timeVec,timeUntis);

%% Write Interp to NCtiles

if doNCtiles
    
    copyfile(diagnosticFile,interpDir);
    
    if ~exist(fullfile(interpDir,'README'),'file')
        copyfile(readmeFile,fullfile(interpDir,'README'));
    end
    
    
    interp2nctiles(interpDir,selectFld);
    
    for i = 1:length(selectFld)
        system(['mv ' fullfile(interpDir,'nctiles_tmp',selectFld{i}) ' ' nctileDir '/']);
    end
    
    
end