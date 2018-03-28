
if userStep==1;%diags to be computed
    listDiags='ptrZm ptrTop50m ptr158W ptrNorth ptrSouth ptrGlo';
elseif userStep==2;%input files and variables
    listFlds={};
    for kk=1:99; listFlds={listFlds{:},sprintf('TRAC%02d',kk)}; end;
    listFlds={listFlds{:},'TRAC0a','TRAC0b','TRAC0c','TRAC0d','TRAC0e','TRAC0f','TRAC0g'};
    listFldsNames=deblank(listFlds);
    listFiles={'ptr_3d_set1'};
    listSubdirs={[dirModel 'diags/']};
elseif userStep==3;%computational part;
    
    %preliminary steps:
    nl=length(mygrid.LATS);
    nr=length(mygrid.RC);
    w50m=mk3D(mygrid.DRF,mygrid.mskC).*repmat(mygrid.RAC,[1 1 nr]);
    w50m=w50m.*mygrid.hFacC; w50m(:,:,6:end)=NaN;
    volNorth=mk3D(mygrid.DRF,mygrid.mskC).*mygrid.hFacC.*mk3D(mygrid.RAC.*(mygrid.YC>0),mygrid.mskC);
    volSouth=mk3D(mygrid.DRF,mygrid.mskC).*mygrid.hFacC.*mk3D(mygrid.RAC.*(mygrid.YC<0),mygrid.mskC);
    volGlo=mk3D(mygrid.DRF,mygrid.mskC).*mygrid.hFacC.*mk3D(mygrid.RAC,mygrid.mskC);;
    
    %compute zonal means, sections, layers:
    ptrZm=zeros(nl,nr,106); ptrTop50m=repmat(0*mygrid.Depth,[1 1 106]); ptr158W=zeros(321,nr,106);
    ptrNorth=zeros(nr,106); ptrSouth=zeros(nr,106); ptrGlo=zeros(nr,106);
    for kk=1:106;
        fprintf([listFlds{kk} '...\n']);
        %
        fld=eval(listFlds{kk});
        ptrZm(:,:,kk)=calc_zonmean_T(fld);
        %
        ptrTop50m(:,:,kk)=nansum(w50m.*fld,3)./nansum(w50m,3);
        %
        [LO,LA,tmp1,X,Y]=gcmfaces_section([-158 -158],[-89 90],fld);
        ptr158W(:,:,kk)=tmp1;
        %
        ptrNorth(:,kk)=nansum(volNorth.*fld,0)./nansum(volNorth,0);
        ptrSouth(:,kk)=nansum(volSouth.*fld,0)./nansum(volSouth,0);
        ptrGlo(:,kk)=nansum(volGlo.*fld,0)./nansum(volGlo,0);
        %
    end;
    
    %===================== COMPUTATIONAL SEQUENCE ENDS =========================%
    %===================== PLOTTING SEQUENCE BEGINS    =========================%
    
elseif userStep==-1;%plotting
    
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
    
    %
    
    if (sum(strcmp(choicePlot,'all'))|sum(strcmp(choicePlot,'ptrTop50mSeason')));
        if addToTex; write2tex(fileTex,1,'Top 50m biomass (seasonal cycle)',2); end;
        cc=round([-2:0.2:1.2]*10)/10; bot=10^(cc(1)-2);
        nrec=1+diff(myparms.recInAve);
        for mm=1:12;
            fld=sum(mean(alldiag.ptrTop50m(:,:,21:55,mm:12:nrec),4),3); 
            fld(fld<bot)=bot; fld=log10(fld);
            figureL; m_map_gcmfaces(fld,1.2,{'myCaxis',cc},{'myCmap','inferno'});
            myCaption={['phyto-plankton -- log10[C] where C is the month nb ' num2str(mm)  ' mean, top 50m average (in mgC/m3)']};
            if addToTex; write2tex(fileTex,2,myCaption,gcf); end;
        end;
        %
        for mm=1:12;
            fld=sum(mean(alldiag.ptrTop50m(:,:,56:71,mm:12:nrec),4),3); 
            fld(fld<bot)=bot; fld=log10(fld);
            figureL; m_map_gcmfaces(fld,1.2,{'myCaxis',cc},{'myCmap','inferno'});
            myCaption={['zoo-plankton -- log10[C] where C is the month nb ' num2str(mm)  ' mean, top 50m average (in mgC/m3)']};
            if addToTex; write2tex(fileTex,2,myCaption,gcf); end;
        end;
    end;
    
    if (sum(strcmp(choicePlot,'all'))|sum(strcmp(choicePlot,'ptrTop50mAnnual')));
        if addToTex; write2tex(fileTex,1,'Top 50m biomass (plankton types)',2); end;
        cc=round([-2:0.2:1.2]*10)/10; bot=10^(cc(1)-2);
        for iPtr=21:71;
            fld=mean(alldiag.ptrTop50m(:,:,iPtr,:),4); fld(fld<bot)=bot; fld=log10(fld);
            figureL; m_map_gcmfaces(fld,1.2,{'myCaxis',cc},{'myCmap','inferno'});
            myCaption={['log10[C] where C is the annual mean, top 50m average of ' sprintf('c%02d',iPtr-20) ' (in mgC/m3)']};
            if addToTex; write2tex(fileTex,2,myCaption,gcf); end;
        end;
    end;
    
    %
    
    if (sum(strcmp(choicePlot,'all'))|sum(strcmp(choicePlot,'ptr158Wseason')));
        if addToTex; write2tex(fileTex,1,'158W biomass (seasonal cycle)',2); end;
        [LO,LA,tmp1,X,Y]=gcmfaces_section([-158 -158],[-89 90],mygrid.hFacC);
        cc=round([-2:0.2:1.2]*10)/10; bot=10^(cc(1)-2);
        nrec=1+diff(myparms.recInAve);
        for mm=1:12;
            fld=sum(mean(alldiag.ptr158W(:,:,21:55,mm:12:nrec),4),3); 
            fld(fld<bot)=bot; fld=log10(fld);
            figureL; set(gcf,'Renderer','zbuffer'); pcolor(X,Y,fld); 
            shading interp; axis([20 55 -300 0]); gcmfaces_cmap_cbar(cc,{'myCmap','inferno'});
            myCaption={['phyto-plankton -- log10[C] where C is the month nb ' num2str(mm)  ' mean at 158W (in mgC/m3)']};
            if addToTex; write2tex(fileTex,2,myCaption,gcf); end;
        end;
        %
        for mm=1:12;
            fld=sum(mean(alldiag.ptr158W(:,:,56:71,mm:12:nrec),4),3); 
            fld(fld<bot)=bot; fld=log10(fld);
            figureL; set(gcf,'Renderer','zbuffer'); pcolor(X,Y,fld); 
            shading interp; axis([20 55 -300 0]); gcmfaces_cmap_cbar(cc,{'myCmap','inferno'});
            myCaption={['zoo-plankton -- log10[C] where C is the month nb ' num2str(mm)  ' mean at 158W (in mgC/m3)']};
            if addToTex; write2tex(fileTex,2,myCaption,gcf); end;
        end;
    end;
    
    if (sum(strcmp(choicePlot,'all'))|sum(strcmp(choicePlot,'ptr158Wannual')));
        if addToTex; write2tex(fileTex,1,'158W biomass (plankton types)',2); end;
        [LO,LA,tmp1,X,Y]=gcmfaces_section([-158 -158],[-89 90],mygrid.hFacC);
        cc=round([-2:0.2:1.2]*10)/10; bot=10^(cc(1)-2);
        for iPtr=21:71;
            fld=mean(alldiag.ptr158W(:,:,iPtr,:),4); 
            fld(fld<bot)=bot; fld=log10(fld);
            figureL; set(gcf,'Renderer','zbuffer'); pcolor(X,Y,fld); 
            shading interp; axis([20 55 -300 0]); gcmfaces_cmap_cbar(cc,{'myCmap','inferno'});
            myCaption={['log10[C] where C is the annual mean of ' sprintf('c%02d',iPtr-20) ' at 158W (in mgC/m3)']};
            if addToTex; write2tex(fileTex,2,myCaption,gcf); end;
        end;
    end;
    
    %
    
    if (sum(strcmp(choicePlot,'all'))|sum(strcmp(choicePlot,'ptrZmSeason')));
        if addToTex; write2tex(fileTex,1,'Zonal mean biomass (seasonal cycle)',2); end;
        X=mygrid.LATS*ones(1,length(mygrid.RC)); Y=ones(length(mygrid.LATS),1)*(mygrid.RC');
        cc=round([-2:0.2:1.2]*10)/10; bot=10^(cc(1)-2);
        nrec=1+diff(myparms.recInAve);
        for mm=1:12;
            fld=sum(mean(alldiag.ptrZm(:,:,21:55,mm:12:nrec),4),3); 
            fld(fld<bot)=bot; fld=log10(fld);
            figureL; set(gcf,'Renderer','zbuffer'); pcolor(X,Y,fld); 
            shading interp; axis([-90 90 -300 0]); gcmfaces_cmap_cbar(cc,{'myCmap','inferno'});
            myCaption={['phyto-plankton -- log10[C] where C is the month nb ' num2str(mm)  ' mean, annual mean (in mgC/m3)']};
            if addToTex; write2tex(fileTex,2,myCaption,gcf); end;
        end;
        %
        for mm=1:12;
            fld=sum(mean(alldiag.ptrZm(:,:,56:71,mm:12:nrec),4),3); 
            fld(fld<bot)=bot; fld=log10(fld);
            figureL; set(gcf,'Renderer','zbuffer'); pcolor(X,Y,fld); 
            shading interp; axis([-90 90 -300 0]); gcmfaces_cmap_cbar(cc,{'myCmap','inferno'});
            myCaption={['zoo-plankton -- log10[C] where C is the month nb ' num2str(mm)  ' mean, annual mean (in mgC/m3)']};
            if addToTex; write2tex(fileTex,2,myCaption,gcf); end;
        end;
    end;
    
    if (sum(strcmp(choicePlot,'all'))|sum(strcmp(choicePlot,'ptrZmAnnual')));
        if addToTex; write2tex(fileTex,1,'Zonal mean biomass (plankton types)',2); end;
        X=mygrid.LATS*ones(1,length(mygrid.RC)); Y=ones(length(mygrid.LATS),1)*(mygrid.RC');
        cc=round([-2:0.2:1.2]*10)/10; bot=10^(cc(1)-2);
        for iPtr=21:71;
            fld=mean(alldiag.ptrZm(:,:,iPtr,:),4); 
            fld(fld<bot)=bot; fld=log10(fld);
            figureL; set(gcf,'Renderer','zbuffer'); pcolor(X,Y,fld); 
            shading interp; axis([-90 90 -300 0]); gcmfaces_cmap_cbar(cc,{'myCmap','inferno'});
            myCaption={['log10[C] where C is the annual mean, zonal mean of ' sprintf('c%02d',iPtr-20) ' (in mgC/m3)']};
            if addToTex; write2tex(fileTex,2,myCaption,gcf); end;
        end;
    end;
        
end;
