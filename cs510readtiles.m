function [fld]=cs510readtiles(dirIn,filIn,iStep,iFld);
%[fld]=cs510readtiles(dirIn,filIn,iStep,iFld);
%e.g. [fld]=cs510readtiles('ptr/','_',72,21);

[dims,prec,tiles]=cs510readmeta(dirIn);
n1=tiles(1,2);
n2=tiles(1,4);
n3=dims(3);
recl3D=n1*n2*n3*4;
if strcmp(prec,'float64'); recl3D=2*recl3D; end;

fld=zeros(dims);
for iTile=1:size(tiles,1);
  fil=sprintf('res_%04d/%s.%010d',iTile-1,filIn,iStep);
  fil=dir([dirIn filesep fil '*']);
  %
  fid=fopen([fil.folder filesep fil.name],'r','b');
  status=fseek(fid,(iFld-1)*recl3D,'bof');
  tmp=reshape(fread(fid,n1*n2*n3,prec),[n1 n2 n3]);
  tmp(tmp==0)=NaN;
  fclose(fid);
  %
  ii=[tiles(iTile,1):tiles(iTile,2)];
  jj=[tiles(iTile,3):tiles(iTile,4)];
  fld(ii,jj,:)=tmp;
end;
fld=convert2gcmfaces(fld);

