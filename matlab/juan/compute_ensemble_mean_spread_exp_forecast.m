clear all
close all

%From the grads output for each experiment, compute the ensemble mean and
%spread. (The ensemble mean is alredy computed by the system so only que
%ensemble spread is written).
nx=136;
ny=108;
nfields=6*13+7;
enssize=40;
endian='b';
umbral=[1 5 10 20 50];
acum_times=[6 12 24];

forecast_length=72;
forecast_init_frec=24;
forecast_output_frec=3;

rain_st_index=27;
rain_cv_index=28;

forecast_times=0:forecast_output_frec:forecast_length;

startdate='2008082012';
enddate=  '2008093012';

EXPERIMENT_PATH='/home/jruiz/datos/EXPERIMENTS/FORECAST_QFX2DZLOC40M_MEMNC/';

datenumc=datenum(startdate,'yyyymmddHH');
datenume=datenum(enddate,'yyyymmddHH');


while ( datenumc <= datenume)

datestr(datenumc,'yyyymmddHH')

%COMPUTE THE ANALISIS MEAN AND SPREAD.


datarain=zeros(nx,ny,length(forecast_times),enssize);

for jj = 1:length(forecast_times);
    
meanv=zeros(nx,ny,nfields);
sprd=zeros(nx,ny,nfields);

    if ( forecast_times(jj) < 10 )
        lead_str=['0' num2str(forecast_times(jj))];
    else
        lead_str=num2str(forecast_times(jj));
    end

  
  for ii = 1:enssize 
    enss=num2str(ii);
    if( ii < 100 );enss=['0' enss];end
    if( ii < 10  );enss=['0' enss];end
    
    filepath=[EXPERIMENT_PATH '/' datestr(datenumc,'yyyymmddHHMM') '/PLEV_M' enss '_F' lead_str '.dat'];
    data=read_bin_fun(nx,ny,nfields,filepath,endian);
    data(data > 1e10)=NaN;
    
    meanv=meanv+data;
    sprd=sprd+data.^2;

    datarain(:,:,jj,ii)=squeeze(data(:,:,rain_st_index)+data(:,:,rain_cv_index));
  end


meanv=meanv/enssize;
sprd=sprd/enssize-meanv.^2;
filemean=[EXPERIMENT_PATH '/' datestr(datenumc,'yyyymmddHHMM') '/plev_sprd_f' lead_str '.dat'];
ns=fopen(filemean,'w',endian);
for ii = 1:nfields
   fwrite(ns,sprd(:,:,ii),'single'); 
end

fclose(ns);

filemean=[EXPERIMENT_PATH '/' datestr(datenumc,'yyyymmddHHMM') '/plev_mean_f' lead_str '.dat'];
ns=fopen(filemean,'w',endian);
for ii = 1:nfields
   fwrite(ns,meanv(:,:,ii),'single');
end
fclose(ns);


%Calculamos la probabilidad en base a la lluvia acumulada a diferentes
%tiempos
lead_time=forecast_output_frec*(jj-1);
 for kk=1:length(acum_times)
  if( lead_time > 0 & mod(lead_time,acum_times(kk))==0 )
   

   resta_index=acum_times(kk)/forecast_output_frec;
   tmp_acum_rain=squeeze(datarain(:,:,jj,:)-datarain(:,:,jj-resta_index,:));
   
   %Calculo la probabilidad
   probabilidad=zeros(nx,ny,length(umbral));
    for iumb=1:length(umbral)
       for iens=1:enssize
       probabilidad(:,:,iumb) = probabilidad(:,:,iumb) + double( tmp_acum_rain(:,:,iens) > umbral(iumb) );
       end
    end
    
      
   filemean=[EXPERIMENT_PATH '/' datestr(datenumc,'yyyymmddHHMM') '/probabilidad_lluvia_a' num2str(acum_times(kk)) '_f' lead_str '.dat']; 
   ns=fopen(filemean,'w',endian);
   
   for ii = 1:length(umbral)
     fwrite(ns,probabilidad(:,:,ii),'single');
   end
   fclose(ns);
    
   filemean=[EXPERIMENT_PATH '/' datestr(datenumc,'yyyymmddHHMM') '/lluvia_media_a' num2str(acum_times(kk)) '_f' lead_str '.dat'];
   ns=fopen(filemean,'w',endian);
   
   for ii = 1:length(umbral)
     fwrite(ns,mean(tmp_acum_rain,3),'single');
   end
   fclose(ns);

  end
 end
end

datenumc=datenumc+forecast_init_frec/24;

end
