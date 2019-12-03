clear all
close all


%Compute the correlation deribed fron the ensemble between the parameter and 
%different model variables.

nx=136;
ny=108;
nfields=6*13+7
nfieldsana=5*14+10+3
enssize=40;
endian='b';

forecastlength=72;
forecastfreq=24;
forecastinitfreq=24;
nlead=forecastlength/forecastfreq;

parameter_index=20; %Which data correspond to the parameter.

startdate='2008082012';
enddate=  '2008092712';

%El path al pronostico y a los analisis que se usaron para generar ese pronostico.
EXPERIMENT_PATH_FOR='/home/jruiz/datos/EXPERIMENTS/FORECAST_QFX0DNOZLOC40M_MEMNC/'
EXPERIMENT_PATH_ANA='/home/jruiz/datos/EXPERIMENTS/QFX0DNOZLOC40M_MEMNC/'

datenumc=datenum(startdate,'yyyymmddHH');
datenume=datenum(enddate,'yyyymmddHH');


meancovariance=zeros(nx,ny,nfields,nlead);
stdcovariance=zeros(nx,ny,nfields,nlead);

meancorrelation=zeros(nx,ny,nfields,nlead);
stdcorrelation=zeros(nx,ny,nfields,nlead);

meanvariables=zeros(nx,ny,nfields,nlead);

timecounter=0;
while ( datenumc <= datenume)

datestr(datenumc,'yyyymmddHH')

%COMPUTE THE ANALISIS MEAN AND SPREAD.
datastd=zeros(nx,ny,nfields,nlead);
datamean=zeros(nx,ny,nfields,nlead);

parameterstd=0;
parametermean=0;

dataparcov=zeros(nx,ny,nfields,nlead);

for il=1:nlead
il

  lead=(il)*forecastfreq;
  leads=num2str(lead);
  if( lead < 10 );leads=['0' leads];end;

   for ii=1:enssize
    
    enss=num2str(ii);
    if( ii < 100 );enss=['0' enss];end
    if( ii < 10  );enss=['0' enss];end
    
    filepath=[EXPERIMENT_PATH_FOR '/' datestr(datenumc,'yyyymmddHHMM') '/PLEV_M' enss '_F' leads '.dat'];
    data=read_bin_fun(nx,ny,nfields,filepath,endian);
    data(data > 1e10)=NaN;

    if( il == 1)
      %Los archivos del pronostico no contienen  los parametros, por eso tengo que recurrir a los analisis a partir del cual esos pronosticos se inicializaron.
      %Los parametros se asumen constantes en espacio y ademas constantes durante el pronostico. 
      filepath=[EXPERIMENT_PATH_ANA '/anal/' datestr(datenumc,'yyyymmddHHMM') '/plev_anal_' enss '.dat'];
      dataana=read_bin_fun(nx,ny,nfieldsana,filepath,endian);
      parameter(ii)=dataana(100,60,parameter_index);

    end

    datastd(:,:,:,il)=datastd(:,:,:,il)+data.^2;
    datamean(:,:,:,il)=datamean(:,:,:,il)+data;
    %for kk=1:nfields
    %Elegimos un punto sobre el agua ya que el parametro esta siendo estimado de forma 0D y ademas sobre el continente no lo estamos estimando.
    dataparcov(:,:,:,il)=dataparcov(:,:,:,il)+data(:,:,:)*parameter(ii);
    %end
    
   end  %End over ensemble members.

   

end  %End over lead times

parametermean=mean(parameter);
parameterstd=std(parameter);

datamean=datamean/enssize;
tmp=(datastd/enssize - datamean.^2);
tmp(tmp < 0.0)=0.0;

datastd=sqrt(tmp);

meanvariables=meanvariables+datamean;

dataparcov=dataparcov/enssize-datamean*parametermean;

correlation= ( dataparcov )./( datastd * parameterstd );

filemean=[EXPERIMENT_PATH_FOR '/' datestr(datenumc,'yyyymmddHHMM') '/PARAMETERCORRELATION.mat'];
save(filemean,'correlation','dataparcov','datamean');


meancovariance=meancovariance+dataparcov;
meancorrelation=meancorrelation+correlation;

stdcovariance=stdcovariance+dataparcov.^2;
stdcorrelation=stdcorrelation+correlation.^2;

datenumc=datenumc+forecastinitfreq/24;
timecounter=timecounter+1;


end %End over the dates.


meancovariance=meancovariance/timecounter;
meancorrelation=meancorrelation/timecounter;

stdcovariance=stdcovariance/timecounter - meancovariance.^2;
stdcorrelation=stdcorrelation/timecounter - meancorrelation.^2;

meanvariables=meanvariables/timecounter;

save([EXPERIMENT_PATH_FOR '/par_correlation.mat'],'meancovariance','meancorrelation','stdcovariance','stdcorrelation','meanvariables');

