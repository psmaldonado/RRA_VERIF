clear all
close all

%To compare the 40 member control against the observations.

BASEURL='/data/letkf02/jruiz/';
EXPNAME='FORECAST_EXP_40mem_CONTROL';
ENSSIZE=40;
FORECAST_LENGTH=72;
INIT_FREC=12;

VERIFDIR=[BASEURL '/' EXPNAME '/verification_obs/'];
system(['mkdir ' VERIFDIR]);

INIDATE='2008090100';
ENDDATE='2008090100';

PLOT=false;

%==========================================================================
%Dimensions.
[xdef ydef zdef]=def_grid_grads;

%==========================================================================
%Read and plot data
%==========================================================================
nfor=FORECAST_LENGTH/6+1;

inid=datenum(INIDATE,'yyyymmddHH');
endd=datenum(ENDDATE,'yyyymmddHH');

nx=length(xdef);
ny=length(ydef);
nz=length(zdef);

MEANMEMBER=ENSSIZE+1;  %El pronostico de la media y la media del analisis esta en el miembro N+1;

%Fields
RMSEU=zeros(nz,nfor);
RMSEV=zeros(nz,nfor);
RMSET=zeros(nz,nfor);
RMSEQ=zeros(nz,nfor);
RMSEH=zeros(nz,nfor);
RMSEP=zeros(nz,nfor);
RMSESLP=zeros(nfor);

BIASU=zeros(nz,nfor);
BIASV=zeros(nz,nfor);
BIAST=zeros(nz,nfor);
BIASQ=zeros(nz,nfor);
BIASH=zeros(nz,nfor);
BIASP=zeros(nz,nfor);
BIASSLP=zeros(nfor);

curd=inid;
i=1;

obslon=[];
obslat=[];
obslev=[];
obstime=[];
obselm=[];
obstyp=[];
obsdat=[];
obserr=[];
hxf=[];
obsdatenum=[];

while(curd <= endd)

      dateinit=datestr(curd,'yyyymmddHHMM')

      %Read in letkf analysis ensemble mean.
      iens=MEANMEMBER;

      
      file=[BASEURL '/' EXPNAME '/gues/control/' dateinit '/verification.dat'];
      %LEEMOS EL PRONOSTICO EN EL ESPACIO DE LAS OBSERVACIONES. 
      [tmpobslon tmpobslat tmpobslev tmpobstime tmpobselm tmpobstyp tmpobsdat tmpobserr tmphxf]=fun_read_letkf_verification(file,1);

      %Aca se pueden agregar algunos filtros a las obs.
      
      %Compute the date for each observation.
      tmpobsdatenum=(tmpobstime-1)/24+curd;      %El tiempo 1 corresponde al analysis.
      
      obslon=[obslon ; tmpobslon];
      obslat=[obslat ; tmpobslat];
      obslev=[obslev ; tmpobslev];
      obstime=[obstime; tmpobstime];
      obselm=[obselm; tmpobselm];
      obstyp=[obstyp; tmpobstyp];
      obsdat=[obsdat; tmpobsdat];
      obserr=[obserr; tmpobserr];
      obsdatenum=[obsdatenum;tmpobsdatenum];
      hxf=   [hxf; tmphxf];
       
      
   
   i=i+1;
   curd=curd+INIT_FREC/24; 
end

   
[verifstruct]=fun_verify_level_obselm_obstype(obslon,obslat,obslev,obstime,obselm,obstyp,obsdat,obserr,hxf);
    
save([VERIFDIR '/rmse_bias_obs.mat'],'verifstruct');
                             
