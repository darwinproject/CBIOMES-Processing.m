%userStep is set in basic_diags_ecco in 'gudA' blocs
%this routine is by choice not a function, in
%order to have access to entire workspace)

if ~strcmp(setDiags,'gudA')
    error(['unknown setDiags ' setDiags]);
end;

%%%%%%%%%%%%%%%%%%TEMPLATE%%%%%%%%%%%%%%%%%%%

if strcmp(setDiags,'gudA')&userStep==1;%diags to be computed
    listDiags='PP_Vi PP_Zm PP_158W PP_North PP_South PP_Glo';
    listDiags=[listDiags ' Nfix_Vi Nfix_Zm Nfix_158W Nfix_North Nfix_South Nfix_Glo'];
    listDiags=[listDiags ' Denit_Vi Denit_Zm Denit_158W Denit_North Denit_South Denit_Glo'];
    listDiags=[listDiags ' PAR_Top PAR_Zm PAR_158W'];
    listDiags=[listDiags ' PARF_Top PARF_Zm PARF_158W'];
end;

if strcmp(setDiags,'gudA')&userStep==2;%input files and variables
    listFlds={'PP','Nfix','Denit','PAR','PARF'};
    listFldsNames=deblank(listFlds);
    listFiles={'gud_3d_set1'};
    listSubdirs={[dirModel 'diags_gud/'],[dirModel 'diags/']};
end;

if strcmp(setDiags,'gudA')&userStep==3;%computational part;
    %preliminary steps:
    nl=length(mygrid.LATS);
    nr=length(mygrid.RC);
    drf3d=mk3D(mygrid.DRF,mygrid.mskC).*mygrid.hFacC;
    volNorth=mk3D(mygrid.DRF,mygrid.mskC).*mygrid.hFacC.*mk3D(mygrid.RAC.*(mygrid.YC>0),mygrid.mskC);
    volSouth=mk3D(mygrid.DRF,mygrid.mskC).*mygrid.hFacC.*mk3D(mygrid.RAC.*(mygrid.YC<0),mygrid.mskC);
    volGlo=mk3D(mygrid.DRF,mygrid.mskC).*mygrid.hFacC.*mk3D(mygrid.RAC,mygrid.mskC);;

    for kk=1:length(listFlds);
      fld=eval(listFlds{kk});
      %
      tmpZm=calc_zonmean_T(fld);
      [LO,LA,tmp158W,X,Y]=gcmfaces_section([-158 -158],[-89 90],fld);
      eval([listFlds{kk} '_Zm=tmpZm;']); eval([listFlds{kk} '_158W=tmp158W;']);
      %
      if kk<4;
        tmpVi=nansum(drf3d.*fld,3);
        tmpGlo=nansum(volGlo.*fld)./nansum(volGlo);
        tmpNorth=nansum(volNorth.*fld)./nansum(volNorth);
        tmpSouth=nansum(volSouth.*fld)./nansum(volSouth);
        eval([listFlds{kk} '_Vi=tmpVi;']); eval([listFlds{kk} '_Glo=tmpGlo;']);
        eval([listFlds{kk} '_South=tmpSouth;']); eval([listFlds{kk} '_North=tmpNorth;']);
      end;
      %
      if kk>=4;
        eval([listFlds{kk} '_Top=fld(:,:,1);']);
      end;
    end;

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
    %records that correspond to each season
    nrec=1+diff(myparms.recInAve);
    DJF=[[12:12:nrec] [1:12:nrec] [2:12:nrec]];
    MMA=[[3:12:nrec] [4:12:nrec] [5:12:nrec]];
    JJA=[[6:12:nrec] [7:12:nrec] [8:12:nrec]];
    SON=[[9:12:nrec] [10:12:nrec] [11:12:nrec]];

   if (sum(strcmp(choicePlot,'all'))|sum(strcmp(choicePlot,'monthlyGlo')));
        if addToTex; write2tex(fileTex,1,'Monthly Time Series',2); end;

        for vv=1:3;
          switch vv;
          case 1; tit='Primary Production (in mmol C/m3/s); global and hemispheric means'; aa=[0 nrec 0 1e-7]; vvName='alldiag.PP';
          case 2; tit='N Fixation (in mmol C/m3/s); global and hemispheric means'; aa=[0 nrec 0 2e-9]; vvName='alldiag.Nfix';
          case 3; tit='Denitrification (in mmol C/m3/s); global and hemispheric means'; aa=[0 nrec 0 1e-9]; vvName='alldiag.Denit';
          end;
          tmpGlo=eval([vvName '_Glo']);
          tmpNorth=eval([vvName '_North']);
          tmpSouth=eval([vvName '_South']);
          figureL; plot(tmpGlo,'k','LineWidth',2); hold on;
          plot(tmpNorth,'b','LineWidth',2); plot(tmpSouth,'r','LineWidth',2);
          axis(aa); grid on; legend('Global','North. Hem.','South. Hem.');
          myCaption={tit}; if addToTex; write2tex(fileTex,2,myCaption,gcf); end;
        end;
    end;

    if (sum(strcmp(choicePlot,'all'))|sum(strcmp(choicePlot,'seasonMaps')));
        if addToTex; write2tex(fileTex,1,'Seasonal Mean Maps',2); end;

        for vv=1:5;
          switch vv;
          case 1; tit='Primary Production (in mmol C/m2/s); vertical integral'; cc=[0 1e-3]; fld=alldiag.PP_Vi;
          case 2; tit='N Fixation (in mmol C/m2/s); vertical integral'; cc=[0 2e-5]; fld=alldiag.Nfix_Vi;
          case 3; tit='Denitrification (in mmol C/m2/s); vertical integral'; cc=[0 5e-5]; fld=alldiag.Denit_Vi;
          case 4; tit='PAR at top of layer (in uEin/m2/s); top level'; cc=[0 500]; fld=alldiag.PAR_Top;
          case 5; tit='total PAR at layer center (in uEin/m2/s); top level'; cc=[0 800]; fld=alldiag.PARF_Top;
          end;
          for mm=1:4;
            switch mm;
            case 1; ssn=DJF; ssnTxt='Dec.-Jan.-Feb. average';
            case 2; ssn=MMA; ssnTxt='Mar.-Apr.-May. average';
            case 3; ssn=JJA; ssnTxt='Jun.-Jul.-Aug. average';
            case 4; ssn=SON; ssnTxt='Sep.-Oct.-Nov. average';
            end;

            tmp=mean(fld(:,:,ssn),3);
            figureL; m_map_gcmfaces(tmp,1.2,{'myCaxis',cc},{'myCmap','inferno'});
            myCaption={[tit ' for the ' ssnTxt]};
            if addToTex; write2tex(fileTex,2,myCaption,gcf); end;
          end;
        end;
    end;

    if (sum(strcmp(choicePlot,'all'))|sum(strcmp(choicePlot,'season158W')));
        if addToTex; write2tex(fileTex,1,'Seasonal Mean 158W Sections',2); end;
        [LO,LA,tmp1,X,Y]=gcmfaces_section([-158 -158],[-89 90],mygrid.hFacC);

        for vv=1:5;
          switch vv;
          case 1; tit='Primary Production (in mmol C/m2/s); 158W section'; cc=[0 1e-5]; fld=alldiag.PP_158W;
          case 2; tit='N Fixation (in mmol C/m2/s); 158W section'; cc=[0 5e-7]; fld=alldiag.Nfix_158W;
          case 3; tit='Denitrification (in mmol C/m2/s); 158W section'; cc=[0 5e-7]; fld=alldiag.Denit_158W;
          case 4; tit='PAR at top of layer (in uEin/m2/s); 158W section'; cc=[0 500]; fld=alldiag.PAR_158W;
          case 5; tit='total PAR at layer center (in uEin/m2/s); 158W section'; cc=[0 800]; fld=alldiag.PARF_158W;
          end;
          for mm=1:4;
            switch mm;
            case 1; ssn=DJF; ssnTxt='Dec.-Jan.-Feb. average';
            case 2; ssn=MMA; ssnTxt='Mar.-Apr.-May. average';
            case 3; ssn=JJA; ssnTxt='Jun.-Jul.-Aug. average';
            case 4; ssn=SON; ssnTxt='Sep.-Oct.-Nov. average';
            end;

            tmp=mean(fld(:,:,ssn),3);
            figureL; set(gcf,'Renderer','zbuffer'); pcolor(X,Y,tmp);
            shading interp; axis([20 55 -300 0]); caxis(cc); colormap('inferno'); colorbar;
            myCaption={[tit ' for the ' ssnTxt]};
            if addToTex; write2tex(fileTex,2,myCaption,gcf); end;
          end;
        end;
    end;

    if (sum(strcmp(choicePlot,'all'))|sum(strcmp(choicePlot,'seasonZM')));
        if addToTex; write2tex(fileTex,1,'Seasonal Mean Zonal Mean',2); end;
        X=mygrid.LATS*ones(1,length(mygrid.RC)); Y=ones(length(mygrid.LATS),1)*(mygrid.RC');

        for vv=1:5;
          switch vv;
          case 1; tit='Primary Production (in mmol C/m2/s); zonal mean'; cc=[0 1e-5]; fld=alldiag.PP_Zm;
          case 2; tit='N Fixation (in mmol C/m2/s); zonal mean'; cc=[0 2e-7]; fld=alldiag.Nfix_Zm;
          case 3; tit='Denitrification (in mmol C/m2/s); zonal mean'; cc=[0 2e-8]; fld=alldiag.Denit_Zm;
          case 4; tit='PAR at top of layer (in uEin/m2/s); zonal mean'; cc=[0 500]; fld=alldiag.PAR_Zm;
          case 5; tit='total PAR at layer center (in uEin/m2/s); zonal mean'; cc=[0 800]; fld=alldiag.PARF_Zm;
          end;
          for mm=1:4;
            switch mm;
            case 1; ssn=DJF; ssnTxt='Dec.-Jan.-Feb. average';
            case 2; ssn=MMA; ssnTxt='Mar.-Apr.-May. average';
            case 3; ssn=JJA; ssnTxt='Jun.-Jul.-Aug. average';
            case 4; ssn=SON; ssnTxt='Sep.-Oct.-Nov. average';
            end;

            tmp=mean(fld(:,:,ssn),3);
            figureL; set(gcf,'Renderer','zbuffer'); pcolor(X,Y,tmp);
            shading interp; axis([-90 90 -300 0]); caxis(cc); colormap('inferno'); colorbar;
            myCaption={[tit ' for the ' ssnTxt]};
            if addToTex; write2tex(fileTex,2,myCaption,gcf); end;
          end;
        end;
    end;

end;

