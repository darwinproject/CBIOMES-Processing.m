
dirIn=[pwd '/diags_trsp/']; list0=dir([dirIn 'trsp_3d_set1*.data']);

if isempty(whos('MGtoIG'));
p = genpath('gcmfaces/'); addpath(p);
grid_load; gcmfaces_global;

lat=linspace(20,50,60); lon=linspace(-230,-130,200);
[lat,lon]=meshgrid(lat,lon);

interp=gcmfaces_interp_coeffs(lon(:),lat(:));
MGtoIG.gridName='llc90';
MGtoIG.lon=lon;
MGtoIG.lat=lat;
MGtoIG.matrix=interp.SPM;
end;

dirOut=[dirIn(1:end-1) '_maps/'];
if ~isdir(dirOut); mkdir(dirOut); end;

for ii=1:length(list0);
disp(ii);
%
fld=read_bin([dirIn list0(ii).name]);
nfld=size(fld{1},3)/50;
fldU=fld(:,:,1);
fldV=fld(:,:,1+50);
[fldUe,fldVn]=calc_UV_zonmer(fldU,fldV);
nfld=2; fld=cat(3,fldUe,fldVn);
fld=fld.*repmat(mygrid.mskC(:,:,1),[1 1 nfld]);
%
tmp1=convert2vector(fld);
[tmp0,s3]=size(tmp1);
tmp0=1*~isnan(tmp1);
tmp1(isnan(tmp1))=0;
%
tmp0=MGtoIG.matrix*tmp0;
tmp1=MGtoIG.matrix*tmp1;
maps=reshape(tmp1./tmp0,[size(MGtoIG.lon) s3]);
%
save([dirOut list0(ii).name(1:end-5) '.mat'],'maps','lon','lat');
end;






