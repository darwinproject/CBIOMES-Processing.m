
if userStep==1;%diags to be computed
    listDiags='ptrZm ptrTop50m ptr158W ptrNorth ptrSouth ptrGlo';
elseif userStep==2;%input files and variables
    listFlds=PTRACERS_varnames; listFldsNames=listFlds;
    listFiles={'ptr_3d_set1'};
    listSubdirs={[dirModel 'diags_ptr/'],[dirModel 'diags/']};
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

elseif userStep==0;%loading / post-processing of mat files

  %records that correspond to each season
  nrec=1+diff(myparms.recInAve);
  rec0=myparms.recInAve(1)-1;
  DJF=rec0+[[12:12:nrec] [1:12:nrec] [2:12:nrec]];
  MMA=rec0+[[3:12:nrec] [4:12:nrec] [5:12:nrec]];
  JJA=rec0+[[6:12:nrec] [7:12:nrec] [8:12:nrec]];
  SON=rec0+[[9:12:nrec] [10:12:nrec] [11:12:nrec]];
  ssnNrec=[length(DJF) length(MMA) length(JJA) length(SON)];

  %load first record and initialize arrays
  alldiag=diags_read_from_mat(dirMat,[fileMat '_*.mat'],'',1);
  for ii=1:length(alldiag.listDiags);
    tmp0=alldiag.listDiags{ii};
    tmp1=getfield(alldiag,tmp0);
    if isa(tmp1,'gcmfaces')|strcmp(tmp0,'ptrZm')|strcmp(tmp0,'ptr158W');
      tmp1=0*repmat(tmp1,[1 1 1 4]);
    elseif ~strcmp(tmp0,'listTimes')|~strcmp(tmp0,'listSteps');
      tmp1=0*repmat(tmp1,[1 1 nrec]);
    else;
      tmp1=0*repmat(tmp1,[nrec 1]);
    end;
    alldiag=setfield(alldiag,tmp0,tmp1);
  end;

  %assemble seasonal averages or time series
  tic;
  fprintf('Reading files: started ... \n');
  for jj=myparms.recInAve(1):myparms.recInAve(2);
    ssn=find([sum(DJF==jj) sum(MMA==jj) sum(JJA==jj) sum(SON==jj)]);
    tmpdiag=diags_read_from_mat(dirMat,[fileMat '_*.mat'],'',jj);
    for ii=1:length(alldiag.listDiags);
      tmp0=tmpdiag.listDiags{ii};
      tmp1=getfield(tmpdiag,tmp0);
      tmp2=getfield(alldiag,tmp0);
      if isa(tmp1,'gcmfaces')|strcmp(tmp0,'ptrZm')|strcmp(tmp0,'ptr158W');
        tmp2(:,:,:,ssn)=tmp2(:,:,:,ssn)+tmp1/ssnNrec(ssn);
      elseif ~strcmp(tmp0,'listTimes')|~strcmp(tmp0,'listSteps');
        tmp2(:,:,jj)=tmp1;
      end;
      alldiag=setfield(alldiag,tmp0,tmp2);
    end;
  end;  
  fprintf('Reading files: ... ended \n');
  toc;

  diagsWereLoaded=1;
    
elseif userStep==-1;%plotting
    
    if isempty(setDiagsParams);
        choicePlot={'all'};
    else;
        choicePlot=setDiagsParams;
    end;
    
    %season names:
    ssnName={'DJF','MAM','JJA','SON'};

    %number of records:
    nrec=1+diff(myparms.recInAve);

%%

   if (sum(strcmp(choicePlot,'all'))|sum(strcmp(choicePlot,'monthlyGlo')));
        if addToTex; write2tex(fileTex,1,'Monthly Time Series For Top 50m Mean',2); end;

        wei=mygrid.DRF; wei(mygrid.RC<-50)=0; 
        wei=repmat(wei/sum(wei),[1 nrec]);
        tim=squeeze(TT);
        for iPtr=[21:71 1:20 72:106];
          tmpGlo=sum(wei.*squeeze(alldiag.ptrGlo(:,iPtr,:)),1);
          tmpNorth=sum(wei.*squeeze(alldiag.ptrNorth(:,iPtr,:)),1);
          tmpSouth=sum(wei.*squeeze(alldiag.ptrSouth(:,iPtr,:)),1);
          figureL; plot(tim,tmpGlo,'k','LineWidth',2); hold on;
          plot(tim,tmpNorth,'b','LineWidth',2); plot(tim,tmpSouth,'r','LineWidth',2);
          grid on; %legend('Global','North. Hem.','South. Hem.');
          myCaption={['Global (black), Northern (blue), and Southern (red) mean, top 50m average concentration ' ...
                        ' of ' PTRACERS_names(iPtr) ' (in ' PTRACERS_units(iPtr) ')']};
          if addToTex; write2tex(fileTex,2,myCaption,gcf); end;
        end;
    end;

%%

    if (sum(strcmp(choicePlot,'all'))|sum(strcmp(choicePlot,'ptrTop50mSeason')));
        if addToTex; write2tex(fileTex,1,'Top 50m biomass (seasonal cycle)',2); end;
        cc=round([-2:0.2:1.2]*10)/10; bot=10^(cc(1)-2);
        for ssn=1:4;
            fld=sum(alldiag.ptrTop50m(:,:,21:55,ssn),3); 
            fld(fld<bot)=bot; fld=log10(fld);
            figureL; m_map_gcmfaces(fld,1.2,{'myCaxis',cc},{'myCmap','inferno'});
            myCaption={['phyto-plankton -- log10(C) where C is the ' ssnName{ssn} ' mean, top 50m average (in mgC/m3)']};
            if addToTex; write2tex(fileTex,2,myCaption,gcf); end;
        end;
        %
        for ssn=1:4;
            fld=sum(alldiag.ptrTop50m(:,:,56:71,ssn),3);
            fld(fld<bot)=bot; fld=log10(fld);
            figureL; m_map_gcmfaces(fld,1.2,{'myCaxis',cc},{'myCmap','inferno'});
            myCaption={['zoo-plankton -- log10(C) where C is the ' ssnName{ssn} ' mean, top 50m average (in mgC/m3)']};
            if addToTex; write2tex(fileTex,2,myCaption,gcf); end;
        end;
    end;
    
    if (sum(strcmp(choicePlot,'all'))|sum(strcmp(choicePlot,'ptrTop50mAnnual')));
        if addToTex; write2tex(fileTex,1,'Top 50m biomass (plankton types)',2); end;
        cc=round([-2:0.2:1.2]*10)/10-1; bot=10^(cc(1)-2);
        for iPtr=21:71;
            fld=mean(alldiag.ptrTop50m(:,:,iPtr,:),4); fld(fld<bot)=bot; fld=log10(fld);
            figureL; m_map_gcmfaces(fld,1.2,{'myCaxis',cc},{'myCmap','inferno'});
            myCaption={['log10(C) where C is the annual mean, top 50m average ' ...
                        ' of ' PTRACERS_names(iPtr) ' (in ' PTRACERS_units(iPtr) ')']};
            if addToTex; write2tex(fileTex,2,myCaption,gcf); end;
        end;
    end;

    if (sum(strcmp(choicePlot,'all'))|sum(strcmp(choicePlot,'nutrientTop50mAnnual')));
        if addToTex; write2tex(fileTex,1,'Top 50m nutrients and chlorophyll',2); end;
        for iPtr=[1:20 72:106];
            cc=PTRACERS_ranges(iPtr);
            fld=mean(alldiag.ptrTop50m(:,:,iPtr,:),4);
            figureL; m_map_gcmfaces(fld,1.2,{'myCaxis',cc},{'myCmap','inferno'});
            myCaption={['Annual mean, top 50m average concentration ' ...
                        ' of ' PTRACERS_names(iPtr) ' (in ' PTRACERS_units(iPtr) ')']};
            if addToTex; write2tex(fileTex,2,myCaption,gcf); end;
        end;
    end;
    
%%
    
    if (sum(strcmp(choicePlot,'all'))|sum(strcmp(choicePlot,'ptrZmSeason')));
        if addToTex; write2tex(fileTex,1,'Zonal mean biomass (seasonal cycle)',2); end;
        X=mygrid.LATS*ones(1,length(mygrid.RC)); Y=ones(length(mygrid.LATS),1)*(mygrid.RC');
        cc=round([-2:0.2:1.2]*10)/10; bot=10^(cc(1)-2);
        depthTics=[0:50:500]; depthLims=[0 500 500];
        for ssn=1:4;
            fld=sum(alldiag.ptrZm(:,:,21:55,ssn),3); 
            fld(fld<bot)=bot; fld=log10(fld);
            figureL; set(gcf,'Renderer','zbuffer'); 
            depthStretchPlot('pcolor',{X,Y,fld},depthTics,depthLims); grid on;
            set(gca,'Layer','top'); shading interp; gcmfaces_cmap_cbar(cc,{'myCmap','inferno'});
            myCaption={['phyto-plankton -- log10(C) where C is the ' ssnName{ssn} ' mean, annual mean (in mgC/m3)']};
            if addToTex; write2tex(fileTex,2,myCaption,gcf); end;
        end;
        %
        for ssn=1:4;
            fld=sum(alldiag.ptrZm(:,:,56:71,ssn),3); 
            fld(fld<bot)=bot; fld=log10(fld);
            figureL; set(gcf,'Renderer','zbuffer');
            depthStretchPlot('pcolor',{X,Y,fld},depthTics,depthLims); grid on;
            set(gca,'Layer','top'); shading interp; gcmfaces_cmap_cbar(cc,{'myCmap','inferno'});
            myCaption={['zoo-plankton -- log10(C) where C is the ' ssnName{ssn} ' mean, annual mean (in mgC/m3)']};
            if addToTex; write2tex(fileTex,2,myCaption,gcf); end;
        end;
    end;
    
    if (sum(strcmp(choicePlot,'all'))|sum(strcmp(choicePlot,'ptrZmAnnual')));
        if addToTex; write2tex(fileTex,1,'Zonal mean biomass (plankton types)',2); end;
        X=mygrid.LATS*ones(1,length(mygrid.RC)); Y=ones(length(mygrid.LATS),1)*(mygrid.RC');
        cc=round([-2:0.2:1.2]*10)/10-1; bot=10^(cc(1)-2);
        depthTics=[0:50:500]; depthLims=[0 500 500];
        for iPtr=21:71;
            fld=mean(alldiag.ptrZm(:,:,iPtr,:),4); 
            fld(fld<bot)=bot; fld=log10(fld);
            figureL; set(gcf,'Renderer','zbuffer');
            depthStretchPlot('pcolor',{X,Y,fld},depthTics,depthLims); grid on;
            set(gca,'Layer','top'); shading interp; gcmfaces_cmap_cbar(cc,{'myCmap','inferno'});
            myCaption={['log10(C) where C is the annual mean, zonal mean ' ...
                        ' of ' PTRACERS_names(iPtr) ' (in ' PTRACERS_units(iPtr) ')']};
            if addToTex; write2tex(fileTex,2,myCaption,gcf); end;
        end;
    end;

    if (sum(strcmp(choicePlot,'all'))|sum(strcmp(choicePlot,'nutrientZmAnnual')));
        if addToTex; write2tex(fileTex,1,'Zonal mean nutrients and chlorophyll',2); end;
        X=mygrid.LATS*ones(1,length(mygrid.RC)); Y=ones(length(mygrid.LATS),1)*(mygrid.RC');
        for iPtr=[1:20 72:106];
            depthTics=[0:50:500]; depthLims=[0 500 500];
            if iPtr<21; depthTics=[0:100:500 1000:500:6000]; depthLims=[0 500 6000]; end;
            cc=PTRACERS_ranges(iPtr);
            fld=mean(alldiag.ptrZm(:,:,iPtr,:),4);
            figureL; set(gcf,'Renderer','zbuffer');
            depthStretchPlot('pcolor',{X,Y,fld},depthTics,depthLims); grid on;
            set(gca,'Layer','top'); shading interp; colormap('inferno'); colorbar; caxis(cc);
            myCaption={['Annual mean, zonal mean concentration ' ...
                        ' of ' PTRACERS_names(iPtr) ' (in ' PTRACERS_units(iPtr) ')']};
            if addToTex; write2tex(fileTex,2,myCaption,gcf); end;
        end;
    end;

%%

    if (sum(strcmp(choicePlot,'all'))|sum(strcmp(choicePlot,'ptr158Wseason')));
        if addToTex; write2tex(fileTex,1,'158W biomass (seasonal cycle)',2); end;
        [LO,LA,msk,X,Y]=gcmfaces_section([-158 -158],[-89 90],mygrid.mskC);
        cc=round([-2:0.2:1.2]*10)/10; bot=10^(cc(1)-2);
        depthTics=[0:50:500]; depthLims=[0 500 500];
        for ssn=1:4;
            fld=msk.*sum(alldiag.ptr158W(:,:,21:55,ssn),3);
            fld(fld<bot)=bot; fld=log10(fld);
            figureL; set(gcf,'Renderer','zbuffer'); 
            depthStretchPlot('pcolor',{X,Y,fld},depthTics,depthLims); grid on; aa=axis; aa(1:2)=[10 60]; axis(aa);
            set(gca,'Layer','top'); shading interp; gcmfaces_cmap_cbar(cc,{'myCmap','inferno'});
            myCaption={['phyto-plankton -- log10(C) where C is the ' ssnName{ssn} ' mean at 158W (in mgC/m3)']};
            if addToTex; write2tex(fileTex,2,myCaption,gcf); end;
        end;
        %
        for ssn=1:4;
            fld=msk.*sum(alldiag.ptr158W(:,:,56:71,ssn),3);
            fld(fld<bot)=bot; fld=log10(fld);
            figureL; set(gcf,'Renderer','zbuffer'); 
            depthStretchPlot('pcolor',{X,Y,fld},depthTics,depthLims); grid on; aa=axis; aa(1:2)=[10 60]; axis(aa);
            set(gca,'Layer','top'); shading interp; gcmfaces_cmap_cbar(cc,{'myCmap','inferno'});
            myCaption={['zoo-plankton -- log10(C) where C is the ' ssnName{ssn} ' mean at 158W (in mgC/m3)']};
            if addToTex; write2tex(fileTex,2,myCaption,gcf); end;
        end;
    end;

    if (sum(strcmp(choicePlot,'all'))|sum(strcmp(choicePlot,'ptr158Wannual')));
        if addToTex; write2tex(fileTex,1,'158W biomass (plankton types)',2); end;
        [LO,LA,msk,X,Y]=gcmfaces_section([-158 -158],[-89 90],mygrid.mskC);
        cc=round([-2:0.2:1.2]*10)/10-1; bot=10^(cc(1)-2);
        depthTics=[0:50:500]; depthLims=[0 500 500];
        for iPtr=21:71;
            fld=msk.*mean(alldiag.ptr158W(:,:,iPtr,:),4);
            fld(fld<bot)=bot; fld=log10(fld);
            figureL; set(gcf,'Renderer','zbuffer'); 
            depthStretchPlot('pcolor',{X,Y,fld},depthTics,depthLims); grid on; aa=axis; aa(1:2)=[10 60]; axis(aa);
            set(gca,'Layer','top'); shading interp; gcmfaces_cmap_cbar(cc,{'myCmap','inferno'});
            myCaption={['log10(C) where C is the annual mean ' ...
                        ' of ' PTRACERS_names(iPtr) ' at 158W (in ' PTRACERS_units(iPtr) ')']};
            if addToTex; write2tex(fileTex,2,myCaption,gcf); end;
        end;
    end;

    if (sum(strcmp(choicePlot,'all'))|sum(strcmp(choicePlot,'nutrient158Wannual')));
        if addToTex; write2tex(fileTex,1,'158W nutrients and chlorophyll',2); end;
        [LO,LA,msk,X,Y]=gcmfaces_section([-158 -158],[-89 90],mygrid.mskC);
        for iPtr=[1:20 72:106];
            depthTics=[0:50:500]; depthLims=[0 500 500];
            cc=PTRACERS_ranges(iPtr);
            fld=msk.*mean(alldiag.ptr158W(:,:,iPtr,:),4);
            figureL; set(gcf,'Renderer','zbuffer');
            depthStretchPlot('pcolor',{X,Y,fld},depthTics,depthLims); grid on; aa=axis; aa(1:2)=[10 60]; axis(aa);
            set(gca,'Layer','top'); shading interp; colormap('inferno'); colorbar; caxis(cc);
            myCaption={['Annual mean concentration ' ...
                        ' of ' PTRACERS_names(iPtr) ' at 158W (in ' PTRACERS_units(iPtr) ')']};
            if addToTex; write2tex(fileTex,2,myCaption,gcf); end;
        end;
    end;

end;
