function []=eccov4_climplot(jj);

global dirOut dirIn; 
%dirIn='./';
%dirOut='./';
extOut='';

kk=[];
if jj==1; nm='MXLDEPTH'; cc=[0:10:200];
elseif jj==2; nm='ETAN'; cc=[-0.5:0.05:0.5];
elseif jj==11; nm='MXLDEPTH'; cc=[0:20:400]; mon=3;
elseif jj==12; nm='THETA'; cc=[2:22]; mon=3; kk=20; dep='300';
elseif jj==13; nm='SALT'; cc=[32:0.1:35]; mon=3; kk=20; dep='300';
elseif jj==14; nm='NVELMASS'; cc=[-1:0.1:1]/10; mon=3; kk=20; dep='300';
elseif jj==15; nm='EVELMASS'; cc=[-1:0.1:1]/10; mon=3; kk=20; dep='300';
elseif jj==16; nm='NVELMASS'; cc=[-1:0.1:1]/10; mon=3; kk=1; dep='5';
elseif jj==17; nm='EVELMASS'; cc=[-1:0.1:1]/10; mon=3; kk=1; dep='5';
elseif jj==18; nm='NVELMASS'; cc=[-1:0.1:1]/10; mon=9; kk=1; dep='5';
elseif jj==19; nm='EVELMASS'; cc=[-1:0.1:1]/10; mon=9; kk=1; dep='5';
elseif jj==-1; nm='THETA'; cc=[2:1:22]; mon=3;
elseif jj==-2; nm='THETA'; cc=[2:1:22]; mon=9;
elseif jj==-3; nm='SALT'; cc=[32:0.1:35]; mon=3;
elseif jj==-4; nm='SALT'; cc=[32:0.1:35]; mon=9;
end;

if isempty(kk);
    fld=read_nctiles([dirIn nm '/' nm]);
else;
    fld=read_nctiles([dirIn nm '/' nm],nm,[],kk);
end;

[LO,LA,sctn,X,Y]=gcmfaces_section([-158 -158],[-89 90],fld);

if jj>0&jj<10; 
    [X,Y]=meshgrid(LA,[-11:24]); Z=[sctn sctn sctn]'; aa=[20 55 0 12];
    filOut=[nm '_timlat'];
elseif jj<0;
    Z=sctn(:,:,mon); aa=[20 55 -300 0];
    filOut=[nm '_deplat_mon' num2str(mon)];
elseif jj==11;
    filOut=[nm '_lonlat_mon' num2str(mon)];
elseif jj>=12;
    filOut=[nm '_lonlat_mon' num2str(mon) '_dep' num2str(dep)];
end;

if jj<10;
    figureL; contourf(X,Y,Z,cc); axis(aa); caxis([cc(1) cc(end)]); colorbar;
else;
    figureL; m_map_gcmfaces(fld(:,:,mon),4.9,{'myCaxis',cc})
end;

eval(['print -djpeg90 ' dirOut filOut extOut  '.jpg;']);
