clear all
close all


%Compute the correlation deribed fron the ensemble between the parameter and 
%different model variables.

nx=136;
ny=108;
nfields=5*14+10+3
enssize=40;
endian='b';

parameter_index=20; %Which data correspond to the parameter.

startdate='2008082000';
enddate=  '2008092918';

EXPERIMENT_PATH='/home/jruiz/datos/EXPERIMENTS/QFX0DNOZLOC40M_MEMNC/'

datenumc=datenum(startdate,'yyyymmddHH');
datenume=datenum(enddate,'yyyymmddHH');


meancovariance=zeros(nx,ny,nfields);
stdcovariance=zeros(nx,ny,nfields);

meancorrelation=zeros(nx,ny,nfields);
stdcorrelation=zeros(nx,ny,nfields);

meanvariables=zeros(nx,ny,nfields);

timecounter=0;
while ( datenumc <= datenume)

datestr(datenumc,'yyyymmddHH')

%COMPUTE THE ANALISIS MEAN AND SPREAD.
datastd=zeros(nx,ny,nfields);
datamean=zeros(nx,ny,nfields);
parstd=zeros(nx,ny);
parmean=zeros(nx,ny);
dataparcov=zeros(nx,ny,nfields);


for ii=1:enssize
    
    enss=num2str(ii);
    if( ii < 100 );enss=['0' enss];end
    if( ii < 10  );enss=['0' enss];end
    
    filepath=[EXPERIMENT_PATH '/gues/' datestr(datenumc,'yyyymmddHHMM') '/plev_gues_' enss '.dat'];
    data=read_bin_fun(nx,ny,nfields,filepath,endian);
    data(data > 1e10)=NaN;

    datastd=datastd+data.^2;
    datamean=datamean+data;
    for kk=1:nfields
     %Elegimos un punto sobre el agua ya que el parametro esta siendo estimado de forma 0D y ademas sobre el continente no lo estamos estimando.
     dataparcov(:,:,kk)=dataparcov(:,:,kk)+data(:,:,kk).*data(100,60,parameter_index);
    end
   
    
end

datamean=datamean/enssize;
tmp=(datastd/enssize - datamean.^2);
tmp(tmp < 0.0)=0.0;

datastd=sqrt(tmp);

meanvariables=meanvariables+datamean;

for kk=1:nfields
dataparcov(:,:,kk)=dataparcov(:,:,kk)/enssize-datamean(:,:,kk).*datamean(100,60,parameter_index);
end

for kk=1:nfields
correlation(:,:,kk)= ( dataparcov(:,:,kk) )./( datastd(:,:,kk) .* datastd(100,60,parameter_index) );
end


filemean=[EXPERIMENT_PATH '/gues/' datestr(datenumc,'yyyymmddHHMM') '/plev_gues_parametercorrelation.mat'];
save(filemean,'correlation','dataparcov','datamean');

%ns=fopen(filemean,'w',endian);
%for kk = 1:nfields
%   fwrite(ns,correlation(:,:,kk),'single'); 
%end

%filemean=[EXPERIMENT_PATH '/gues/' datestr(datenumc,'yyyymmddHHMM') '/plev_gues_parametercovariance.dat'];
%ns=fopen(filemean,'w',endian);
%for kk = 1:nfields
%   fwrite(ns,dataparcov(:,:,kk),'single');
%end

%fclose(ns);

meancovariance=meancovariance+dataparcov;
meancorrelation=meancorrelation+correlation;

stdcovariance=stdcovariance+dataparcov.^2;
stdcorrelation=stdcorrelation+correlation.^2;

datenumc=datenumc+1/4;
timecounter=timecounter+1;
end


meancovariance=meancovariance/timecounter;
meancorrelation=meancorrelation/timecounter;

stdcovariance=stdcovariance/timecounter - meancovariance.^2;
stdcorrelation=stdcorrelation/timecounter - meancorrelation.^2;

meanvariables=meanvariables/timecounter;

save([EXPERIMENT_PATH '/par_correlation.mat'],'meancovariance','meancorrelation','stdcovariance','stdcorrelation','meanvariables');



