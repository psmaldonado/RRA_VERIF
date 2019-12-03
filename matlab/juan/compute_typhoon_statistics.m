clear all
close all
%Esta figura genera el grafico con la trayectoria de los ciclones
%tropicales.

startdate='2008082012';
enddate='2008093012';
traj_start_frec=24;
ens_size=40;
fontsize=35
load coast




best_track_file='./trajectories_wrf/JMA_BESTTRACK.mat';

PATH_EXPERIMENT{1}='../FORECAST_CONTROL40M_MEMNC/';
PATH_EXPERIMENT{2}='../FORECAST_QFX0DNOZLOC40M_MEMNC/';


EXP_COLOR{1}=[0 0 0];
EXP_COLOR{2}=[0.3 0.3 0.3];
%EXP_COLOR{3}='-b+';
%EXP_COLOR{4}='-ro';
%EXP_COLOR{5}='-r+';

nexp=size(PATH_EXPERIMENT,2);

PATH_FIGURE='./FIGURES/';
mkdir(PATH_FIGURE);

leadtime=72;
timefrec=3;
maxdist=500e3;    %Max distance in meters.

ednum=datenum(enddate,'yyyymmddHH');
sdnum=datenum(startdate,'yyyymmddHH');

cdnum=sdnum;

%Load besttrack data.
load(best_track_file);

%totaldisttrack=zeros(nexp,leadtime/timefrec+1);
%ntotaldisttrack=zeros(nexp,leadtime/timefrec+1);

%totaldiffp=zeros(nexp,leadtime/timefrec+1);        %Intensity errors.

nstorm=0;

while (cdnum <= ednum)

sf=cdnum;
ef=cdnum+leadtime/24;

%Get for the current forecast period the observed typhoons tracks.
[CurrentTracks]=get_current_tracks_fun(sf,ef,BestTrack);

nbt=size(CurrentTracks,2); %Number of best tracks for this date.

%For each CurrentTrack we will get the forecasted track.


for it=1:nbt
    nstorm=nstorm+1;

    
for iexp=1:nexp %Hacemos el loop sobre los experimentos.    
    
for iens=1:ens_size
   %Comparison with EXP 40 MEM CONTROL FORECASTED TRACK ------------------
   strens=num2str(iens);
   
      ExperimentBestTrack(iens).minlon=NaN;
      ExperimentBestTrack(iens).minlat=NaN;
      ExperimentBestTrack(iens).daten=NaN;
      ExperimentBestTrack(iens).minanom=NaN;
      ExperimentBestTrack(iens).maxwind=NaN;
      ExperimentBestTrack(iens).uvelf=NaN;
      ExperimentBestTrack(iens).vvelf=NaN;
      ExperimentBestTrack(iens).trajnumber=NaN;
      ExperimentBestTrack(iens).dist_track=NaN;
      
   file_track=[ PATH_EXPERIMENT{iexp} '/trajectories/' datestr(sf,'yyyymmddHH') '/trajectories_' strens '.mat'];
   fid=fopen(file_track);if(fid>0);fclose(fid);end
   if(fid > 0)
   load(file_track);
   clear ExperimentTrack;
   ExperimentTrack=TrajStruct;
   ngt=size(ExperimentTrack,2);
   BestDist=1e10;
    
    for jj=1:ngt
    
     lon1=CurrentTracks(it).minlon;
     lat1=CurrentTracks(it).minlat;
     times1=CurrentTracks(it).daten;
     lon2=ExperimentTrack(jj).minlon;
     lat2=ExperimentTrack(jj).minlat;
     times2=ExperimentTrack(jj).daten;
     [dist_track npuntos ntimes index1 index2]...
     =compare_track_fun(lon1,lat1,times1,lon2,lat2,times2,maxdist);
 
     %Calculo la distancia pesada por el tiempo (la distancia de los
     %primeros tiempos es la mas importante y la de los tiempos posteriores
     %la menos importante).
     tmp=1:length(dist_track);
     wdist=sum(dist_track.*(1./tmp))/sum(1./tmp);
 
 
     %if(mean(dist_track)/maxdist < 3 && mean(dist_track) < BestDist  & length(index2) > 2)
     if(wdist/maxdist < 1 && wdist < BestDist  & length(index2) > 2)
      ExperimentBestTrack(iens).minlon=ExperimentTrack(jj).minlon;
      ExperimentBestTrack(iens).minlat=ExperimentTrack(jj).minlat;
      ExperimentBestTrack(iens).daten=ExperimentTrack(jj).daten;
      ExperimentBestTrack(iens).minanom=ExperimentTrack(jj).minanomf;
      ExperimentBestTrack(iens).maxwind=ExperimentTrack(jj).maxwind;
      ExperimentBestTrack(iens).uvelf=ExperimentTrack(jj).uvelf;
      ExperimentBestTrack(iens).vvelf=ExperimentTrack(jj).vvelf;
      ExperimentBestTrack(iens).trajnumber=jj;
      ExperimentBestTrack(iens).dist_track=NaN(1,length(ExperimentBestTrack(iens).minlon));
      ExperimentBestTrack(iens).dist_track(index2)=dist_track;
      
      BestDist=wdist;
     end
    end
   end
    
end



%
MeanBestTrack.daten=sf:timefrec/24:ef;
nelements=length(sf:timefrec/24:ef);
MeanBestTrack.minlon=zeros(1,nelements);
MeanBestTrack.minlat=zeros(1,nelements);
MeanBestTrack.minanom=zeros(1,nelements);
MeanBestTrack.maxwind=zeros(1,nelements);
MeanBestTrack.ntraj=zeros(1,nelements);

for iens=1:ens_size
    
[intersection,index1,index2]=intersect(MeanBestTrack.daten,ExperimentBestTrack(iens).daten);

MeanBestTrack.minlon(index1)=MeanBestTrack.minlon(index1)+ExperimentBestTrack(iens).minlon(index2);
MeanBestTrack.minlat(index1)=MeanBestTrack.minlat(index1)+ExperimentBestTrack(iens).minlat(index2);
MeanBestTrack.minanom(index1)=MeanBestTrack.minanom(index1)+ExperimentBestTrack(iens).minanom(index2);
MeanBestTrack.maxwind(index1)=MeanBestTrack.maxwind(index1)+ExperimentBestTrack(iens).maxwind(index2);
MeanBestTrack.ntraj(index1)=MeanBestTrack.ntraj(index1)+1;

end

%CALCULO LA MEDIA DE LAS POSICIONES DE LOS MIEMBROS DEL ENSAMBLE.

MeanBestTrack.ntraj(MeanBestTrack.ntraj == 0)=NaN;

MeanBestTrack.minlon=MeanBestTrack.minlon./MeanBestTrack.ntraj;
MeanBestTrack.minlat=MeanBestTrack.minlat./MeanBestTrack.ntraj;
MeanBestTrack.minanom=MeanBestTrack.minanom./MeanBestTrack.ntraj;
MeanBestTrack.maxwind=MeanBestTrack.maxwind./MeanBestTrack.ntraj;

isnanntraj=isnan(MeanBestTrack.ntraj);
MeanBestTrack.minlon(isnanntraj)=[];
MeanBestTrack.minlat(isnanntraj)=[];
MeanBestTrack.minanom(isnanntraj)=[];
MeanBestTrack.maxwind(isnanntraj)=[];
MeanBestTrack.daten(isnanntraj)=[];
MeanBestTrack.ntraj(isnanntraj)=[];

lon1=CurrentTracks(it).minlon;
lat1=CurrentTracks(it).minlat;
times1=CurrentTracks(it).daten;
lon2=MeanBestTrack.minlon;
lat2=MeanBestTrack.minlat;
times2=MeanBestTrack.daten;
     
%CALCULO EL ERROR DE POSICION PARA LA MEDIA DEL ENSAMBLE.
[dist_track npuntos ntimes index1 index2]...
    =compare_track_fun(lon1,lat1,times1,lon2,lat2,times2,maxdist);
 
MeanBestTrack.dist_track=NaN(1,length(MeanBestTrack.minlon));
MeanBestTrack.dist_track(index2)=dist_track;

%ACUMULO EL ERROR EN LA VARIABLE TOTALDISTTRACK

tmptime=sf:timefrec/24:ef;
tmpindex=~isnan(MeanBestTrack.dist_track);
[intersection,index1,index2]=intersect(MeanBestTrack.daten(tmpindex),tmptime);
totaldisttrack(nstorm,:,iexp)=NaN;
totaldisttrack(nstorm,index2,iexp)=MeanBestTrack.dist_track(index1);

%CALCULO EL ERROR DE INTENSIDAD PARA LA MEDIA DEL ENSAMBLE
[intersection,index1,index2]=intersect(CurrentTracks(it).daten,MeanBestTrack.daten);
[intersection,index1,index2]=intersect(CurrentTracks(it).daten,MeanBestTrack.daten);
MeanBestTrack.dist_p=NaN(1,length(MeanBestTrack.minlon));
MeanBestTrack.dist_p=NaN(1,length(MeanBestTrack.minlon));
MeanBestTrack.dist_p(index2)=( MeanBestTrack.minanom(index2) - CurrentTracks(it).minanomf(index1) );

%ACUMULO EL ERROR EN LA VARIABLE TOTALDISTTRACK
tmpindex=~isnan(MeanBestTrack.dist_p);
tmpindex=~isnan(MeanBestTrack.dist_p);
[intersection,index1,index2]=intersect(MeanBestTrack.daten(tmpindex),tmptime);

totaldiffp(nstorm,:,iexp)=NaN;
totaldiffp(nstorm,index2,iexp)=MeanBestTrack.dist_p(index1);
%ntotaldisttrack(nstorm,iexp,index2)=ntotaldisttrack(iexp,index2)+1;


%-----------------------------

if( sf == datenum('2008091612','yyyymmddHH') & strcmp(strtrim(CurrentTracks(it).name),'SINLAKU') ) 
   Caso1.title=[datestr(sf) ' - ' CurrentTracks(it).name];
   Caso1.longitud.besttrack=CurrentTracks(it).minlon;
   Caso1.latitud.besttrack=CurrentTracks(it).minlat;
   Caso1.leadtime.besttrack=(MeanBestTrack.daten-sf)*24;
   if( iexp == 1)
          
          Caso1.longitud.exp1=MeanBestTrack.minlon;
          Caso1.latitud.exp1=MeanBestTrack.minlat;
          Caso1.leadtime.exp1=(MeanBestTrack.daten-sf)*24;
          Caso1.error.exp1=MeanBestTrack.dist_track/1e3;
   end
   if( iexp == 2)
          Caso1.longitud.exp2=MeanBestTrack.minlon;
          Caso1.latitud.exp2=MeanBestTrack.minlat;
          Caso1.leadtime.exp2=(MeanBestTrack.daten-sf)*24;
          Caso1.error.exp2=MeanBestTrack.dist_track/1e3;
   end   
  
end

if( sf == datenum('2008091412','yyyymmddHH') & strcmp(strtrim(CurrentTracks(it).name),'SINLAKU') ) 
   Caso2.title=[datestr(sf) ' - ' CurrentTracks(it).name];
   Caso2.longitud.besttrack=CurrentTracks(it).minlon;
   Caso2.latitud.besttrack=CurrentTracks(it).minlat;
   Caso2.leadtime.besttrack=(MeanBestTrack.daten-sf)*24;
   if( iexp == 1)
          
          Caso2.longitud.exp1=MeanBestTrack.minlon;
          Caso2.latitud.exp1=MeanBestTrack.minlat;
          Caso2.leadtime.exp1=(MeanBestTrack.daten-sf)*24;
          Caso2.error.exp1=MeanBestTrack.dist_track/1e3;
   end
   if( iexp == 2)
          Caso2.longitud.exp2=MeanBestTrack.minlon;
          Caso2.latitud.exp2=MeanBestTrack.minlat;
          Caso2.leadtime.exp2=(MeanBestTrack.daten-sf)*24;
          Caso2.error.exp2=MeanBestTrack.dist_track/1e3;
   end   
  
end

   
end %End del do sobre los experimentos.

end %End del do sobre los sistemas.

cdnum=cdnum+traj_start_frec/24;
end

%If we have nan in one experiment then we remove that datapoint from both
%experiments

%For location error
for ii=1:size(totaldisttrack,1)
    for jj=1:size(totaldisttrack,2)
        tmp=squeeze(totaldisttrack(ii,jj,:));
        logicalvar=any(tmp == 0);
        if(logicalvar)
            totaldisttrack(ii,jj,:)=NaN;
        end
    end
end
for ii=1:size(totaldiffp,1)
    for jj=1:size(totaldiffp,2)
        tmp=squeeze(totaldiffp(ii,jj,:));
        logicalvar=any(tmp == 0);
        if(logicalvar)
            totaldiffp(ii,jj,:)=NaN;
        end
    end
end


%Get simple statistics of the errors.
meandisttrack=squeeze(nanmean(totaldisttrack(:,1:2:end,:),1));
ndisttrack=squeeze(nansum(~isnan(totaldisttrack(:,1:2:end,:)),1));
stddisttrack=squeeze(nanstd(totaldisttrack(:,1:2:end,:),0,1));
maxdisttrack=squeeze(max(totaldisttrack(:,1:2:end,:),[],1));
mindisttrack=squeeze(min(totaldisttrack(:,1:2:end,:),[],1));

meandiffp=squeeze(nanmean(totaldiffp(:,1:2:end,:),1));
ndiffp=squeeze(nansum(~isnan(totaldiffp(:,1:2:end,:)),1));
stddiffp=squeeze(nanstd(totaldiffp(:,1:2:end,:),0,1));
maxdiffp=squeeze(max(totaldiffp(:,1:2:end,:),[],1));
mindiffp=squeeze(min(totaldiffp(:,1:2:end,:),[],1));

Ejemplo1(1).name='CTRL';
Ejemplo1(1).longitude=Caso1.longitud.exp1;
Ejemplo1(1).latitude=Caso1.latitud.exp1;
Ejemplo1(1).error=Caso1.error.exp1;
Ejemplo1(1).leadtime=Caso1.leadtime.exp1;

Ejemplo1(2).name='PE';
Ejemplo1(2).longitude=Caso1.longitud.exp2;
Ejemplo1(2).latitude=Caso1.latitud.exp2;
Ejemplo1(2).error=Caso1.error.exp2;
Ejemplo1(2).leadtime=Caso1.leadtime.exp2;

Ejemplo1(3).name='BestTrack';
Ejemplo1(3).longitude=Caso1.longitud.besttrack;
Ejemplo1(3).latitude=Caso1.latitud.besttrack;
Ejemplo1(3).error=zeros(size(Caso1.latitud.besttrack));
Ejemplo1(3).leadtime=Caso1.leadtime.besttrack;

Ejemplo2(1).name='CTRL';
Ejemplo2(1).longitude=Caso2.longitud.exp1;
Ejemplo2(1).latitude=Caso2.latitud.exp1;
Ejemplo2(1).error=Caso2.error.exp1;
Ejemplo2(1).leadtime=Caso2.leadtime.exp1;

Ejemplo2(2).name='PE';
Ejemplo2(2).longitude=Caso2.longitud.exp2;
Ejemplo2(2).latitude=Caso2.latitud.exp2;
Ejemplo2(2).error=Caso2.error.exp2;
Ejemplo1(2).leadtime=Caso2.leadtime.exp2;

Ejemplo2(3).name='BestTrack';
Ejemplo2(3).longitude=Caso2.longitud.besttrack;
Ejemplo2(3).latitude=Caso2.latitud.besttrack;
Ejemplo2(3).error=zeros(size(Caso2.latitud.besttrack));
Ejemplo1(3).leadtime=Caso2.leadtime.besttrack;

save('Typhoon_statistics.mat','meandisttrack','stddisttrack','ndisttrack','Ejemplo2','Ejemplo1' ...
                                   ,'meandiffp'    ,'stddiffp'    ,'ndiffp');

%saveas(gcf,'Figure_9.fig
