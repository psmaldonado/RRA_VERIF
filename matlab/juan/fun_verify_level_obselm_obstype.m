function [verifstruct]=fun_verify_level_obselm_obstype(obslon,obslat,obslev,obstime,obselm,obstyp,obsdat,obserr,hxf)

% This function will read a LETKF verification file and generate a
% verification structure where the verification is done by time // level //
% variable and observation type.
% The following statistics will be computed:
% -number of observations in each category.
% -BIAS
% -RMSE
%----- ADD MORE AS YOU WISH.

%Variable codes:
%  u= 2819
%  v= 2820
%  t= 3073
%  q= 3330
%  rh=3331

%  ps=14593
%  rain=19999
%  tclon=99991
%  tclat=99992
%  tcmpi=99993

%Observation types code
%  adpupa=1
%  aircar=2
%  aircft=3
%  satwnd=4
%  proflr=5
%  vadwnd=6
%  satemp=7
%  adpsfc=8
%  sfcshp=9
%  sfcbog=10
%  spssmi=11
%  syndat=12
%  ers1da=13
%  goesnd=14
%  qkswnd=15
%  msonet=16
%  gpsipw=17
%  rassda=18
%  wdsatr=19
%  ascatw=20
%  airs=21


level_interval=[1040 950 900 850 800 750 700 650 600 550 500 450 400 350 300 250 200 150 100 50]*100;  %This defines the level ranges.
nlevs=length(level_interval)-1;
nbv=size(hxf,2);



%[obslon obslat obslev obstime ...
% obselm obstyp obsdat obserr  ...
%                             hxf]=fun_read_letkf_verification(file,nbv);
                         
 hxm=mean(hxf,2);                        


%get number of times
ntime=max(obstime);


%==========================================================================
% COMPUTE SCORES FOR SURFACE VARIABLES
%==========================================================================

%PSFC
PSFC_type=[8 9];
ntype=length(PSFC_type);
PSFC_RMSE=NaN(ntype,ntime);
PSFC_BIAS=NaN(ntype,ntime);
PSFC_NOBS=NaN(ntype,ntime);
PSFC_SPRD=NaN(ntype,ntime);
for itime=1:ntime
    for itype=1:ntype
      index=obselm==14593 & obstyp == PSFC_type(itype) & obstime == itime;
      PSFC_RMSE(itype,itime)=sqrt(mean((obsdat(index)-hxm(index)).^2));
      PSFC_BIAS(itype,itime)=mean(obsdat(index)-hxm(index));
      PSFC_NOBS(itype,itime)=sum(index);
      PSFC_SPRD(itype,itime)=sqrt(mean(var(hxf(index,:),[],2)));  
    end
end

%USFC
USFC_type=[9 10 15];
ntype=length(USFC_type);
USFC_RMSE=NaN(ntype,ntime);
USFC_BIAS=NaN(ntype,ntime);
USFC_NOBS=NaN(ntype,ntime);
USFC_SPRD=NaN(ntype,ntime);
for itime=1:ntime
    for itype=1:ntype
      index=obselm==2819 & obstyp == USFC_type(itype) & obstime == itime;
      USFC_RMSE(itype,itime)=sqrt(mean((obsdat(index)-hxm(index)).^2));
      USFC_BIAS(itype,itime)=mean(obsdat(index)-hxm(index));
      USFC_NOBS(itype,itime)=sum(index);
      USFC_SPRD(itype,itime)=sqrt(mean(var(hxf(index,:),[],2)));
    end
end

%VSFC
VSFC_type=[9 10 15];
ntype=length(VSFC_type);
VSFC_RMSE=NaN(ntype,ntime);
VSFC_BIAS=NaN(ntype,ntime);
VSFC_NOBS=NaN(ntype,ntime);
VSFC_SPRD=NaN(ntype,ntime);
for itime=1:ntime
    for itype=1:ntype
      index=obselm==2820 & obstyp == VSFC_type(itype) & obstime == itime;
      VSFC_RMSE(itype,itime)=sqrt(mean((obsdat(index)-hxm(index)).^2));
      VSFC_BIAS(itype,itime)=mean(obsdat(index)-hxm(index));
      VSFC_NOBS(itype,itime)=sum(index);
      VSFC_SPRD(itype,itime)=sqrt(mean(var(hxf(index,:),[],2)));
    end
end

%==========================================================================
% COMPUTE SCORES FOR 3D VARIABLES
%==========================================================================

%U3D
U3D_type=[3 5 6];
ntype=length(U3D_type);
U3D_RMSE=NaN(ntype,nlevs,ntime);
U3D_BIAS=NaN(ntype,nlevs,ntime);
U3D_NOBS=NaN(ntype,nlevs,ntime);
U3D_SPRD=NaN(ntype,nlevs,ntime);
for itime=1:ntime
    for itype=1:ntype
      index=obselm==2819 & obstyp == U3D_type(itype) & obstime == itime;
      tmpdat=obsdat(index);tmplev=obslev(index);tmphxm=hxm(index);tmphxf=hxf(index,:);
      for ilevel=1:nlevs
      index=tmplev < level_interval(ilevel) & tmplev >= level_interval(ilevel+1);
      U3D_RMSE(itype,ilevel,itime)=sqrt(mean((tmpdat(index)-tmphxm(index)).^2));
      U3D_BIAS(itype,ilevel,itime)=mean(tmpdat(index)-tmphxm(index));
      U3D_NOBS(itype,ilevel,itime)=sum(index);
      U3D_SPRD(itype,ilevel,itime)=sqrt(mean(var(tmphxf(index,:),[],2)));
      end
    end
end

%U3D
V3D_type=[3 5 6];
ntype=length(V3D_type);
V3D_RMSE=NaN(ntype,nlevs,ntime);
V3D_BIAS=NaN(ntype,nlevs,ntime);
V3D_NOBS=NaN(ntype,nlevs,ntime);
V3D_SPRD=NaN(ntype,nlevs,ntime);
for itime=1:ntime
    for itype=1:ntype
      index=obselm==2820 & obstyp == V3D_type(itype) & obstime == itime;
      tmpdat=obsdat(index);tmplev=obslev(index);tmphxm=hxm(index);tmphxf=hxf(index,:);
      for ilevel=1:nlevs
      index=tmplev < level_interval(ilevel) & tmplev >= level_interval(ilevel+1);
      V3D_RMSE(itype,ilevel,itime)=sqrt(mean((tmpdat(index)-tmphxm(index)).^2));
      V3D_BIAS(itype,ilevel,itime)=mean(tmpdat(index)-tmphxm(index));
      V3D_NOBS(itype,ilevel,itime)=sum(index);
      V3D_SPRD(itype,ilevel,itime)=sqrt(mean(var(tmphxf(index,:),[],2)));
      end
    end
end

%T3D
T3D_type=[1 3 21];
ntype=length(T3D_type);
T3D_RMSE=NaN(ntype,nlevs,ntime);
T3D_BIAS=NaN(ntype,nlevs,ntime);
T3D_NOBS=NaN(ntype,nlevs,ntime);
T3D_SPRD=NaN(ntype,nlevs,ntime);
for itime=1:ntime
    for itype=1:ntype
      index=obselm==3073 & obstyp == T3D_type(itype) & obstime == itime;
      tmpdat=obsdat(index);tmplev=obslev(index);tmphxm=hxm(index);tmphxf=hxf(index,:);
      for ilevel=1:nlevs
      index=tmplev < level_interval(ilevel) & tmplev >= level_interval(ilevel+1);
      T3D_RMSE(itype,ilevel,itime)=sqrt(mean((tmpdat(index)-tmphxm(index)).^2));
      T3D_BIAS(itype,ilevel,itime)=mean(tmpdat(index)-tmphxm(index));
      T3D_NOBS(itype,ilevel,itime)=sum(index);
      T3D_SPRD(itype,ilevel,itime)=sqrt(mean(var(tmphxf(index,:),[],2)));
      end
    end
end

%Q3D
Q3D_type=[1 21];
ntype=length(Q3D_type);
Q3D_RMSE=NaN(ntype,nlevs,ntime);
Q3D_BIAS=NaN(ntype,nlevs,ntime);
Q3D_NOBS=NaN(ntype,nlevs,ntime);
Q3D_SPRD=NaN(ntype,nlevs,ntime);
for itime=1:ntime
    for itype=1:ntype
      index=obselm==3330 & obstyp == Q3D_type(itype) & obstime == itime;
      tmpdat=obsdat(index);tmplev=obslev(index);tmphxm=hxm(index);tmphxf=hxf(index,:);
      for ilevel=1:nlevs
      index=tmplev < level_interval(ilevel) & tmplev >= level_interval(ilevel+1);
      Q3D_RMSE(itype,ilevel,itime)=sqrt(mean((tmpdat(index)-tmphxm(index)).^2));
      Q3D_BIAS(itype,ilevel,itime)=mean(tmpdat(index)-tmphxm(index));
      Q3D_NOBS(itype,ilevel,itime)=sum(index);
      Q3D_SPRD(itype,ilevel,itime)=sqrt(mean(var(tmphxf(index,:),[],2)));
      end
    end
end

%==========================================================================

%Prepare structure for output.
verifstruct.PSFC_RMSE=PSFC_RMSE;
verifstruct.PSFC_BIAS=PSFC_BIAS;
verifstruct.PSFC_NOBS=PSFC_NOBS;
verifstruct.PSFC_SPRD=PSFC_SPRD;
verifstruct.PSFC_type=PSFC_type;

verifstruct.USFC_RMSE=USFC_RMSE;
verifstruct.USFC_BIAS=USFC_BIAS;
verifstruct.USFC_NOBS=USFC_NOBS;
verifstruct.USFC_SPRD=USFC_SPRD;
verifstruct.USFC_type=USFC_type;

verifstruct.VSFC_RMSE=VSFC_RMSE;
verifstruct.VSFC_BIAS=VSFC_BIAS;
verifstruct.VSFC_NOBS=VSFC_NOBS;
verifstruct.VSFC_SPRD=VSFC_SPRD;
verifstruct.VSFC_type=VSFC_type;

verifstruct.U3D_RMSE=U3D_RMSE;
verifstruct.U3D_BIAS=U3D_BIAS;
verifstruct.U3D_NOBS=U3D_NOBS;
verifstruct.U3D_SPRD=U3D_SPRD;
verifstruct.U3D_type=U3D_type;

verifstruct.V3D_RMSE=V3D_RMSE;
verifstruct.V3D_BIAS=V3D_BIAS;
verifstruct.V3D_NOBS=V3D_NOBS;
verifstruct.V3D_SPRD=V3D_SPRD;
verifstruct.V3D_type=V3D_type;

verifstruct.Q3D_RMSE=Q3D_RMSE;
verifstruct.Q3D_BIAS=Q3D_BIAS;
verifstruct.Q3D_NOBS=Q3D_NOBS;
verifstruct.Q3D_SPRD=Q3D_SPRD;
verifstruct.Q3D_type=Q3D_type;

verifstruct.T3D_RMSE=T3D_RMSE;
verifstruct.T3D_BIAS=T3D_BIAS;
verifstruct.T3D_NOBS=T3D_NOBS;
verifstruct.T3D_SPRD=T3D_SPRD;
verifstruct.T3D_type=T3D_type;

