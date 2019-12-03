clear all
close all

%From the grads output for each experiment, compute the ensemble mean and
%spread. (The ensemble mean is alredy computed by the system so only que
%ensemble spread is written).
nx=136;
ny=108;
nfields=5*14+10+3
enssize=40;
endian='b';

startdate='2008080706';
enddate=  '2008093000';

EXPERIMENT_PATH='/home/jruiz/datos/EXPERIMENTS/QFX0D40M_IDEAL_CONSTANTPAR0.8_MEMNC/'

datenumc=datenum(startdate,'yyyymmddHH');
datenume=datenum(enddate,'yyyymmddHH');


while ( datenumc <= datenume)

datestr(datenumc,'yyyymmddHH')

%COMPUTE THE ANALISIS MEAN AND SPREAD.
mean=zeros(nx,ny,nfields);
sprd=zeros(nx,ny,nfields);
for ii = 1:enssize
    
    enss=num2str(ii);
    if( ii < 100 );enss=['0' enss];end
    if( ii < 10  );enss=['0' enss];end
    
    filepath=[EXPERIMENT_PATH '/anal/' datestr(datenumc,'yyyymmddHHMM') '/plev_anal_' enss '.dat'];
    data=read_bin_fun(nx,ny,nfields,filepath,endian);
    data(data > 1e10)=NaN;
    
    mean=mean+data;
    sprd=sprd+data.^2;
    
end

mean=mean/enssize;

sprd=sprd/enssize-mean.^2;

filemean=[EXPERIMENT_PATH '/anal/' datestr(datenumc,'yyyymmddHHMM') '/plev_anal_sprd.dat'];
ns=fopen(filemean,'w',endian);
for ii = 1:nfields
   fwrite(ns,sprd(:,:,ii),'single'); 
end

filemean=[EXPERIMENT_PATH '/anal/' datestr(datenumc,'yyyymmddHHMM') '/plev_anal_mean.dat'];
ns=fopen(filemean,'w',endian);
for ii = 1:nfields
   fwrite(ns,mean(:,:,ii),'single');
end
fclose(ns);

%COMPUTE THE GUESS MEAN AND SPREAD.
mean=zeros(nx,ny,nfields);
sprd=zeros(nx,ny,nfields);
for ii = 1:enssize
    
    enss=num2str(ii);
    if( ii < 100 );enss=['0' enss];end
    if( ii < 10  );enss=['0' enss];end
    
    filepath=[EXPERIMENT_PATH '/gues/' datestr(datenumc,'yyyymmddHHMM') '/plev_gues_' enss '.dat'];
    data=read_bin_fun(nx,ny,nfields,filepath,endian);
    data(data > 1e10)=NaN;
    
    mean=mean+data;
    sprd=sprd+data.^2;
    
end

mean=mean/enssize;

sprd=sprd/enssize-mean.^2;


filemean=[EXPERIMENT_PATH '/gues/' datestr(datenumc,'yyyymmddHHMM') '/plev_gues_sprd.dat'];

ns=fopen(filemean,'w',endian);

for ii = 1:nfields
   fwrite(ns,sprd(:,:,ii),'single'); 
end
fclose(ns);

filemean=[EXPERIMENT_PATH '/gues/' datestr(datenumc,'yyyymmddHHMM') '/plev_gues_mean.dat'];
ns=fopen(filemean,'w',endian);
for ii = 1:nfields
   fwrite(ns,mean(:,:,ii),'single');
end
fclose(ns);


datenumc=datenumc+1/4;
end
