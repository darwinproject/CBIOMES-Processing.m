%userStep is set in basic_diags_ecco in 'gudA' blocs
%this routine is by choice not a function, in
%order to have access to entire workspace)

if ~strcmp(setDiags,'gudA')
    error(['unknown setDiags ' setDiags]);
end;

%%%%%%%%%%%%%%%%%%TEMPLATE%%%%%%%%%%%%%%%%%%%

if strcmp(setDiags,'gudA')&userStep==1;%diags to be computed
    listDiags='ppZm ppTop50m pp158W ppNorth ppSouth ppGlo';
end;

if strcmp(setDiags,'gudA')&userStep==2;%input files and variables
    listFlds={'PP'};
    listFldsNames=deblank(listFlds);
    listFiles={'gud_3d_set1'};
    listSubdirs={[dirModel 'diags/']};
end;

if strcmp(setDiags,'gudA')&userStep==3;%computational part;
    %preliminary steps:
    nl=length(mygrid.LATS);
    nr=length(mygrid.RC);
    w50m=mk3D(mygrid.DRF,mygrid.mskC).*repmat(mygrid.RAC,[1 1 nr]);
    w50m=w50m.*mygrid.hFacC; w50m(:,:,6:end)=NaN;
    volNorth=mk3D(mygrid.DRF,mygrid.mskC).*mygrid.hFacC.*mk3D(mygrid.RAC.*(mygrid.YC>0),mygrid.mskC);
    volSouth=mk3D(mygrid.DRF,mygrid.mskC).*mygrid.hFacC.*mk3D(mygrid.RAC.*(mygrid.YC<0),mygrid.mskC);
    volGlo=mk3D(mygrid.DRF,mygrid.mskC).*mygrid.hFacC.*mk3D(mygrid.RAC,mygrid.mskC);;

    ppZm=zeros(nl,nr,1); ppTop50m=repmat(0*mygrid.Depth,[1 1 1]); pp158W=zeros(321,nr,1);
    ppNorth=zeros(nr,1); ppSouth=zeros(nr,1); ppGlo=zeros(nr,1);
    kk=1;
    %
    fld=eval(listFlds{kk});
    ppZm(:,:,kk)=calc_zonmean_T(fld);
    %
    ppTop50m(:,:,kk)=nansum(w50m.*fld,3)./nansum(w50m,3);
    %
    [LO,LA,tmp1,X,Y]=gcmfaces_section([-158 -158],[-89 90],fld);
    pp158W(:,:,kk)=tmp1;
    %
    ppNorth(:,kk)=nansum(volNorth.*fld,0)./nansum(volNorth,0);
    ppSouth(:,kk)=nansum(volSouth.*fld,0)./nansum(volSouth,0);
    ppGlo(:,kk)=nansum(volGlo.*fld,0)./nansum(volGlo,0);
    %
end;

if strcmp(setDiags,'gudA')&userStep==-1;%plotting

    if isempty(setDiagsParams);
        choicePlot={'all'};
    else;
        choicePlot=setDiagsParams;
    end;

    %determine number of years in alldiag.listTimes
    myTimes=alldiag.listTimes;
    %determine the number of records in one year (lYear)
    tmp1=mean(myTimes(2:end)-myTimes(1:end-1));
    lYear=round(1/tmp1);
    %in case when lYear<2 we use records as years
    if ~(lYear>=2); lYear=1; myTimes=[1:length(myTimes)]; end;
    %determine the number of full years (nYears)
    nYears=floor(length(myTimes)/lYear);

    if (sum(strcmp(choicePlot,'all'))|sum(strcmp(choicePlot,'ppTop50mSeason')));
        if addToTex; write2tex(fileTex,1,'fill in appropriate section title here',2); end;
        cc=[0 1e-5];
        nrec=1+diff(myparms.recInAve);
        for mm=1:12;
            fld=mean(alldiag.ppTop50m(:,:,mm:12:nrec),3);
            figureL; m_map_gcmfaces(fld,1.2,{'myCaxis',cc},{'myCmap','inferno'});
            myCaption={'fill in appropriate figure caption here'};
            if addToTex; write2tex(fileTex,2,myCaption,gcf); end;
        end;
    end;

    if (sum(strcmp(choicePlot,'all'))|sum(strcmp(choicePlot,'pp158Wseason')));
        if addToTex; write2tex(fileTex,1,'fill in appropriate section title here',2); end;
        [LO,LA,tmp1,X,Y]=gcmfaces_section([-158 -158],[-89 90],mygrid.hFacC);
        cc=[0 1e-5];
        nrec=1+diff(myparms.recInAve);
        for mm=1:12;
            fld=mean(alldiag.pp158W(:,:,mm:12:nrec),3);
            figureL; set(gcf,'Renderer','zbuffer'); pcolor(X,Y,fld);
            shading interp; axis([20 55 -300 0]); caxis(cc); colormap('inferno'); colorbar;
            myCaption={'fill in appropriate figure caption here'};
            if addToTex; write2tex(fileTex,2,myCaption,gcf); end;
        end;
    end;

    if (sum(strcmp(choicePlot,'all'))|sum(strcmp(choicePlot,'ppZmSeason')));
        if addToTex; write2tex(fileTex,1,'fill in appropriate section title here',2); end;
        X=mygrid.LATS*ones(1,length(mygrid.RC)); Y=ones(length(mygrid.LATS),1)*(mygrid.RC');
        cc=[0 1e-5];
        nrec=1+diff(myparms.recInAve);
        for mm=1:12;
            fld=mean(alldiag.ppZm(:,:,mm:12:nrec),3);
            figureL; set(gcf,'Renderer','zbuffer'); pcolor(X,Y,fld);
            shading interp; axis([-90 90 -300 0]); caxis(cc); colormap('inferno'); colorbar;
            myCaption={['phyto-plankton -- log10[C] where C is the month nb ' num2str(mm)  ' mean, annual mean (in mgC/m3)']};
            if addToTex; write2tex(fileTex,2,myCaption,gcf); end;
        end;
    end;

end;

