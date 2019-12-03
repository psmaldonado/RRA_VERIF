clear all
close all

%To compare the 40 member control against the GDAS.

BASEURL='/home/jruiz/datos/EXPERIMENTS/';
EXPNAME='FORECAST_QFX2DNOZLOC40M_MEMNC';
CMORPHPATH='/home/jruiz/datos/DATA/CMORPH/';

FORECAST_LENGTH=72;
INIT_FREC=24;
OUTPUT_FREC=06;

VERIFDIR=[BASEURL '/' EXPNAME '/verification_cmorph/'];
system(['mkdir ' VERIFDIR]);

INIDATE='2008082012';
ENDDATE='2008083012';

accum_times=[6 12 24];
umbral=[1 5 10 20 50];

%==========================================================================
%Read and plot data
%==========================================================================
nfor=FORECAST_LENGTH/6+1;

inid=datenum(INIDATE,'yyyymmddHH');
endd=datenum(ENDDATE,'yyyymmddHH');

%==========================================================================
%Dimensions.
[xdef ydef]=def_grid_grads;

nx=length(xdef);
ny=length(ydef);
nz=13;

%Lets loop over the accumulation times.  
max_times=endd-inid+1;

   
for ia=1:length(accum_times)
  
curd=inid;
i=1;
max_index=floor(FORECAST_LENGTH./accum_times(ia));

fprecip=NaN(nx,ny,max_index,max_times);
oprecip=NaN(nx,ny,max_index,max_times);

    
while(curd <= endd)
   

      dateinit  =datestr(curd,'yyyymmddHHMM');
      
      
      for ifor=1:nfor;
      %Read in letkf analysis ensemble mean.
      lead=(ifor-1)*OUTPUT_FREC;
      if( lead < 10 )
  leadstr=['0' num2str(lead)];
     else
  leadstr=num2str(lead);
      end
      

	  
	 if( lead >0 & mod(lead,accum_times(ia))==0 )
	     
	     
	     file=[BASEURL '/' EXPNAME '/' dateinit '/lluvia_media_a' num2str(accum_times(ia)) '_f' leadstr '.dat' ];
	     nfile=fopen(file,'r','b');
	     if(nfile >0)
	     forecast_precip=fread(nfile,[nx ny],'single');
	     fclose(nfile);
	     else
	     forecast_precip=NaN(nx,ny);
	     end
	     
	     date_cmorph=datestr(curd+lead/24,'yyyymmddHH');
	     file=[CMORPHPATH '/CMORPH_V1.0_ADJ_WRF_DOMAIN_a_' num2str(accum_times(ia)) '_' date_cmorph ];
	     nfile=fopen(file,'r','l');
	     if(nfile>0)
	     observed_precip=fread(nfile,[nx ny],'single');
	     fclose(nfile);
	     else
	     observed_precip=NaN(nx,ny);
	     end
	     
	     
	     fprecip(:,:,lead/accum_times(ia),i)=forecast_precip;
	     oprecip(:,:,lead/accum_times(ia),i)=observed_precip;
	     
	 end
	  
      end
     
      
  
  i=i+1;
  curd=curd+INIT_FREC/24; 
end

%Now compute ETS and BIAS.
n_muestras=100; %Bootstrap sample size.
alfa=1; %Significance level
i_corte=round(n_muestras*alfa/(2*100));


meano{ia}=nanmean( oprecip-fprecip , 4 );
meanf{ia}=nanmean( oprecip-fprecip , 4 );


ets{ia}=NaN(length(umbral),size(fprecip,3),3);
bias{ia}=NaN(length(umbral),size(fprecip,3),3);

ets_tr{ia}=NaN(length(umbral),size(fprecip,3),3);
bias_tr{ia}=NaN(length(umbral),size(fprecip,3),3);

ets_ml{ia}=NaN(length(umbral),size(fprecip,3),3);
bias_ml{ia}=NaN(length(umbral),size(fprecip,3),3);


for index=1:size(fprecip,3);

    %Ets and bias for the entire domain.
    tmpo=reshape(squeeze(oprecip(5:end-5,5:end-5,index,:)),[(nx-10+1)*(ny-10+1)*max_times 1]);
    tmpf=reshape(squeeze(fprecip(5:end-5,5:end-5,index,:)),[(nx-10+1)*(ny-10+1)*max_times 1]);
    random_index=bootstrap_fun(length(tmpo),n_muestras);
    for ii=1:n_muestras
      tmp_ets(:,ii)=ets_fun(tmpo(random_index(:,ii)),tmpf(random_index(:,ii)),umbral);    
      tmp_bias(:,ii)=biasarea_fun(tmpo(random_index(:,ii)),tmpf(random_index(:,ii)),umbral); 
    end 
    %Primero ordenamos la variable de mayor a menor
    tmp_ets=sort(tmp_ets,3,'ascend');

    %Interpolo el valor de los scores. correspondiente al valor de corte superior e
    %inferior.
    ets{ia}(:,index,1)=median(tmp_ets,2);              %The first element is the median.
    ets{ia}(:,index,2)=prctile(tmp_ets,alfa,2);     %The second element is the lower bound.
    ets{ia}(:,index,3)=prctile(tmp_ets,100-alfa,2);     %The third element is the upper bound.

    bias{ia}(:,index,1)=median(tmp_bias,2);
    bias{ia}(:,index,2)=prctile(tmp_bias,alfa,2);
    bias{ia}(:,index,3)=prctile(tmp_bias,100-alfa,2);

    %Ets and bias over the tropics.
    tmpo=reshape(squeeze(oprecip(5:end-5,5:55,index,:)),[(nx-10+1)*(55-5+1)*max_times 1]);
    tmpf=reshape(squeeze(fprecip(5:end-5,5:55,index,:)),[(nx-10+1)*(55-5+1)*max_times 1]);
    random_index=bootstrap_fun(length(tmpo),n_muestras);

    for ii=1:n_muestras
      tmp_ets(:,ii)=ets_fun(tmpo(random_index(:,ii)),tmpf(random_index(:,ii)),umbral);
      tmp_bias(:,ii)=biasarea_fun(tmpo(random_index(:,ii)),tmpf(random_index(:,ii)),umbral);                                                                                                            
    end
    %Primero ordenamos la variable de mayor a menor
    tmp_ets=sort(tmp_ets,3,'ascend');

    %Interpolo el valor de los scores. correspondiente al valor de corte superior e
    %inferior.
    ets_tr{ia}(:,index,1)=median(tmp_ets,2);              %The first element is the median.
    ets_tr{ia}(:,index,2)=prctile(tmp_ets,alfa,2);     %The second element is the lower bound.
    ets_tr{ia}(:,index,3)=prctile(tmp_ets,100-alfa,2);     %The third element is the upper bound.

    bias_tr{ia}(:,index,1)=median(tmp_bias,2);
    bias_tr{ia}(:,index,2)=prctile(tmp_bias,alfa,2);
    bias_tr{ia}(:,index,3)=prctile(tmp_bias,100-alfa,2);


    %Ets and bias over mid-latitudes
    tmpo=reshape(squeeze(oprecip(5:end-5,55:end-5,index,:)),[(nx-10+1)*(ny-5-55+1)*max_times 1]);
    tmpf=reshape(squeeze(fprecip(5:end-5,55:end-5,index,:)),[(nx-10+1)*(ny-5-55+1)*max_times 1]);
    random_index=bootstrap_fun(length(tmpo),n_muestras);

    for ii=1:n_muestras
      tmp_ets(:,ii)=ets_fun(tmpo(random_index(:,ii)),tmpf(random_index(:,ii)),umbral);
      tmp_bias(:,ii)=biasarea_fun(tmpo(random_index(:,ii)),tmpf(random_index(:,ii)),umbral);                                       
    end
    %Primero ordenamos la variable de mayor a menor
    tmp_ets=sort(tmp_ets,3,'ascend');
    
    %Interpolo el valor de los scores. correspondiente al valor de corte superior e
    %inferior.
    ets_ml{ia}(:,index,1)=median(tmp_ets,2);              %The first element is the median.
    ets_ml{ia}(:,index,2)=prctile(tmp_ets,alfa,2);     %The second element is the lower bound.
    ets_ml{ia}(:,index,3)=prctile(tmp_ets,100-alfa,2);     %The third element is the upper bound.

    bias_ml{ia}(:,index,1)=median(tmp_bias,2);
    bias_ml{ia}(:,index,2)=prctile(tmp_bias,alfa,2);
    bias_ml{ia}(:,index,3)=prctile(tmp_bias,100-alfa,2);

end


end

    
save([VERIFDIR '/ets_bias.mat'],'ets','bias','ets_tr','bias_tr','ets_ml','bias_ml','meano','meanf');
                             



