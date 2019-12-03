clear all
close all

%To compare the control forecast against the observations.

BASEURL='/data/letkf02/jruiz/';
EXPNAME='FORECAST_EXP_40mem_sfflux_ntpar_smooth_fixparinf0.05_qfxhfx_loc';
ENSSIZE=40;
FORECAST_LENGTH=72;
INIT_FREC=12;

VERIFDIR=[BASEURL '/' EXPNAME '/verification_obs/'];
system(['mkdir ' VERIFDIR]);

INIDATE='2008082100';
ENDDATE='2008093000';

level_interval=[1040 950 900 850 800 750 700 650 600 550 500 450 400 350 300 250 200 150 100 50]*100;  %This defines the level ranges.
nlevs=length(level_interval)-1;
time_interval=[0 3 9 15 21 27 33 39 45 51 57 63 69 75];
ntimes=length(time_interval)-1;

PLOT=false;

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


%==========================================================================
%Dimensions.
[xdef ydef zdef]=def_grid_grads;

%==========================================================================
%Read and plot data
%==========================================================================
nfor=FORECAST_LENGTH/6+1;

inid=datenum(INIDATE,'yyyymmddHH');
endd=datenum(ENDDATE,'yyyymmddHH');


MEANMEMBER=ENSSIZE+1;  %El pronostico de la media y la media del analisis esta en el miembro N+1;

%Fields
RMSEU=zeros(nlevs,nfor);
RMSEV=zeros(nlevs,nfor);
RMSET=zeros(nlevs,nfor);
RMSEQ=zeros(nlevs,nfor);
RMSEH=zeros(nlevs,nfor);
RMSEP=zeros(nlevs,nfor);
RMSEUSFC=zeros(nfor,1);
RMSEVSFC=zeros(nfor,1);
RMSEPSFC=zeros(nfor,1);

BIASU=zeros(nlevs,nfor);
BIASV=zeros(nlevs,nfor);
BIAST=zeros(nlevs,nfor);
BIASQ=zeros(nlevs,nfor);
BIASH=zeros(nlevs,nfor);
BIASP=zeros(nlevs,nfor);
BIASUSFC=zeros(nfor,1);
BIASVSFC=zeros(nfor,1);
BIASPSFC=zeros(nfor,1);

NU=zeros(nlevs,nfor);
NV=zeros(nlevs,nfor);
NT=zeros(nlevs,nfor);
NQ=zeros(nlevs,nfor);
NH=zeros(nlevs,nfor);
NP=zeros(nlevs,nfor);
NUSFC=zeros(nfor,1);
NVSFC=zeros(nfor,1);
NPSFC=zeros(nfor,1);

curd=inid;
i=1;


while(curd <= endd)

      dateinit=datestr(curd,'yyyymmddHHMM')

      %Read in letkf analysis ensemble mean.
      iens=MEANMEMBER;

      
      file=[BASEURL '/' EXPNAME '/gues/control/' dateinit '/verification.dat'];
      %LEEMOS EL PRONOSTICO EN EL ESPACIO DE LAS OBSERVACIONES. 
      [obslon obslat obslev obstime obselm obstyp obsdat obserr hxf]=fun_read_letkf_verification(file,1);

current_type=[8 9];
ntype=length(current_type);
for itime=1:ntimes
    for itype=1:ntype
      index=obselm==14593 & obstyp == current_type(itype) & obstime <= time_interval(itime+1) & obstime > time_interval(itime);
      RMSEPSFC(itime)=RMSEPSFC(itime)+sum((obsdat(index)-hxf(index)).^2);
      BIASPSFC(itime)=BIASPSFC(itime)+sum(obsdat(index)-hxf(index));
      NPSFC(itime)=NPSFC(itime)+sum(index);
    end
end

current_type=[9 10 15];
ntype=length(current_type);
for itime=1:ntimes
    for itype=1:ntype
      index=obselm==2819 & obstyp == current_type(itype) & obstime <= time_interval(itime+1) & obstime > time_interval(itime);
      RMSEUSFC(itime)=RMSEUSFC(itime)+sum((obsdat(index)-hxf(index)).^2);
      BIASUSFC(itime)=BIASUSFC(itime)+sum(obsdat(index)-hxf(index));
      NUSFC(itime)=NUSFC(itime)+sum(index);
    end
end

current_type=[9 10 15];
ntype=length(current_type);
for itime=1:ntimes
    for itype=1:ntype
      index=obselm==2820 & obstyp == current_type(itype) & obstime <= time_interval(itime+1) & obstime > time_interval(itime);
      RMSEVSFC(itime)=RMSEVSFC(itime)+sum((obsdat(index)-hxf(index)).^2);
      BIASVSFC(itime)=BIASVSFC(itime)+sum(obsdat(index)-hxf(index));
      NVSFC(itime)=NVSFC(itime)+sum(index);
    end
end


current_type=[1 3 4 5 6];
indexo=obselm==2819;
tmpobstime=obstime(indexo);
tmpobstyp=obstyp(indexo);
tmpobsdat=obsdat(indexo);
tmpobslev=obslev(indexo);

ntype=length(current_type);
for itime=1:ntimes
    for itype=1:ntype
      for ilev=1:nlevs
      index=tmpobstyp == current_type(itype) & tmpobstime <= time_interval(itime+1) & tmpobstime > time_interval(itime) & ...
            tmpobslev <= level_interval(ilev) & tmpobslev > level_interval(ilev+1);
      RMSEU(ilev,itime)=RMSEU(ilev,itime)+sum((tmpobsdat(index)-hxf(index)).^2);
      BIASU(ilev,itime)=BIASU(ilev,itime)+sum(tmpobsdat(index)-hxf(index));
      NU(ilev,itime)=NU(ilev,itime)+sum(index);
      end
    end
end



current_type=[1 3 4 5 6];

indexo=obselm==2820;
tmpobstime=obstime(indexo);
tmpobstyp=obstyp(indexo);
tmpobsdat=obsdat(indexo);
tmpobslev=obslev(indexo);
ntype=length(current_type);
for itime=1:ntimes
    for itype=1:ntype
      for ilev=1:nlevs
      index= tmpobstyp == current_type(itype) & tmpobstime <= time_interval(itime+1) & tmpobstime > time_interval(itime) & ...
            tmpobslev <= level_interval(ilev) & tmpobslev > level_interval(ilev+1);
      RMSEV(ilev,itime)=RMSEV(ilev,itime)+sum((tmpobsdat(index)-hxf(index)).^2);
      BIASV(ilev,itime)=BIASV(ilev,itime)+sum(tmpobsdat(index)-hxf(index));
      NV(ilev,itime)=NV(ilev,itime)+sum(index);
      end
    end
end

current_type=[1 3 21];

indexo=obselm==3073;
tmpobstime=obstime(indexo);
tmpobstyp=obstyp(indexo);
tmpobsdat=obsdat(indexo);
tmpobslev=obslev(indexo);
ntype=length(current_type);
for itime=1:ntimes
    for itype=1:ntype
      for ilev=1:nlevs
      index= tmpobstyp == current_type(itype) & tmpobstime <= time_interval(itime+1) & tmpobstime > time_interval(itime) & ...
            tmpobslev <= level_interval(ilev) & tmpobslev > level_interval(ilev+1);
      RMSET(ilev,itime)=RMSET(ilev,itime)+sum((tmpobsdat(index)-hxf(index)).^2);
      BIAST(ilev,itime)=BIAST(ilev,itime)+sum(tmpobsdat(index)-hxf(index));
      NT(ilev,itime)=NT(ilev,itime)+sum(index);
      end
    end
end

current_type=[1 3 21];

indexo=obselm==3330;
tmpobstime=obstime(indexo);
tmpobstyp=obstyp(indexo);
tmpobsdat=obsdat(indexo);
tmpobslev=obslev(indexo);
ntype=length(current_type);
for itime=1:ntimes
    for itype=1:ntype
      for ilev=1:nlevs
      index= tmpobstyp == current_type(itype) & tmpobstime <= time_interval(itime+1) & tmpobstime > time_interval(itime) & ...
            tmpobslev <= level_interval(ilev) & tmpobslev > level_interval(ilev+1);
      RMSEQ(ilev,itime)=RMSEQ(ilev,itime)+sum((tmpobsdat(index)-hxf(index)).^2);
      BIASQ(ilev,itime)=BIASQ(ilev,itime)+sum(tmpobsdat(index)-hxf(index));
      NQ(ilev,itime)=NQ(ilev,itime)+sum(index);
      end
    end
end

   
   i=i+1;
   curd=curd+INIT_FREC/24; 
end


RMSEU=sqrt(RMSEU./NU);
RMSEV=sqrt(RMSEV./NV);
RMSET=sqrt(RMSET./NT);
RMSEQ=sqrt(RMSEQ./NQ);
RMSEH=sqrt(RMSEH./NH);
RMSEP=sqrt(RMSEP./NP);
RMSEUSFC=sqrt(RMSEUSFC./NUSFC);
RMSEVSFC=sqrt(RMSEVSFC./NVSFC);
RMSEPSFC=sqrt(RMSEPSFC./NPSFC);

BIASU=(BIASU./NU);
BIASV=(BIASV./NV);
BIAST=(BIAST./NT);
BIASQ=(BIASQ./NQ);
BIASH=(BIASH./NH);
BIASP=(BIASP./NP);
BIASUSFC=(BIASUSFC./NUSFC);
BIASVSFC=(BIASVSFC./NVSFC);
BIASPSFC=(BIASPSFC./NPSFC);


   
    
save([VERIFDIR '/rmse_bias_obs.mat'],'RMSEU','RMSEV','RMSET','RMSEQ','RMSEH','RMSEP','RMSEUSFC','RMSEVSFC',...
                                     'RMSEPSFC','BIASU','BIASV','BIAST','BIASQ','BIASH','BIASP','BIASUSFC',... 
                                     'BIASVSFC','BIASPSFC','NU','NV','NT','NQ','NH','NP','NUSFC','NVSFC','NPSFC');
                             
