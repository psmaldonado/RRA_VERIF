clear all
close all


init_time='20130713110440';
end_time ='20130713200010';
%end_time='20130713110440';


interval=30;  %Interval is in seconds!!!

folder_path=['/data1/jruiz/RADARQC/2013-0713/matlab/'];
radardatapath=['/data1/jruiz/RADARQC/2013-0713/matlab/'];
outpath=radardatapath;

endian='l';  %Endian order of input.

%cartesian grid
xres=100; %Horizontal res in m (x)
yres=100; %Horizontal res in m (y)
zres=100; %meters

zmax=20000;


current_time_num=datenum(init_time,'yyyymmddHHMMSS');
end_time_num=datenum(end_time,'yyyymmddHHMMSS');

first_cycle=true;

while ( current_time_num <= end_time_num )
    
  date_str=datestr(current_time_num,'yyyymmddHHMMSS');
  %Input files
  inputfile=[radardatapath 'PAWR_LETKF_INPUTV3_' date_str(1:8) '-' date_str(9:14) '.dat']
  outputfile=[outpath '/PAWR_CART3D_' date_str(1:8) '-' date_str(9:14) '.dat'];
  

  year=str2num(datestr(current_time_num,'yyyy'));
  month=str2num(datestr(current_time_num,'mm'));
  day=str2num(datestr(current_time_num,'dd'));
  hour=str2num(datestr(current_time_num,'HH'));
  minute=str2num(datestr(current_time_num,'MM'));
  second=str2num(datestr(current_time_num,'SS'));
  
  
  
  %Read the data
  [radar , ref , wind , qcflag , attenuation]=read_radar_data_seq(inputfile,endian);
  
  %Assign an arbitrary value to those missing values that are believed to
  %correspond to no clouds.
  ref( ref < 0 & qcflag < 900)=0.0;
  ref( ref < 0 & qcflag >= 900)=NaN;
  
  if(first_cycle)
      tmp_elevation=[];
      tmp_range=[];
      sounding.nothing=[];
      [radar]=georeference_radar_data(radar,sounding);
  end
  
  radar.radius=radar.radius+100;
  radar.Rh=radar.Rh+100;
  
  [data_cart xv yv zv tmp_elevation tmp_range tmp_radar_data]=interp_3d_fun(radar,ref,tmp_elevation,tmp_range,xres,yres);

  nout=fopen(outputfile,'w','l');
  
  data_cart(isnan(data_cart))=-9999; %Set an undef code for the missing values.
  
  for iz=1:length(zv)
    
    fwrite(nout,data_cart(:,:,iz)','single');
   
  end
  fclose(nout);

  current_time_num=current_time_num + (interval/86400);
  current_time_num= round(current_time_num*86400)/86400;

end

