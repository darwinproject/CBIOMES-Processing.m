%% Running Pipeline on sample* directories

% Put tools on path
p = genpath([pwd '/tools/']);
addpath(p);

% which sample directory
sampledir = 'DarwinModelOutputSamples';
sample = 'sample3';
diagnosticFile = fullfile(sampledir,'doc/available_diagnostics.log');
readmeFile = fullfile(sampledir,'README.md');
dirOutput = fullfile(sampledir,sample,'output/');
interpDir = fullfile(dirOutput,'diags_interp/');

switch sample
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
        disp('Not a valid sample directory name')
end

%% Read in the Grid
disp('Reading in the grid')

dirGrid = [fullfile(sampledir,sample,'grid') filesep];

gcmfaces_global;
if isempty(mygrid)
    fprintf(['loading grid from ' dirGrid '\n']);
    grid_load(dirGrid,nfaces,fileformat);
end

%% Interpolate Output
disp('Interpolating output files')

if ~exist(fullfile(dirOutput,'available_diagnostics.log'),'file')
    copyfile(diagnosticFile,dirOutput);
end

if strcmp(sample,'sample3')
    
    % Get list of interpolated names
    [listInterp,listNot]=process2interp(dirOutput,outputPrefix,'');
    
    % Do the interpolation
    fnames = dir(fullfile(dirOutput,[subdirPrefix '0000'],[outputPrefix '*.data']));
    for i = 1:length(fnames)
        fparts = strsplit(fnames(i).name,'.');
        iStep = str2double(fparts{2});
        
        [fld,fldfname] = readsample3(dirOutput,iStep);
        process2interp(dirOutput,outputPrefix,'',listInterp,fld,fldfname);
    end
    
else
    % Get list of interpolated names
    [listInterp,listNot]=process2interp(dirOutput,outputPrefix,'');
    
    % Do the interpolation
    process2interp(dirOutput,outputPrefix,'',listInterp);
end

% Rename completed interpolated files directory
movefile(fullfile(dirOutput,'diags_interp_tmp'),interpDir)
%% Write to NetCDF Files

if ~exist(fullfile(interpDir,'available_diagnostics.log'),'file')
    copyfile(diagnosticFile,interpDir);
end

if ~exist(fullfile(interpDir,'README'),'file')
    copyfile(readmeFile,fullfile(interpDir,'README'));
end

selectFld=dir(interpDir); selectFld={selectFld(:).name};
jj = cellfun(@(x) contains(x,'TRAC'),selectFld);
selectFld={selectFld{jj}};

interp2nctiles(interpDir,selectFld);

movefile(fullfile(interpDir,'nctiles_tmp'),fullfile(dirOutput,'nctiles'))

