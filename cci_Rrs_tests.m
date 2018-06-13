

dir0='201805-CBIOMES-climatology/nctiles/';
list0=dir([dir0 'IrradianceReflectance/']);
ii = find(strncmp({list0(:).name},'Rirr',4));

fld=NaN*repmat(mygrid.RAC,[1 1 12 13]);
for jj=1:13;
    tmp=list0(ii(jj)).name;
    fld(:,:,:,jj)=read_nctiles([dir0 'IrradianceReflectance/' tmp '/' tmp]);
end;

ttmp=fld/3;
fld=(0.52*ttmp)./(1-1.7*ttmp);

wv_cci=[412, 443, 490, 510, 555, 670];
wv_drwn3=[400,425,450,475,500,525,550,575,600,625,650,675,700];

tmp1=interp1(wv_drwn3,[1:13],wv_cci);
jj=floor(tmp1); ww=tmp1-jj;

wv_drwn3(jj).*(1-ww)+wv_drwn3(jj+1).*ww

FLD=NaN*repmat(mygrid.RAC,[1 1 12 13]);
for kk=1:6;
    tmp0=fld(:,:,:,jj(kk)); tmp1=fld(:,:,:,jj(kk)+1);
    FLD(:,:,:,kk)=tmp0.*(1-ww(kk))+tmp1.*ww(kk);
end;

for kk=1:6;
    figureL; 
    tmp=mean(FLD(:,:,:,kk),3); cc=1e-3*ceil(nanmax(tmp)*1e3);
    m_map_gcmfaces(tmp,1.2,{'myCaxis',cc*[0:0.1:1]},{'myCmap','inferno'});
    title(['201805-CBIOMES-climatology: annual mean rrs at ' num2str(wv_cci(kk))]);
    print(gcf,'-dpng',['~/Desktop/rrs_' num2str(wv_cci(kk)) '_annualmean.png']);
end;

