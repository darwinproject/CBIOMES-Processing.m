%% Running Pipeline on sample* directories
clear all


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
interpDir = [fullfile(sampledir,sample,'diags_interp_') datestr(now,'yyyymmdd_HHMM') filesep]; %'20190304_1659' filesep]; %
nctileDir = [fullfile(sampledir,sample,'nctiles_') datestr(now,'yyyymmdd_HHMM') filesep];
selectFld = {'biomass0to50ave','chl0to50ave'};

% Time Units
timeUntis = 'days since 1992-1-1 0:0:0';
dateStart = [1992 1 1];

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
    case 'sample3'
        outputPrefix = '_';
        nfaces = 6;
        fileformat = 'cube';
        subdirPrefix = 'res_';
        timeInterval = 3;
    otherwise
        disp('Not a valid sample type')
end

doNCtiles = 1;
doInterp = 1;
doInterpForce = 1;

%% Read in the Grid
disp('Reading in the grid')

%dirGrid = [fullfile(sampledir,sample,'grid') filesep];

gcmfaces_global;
if isempty(mygrid)
    fprintf(['loading grid from ' dirGrid '\n']);
    grid_load(dirGrid,nfaces,fileformat);
end

%% Calculate Additional Fields

if doInterp
    if strcmp(sampleType,'sample3')
        
        fnames = dir(fullfile(dirOutput,[subdirPrefix '0000'],[outputPrefix '*.data'])); % get filenames from one directory to determine time steps
        prefix = subdirPrefix;
    else
        fnames = dir(fullfile(dirOutput,[outputPrefix '*.data']));
        prefix = outputPrefix;
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
    
    % Add to Diags
    bioName = addLineAvailDiag(diagnosticFile, 'Plk050', 1, [], 'SMR     M1', 'mmol C/', 'Average plankton concentration (top 50m)');
    chlName = addLineAvailDiag(diagnosticFile, 'Chl050', 1, [], 'SMR     M1', 'mg Chl', 'Average chlorophyll concentration (top 50m)');
    selectFld = {bioName,chlName};
    
    disp('Calculating and interpolating Plk050 and Chl050')
    
    nsteps = length(fnames);
    
    if ~isempty(getenv('SLURM_ARRAY_TASK_ID')) % In slurm job array to parallelize selectFld
        taskID = getenv('SLURM_ARRAY_TASK_ID');
        numTasks = getenv('SLURM_ARRAY_TASK_COUNT');

        myidx = taskID:numTasks:nsteps;
    else
        myidx = 1:nsteps;
    end
    
    for i = myidx
        fparts = strsplit(fnames(i).name,'.');
        if isempty(dir([interpDir 'Chl050' filesep '*' fparts{2} '.meta'])) || doInterpForce % Skip if already interpolated
            
            iStep = str2double(fparts{2});
            savename = strjoin(fparts(1:2),'.');
            [biomass0to50ave,chl0to50ave] = calcTop50AveBiomass(dirOutput,prefix,iStep);
            
            % Save to Output
            saveDir = fullfile(dirOutput,'additionalFields');
            if ~isdir(saveDir); mkdir(saveDir); end;
            [dims,prec,tiles]=cs510readmeta(dirOutput);
            
            %write binary field (masked)
            write2file(fullfile(saveDir,[savename '.Plk050.data']),convert2vector(biomass0to50ave),32,0);
            write2file(fullfile(saveDir,[savename '.Chl050.data']),convert2vector(chl0to50ave),32,0);
            
            %create meta file
            write2meta(fullfile(saveDir,[savename '.Plk050.data']),dims(1:2),32,{'Plk050'});
            write2meta(fullfile(saveDir,[savename '.Chl050.data']),dims(1:2),32,{'Chl050'});
            
            % Interpolate
            fldfname = strjoin(fparts(1:2),'.');
            process2interp(dirOutput,outputPrefix,{bioName},biomass0to50ave,fldfname);
            fldfname = strjoin(fparts(1:2),'.');
            process2interp(dirOutput,outputPrefix,{chlName},biomass0to50ave,fldfname);
            
            if ~exist(fullfile(interpDir,'Plk050'),'dir'); mkdir(fullfile(interpDir,'Plk050')); end
            if ~exist(fullfile(interpDir,'Chl050'),'dir'); mkdir(fullfile(interpDir,'Chl050')); end
            
            system(['mv ' dirOutput filesep 'diags_interp_tmp/Plk050/* ' fullfile(interpDir,'Plk050')]);
            system(['mv ' dirOutput filesep 'diags_interp_tmp/Chl050/* ' fullfile(interpDir,'Chl050')]);
        else
            disp(['skipping ' fnames(i).name])
        end
    end
    
    clear biomass0to50ave chl0to50ave
    
    % Rename completed interpolated files directory
    movefile(fullfile(dirOutput,'diags_interp_tmp'),interpDir)
    
else
    
    bioName = addLineAvailDiag(diagnosticFile, 'Plk050', 1, [], 'SMR     M1', 'mmol C/', 'Average plankton concentration (top 50m)');
    chlName = addLineAvailDiag(diagnosticFile, 'Chl050', 1, [], 'SMR     M1', 'mg Chl', 'Average chlorophyll concentration (top 50m)');
    selectFld = {bioName,chlName};
end

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
    
    system(['mv ' fullfile(interpDir,'nctiles_tmp','Plk050') ' ' nctileDir '/']);
    system(['mv ' fullfile(interpDir,'nctiles_tmp','Chl050') ' ' nctileDir '/']);
    
end