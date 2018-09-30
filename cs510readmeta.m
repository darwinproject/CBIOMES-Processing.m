function [dims,prec,tiles]=cs510readmeta(dirMeta);
%[dims,prec,tiles]=cs510readmeta(dirMeta);

%%read lines
fid=fopen([dirMeta filesep '_.meta'],'rt');
while 1;
    tline = fgetl(fid);
    if ~ischar(tline), break, end
    if isempty(whos('tmp3')); tmp3=tline; else; tmp3=[tmp3 ' ' tline]; end;
end
fclose(fid);

%%evaluate
eval(tmp3);

%%format output
tiles=reshape(tiles,[7 300]);
tiles=cell2mat(tiles(3:6,:))';
dims=reshape(dimList,[3 3]);
dims=dims(1,:);
prec=dataprec;

