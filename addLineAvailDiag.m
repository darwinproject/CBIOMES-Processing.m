function diagName = addLineAvailDiag(fname, diagName, levs, mate, code, units, title)
%addLineAvailDiag Adds a line containing information for newly created fields
%   This creates a new line in the available_diagnostics.log file for a new field.
%   Inputs:
%       fname: full path to file
%       diagName: the name of your new field/diagnostic (max 8 characters, otherwise will be truncated)
%       levs: integer number of levels
%       mate: diagnostic mate number (pass in empty array if none)
%       code: parser code for this diagnostic
%       units: field units for this diagnostic
%       title: field description for this diagnostic (max 80 characters)
%   Outputs:
%       diagName: diagName written to file
%   Usage:
%       diagName = addLineAvailDiag(diagnosticFile, 'Plk050', 1, [], 'SMR     M1', 'mmol C/', 'Average plankton concentration (top 50m)');

% First get max number used in file
fid=fopen(fname,'rt');
maxNum = 0;

diagName = sprintf('%-8s',diagName(1:min(8,length(diagName))));

while ~feof(fid)
    tline = fgetl(fid);
    
    if contains(tline,'|') && ~contains(tline,'  Num  |<-Name->|')
        if contains(tline, diagName)
            diagName = deblank(diagName);
            return
        end
        lineNum = str2double(tline(1:7));
        if lineNum > maxNum
            maxNum = lineNum;
        end
    end
end
fclose(fid);

gcmfaces_global;

% Create Line
diagNum = sprintf('% 6d ',maxNum+1);
levs = sprintf('% 3d ',levs);
if isempty(mate)
    mate = '       ';
else
    sprintf('% 7d ',mate); % If pass in pair should figure this out
end

code = code;%'SMR     M1';
units = sprintf('%-16s',units);%'mmol C/         ';
title = title(1:min(80,length(title)));

wline = [diagNum '|' diagName '|' levs '|' mate '|' code '|' units '|' title newline];

fid=fopen(fname,'a');
fwrite(fid,wline);
fclose(fid);

diagName = deblank(diagName);

end

