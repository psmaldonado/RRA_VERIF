clear all
close all

%COMPUTE ESTIMATED PARAMETERS EVOLUCION TEMPORAL DEL PARAMETRO MEDIO
%ESPACIAL, CAMPO MEDIO DE PARAMETROS ESTIMADOS Y SU VARIABILIDAD TEMPORAL.


nx=136;
ny=108;
nfields=21;
enssize=40;
endian='b';

startdate='2008080706';
enddate=  '2008092918';

mean_times=120; %Numero de tiempos que van a ser utilizados para obtener los parametros promedio. 


EXPERIMENT_PATH='/home/jruiz/datos/EXPERIMENTS/QFX2DNOZLOC40M_MEMNC/';

datenumc=datenum(startdate,'yyyymmddHH');
datenume=datenum(enddate,'yyyymmddHH');

timecount=1;
while ( datenumc <= datenume)

datestr(datenumc,'yyyymmddHH')

%COMPUTE THE ANALISIS MEAN AND SPREAD.
datamean=zeros(nx,ny,nfields);
datasprd=zeros(nx,ny,nfields);
for ii = 1:enssize
    
    enss=num2str(ii);
    if( ii < 100 );enss=['0' enss];end
    if( ii < 10  );enss=['0' enss];end
    
    filepath=[EXPERIMENT_PATH '/anal/' datestr(datenumc,'yyyymmddHHMM') '/plev_anal_' enss '.dat'];
    data=read_bin_fun(nx,ny,nfields,filepath,endian);
    data(data > 1e10)=NaN;
    
    datamean=datamean+data;
    datasprd=datasprd+data.^2;
    
end
par_mean=datamean(:,:,19:end);
par_std =datasprd(:,:,19:end);

par_mean=par_mean/enssize;
sprd=sqrt(par_std/enssize-par_mean.^2);

if( timecount == mean_times)
    parameter_time_mean=par_mean;
    parameter_time_var=par_mean.^2;
elseif( timecount > mean_times);
    parameter_time_mean=parameter_time_mean+par_mean;
    parameter_time_var =parameter_time_var + par_mean.^2;
end

parameter_spatial_average(timecount,:)=mean(mean(par_mean));

timecount=timecount+1;
datenumc=datenumc+6/24;
end

parameter_time_mean=parameter_time_mean/(timecount-mean_times+1);
parameter_time_var=sqrt(parameter_time_var/(timecount-mean_times+1)-parameter_time_mean.^2);


output_file=[EXPERIMENT_PATH '/parameters.mat'];


save(output_file,'parameter_spatial_average','parameter_time_mean','parameter_time_var');

