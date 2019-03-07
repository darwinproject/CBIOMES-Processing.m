%% Running Pipeline on sample* directories

% Put tools on path
p = genpath([pwd '/../']);
addpath(p);

% which sample directory
samplebase = '../../DarwinModelOutputSamples/';
sampleType = 'sample3';
sample = 'ptr';
sampledir = fullfile(samplebase,sample);
diagnosticFile = fullfile(sampledir,'available_diagnostics.log');
readmeFile = fullfile(samplebase,'README.md');
dirGrid = [fullfile(samplebase,sampleType,'grid') filesep];
dirOutput = [fullfile(sampledir,'output') filesep];
interpDir = fullfile(sampledir,'diags_interp/');
selectFld = {'biomass0to50ave','chl0to50ave'};

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
        iterateOverFiles = 1;
    otherwise
        disp('Not a valid sample type')
end

latlon1D = 1;
doNCtiles = 1;
doInterp = 0;
doInterpForce = 0;

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
    
    % Add to Diags
    bioName = addLineAvailDiag(diagnosticFile, 'Plk050', 1, [], 'SMR     M1', 'mmol C/', 'Average plankton concentration (top 50m)');
    chlName = addLineAvailDiag(diagnosticFile, 'Chl050', 1, [], 'SMR     M1', 'mg Chl', 'Average chlorophyll concentration (top 50m)');
    selectFld = {bioName,chlName};
    
    disp('Calculating and interpolating Plk050 and Chl050')
    
    if ~isempty(getenv('SLURM_ARRAY_TASK_ID')) % In slurm job array to parallelize selectFld
        taskID = getenv('SLURM_ARRAY_TASK_ID');
        numTasks = getenv('SLURM_ARRAY_TASK_COUNT');

        myidx = taskID:numTasks:length(fnames);
    else
        myidx = 1:length(fnames);
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
            process2interp(dirOutput,outputPrefix,'',interpDir,diagnosticFile,{bioName},biomass0to50ave,fldfname);
            fldfname = strjoin(fparts(1:2),'.');
            process2interp(dirOutput,outputPrefix,'',interpDir,diagnosticFile,{chlName},biomass0to50ave,fldfname);
        else
            disp(['skipping ' fnames(i).name])
        end
    end
    
    clear biomass0to50ave chl0to50ave
    
else
    
    bioName = addLineAvailDiag(diagnosticFile, 'Plk050', 1, [], 'SMR     M1', 'mmol C/', 'Average plankton concentration (top 50m)');
    chlName = addLineAvailDiag(diagnosticFile, 'Chl050', 1, [], 'SMR     M1', 'mg Chl', 'Average chlorophyll concentration (top 50m)');
    selectFld = {bioName,chlName};
end

%% Write Interp to NCtiles

if doNCtiles
    
    copyfile(diagnosticFile,interpDir);
    
    if ~exist(fullfile(interpDir,'README'),'file')
        copyfile(readmeFile,fullfile(interpDir,'README'));
    end
    
    
    interp2nctiles(interpDir,selectFld);
    
    system(['mv ' fullfile(interpDir,'nctiles_tmp','Plk050') ' ' fullfile(sampledir,'nctiles') '/']);
    system(['mv ' fullfile(interpDir,'nctiles_tmp','Chl050') ' ' fullfile(sampledir,'nctiles') '/']);
    
    %movefile(fullfile(interpDir,'nctiles_tmp','Plk050'),fullfile(sampledir,'nctiles'))
    %movefile(fullfile(interpDir,'nctiles_tmp','Chl050'),fullfile(sampledir,'nctiles'))
    %movefile(fullfile(interpDir,'nctiles_tmp'),fullfile(dirOutput,'nctiles'))
end