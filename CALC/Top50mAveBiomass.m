
%load grid
gcmfaces_global;
grid_load;

%compute weights to perform 0-50m average
nr=max(find(mygrid.RC>-50));
w50m=mk3D(mygrid.DRF(1:nr),mygrid.mskC(:,:,1:nr));
w50m=w50m.*mygrid.hFacC(:,:,1:nr);
tmp1=nansum(w50m,3); 
w50m=w50m./repmat(tmp1,[1 1 nr]);

%select a file / record
fil='diags_ptr/ptr_3d_set1.0000000732.data';

%read one field at a time and sum over all plankton types
biomass0to50ave=0*mygrid.RAC;
for itr=21:71;
  fld=read_bin(fil,itr);
  biomass0to50ave=biomass0to50ave+nansum(fld(:,:,1:nr).*w50m,3);
end;

%read one field at a time and sum over all zooplankton types
chl0to50ave=0*mygrid.RAC;
for itr=72:106
  fld=read_bin(fil,itr);
  chl0to50ave=chl0to50ave+nansum(fld(:,:,1:nr).*w50m,3);
end;

