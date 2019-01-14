function []=cci_Rrs_remap(dirIn,dirOut,yearVec);
% cci_Rrs_remap reads in OC-CCI data (netcdf files, sinusoidal grid),
%    remaps it to llc90 grid (using bin-average, binary file). 
%
%example:
% dirIn='monthly_sinusoidal/';
% dirOut='monthly_llc90/';
% yearVec=[2000 2001];
% cci_Rrs_remap(dirIn,dirOut,yearVec);

if isempty(which('gcmfaces')); p = genpath('gcmfaces/'); addpath(p); grid_load; end;

gcmfaces_global;

listVar={'Rrs_412','Rrs_443','Rrs_490','Rrs_510','Rrs_555','Rrs_670'};
prefIn='ESACCI-OC-L3S-OC_PRODUCTS-MERGED-1D_DAILY_4km_SIN_PML_OCx_QAA-';
%prefIn='ESACCI-OC-L3S-OC_PRODUCTS-MERGED-1M_MONTHLY_4km_SIN_PML_OCx_QAA-';
suffIn='-fv3.1.nc';
prefOut='OC_CCI_L3S_';
if isempty(dir(dirOut)); mkdir(dirOut); end;

for vv=listVar;
    for yy=yearVec;
        fprintf(['creating: ' prefOut vv{1} '_' num2str(yy) '\n']);

        fidOut=fopen([dirOut prefOut vv{1} '_' num2str(yy)],'w','b');
        fileList=dir([dirIn num2str(yy) filesep prefIn '*' suffIn]);
        fileList={fileList(:).name};
        nfil=length(fileList);
        for mm=1:nfil;
            if mod(mm,10)==0; fprintf(['  status: processing ' fileList{mm} ' ...\n']); end;            

            filIn=[dirIn num2str(yy) filesep fileList{mm}];
            ncload(filIn,'lon','lat',vv{1});
            fld=eval(vv{1});
            
            if isempty(whos('cci_loc'))||length(cci_loc.XC)~=length(lon);
                cci_loc=gcmfaces_loc_tile(90,90,lon,lat);
                %
                tmp00=convert2array(mygrid.RAC);
                m=prod(size(tmp00));
                n=length(lon);
                S = sparse(cci_loc.point,[1:n],ones(1,n),m,n);
            end;
            
            vec=double(fld)';
            msk=1*(vec<1e36&~isnan(vec));
            vec(msk==0)=0;
            
            tmp0=S*msk;
            tmp1=S*(msk.*vec);
            tmp1(tmp0>0)=tmp1(tmp0>0)./tmp0(tmp0>0);
            tmp1(tmp0==0)=NaN;
            
            tmp11=reshape(tmp1,size(tmp00));
            tmp2=convert2array(tmp11);
            
            fwrite(fidOut,convert2gcmfaces(tmp2),'float32');
        end;
        fclose(fidOut);
        fprintf(['Done with ' prefOut vv{1} '_' num2str(yy) '\n']);
    end;
end;


