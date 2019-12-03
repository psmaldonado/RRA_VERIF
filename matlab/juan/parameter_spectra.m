clear all
close all

%Spatial spectra of estimated parameters.

DATA_PATH='/data/letkf02/jruiz/'

EXPERIMENT='/EXP_40mem_sfflux_ntpar_nsmooth_fixparinf_qfxhfx/';
CONSTFILE='/data/letkf02/jruiz/const.grd'; %constant fields.
EXP_INI_DATE='2008081506';
EXP_END_DATE='2008093018';
EST_FREC=6;                                    %Analysis frequency. (hours)

BIAS_OFFSET=10;                   %How many times before bias computation starts.

%WRFGRID.

nvars=9*40+4+3; 
nx_s=137;
ny_s=109;
nz_s=40;

%Let's read surface constants file.
   nconst=fopen(CONSTFILE,'r','b');
   if(nconst ~= -1)
     longitude=fread(nconst,[nx_s ny_s],'single')';
     latitude=fread(nconst,[nx_s ny_s],'single')';
     longitude_u=fread(nconst,[nx_s ny_s],'single')';
     latitude_u=fread(nconst,[nx_s ny_s],'single')';
     longitude_v=fread(nconst,[nx_s ny_s],'single')';
     latitude_v=fread(nconst,[nx_s ny_s],'single')';
     fcori=fread(nconst,[nx_s ny_s],'single')';
     hgt=fread(nconst,[nx_s ny_s],'single')';
     landmask=fread(nconst,[nx_s ny_s],'single')';
     fclose(nconst);
   else
     display('WARNING, I DID NOT FIND THE CONST FILE')
   end


%Read parameter ensemble

INI_DATE_NUM=datenum(EXP_INI_DATE,'yyyymmddHH');
END_DATE_NUM=datenum(EXP_END_DATE,'yyyymmddHH');
C_DATE_NUM=INI_DATE_NUM;
NTIMES=(END_DATE_NUM-INI_DATE_NUM)*24/EST_FREC+1;

MEAN_PARAM_SPE=zeros(3,ny_s,NTIMES);     %AVERAGED (over latitudes) PARAMETER SPECTRA


MEAN_PARAMETER=zeros(ny_s,nx_s,3);
STD_PARAMETER=zeros(ny_s,nx_s,3);

nfiles=0;

power=zeros(ny_s-2,NTIMES,3);


while ( C_DATE_NUM <= END_DATE_NUM )
  ITIME=(C_DATE_NUM-INI_DATE_NUM)*24/EST_FREC+1;
   
   anamean=strcat(DATA_PATH,EXPERIMENT,'/anal/',datestr(C_DATE_NUM,'yyyymmddHH'),'00/','anal_me.grd')
   
   nanam=fopen(anamean,'r','b');
   
   anal=NaN(ny_s,nx_s,nvars);

   
   if(nanam ~= -1)
     for ivars=1:nvars
     anal(:,:,ivars)=fread(nanam,[nx_s ny_s],'single')';
     end
     fclose(nanam);
   else
     display('WARNING, I DID NOT FIND ANALYSIS MEAN FILE')
   end
   
 if( nanam ~=-1 )
 nfiles=nfiles+1;
 %Compute spectra.
 for ipar=1:3
     tmp=anal(:,:,nvars-3+ipar);
   for jj=2:nx_s-1
        four=fft(squeeze(tmp(2:end-1,jj)));
        power(:,ITIME,ipar)=power(:,ITIME,ipar)+sqrt(four.*conj(four))/(ny_s-2);
   end
   power(:,ITIME,ipar)=power(:,ITIME,ipar)/(nx_s-2);

   MEAN_PARAMETER(:,:,ipar)=MEAN_PARAMETER(:,:,ipar)+tmp;
   STD_PARAMETER(:,:,ipar)=STD_PARAMETER(:,:,ipar)+tmp.^2;

  end
 end

 
C_DATE_NUM=C_DATE_NUM + EST_FREC/24;
end

MEAN_PARAMETER=MEAN_PARAMETER/nfiles;
STD_PARAMETER=sqrt(STD_PARAMETER/nfiles-MEAN_PARAMETER.^2);

save([DATA_PATH '/' EXPERIMENT 'parameter_spe_' EXP_INI_DATE '_' EXP_END_DATE '.mat'],'MEAN_PARAMETER','STD_PARAMETER','power')

