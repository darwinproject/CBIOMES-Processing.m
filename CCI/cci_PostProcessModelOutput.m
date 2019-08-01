function []=cci_PostProcessModelOutput();

gcmfaces_global;

list0=dir('monthly_model/surf_2d_set1.*.data');
tt=zeros(1,length(list0));
for ii=1:length(tt);
    tmp1=list0(ii).name(14:end-5);
    tt(ii+1)=str2num(tmp1);
end;

tt=datenum(1992,1,1)+0.5*(tt(1:end-1)+tt(2:end))/24;

% gud_waveband_centers = [400.,425.,450.,475.,500,525,550,575,600,625,650,675,700.]
% New_wavebands        = [412.,443.,490.,510.,555.,670.]

%input variables
wv_drwn3=[400,425,450,475,500,525,550,575,600,625,650,675,700];
nIn=14; 

%output variables:
listOut={'Rrs_412','Rrs_443','Rrs_490','Rrs_510','Rrs_555','Rrs_670'};
wv_cci=[412, 443, 490, 510, 555, 670];
nOut=6;

%coefficients to interpolate to new waveband centers:
tmp1=interp1(wv_drwn3,[1:13],wv_cci);
jj=floor(tmp1); ww=tmp1-jj;

%main loop
mm=0;
dirOut='daily_model/';
for yy=1992:2011;
    display(yy)
    tic;
    nd=datenum(yy+1,1,1)-datenum(yy,1,1);
    for vv=1:nOut;
        fid(vv)=fopen([dirOut listOut{vv} '_' num2str(yy)],'w','b');
    end;
    for dd=1:nd;
        tcur=datenum(yy,1,1,12,0,0)+dd-1;
        nn=max(find(tt(1:end-1)<=tcur&tt(2:end)>tcur));
        if ~isempty(nn);
            if nn~=mm;
                mm=nn;
                fld0=read_bin(['monthly_model/' list0(mm).name]);
                fld1=read_bin(['monthly_model/' list0(mm+1).name]);                
            end;
            tmp0=(tcur-tt(nn))/(tt(nn+1)-tt(nn));
            fld=(1-tmp0)*fld0+tmp0*fld1;           
        else;
            fld=NaN*repmat(mygrid.XC,[1 1 nIn]);
        end;
        fld=fld(:,:,2:end);
        fld=fld/3;
        fld=(0.52*fld)./(1-1.7*fld);
        for vv=1:nOut;
            tmp0=fld(:,:,jj(vv)); tmp1=fld(:,:,jj(vv)+1);
            fldOut=tmp0.*(1-ww(vv))+tmp1.*ww(vv);
            fwrite(fid(vv),convert2gcmfaces(fldOut),'float32');
        end;
    end;
    for vv=1:nOut; fclose(fid(vv)); end;
    toc;
end;

display([yy dd mm])


    


