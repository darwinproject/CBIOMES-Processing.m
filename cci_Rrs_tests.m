function []=cci_Rrs_tests();

gcmfaces_global; if isempty(mygrid); error('please load llc90 grid'); end;

%% test 1: single spectrum case

wv_cci=[412, 443, 490, 510, 555, 670];
wv_drwn3=[400,425,450,475,500,525,550,575,600,625,650,675,700];

Rirr              = 1e-3*[23.7641,26.5037,27.9743,30.4914,28.1356,21.9385,18.6545,13.5100,5.6338,3.9272,2.9621,2.1865,1.8015];
ttmp=Rirr/3;
Rirr_convert      = (0.52*ttmp)./(1-1.7*ttmp);
Rirr_interp       = interp1(wv_drwn3,Rirr_convert,wv_cci);

%starting point (Rirr, 13 bands):
%1e-3 * 
% 23.7641
% 26.5037
% 27.9743
% 30.4914
% 28.1356
% 21.9385
% 18.6545
% 13.5100
%  5.6338
%  3.9272
%  2.9621
%  2.1865
%  1.8015

%After conversion:
%1e-3 *
%  4.1753
%  4.6640
%  4.9270
%  5.3781
%  4.9558
%  3.8505
%  3.2680
%  2.3598
%  0.9796
%  0.6822
%  0.5143
%  0.3795
%  0.3126

%After interpolation:
%1e-3 *
%  4.4099
%  4.8533
%  5.1247
%  4.5137
%  3.0864
%  0.4064

%% test 2: visual comparison between maps

dir0=[pwd '/201805-CBIOMES-climatology/nctiles/'];
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

FLD=NaN*repmat(mygrid.RAC,[1 1 12 6]);
for kk=1:6;
    tmp0=fld(:,:,:,jj(kk)); tmp1=fld(:,:,:,jj(kk)+1);
    FLD(:,:,:,kk)=tmp0.*(1-ww(kk))+tmp1.*ww(kk);
end;

cc_from_BB=[25 17 8.2 8.2 8.0 2.3]*1e-3;

for kk=1:6;
    figureL; 
    tmp=FLD(:,:,1,kk); cc=cc_from_BB(kk);
    m_map_gcmfaces(tmp,1.2,{'myCaxis',cc*[0:0.1:1]},{'myCmap','inferno'});
    title(['201805-CBIOMES-climatology: annual mean rrs at ' num2str(wv_cci(kk))]);
%     print(gcf,'-dpng',['~/Desktop/rrs_' num2str(wv_cci(kk)) '_annualmean.png']);
end;

