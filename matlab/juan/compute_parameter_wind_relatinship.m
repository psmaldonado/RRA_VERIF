clear all
close all


%The idea of this script is to find a relationship between the parameter
%estimated at each grid point (or its anomaly with respect to the time
%average of the estimated values) and the wind speed. This information can
%be used to improve the parametrization and to modify the way in which the
%wind speed afects these fluxes. 


nx=136;
ny=108;
enssize=40;
endian='b';

parameter_index=20; %Which data correspond to the parameter.

startdate='2008082000';  %Start after the end of the spin up period.
enddate=  '2008092918';

EXPERIMENT_PATH='../QFX0DNOZLOC40M_MEMNC/';

LANDMASKFILE='../TRUE_RUN_SINLAKU_CONSTANT_QFX0.8_60KM/landmask.dat';

datenumc=datenum(startdate,'yyyymmddHH');
datenume=datenum(enddate,'yyyymmddHH');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   READ LAND SEA MASK 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

nfile=fopen(LANDMASKFILE,'r','b');

LANDMASK=fread(nfile,[nx ny],'single')';

fclose(nfile); 


time_counter=0;
while ( datenumc <= datenume)
time_counter = time_counter + 1;
datestr(datenumc,'yyyymmddHH')


filepath=[EXPERIMENT_PATH '/anal/' datestr(datenumc,'yyyymmddHHMM') '/plev_anal_me.dat']
    
[U(:,:,:) V(:,:,:) Q(:,:,:) H(:,:,:) T(:,:,:) ...
 U10(:,:) V10(:,:) P(:,:) MCAPE(:,:) MCIN(:,:) RAINC(:,:) RAINNC(:,:) ...
 HFX_FACTOR(:,:) QFX_FACTOR(:,:) UST_FACTOR(:,:) ]=read_arwpost_analysis(filepath,nx,ny,14,true);
   
    
QFX_FACTOR_T(:,:,time_counter)=QFX_FACTOR;    

W10_T(:,:,time_counter)=sqrt( U10 .^ 2 + V10 .^ 2 );

W_T(:,:,time_counter) = nanmean( sqrt( U(:,:,1:3) .^ 2 + V(:,:,1:3) .^ 2 ) , 3 );

MASK_T(:,:,time_counter)=LANDMASK;

datenumc = datenumc + 1;
  
end

%Compute the time mean of the estimated QFX_FACTOR and compute the anomaly
%of the estimated parameter with respeact to this mean.
QFX_FACTOR_MEAN_T=nanmean( QFX_FACTOR , 3 );

for ii=1:size(QFX_FACTOR_T,3)
    QFX_FACTOR_T(:,:,ii)=QFX_FACTOR_T(:,:,ii) - QFX_FACTOR_MEAN_T ;
end

%Keep only the sea points of each array.
QFX_FACTOR_VECT= QFX_FACTOR_T( MASK_T == 0  );

W10_VECT=W10_T( MASK_T == 0 ) ;

W_VECT=W_T( MASK_T == 0 );


%plot(QFX_FACTOR_VECT,W10_VECT,'o')


%save([EXPERIMENT_PATH '/par_wind_relationship.mat'],...);



