clear all
close all

%Script to read a plot 1D parameter ensemble evolution.

DATA_PATH='/data/letkf02/jruiz/'

EXPERIMENT='/EXP_40mem_sfflux_ntpar_smooth_fixparinf0.05_qfxust/';
CONSTFILE='/data/letkf02/jruiz/const.grd'; %constant fields.
TRUTH='/FNL_ANALYSIS/';                                     %True experiment.
EXP_INI_DATE='2008081506';
EXP_END_DATE='2008093018';
EST_FREC=6;                                    %Analysis frequency. (hours)

BIAS_OFFSET=10;                   %How many times before bias computation starts.

%Definiciones de la reticula del SPEEDY.

nvars=9*40+4; 
nx_s=137;
ny_s=109;
nz_s=40;

%Let's read surface constants file.
   nconst=fopen(CONSTFILE,'r','b');
   if(nconst ~= -1)
     longitude=fread(nconst,[nx_s ny_s],'single')';
     latitude=fread(nconst,[nx_s ny_s],'single')';
     longitude_u=fread(nconst,[nx_s ny_s],'single')';
     latitude_u=fread(nconst,[nx_s ny_s],'single')';
     longitude_v=fread(nconst,[nx_s ny_s],'single')';
     latitude_v=fread(nconst,[nx_s ny_s],'single')';
     fcori=fread(nconst,[nx_s ny_s],'single')';
     hgt=fread(nconst,[nx_s ny_s],'single')';
     landmask=fread(nconst,[nx_s ny_s],'single')';
     fclose(nconst);
   else
     display('WARNING, I DID NOT FIND THE CONST FILE')
   end

%Select sea and land points.

points_s=landmask==0;
points_l=landmask==1;



%Read parameter ensemble

INI_DATE_NUM=datenum(EXP_INI_DATE,'yyyymmddHH');
END_DATE_NUM=datenum(EXP_END_DATE,'yyyymmddHH');
C_DATE_NUM=INI_DATE_NUM;
NTIMES=(END_DATE_NUM-INI_DATE_NUM)*24/EST_FREC+1;

ANAL_RMSE_SERIE_G=NaN(nvars,NTIMES);     %RMSE GLOBAL
ANAL_SPRD_SERIE_G=NaN(nvars,NTIMES);     %SPRD GLOBAL

GUES_RMSE_SERIE_G=NaN(nvars,NTIMES);     %RMSE GLOBAL
GUES_SPRD_SERIE_G=NaN(nvars,NTIMES);     %SPRD GLOBAL

ANAL_RMSE_SERIE_LAND=NaN(nvars,NTIMES);     %RMSE GLOBAL
ANAL_SPRD_SERIE_LAND=NaN(nvars,NTIMES);     %SPRD GLOBAL

GUES_RMSE_SERIE_LAND=NaN(nvars,NTIMES);     %RMSE GLOBAL
GUES_SPRD_SERIE_LAND=NaN(nvars,NTIMES);     %SPRD GLOBAL

ANAL_RMSE_SERIE_SEA=NaN(nvars,NTIMES);     %RMSE GLOBAL
ANAL_SPRD_SERIE_SEA=NaN(nvars,NTIMES);     %SPRD GLOBAL

GUES_RMSE_SERIE_SEA=NaN(nvars,NTIMES);     %RMSE GLOBAL
GUES_SPRD_SERIE_SEA=NaN(nvars,NTIMES);     %SPRD GLOBAL


ANAL_BIAS=zeros(ny_s,nx_s,nvars);
ANAL_SMEAN=zeros(ny_s,nx_s,nvars);
ANAL_SSPRD=zeros(ny_s,nx_s,nvars);

GUES_BIAS=zeros(ny_s,nx_s,nvars);
GUES_SMEAN=zeros(ny_s,nx_s,nvars);
GUES_SSPRD=zeros(ny_s,nx_s,nvars);


%For error / spread correlation computation.
ANAL_ERRORSPRD=zeros(ny_s,nx_s,nvars);
ANAL_SPRDSPRD=zeros(ny_s,nx_s,nvars);
ANAL_ERRORMEAN=zeros(ny_s,nx_s,nvars);
ANAL_SPRDMEAN=zeros(ny_s,nx_s,nvars);
ANAL_ERRORSPRDCORREL=zeros(ny_s,nx_s,nvars);

GUES_ERRORSPRD=zeros(ny_s,nx_s,nvars);
GUES_SPRDSPRD=zeros(ny_s,nx_s,nvars);
GUES_ERRORMEAN=zeros(ny_s,nx_s,nvars);
GUES_SPRDMEAN=zeros(ny_s,nx_s,nvars);
GUES_ERRORSPRDCORREL=zeros(ny_s,nx_s,nvars);


analnbias=0;
guesnbias=0;
while ( C_DATE_NUM <= END_DATE_NUM )
  ITIME=(C_DATE_NUM-INI_DATE_NUM)*24/EST_FREC+1;
   
   anamean=strcat(DATA_PATH,EXPERIMENT,'/anal/',datestr(C_DATE_NUM,'yyyymmddHH'),'00/','anal_me.grd')
   anasprd=strcat(DATA_PATH,EXPERIMENT,'/anal/',datestr(C_DATE_NUM,'yyyymmddHH'),'00/','anal_sp.grd');

   guesmean=strcat(DATA_PATH,EXPERIMENT,'/anal/',datestr(C_DATE_NUM,'yyyymmddHH'),'00/','gues_me.grd');
   guessprd=strcat(DATA_PATH,EXPERIMENT,'/anal/',datestr(C_DATE_NUM,'yyyymmddHH'),'00/','gues_sp.grd');

   truenat=strcat(DATA_PATH,TRUTH,'/',datestr(C_DATE_NUM,'yyyymmddHH'),'00/','anal001.grd');
   
   nanam=fopen(anamean,'r','b');
   nanas=fopen(anasprd,'r','b');
   ngsm=fopen(guesmean,'r','b');
   ngss=fopen(guessprd,'r','b');
   ntrue=fopen(truenat,'r','b');
   
   analtmpmean=NaN(ny_s,nx_s,nvars);
   analtmpsprd=NaN(ny_s,nx_s,nvars);
   guestmpmean=NaN(ny_s,nx_s,nvars);
   guestmpsprd=NaN(ny_s,nx_s,nvars);

   tmptrue=NaN(ny_s,nx_s,nvars);
   
   if(nanam ~= -1)
     for ivars=1:nvars
     analtmpmean(:,:,ivars)=fread(nanam,[nx_s ny_s],'single')';
     end
     fclose(nanam);
   else
     display('WARNING, I DID NOT FIND ANALYSIS MEAN FILE')
   end
   
   if(nanas ~= -1)
     for ivars=1:nvars
     analtmpsprd(:,:,ivars)=fread(nanas,[nx_s ny_s],'single')';
     end
     fclose(nanas); 
   else
     display('WARNING, I DID NOT FIND ANALYSIS SPREAD FILE')
   end

   if(nanam ~= -1)
     for ivars=1:nvars
     guestmpmean(:,:,ivars)=fread(ngsm,[nx_s ny_s],'single')';
     end
     fclose(ngsm);
   else
     display('WARNING, I DID NOT FIND GUES MEAN FILE')
   end

   if(nanas ~= -1)
     for ivars=1:nvars
     guestmpsprd(:,:,ivars)=fread(ngss,[nx_s ny_s],'single')';
     end
     fclose(ngss);
   else
     display('WARNING, I DID NOT FIND GUES SPREAD FILE')
   end

   
   if(ntrue ~= -1)
     for ivars=1:nvars
     tmptrue(:,:,ivars)=fread(ntrue,[nx_s ny_s],'single')';
     end
     fclose(ntrue); 
   else
     display('WARNING, I DID NOT FIND VERIFICATION FILE')
   end
  
   
 analtmpdiff=(analtmpmean-tmptrue).^2;
 guestmpdiff=(guestmpmean-tmptrue).^2; 
 
 for ivar=1:nvars

 tmpanal=squeeze(analtmpdiff(:,:,ivar));
 tmpgues=squeeze(guestmpdiff(:,:,ivar));

 analauxrmseg(ivar)=squeeze(nanmean(nanmean(cos(latitude*3.14159/180).*tmpanal)));
 guesauxrmseg(ivar)=squeeze(nanmean(nanmean(cos(latitude*3.14159/180).*tmpgues)));

 analauxrmseland(ivar)=squeeze(nanmean(cos(latitude(points_l)*3.14159/180).*tmpanal(points_l)));
 guesauxrmseland(ivar)=squeeze(nanmean(cos(latitude(points_l)*3.14159/180).*tmpgues(points_l)));

 analauxrmsesea(ivar)=squeeze(nanmean(cos(latitude(points_s)*3.14159/180).*tmpanal(points_s)));
 guesauxrmsesea(ivar)=squeeze(nanmean(cos(latitude(points_s)*3.14159/180).*tmpgues(points_s)));

 tmpanal=squeeze(analtmpsprd(:,:,ivar));
 tmpgues=squeeze(guestmpsprd(:,:,ivar));

 analauxsprdg(ivar)=squeeze(nanmean(nanmean(tmpanal)));
 guesauxsprdg(ivar)=squeeze(nanmean(nanmean(tmpgues)));

 analauxsprdland(ivar)=squeeze(nanmean(cos(latitude(points_l)*3.14159/180).*tmpanal(points_l)));
 guesauxsprdland(ivar)=squeeze(nanmean(cos(latitude(points_l)*3.14159/180).*tmpgues(points_l)));

 analauxsprdsea(ivar)=squeeze(nanmean(cos(latitude(points_s)*3.14159/180).*tmpanal(points_s)));
 guesauxsprdsea(ivar)=squeeze(nanmean(cos(latitude(points_s)*3.14159/180).*tmpgues(points_s)));

 tmpanal=squeeze(analtmpmean(:,:,ivar));
 tmpgues=squeeze(guestmpmean(:,:,ivar));

 analauxmeang(ivar)=squeeze(nanmean(nanmean(cos(latitude*3.14159/180).*tmpanal)));
 guesauxmeang(ivar)=squeeze(nanmean(nanmean(cos(latitude*3.14159/180).*tmpgues)));

 analauxmeanland(ivar)=squeeze(nanmean(nanmean(cos(latitude(points_l)*3.14159/180).*tmpanal(points_l))));
 guesauxmeanland(ivar)=squeeze(nanmean(nanmean(cos(latitude(points_l)*3.14159/180).*tmpgues(points_l))));

 analauxmeansea(ivar)=squeeze(nanmean(nanmean(cos(latitude(points_s)*3.14159/180).*tmpanal(points_s))));
 guesauxmeansea(ivar)=squeeze(nanmean(nanmean(cos(latitude(points_s)*3.14159/180).*tmpgues(points_s))));

 end
 
 if(ntrue ~=-1 & nanam ~=-1 & ITIME >= BIAS_OFFSET)
 ANAL_BIAS=ANAL_BIAS+(analtmpmean-tmptrue);
 analnbias=analnbias+1;
 %Computation of RCRV (for ensemble reliability)
 s=(analtmpmean-tmptrue)./analtmpsprd;
 ANAL_SMEAN=ANAL_SMEAN+s;
 ANAL_SSPRD=ANAL_SSPRD+s.^2;
 
 ANAL_ERRORSPRD=ANAL_ERRORSPRD+analtmpdiff;
 ANAL_SPRDSPRD=ANAL_SPRDSPRD+analtmpsprd.^2;
 ANAL_ERRORMEAN=ANAL_ERRORMEAN+(analtmpdiff).^0.5;
 ANAL_SPRDMEAN=ANAL_SPRDMEAN+analtmpsprd;
 ANAL_ERRORSPRDCORREL=ANAL_ERRORSPRDCORREL+(analtmpdiff.^0.5).*analtmpsprd;
 end

 if(ntrue ~=-1 & ngsm ~=-1 & ITIME >= BIAS_OFFSET)
 GUES_BIAS=GUES_BIAS+(guestmpmean-tmptrue);
 guesnbias=guesnbias+1;
 %Computation of RCRV (for ensemble reliability)
 s=(guestmpmean-tmptrue)./guestmpsprd;
 GUES_SMEAN=GUES_SMEAN+s;
 GUES_SSPRD=GUES_SSPRD+s.^2;

 GUES_ERRORSPRD=GUES_ERRORSPRD+guestmpdiff;
 GUES_SPRDSPRD=GUES_SPRDSPRD+guestmpsprd.^2;
 GUES_ERRORMEAN=GUES_ERRORMEAN+(guestmpdiff).^0.5;
 GUES_SPRDMEAN=GUES_SPRDMEAN+guestmpsprd;
 GUES_ERRORSPRDCORREL=GUES_ERRORSPRDCORREL+(guestmpdiff.^0.5).*guestmpsprd;
 end

 
 if(~isnan(analauxrmseg))
     ANAL_RMSE_SERIE_G(:,ITIME)=sqrt(analauxrmseg);
     ANAL_SPRD_SERIE_G(:,ITIME)=sqrt(analauxsprdg);
     ANAL_MEAN_SERIE_G(:,ITIME)=analauxmeang;
 end
 if(~isnan(guesauxrmseg))
     GUES_RMSE_SERIE_G(:,ITIME)=sqrt(guesauxrmseg);
     GUES_SPRD_SERIE_G(:,ITIME)=sqrt(guesauxsprdg);
     GUES_MEAN_SERIE_G(:,ITIME)=sqrt(guesauxmeang);
 end
 if(~isnan(analauxrmseland))
     ANAL_RMSE_SERIE_LAND(:,ITIME)=sqrt(analauxrmseland);
     ANAL_SPRD_SERIE_LAND(:,ITIME)=sqrt(analauxsprdland);
     ANAL_MEAN_SERIE_LAND(:,ITIME)=sqrt(analauxmeanland);
 end
 if(~isnan(guesauxrmsesea))
     GUES_RMSE_SERIE_SEA(:,ITIME)=sqrt(guesauxrmsesea);
     GUES_RMSE_SERIE_SEA(:,ITIME)=sqrt(guesauxsprdsea);
     GUES_MEAN_SERIE_SEA(:,ITIME)=sqrt(analauxmeansea);
 end
 
C_DATE_NUM=C_DATE_NUM + EST_FREC/24;
end

ANAL_BIAS=ANAL_BIAS/analnbias;
GUES_BIAS=GUES_BIAS/guesnbias;
ANAL_SMEAN=ANAL_SMEAN/analnbias;
GUES_SMEAN=GUES_SMEAN/guesnbias;
ANAL_SSPRD=ANAL_SSPRD/analnbias;
GUES_SSPRD=GUES_SSPRD/guesnbias;
ANAL_SSPRD=(ANAL_SSPRD-ANAL_SMEAN.^2).^0.5;
GUES_SSPRD=(GUES_SSPRD-GUES_SMEAN.^2).^0.5;

ANAL_ERRORMEAN=ANAL_ERRORMEAN/analnbias;
GUES_ERRORMEAN=GUES_ERRORMEAN/guesnbias;
ANAL_SPRDMEAN=ANAL_SPRDMEAN/analnbias;
GUES_SPRDMEAN=GUES_SPRDMEAN/guesnbias;

ANAL_RMSE=(ANAL_ERRORSPRD/analnbias).^0.5;
GUES_RMSE=(GUES_ERRORSPRD/guesnbias).^0.5;

ANAL_ERRORSPRD=(ANAL_ERRORSPRD/analnbias-ANAL_ERRORMEAN.^2).^0.5;
GUES_ERRORSPRD=(GUES_ERRORSPRD/guesnbias-GUES_ERRORMEAN.^2).^0.5;

ANAL_SPRDSPRD=(ANAL_SPRDSPRD/analnbias-ANAL_SPRDMEAN.^2).^0.5;
GUES_SPRDSPRD=(GUES_SPRDSPRD/guesnbias-GUES_SPRDMEAN.^2).^0.5;

ANAL_ERRORSPRDCORREL=(ANAL_ERRORSPRDCORREL/analnbias-ANAL_ERRORMEAN.*ANAL_SPRDMEAN)./(ANAL_ERRORSPRD.*ANAL_SPRDSPRD);
GUES_ERRORSPRDCORREL=(GUES_ERRORSPRDCORREL/guesnbias-GUES_ERRORMEAN.*GUES_SPRDMEAN)./(GUES_ERRORSPRD.*GUES_SPRDSPRD);


save([DATA_PATH '/' EXPERIMENT 'analysis_rmse_' EXP_INI_DATE '_' EXP_END_DATE '.mat'],'ANAL_BIAS','GUES_BIAS','ANAL_RMSE_SERIE_G','GUES_RMSE_SERIE_G' ...
                                     ,'ANAL_SPRD_SERIE_G','GUES_SPRD_SERIE_G','ANAL_SMEAN','GUES_SMEAN'...
                                     ,'ANAL_SPRD_SERIE_LAND','GUES_SPRD_SERIE_LAND'...
                                     ,'ANAL_RMSE_SERIE_LAND','GUES_RMSE_SERIE_LAND'...
                                     ,'ANAL_SPRD_SERIE_SEA','GUES_SPRD_SERIE_SEA'...
                                     ,'ANAL_RMSE_SERIE_SEA','GUES_RMSE_SERIE_SEA'...
                                     ,'ANAL_SSPRD','GUES_SSPRD','ANAL_ERRORSPRDCORREL','GUES_ERRORSPRDCORREL'...
                                     ,'ANAL_ERRORMEAN','GUES_ERRORMEAN','ANAL_SPRDMEAN','GUES_SPRDMEAN'...
                                     ,'ANAL_RMSE','GUES_RMSE');

%=========================================================================
% DIAGNOSTIC 
%=========================================================================

%RMSE OF U,V,T AND Q

%figure
%subplot(3,2,1)

%pcolor(RMSE_SERIE_G(1:7,:));
%shading flat
%caxis([0 2])
%title('U GLOBAL')
%plot_color_fun([0.0 0.2 0.4 0.6 0.8 1.0 1.5 2.0],[33 35 21 22 23 24 25 26],0);

%subplot(3,2,2)

%pcolor(RMSE_SERIE_G(8:14,:));
%caxis([0 2])
%shading flat
%plot_color_fun([0.0 0.2 0.4 0.6 0.8 1.0 1.5 2.0],[33 35 21 22 23 24 25 26],0);
%title('V GLOBAL')

%subplot(3,2,3)

%pcolor(RMSE_SERIE_SH(1:7,:));
%caxis([0 2])
%shading flat
%plot_color_fun([0.0 0.2 0.4 0.6 0.8 1.0 1.5 2.0],[33 35 21 22 23 24 25 26],0);
%title('U SH')
%
%subplot(3,2,4)

%pcolor(RMSE_SERIE_SH(8:14,:));
%shading flat
%plot_color_fun([0.0 0.2 0.4 0.6 0.8 1.0 1.5 2.0],[33 35 21 22 23 24 25 26],0);
%caxis([0 2])
%title('V SH')

%subplot(3,2,5)

%pcolor(RMSE_SERIE_NH(1:7,:));
%shading flat
%plot_color_fun([0.0 0.2 0.4 0.6 0.8 1.0 1.5 2.0],[33 35 21 22 23 24 25 26],0);
%caxis([0 2])
%title('U NH')

%subplot(3,2,6)

%pcolor(RMSE_SERIE_NH(8:14,:));
%shading flat
%plot_color_fun([0.0 0.2 0.4 0.6 0.8 1.0 1.5 2.0],[33 35 21 22 23 24 25 26],0);
%caxis([0 2])
%title('V NH')

%plot_color_fun([0.0 0.2 0.4 0.6 0.8 1.0 1.5 2.0],[33 35 21 22 23 24 25 26],2);
%print('-dpng',strcat(EXPERIMENT,'RMSE_SERIE_UV.png'));


%figure
%subplot(3,1,1)

%pcolor(RMSE_SERIE_G(15:21,:));
%plot_color_fun([0.0 0.2 0.4 0.6 0.8 1.0 1.5 2.0],[33 35 21 22 23 24 25 26],0);
%caxis([0 2])
%shading flat
%title('T GLOBAL')

%subplot(3,1,2)

%pcolor(RMSE_SERIE_SH(15:21,:));
%shading flat
%plot_color_fun([0.0 0.2 0.4 0.6 0.8 1.0 1.5 2.0],[33 35 21 22 23 24 25 26],0);
%caxis([0 2])
%title('T SH')

%subplot(3,1,3)

%pcolor(RMSE_SERIE_NH(15:21,:));
%shading flat
%plot_color_fun([0.0 0.2 0.4 0.6 0.8 1.0 1.5 2.0],[33 35 21 22 23 24 25 26],0);
%caxis([0 2])
%title('T NH')
%plot_color_fun([0.0 0.2 0.4 0.6 0.8 1.0 1.5 2.0],[33 35 21 22 23 24 25 26],2);

%print('-dpng',strcat(EXPERIMENT,'RMSE_SERIE_T.png'));

%figure

%subplot(3,1,1)

%pcolor(RMSE_SERIE_G(22:28,:));
%shading flat
%plot_color_fun([0.0 0.05 0.1 0.15 0.2 0.3 0.5 1]*1e-3,[33 35 21 22 23 24 25 26],0);
%title('Q GLOBAL')

%subplot(3,1,2)

%pcolor(RMSE_SERIE_SH(22:28,:));
%shading flat
%plot_color_fun([0.0 0.05 0.1 0.15 0.2 0.3 0.5 1]*1e-3,[33 35 21 22 23 24 25 26],0);
%title('Q SH')

%subplot(3,1,3)

%pcolor(RMSE_SERIE_NH(22:28,:));
%shading flat
%plot_color_fun([0.0 0.05 0.1 0.15 0.2 0.3 0.5 1]*1e-3,[33 35 21 22 23 24 25 26],0);
%title('Q NH')

%plot_color_fun([0.0 0.05 0.1 0.15 0.2 0.3 0.5 1]*1e-3,[33 35 21 22 23 24 25 26],2);
%print('-dpng',strcat(EXPERIMENT,'RMSE_SERIE_Q.png'));



%SPRD OF U,V,T AND Q


%figure
%subplot(2,1,1)

%pcolor(SPRD_SERIE_G(1:7,:));
%shading flat
%caxis([0 2])
%title('U GLOBAL')
%plot_color_fun([0.0 0.2 0.4 0.6 0.8 1.0 1.5 2.0]*0.5,[33 35 21 22 23 24 25 26],0);

%subplot(2,1,2)

%pcolor(SPRD_SERIE_G(8:14,:));
%caxis([0 2])
%shading flat
%plot_color_fun([0.0 0.2 0.4 0.6 0.8 1.0 1.5 2.0]*0.5,[33 35 21 22 23 24 25 26],0);
%title('V GLOBAL')


%plot_color_fun([0.0 0.2 0.4 0.6 0.8 1.0 1.5 2.0]*0.5,[33 35 21 22 23 24 25 26],2);
%print('-dpng',strcat(EXPERIMENT,'SPRD_SERIE_UV.png'));


%figure

%pcolor(SPRD_SERIE_G(15:21,:));
%shading flat
%caxis([0 2])
%title('T GLOBAL')
%plot_color_fun([0.0 0.2 0.4 0.6 0.8 1.0 1.5 2.0]*0.5,[33 35 21 22 23 24 25 26],1);

%print('-dpng',strcat(EXPERIMENT,'SPRD_SERIE_T.png'));

%figure

%pcolor(SPRD_SERIE_G(22:28,:));
%shading flat
%title('Q GLOBAL')
%plot_color_fun([0.0 0.05 0.1 0.15 0.2 0.3 0.5 1]*0.5*1e-3,[33 35 21 22 23 24 25 26],1);
%print('-dpng',strcat(EXPERIMENT,'SPRD_SERIE_Q.png'));





%RMSE OF PS

%figure

%hold on
%plot(RMSE_SERIE_G(29,:));
%plot(RMSE_SERIE_SH(29,:),'r');
%plot(RMSE_SERIE_NH(29,:),'g');
%title('PS')
%axis([0 NTIMES 0 100])

%print('-dpng',strcat(EXPERIMENT,'RMSEGLOBALPS.png'));

%figure
%plot(SPRD_SERIE_G(29,:));
%title('PS')
%axis([0 NTIMES 0 70])

%print('-dpng',strcat(EXPERIMENT,'SPREADPS.png'));


%Plot zonal RMSE

%Average Zonal RMSE over the last 200 times.

%aux=sqrt(squeeze(nanmean(RMSE_ZONAL(:,:,100,end),3)));

%figure
%subplot(2,2,1)
%[auxx auxy]=meshgrid(lat_s,1:nz_s);

%pcolor(auxx,auxy,aux(:,1:7)');
%caxis([0 3])
%title('U GLOBAL')
%subplot(2,2,2)
%shading flat

%pcolor(auxx,auxy,aux(:,8:14)');
%caxis([0 3])
%title('V GLOBAL')
%shading flat




%subplot(2,2,3)

%contourf(auxx,auxy,aux(:,15:21)');
%caxis([0 3])
%title('T GLOBAL')

%subplot(2,2,4)

%contourf(auxx,auxy,aux(:,22:28)');
%caxis([0 3]*1e-4)
%title('Q GLOBAL')

%print('-dpng',strcat(EXPERIMENT,'MEANRMSE.png'));

%BIAS computation.

%[X Y]=meshgrid(lon_s,lat_s);
%X=X-180;
%var_factor=[1 1 1 1e3];
%varn{1}='U',varn{2}='V';varn{3}='T';varn{4}='Q';
%pngn{1}='BIASU',pngn{2}='BIASV';pngn{3}='BIAST';pngn{4}='BIASQ';
%carga_mapa
  
%lon_costa(lon_costa<0)=lon_costa(lon_costa<0)+360;
%for ii=1:(length(lon_costa)-1)
%    if(abs(lon_costa(ii) - lon_costa(ii+1)) > 180)
%        lon_costa(ii)=NaN;
%        lat_costa(ii)=NaN;
%    end
%end

%Plot Bias.

%for ivar=1:4
%figure
%for ilev=1:nz_s-1 
%    subplot(2,3,ilev)
%    pcolor(X,Y,BIAS(:,:,(ivar-1)*nz_s+ilev)*var_factor(ivar));
%    plot_color_fun([-1 -0.8 -0.6 -0.4 -0.2 0.2 0.4 0.6 0.8 1],[48 47 45 43 2 23 25 27 28],0);
%    hold on
%    plot(lon_costa,lat_costa)
%    shading flat
%    title(strcat('BIAS',varn{ivar},'LEVEL',num2str(ilev)));
%end
%  plot_color_fun([-1 -0.8 -0.6 -0.4 -0.2 0.2 0.4 0.6 0.8 1],[48 47 45 43 2 23 25 27 28],2);
%  pngfile=strcat(EXPERIMENT,pngn{ivar},'.png')
%  print('-dpng',pngfile) 
%end

%figure
%    pcolor(X,Y,BIAS(:,:,29)*1e-2);
%    plot_color_fun([-1 -0.8 -0.6 -0.4 -0.2 0.2 0.4 0.6 0.8 1],[48 47 45 43 2 23 25 27 28],0);
   % hold on
%    plot(lon_costa,lat_costa)
%    shading flat
%    title(strcat('BIASPSLEVEL',num2str(ilev)));
%    pngfile=strcat(EXPERIMENT,'BIASPS.png')
%    print('-dpng',pngfile)
    
% %Plot error / spread linear correlation coefficient.
% pngn{1}='R U',pngn{2}='R V';pngn{3}='R T';pngn{4}='R Q';
% for ivar=1:4
% figure
% for ilev=1:nz_s-1 
%     subplot(2,3,ilev)
%     pcolor(X,Y,ERRORSPRDCORREL(:,:,(ivar-1)*nz_s+ilev));
%     plot_color_fun([-0.4 -0.1 0.1 0.4 0.6 0.8 0.9 1.0],[44 2 23 25 27 28 29],0);
%     hold on
%     plot(lon_costa,lat_costa)
%     shading flat
%     title(strcat('ERROR SPREAD R ',varn{ivar},'LEVEL',num2str(ilev)));
% end
%   plot_color_fun([-0.4 -0.1 0.1 0.4 0.6 0.8 0.9 1.0],[44 2 23 25 27 28 29],2);
%   pngfile=strcat(EXPERIMENT,pngn{ivar},'R.png')
%   print('-dpng',pngfile) 
% end
% 
% figure
%     pcolor(X,Y,ERRORSPRDCORREL(:,:,29));
%     plot_color_fun([-0.4 -0.1 0.1 0.4 0.6 0.8 0.9 1.0],[44 2 23 25 27 28 29],0);
%     hold on
%     plot(lon_costa,lat_costa)
%     shading flat
%     title(strcat('R PS LEVEL',num2str(ilev)));
%     pngfile=strcat(EXPERIMENT,'RPS.png')
%     print('-dpng',pngfile)
% 
% 
% %Save data in a mat file.

%save([EXPERIMENT 'analysis_rmse.mat'],'BIAS','RMSE_ZONAL','RMSE_SERIE_G','RMSE_SERIE_NH','RMSE_SERIE_SH','SPRD_SERIE_G','SMEAN','SSPRD','ERRORSPRDCORREL')












