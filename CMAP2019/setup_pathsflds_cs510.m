%% Dirs

% which sample directory
sampledir = 'data/';
sampleType = 'cs510';
diagnosticFile = fullfile(sampledir,'available_diagnostics.log');
readmeFile = fullfile(sampledir,sampleType,'README');
dirGrid = [fullfile(sampledir,sampleType,'grid') filesep];

dirOutput_pat = [fullfile(sampledir,sampleType,'sample') filesep];
linkDir_pat = [fullfile(sampledir,sampleType,'sample','sample') filesep];
dirNewFld_pat = [fullfile(sampledir,sampleType,'sample','newflds') filesep];

precomp_interp_dir = fullfile(sampledir,sampleType,'precomp_interp','halfdeg');

interpDir_pat = [fullfile(sampledir,sampleType,'diags_interp','group')  filesep];
nctileDir_pat = [fullfile(sampledir,sampleType,'nctiles','group') filesep];


%% Time Units
timeUnits = 'days since 1992-1-1 0:0:0';
dateStart = [1992 1 1];

%% Force interpolation if already done
doInterpForce = 0;

%% Group 1: Nutrients
group(1).name = 'Nutrients';

% Fields
group(1).fields = {'TRAC05','TRAC07','TRAC06','TRAC19'};
group(1).source = 'ptr';

% DIN
group(1).newfld(1).flds = 2:4;%{'TRAC04','TRAC03','TRAC02'};
group(1).newfld(1).source = 'ptr';
group(1).newfld(1).operation = 'sum';
group(1).newfld(1).rename = 'DIN';
group(1).newfld(1).levs = 50;
group(1).newfld(1).mate = [];
group(1).newfld(1).code = 'SMR     MR';% parser code for this diagnostic
group(1).newfld(1).units= 'mmol C/';% field units for this diagnostic
group(1).newfld(1).title= 'Sum of NO3, NO2, NH4';% field description for this diagnostic (max 80 characters)

%% Group 2: Bulk Ecosystem Characteristics
group(2).name = 'Bulk_Ecosystem_Characteristcs';

% Fields
group(2).fields = {'PP'};
group(2).source = 'gud';

% Total Chl
group(2).newfld(1).flds = 72:106;
group(2).newfld(1).source = 'ptr';
group(2).newfld(1).operation = 'sum';
group(2).newfld(1).rename = 'ChlTotal';
group(2).newfld(1).levs = 50;
group(2).newfld(1).mate = [];
group(2).newfld(1).code = 'SMR     MR';% parser code for this diagnostic
group(2).newfld(1).units= 'mg Chl/m^3';% field units for this diagnostic
group(2).newfld(1).title= 'Total Chl Concentration';% field description for this diagnostic (max 80 characters)

% Total Phyto Biomass
group(2).newfld(2).flds = 21:55;
group(2).newfld(2).source = 'ptr';
group(2).newfld(2).operation = 'sum';
group(2).newfld(2).rename = 'PhyTotal';
group(2).newfld(2).levs = 50;
group(2).newfld(2).mate = [];
group(2).newfld(2).code = 'SMR     MR';% parser code for this diagnostic
group(2).newfld(2).units= 'mmol C/m^3';% field units for this diagnostic
group(2).newfld(2).title= 'Total Phytoplankton Concentration';% field description for this diagnostic (max 80 characters)

% Total Zooplankton Biomass
group(2).newfld(3).flds = 56:71;
group(2).newfld(3).source = 'ptr';
group(2).newfld(3).operation = 'sum';
group(2).newfld(3).rename = 'ZooTotal';
group(2).newfld(3).levs = 50;
group(2).newfld(3).mate = [];
group(2).newfld(3).code = 'SMR     MR';% parser code for this diagnostic
group(2).newfld(3).units= 'mmol C/m^3';% field units for this diagnostic
group(2).newfld(3).title= 'Total Zooplankton Concentration';% field description for this diagnostic (max 80 characters)

% Shannon Index Phytoplankton
group(2).newfld(4).flds = 21:55;
group(2).newfld(4).source = 'ptr';
group(2).newfld(4).operation = 'shannon';
group(2).newfld(4).rename = 'PhyShann';
group(2).newfld(4).levs = 50;
group(2).newfld(4).mate = [];
group(2).newfld(4).code = 'SMR     MR';% parser code for this diagnostic
group(2).newfld(4).units= '';% field units for this diagnostic
group(2).newfld(4).title= 'Phytoplankton diversity (shannon index)';% field description for this diagnostic (max 80 characters)

% Primary Production- Full depth Integral
group(2).newfld(5).flds = {'PP'};
group(2).newfld(5).source = 'gud';
group(2).newfld(5).operation = 'integral-full';
group(2).newfld(5).rename = 'PPfull';
group(2).newfld(5).levs = 1;
group(2).newfld(5).mate = [];
group(2).newfld(5).code = 'SM P    M1';% parser code for this diagnostic
group(2).newfld(5).units= 'mmol C/m^2/s ';% field units for this diagnostic
group(2).newfld(5).title= 'Primary Production full depth integral';% field description for this diagnostic (max 80 characters)


%% Group 3
group(3).name = 'Phytoplankton_Functional_Types';

% Fields
group(3).fields = {};
group(3).source = 'ptr';

% Pico-prokaryote biomass 
group(3).newfld(1).flds = 21:22;%{'TRAC21','TRAC22'};
group(3).newfld(1).source = 'ptr';
group(3).newfld(1).operation = 'sum';
group(3).newfld(1).rename = 'PicoPro';
group(3).newfld(1).levs = 50;
group(3).newfld(1).mate = [];
group(3).newfld(1).code = 'SMR     MR';% parser code for this diagnostic
group(3).newfld(1).units= 'mmol C/m^3';% field units for this diagnostic
group(3).newfld(1).title= 'Total Pico-Prokaryote Concentration';% field description for this diagnostic (max 80 characters)

% Pico-eukaryote biomass 
group(3).newfld(2).flds = 23:24;%{'TRAC23','TRAC24'};
group(3).newfld(2).source = 'ptr';
group(3).newfld(2).operation = 'sum';
group(3).newfld(2).rename = 'PicoEu';
group(3).newfld(2).levs = 50;
group(3).newfld(2).mate = [];
group(3).newfld(2).code = 'SMR     MR';% parser code for this diagnostic
group(3).newfld(2).units= 'mmol C/m^3';% field units for this diagnostic
group(3).newfld(2).title= 'Total Pico-Eukaryote Concentration';% field description for this diagnostic (max 80 characters)

% Coccolithophore biomass 
group(3).newfld(3).flds = 25:29;%{'TRAC25','TRAC26','TRAC27','TRAC28','TRAC29'};
group(3).newfld(3).source = 'ptr';
group(3).newfld(3).operation = 'sum';
group(3).newfld(3).rename = 'Cocco';
group(3).newfld(3).levs = 50;
group(3).newfld(3).mate = [];
group(3).newfld(3).code = 'SMR     MR';% parser code for this diagnostic
group(3).newfld(3).units= 'mmol C/m^3';% field units for this diagnostic
group(3).newfld(3).title= 'Total Coccolithophore Concentration';% field description for this diagnostic (max 80 characters)

% Diazotroph biomass 
group(3).newfld(4).flds = 30:34;%{'TRAC30','TRAC31','TRAC32','TRAC33','TRAC34'};
group(3).newfld(4).source = 'ptr';
group(3).newfld(4).operation = 'sum';
group(3).newfld(4).rename = 'Diazo';
group(3).newfld(4).levs = 50;
group(3).newfld(4).mate = [];
group(3).newfld(4).code = 'SMR     MR';% parser code for this diagnostic
group(3).newfld(4).units= 'mmol C/m^3';% field units for this diagnostic
group(3).newfld(4).title= 'Total Diazotroph Concentration';% field description for this diagnostic (max 80 characters)

% Diatom biomass 
group(3).newfld(4).flds = 35:45;%{'TRAC35','TRAC36','TRAC37','TRAC38','TRAC39','TRAC40','TRAC41','TRAC42','TRAC43','TRAC44','TRAC45'};
group(3).newfld(4).source = 'ptr';
group(3).newfld(4).operation = 'sum';
group(3).newfld(4).rename = 'Diatom';
group(3).newfld(4).levs = 50;
group(3).newfld(4).mate = [];
group(3).newfld(4).code = 'SMR     MR';% parser code for this diagnostic
group(3).newfld(4).units= 'mmol C/m^3';% field units for this diagnostic
group(3).newfld(4).title= 'Total Diatom Concentration';% field description for this diagnostic (max 80 characters)

% Mixotrophic dinoflagellate biomass 
group(3).newfld(5).flds = 46:55;%{'TRAC46','TRAC47','TRAC48','TRAC49','TRAC50','TRAC51','TRAC52','TRAC53','TRAC54','TRAC55'};
group(3).newfld(5).source = 'ptr';
group(3).newfld(5).operation = 'sum';
group(3).newfld(5).rename = 'MixDino';
group(3).newfld(5).levs = 50;
group(3).newfld(5).mate = [];
group(3).newfld(5).code = 'SMR     MR';% parser code for this diagnostic
group(3).newfld(5).units= 'mmol C/m^3';% field units for this diagnostic
group(3).newfld(5).title= 'Total Mixotrophic dinoflagellate concentration';% field description for this diagnostic (max 80 characters)

%% Group 4
group(4).name = 'Ocean_Color';

% Fields
group(4).fields = {'Rirr003','Rirr007'};
group(4).source = 'surf';

% No new fields for group 4
group(4).newfld = {};

%% Combine into a table for easy iteration
fldTbl = table('Size',[0,11],'VariableNames',{'group','group_name','field','source','sourcefields','operation','levs','mate','code','units','title'},...
    'VariableTypes',{'double','cellstr','cellstr','cellstr','cellstr','cellstr','double','double','cellstr','cellstr','cellstr'});

for i = 1:length(group)
    for j = 1:length(group(i).fields)
        fldTbl = [fldTbl; cell2table({i,group(i).name,group(i).fields{j},group(i).source,{},{},[],[],{},{},{}},...
            'VariableNames',{'group','group_name','field','source','sourcefields','operation','levs','mate','code','units','title'})];
    end
    for j = 1:length(group(i).newfld)
        fldTbl = [fldTbl; cell2table({i,group(i).name,group(i).newfld(j).rename,group(i).newfld(j).source,{group(i).newfld(j).flds},...
            group(i).newfld(j).operation,group(i).newfld(j).levs,group(i).newfld(j).mate,group(i).newfld(j).code,...
            group(i).newfld(j).units,group(i).newfld(j).title},...
            'VariableNames',{'group','group_name','field','source','sourcefields','operation','levs','mate','code','units','title'})];
    end
end