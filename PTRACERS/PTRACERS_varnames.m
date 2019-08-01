function [varname]=PTRACERS_varnames(iTr);
% [varname]=PTRACERS_varnames(iTr);
%    if ~isempty(whos('iTr')); varname=PTRACERS_varnames{iTr}; else; varname=PTRACERS_varnames; end;

PTRACERS_varnames={};
for kk=1:99; PTRACERS_varnames={PTRACERS_varnames{:},sprintf('TRAC%02d',kk)}; end;
PTRACERS_varnames={PTRACERS_varnames{:},'TRAC0a','TRAC0b','TRAC0c','TRAC0d','TRAC0e','TRAC0f','TRAC0g'};

if ~isempty(whos('iTr'));
   varname=PTRACERS_varnames{iTr};
else;
   varname=PTRACERS_varnames;
end;


