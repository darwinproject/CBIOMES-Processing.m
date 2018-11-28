%% Running Pipeline on sample* directories

% Put tools on path
p = genpath([pwd '/../']);
addpath(p);

% which sample directory
sampledir = 'DarwinModelOutputSamples';
sampleType = 'sample3';
sample = 'sample3';
diagnosticFile = fullfile(sampledir,'doc/available_diagnostics.log');
readmeFile = fullfile(sampledir,'README.md');
dirGrid = [fullfile(sampledir,sampleType,'grid') filesep];
dirOutput = fullfile(sampledir,sample,'output/');
interpDir = fullfile(dirOutput,'diags_interp/');
selectFld = {'TRAC21'};

% Which part of processing to do
doInterp = 0;
doNCtiles = 1;
iterateOverFiles = 0;

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

%% Read in the Grid
disp('Reading in the grid')

%dirGrid = [fullfile(sampledir,sample,'grid') filesep];

gcmfaces_global;
if isempty(mygrid)
    fprintf(['loading grid from ' dirGrid '\n']);
    grid_load(dirGrid,nfaces,fileformat);
end

%% Interpolate Output
if doInterp
    disp('Interpolating output files')
    
    if ~exist(fullfile(dirOutput,'available_diagnostics.log'),'file')
        copyfile(diagnosticFile,dirOutput);
    end
    
    if strcmp(sampleType,'sample3')
        
        % Get list of interpolated names
        if ischar(selectFld) || strcmp(selectFld,'all')
            [listInterp,listNot]=process2interp(dirOutput,outputPrefix,'',interpDir,diagnosticFile);
        else
            listInterp = selectFld;
        end
        
        % Do the interpolation
        fnames = dir(fullfile(dirOutput,[subdirPrefix '0000'],[outputPrefix '*.data']));
        for i = 1:length(fnames)
            fparts = strsplit(fnames(i).name,'.');
            iStep = str2double(fparts{2});
            
            if isempty(dir([interpDir listInterp{end} filesep '*' fparts{2} '.meta'])) % Skip if already interpolated
                
                [fld,fldfname] = readsample3(dirGrid,dirOutput,iStep);
                process2interp(dirOutput,outputPrefix,'',interpDir,diagnosticFile,listInterp,fld,fldfname);
            else
                disp(['skipping ' fnames(i).name])
            end
        end
        
    else
        % Get list of interpolated names
        [listInterp,listNot]=process2interp(dirOutput,outputPrefix,'');
        
        % Do the interpolation
        process2interp(dirOutput,outputPrefix,'',listInterp);
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
    
    if ischar(selectFld) || strcmp(selectFld,'all')
        selectFld=dir(interpDir); selectFld={selectFld(:).name};
        jj = cellfun(@(x) contains(x,'TRAC'),selectFld);
        selectFld={selectFld{jj}};
    end
    
    interp2nctiles(interpDir,selectFld,iterateOverFiles);
    
    movefile(fullfile(interpDir,'nctiles_tmp'),fullfile(interpDir,'nctiles'))
    %movefile(fullfile(interpDir,'nctiles_tmp'),fullfile(dirOutput,'nctiles'))
end
