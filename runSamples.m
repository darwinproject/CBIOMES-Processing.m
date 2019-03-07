%% Running Pipeline on sample* directories
clear all;


% Put tools on path
p = genpath([pwd '/../']);
addpath(p);

% which sample directory
sampledir = '../../DarwinModelOutputSamples/';
sampleType = 'sample3';
sample = 'ptr';
diagnosticFile = fullfile(sampledir,'doc/available_diagnostics.log');
readmeFile = fullfile(sampledir,'README.md');
dirGrid = [fullfile(sampledir,sampleType,'grid') filesep];
dirOutput = [fullfile(sampledir,sample,'output') filesep];
interpDir = [fullfile(sampledir,sample,'diags_interp_') datestr(now,'yyyymmdd_HHMM') filesep];
nctileDir = [fullfile(sampledir,sample,'nctiles_') datestr(now,'yyyymmdd_HHMM') filesep];
selectFld = {'TRAC21'};

% Which part of processing to do
doInterp = 1; doInterpForce = 1;
doNCtiles = 1;

switch sampleType
    case 'sample1'
        outputPrefix = 'ptr_3d_set1';
        nfaces = 5;
        fileformat = 'compact';
    case 'sample2'
        outputPrefix = '3d';
        nfaces = 1;
        fileformat = 'straight';
    case 'sample3'
        outputPrefix = '_';
        nfaces = 6;
        fileformat = 'cube';
        subdirPrefix = 'res_';
    otherwise
        disp('Not a valid sample type')
end

if ~isempty(getenv('SLURM_ARRAY_TASK_ID')) % In slurm job array to parallelize selectFld
    taskID = getenv('SLURM_ARRAY_TASK_ID');
    numTasks = getenv('SLURM_ARRAY_TASK_COUNT');
    
    selectFld = selectFld(taskID:numTasks:end);
end

%% Read in the Grid
disp('Reading in the grid')

%dirGrid = [fullfile(sampledir,sample,'grid') filesep];

gcmfaces_global;
if isempty(mygrid)
    fprintf(['loading grid from ' dirGrid '\n']);
    grid_load(dirGrid,nfaces,fileformat);
end

% Select Fields
% Get list of interpolated names
if ischar(selectFld) || strcmp(selectFld,'all')
    [selectFld,listNot]=process2interp(dirOutput,outputPrefix);
end

%% Interpolate Output
if doInterp
    disp('Interpolating output files')
    
    if ~exist(fullfile(dirOutput,'available_diagnostics.log'),'file')
        copyfile(diagnosticFile,dirOutput);
    end
    
    if ~isempty(dir(fullfile(sampledir,sample,'diags_interp*')))
        previnterpDir = dir(fullfile(sampledir,sample,'diags_interp*'));
        interpPrecomp = fullfile(sampledir,sample,previnterpDir(1).name,'interp_precomputed.mat');
        if exist(interpPrecomp,'file')
            interptmpdir = [fullfile(dirOutput,'diags_interp_tmp') filesep];
            if ~exist(interptmpdir,'dir'); mkdir(interptmpdir); end
            copyfile(interpPrecomp,[fullfile(dirOutput,'diags_interp_tmp') filesep]);
        end
    end
    
    listInterp = selectFld;
    
    if strcmp(sampleType,'sample3')
        
        % Do the interpolation
        fnames = dir(fullfile(dirOutput,[subdirPrefix '0000'],[outputPrefix '*.data']));
        for i = 1:length(fnames)
            fparts = strsplit(fnames(i).name,'.');
            iStep = str2double(fparts{2});
            
            if isempty(dir([interpDir listInterp{end} filesep '*' fparts{2} '.meta'])) || doInterpForce % Skip if already interpolated
                for j = 1:length(listInterp)
                    iPtr = str2double(listInterp{j}(end-1:end));
                    if isnan(iPtr)
                        iPtr = 100 + 10*(double(listInterp{j}(end-1))-48) + double(listInterp{j}(end-1))-96;
                    end
                    fldfname = strjoin(fparts(1:2),'.');
                    fld = cs510readtiles(dirOutput,outputPrefix,iStep,iPtr);
                    %process2interp(dirOutput,outputPrefix,'',interpDir,diagnosticFile,listInterp(j),fld,fldfname);
                    process2interp(dirOutput,outputPrefix,listInterp(j),fld,fldfname);
                end
            else
                disp(['skipping ' fnames(i).name])
            end
        end
        
    else
        % Get list of interpolated names
        %[listInterp,listNot]=process2interp(dirOutput,outputPrefix);
        
        % Do the interpolation
        process2interp(dirOutput,outputPrefix,listInterp);
    end
    
    % Rename completed interpolated files directory
    movefile(fullfile(dirOutput,'diags_interp_tmp'),interpDir)
end


%% Write to NetCDF Files
if doNCtiles
    if ~exist(fullfile(interpDir,'available_diagnostics.log'),'file')
        copyfile(diagnosticFile,interpDir);
    end
    
    if ~exist(fullfile(interpDir,'README'),'file')
        copyfile(readmeFile,fullfile(interpDir,'README'));
    end
    
<<<<<<< HEAD
%     if ischar(selectFld) || strcmp(selectFld,'all')
%         selectFld=dir(interpDir); selectFld={selectFld(:).name};
%         jj = cellfun(@(x) contains(x,'TRAC'),selectFld);
%         selectFld={selectFld{jj}};
%     end
=======
>>>>>>> e28bae4a4da5a787707f128c60ce977e9eafa778
    
    interp2nctiles(interpDir,selectFld);
    
    %movefile(fullfile(interpDir,'nctiles_tmp'),fullfile(interpDir,'nctiles'))
    movefile(fullfile(interpDir,'nctiles_tmp'),nctileDir)
end
