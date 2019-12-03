
function  [obslon obslat obslev obstime ...
           obselm obstyp obsdat obserr  ...
           hxf]                             =fun_read_letkf_verification(file,nbv)

%This function read a LETKF verification file and generates different
%arrays with the data.
% File is the name of the file that is going to be read.
% nbv is the number of ensemble members in the experiment.



readbufrl=8+nbv;    %Elements in bufr for read.
readarray=NaN(600000,readbufrl);

nfile=fopen(file,'r','b');

cont=true;
nrecords=0;

while(cont)

readbufr=fread(nfile,readbufrl,'single');
  if(~isempty(readbufr))
    nrecords=nrecords+1;
    readarray(nrecords,:)=readbufr;
    %cont=false
  else
    cont=false;  %EOF has been reached.
  end
end

if(nrecords > 0)
obslon=readarray(1:nrecords,1);       %Longitude
obslat=readarray(1:nrecords,2);       %Latitude
obslev=readarray(1:nrecords,3);       %Level (Pa)
obstime=readarray(1:nrecords,4);      %Time (hours with respect to the beggining of the assimilation window).
obselm=readarray(1:nrecords,5);       %variable code.
obstyp=readarray(1:nrecords,6);       %type of observation (i.e. AIRS, SOUNDINGS, SURFACE, etc.)
obsdat=readarray(1:nrecords,7);       %Observation itself.
obserr=readarray(1:nrecords,8);       %Observational error.
hxf=readarray(1:nrecords,8+1:end);    %Ensemble in the observational space.

fprintf('A total of %f.0 observations has been found in file %s \n',nrecords,file)

else
    
obslon=[];
obslat=[];
obslev=[];
obstime=[];
obselm=[];
obstyp=[];
obsdat=[];
obserr=[];
hxf=[];

fprintf('No verification observations has been found in file %s \n',file)
end


return

 
