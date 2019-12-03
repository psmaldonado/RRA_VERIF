clear all
close all

%To compare the 40 member control against the GDAS.

BASEURL='/export/data/letkf01/kunii/LETKF/result/';
EXPNAME='EXP_ANL015_AIRX2T9_C05_MEM040_INFADPVAL4_BNDW';
EXPNAMEFNL='/export/data/letkf02/jruiz/FNL_ANALYSIS';
ENSSIZE=40;

VERIFDIR=[BASEURL '/' EXPNAME '/verification_fnl/'];
system(['mkdir ' VERIFDIR]);

INIDATE='2008080612';
ENDDATE='2008092018';

PLOT=false;

load coast
%==========================================================================
%Dimensions.
[xdef ydef zdef]=def_grid_grads;

%==========================================================================
%Read and plot data
%==========================================================================

inid=datenum(INIDATE,'yyyymmddHH');
endd=datenum(ENDDATE,'yyyymmddHH');

nx=length(xdef);
ny=length(ydef);
nz=length(zdef);

MEANMEMBER=ENSSIZE+1;  %El pronostico de la media y la media del analisis esta en el miembro N+1;

%Fields
RMSEU=zeros(ny,nx,nz);
RMSEV=zeros(ny,nx,nz);
RMSET=zeros(ny,nx,nz);
RMSEQ=zeros(ny,nx,nz);
RMSEH=zeros(ny,nx,nz);
RMSEP=zeros(ny,nx);
RMSESLP=zeros(ny,nx);

BIASU=zeros(ny,nx,nz);
BIASV=zeros(ny,nx,nz);
BIAST=zeros(ny,nx,nz);
BIASQ=zeros(ny,nx,nz);
BIASH=zeros(ny,nx,nz);
BIASP=zeros(ny,nx);
BIASSLP=zeros(ny,nx);

curd=inid;
i=1;
n2d=zeros(ny,nx);
n3d=zeros(ny,nx,nz);
while(curd <= endd)
    
      %Read in letkf analysis ensemble mean.
      iens=MEANMEMBER;
      SIENS=num2str(1000+iens);SIENS=SIENS(2:end);
      datefolder=datestr(curd+6/24,'yyyymmddHHMM');
      datefile  =datestr(curd     ,'yyyymmddHHMM');
      datefile
      file=[BASEURL '/' EXPNAME '/gues/' SIENS '/' datefolder '/plev/' datefile '.dat'];
      [U V W PSFC QVAPOR VEGFRA SST HGT TSK RAINC RAINNC GEOPT HEIGHT T RH ...
       RH2 U10M V10M SLP MCAPE MCIN]=read_arwpost(file,nx,ny,nz); 
      
      %Read in fnl analysis ensemble mean.
      datefile  =datestr(curd     ,'yyyymmddHHMM');
      file=[EXPNAMEFNL '/' datefile '/plev/' datefile '.dat'];
      [UFNL VFNL WFNL PSFCFNL QVAPORFNL VEGFRAFNL SSTFNL HGTFNL TSKFNL RAINCFNL RAINNCFNL GEOPTFNL HEIGHTFNL TFNL RHFNL ...
       RH2FNL U10MFNL V10MFNL SLPFNL MCAPEFNL MCINFNL]=read_fnl_arwpost(file,nx,ny,nz);
   
       index= isnan(U) | isnan(UFNL);  %This index can be used for other variables.
       U(index)=0;
       UFNL(index)=0;
       V(index)=0;
       UFNL(index)=0;
       T(index)=0;
       TFNL(index)=0;
       QVAPOR(index)=0;
       QVAPORFNL(index)=0;
       GEOPT(index)=0;
       GEOPTFNL(index)=0;
       n3d=n3d+~index;
       
       index= isnan(PSFC) | isnan(PSFCFNL);
       n2d=n2d+ ~index;
       
   
       RMSEU=RMSEU+(U-UFNL).^2;
       RMSEV=RMSEV+(V-VFNL).^2;
       RMSET=RMSET+(T-TFNL).^2;
       RMSEQ=RMSEQ+(QVAPOR-QVAPORFNL).^2;
       RMSEH=RMSEH+(GEOPT-GEOPTFNL).^2;
       RMSEP=RMSEP+(PSFC-PSFCFNL).^2;
       RMSESLP=RMSESLP+(SLP-SLPFNL).^2;
       
       BIASU=BIASU+(U-UFNL);
       BIASV=BIASV+(V-VFNL);
       BIAST=BIAST+(T-TFNL);
       BIASQ=BIASQ+(QVAPOR-QVAPORFNL);
       BIASH=BIASH+(GEOPT-GEOPTFNL);
       BIASP=BIASP+(PSFC-PSFCFNL);
       BIASSLP=BIASSLP+(SLP-SLPFNL);
       
       RMSEUts(i,:)=sqrt(nanmean(nanmean((U-UFNL).^2,2),1));
       RMSEVts(i,:)=sqrt(nanmean(nanmean((V-VFNL).^2,2),1));
       RMSETts(i,:)=sqrt(nanmean(nanmean((T-TFNL).^2,2),1));
       RMSEQts(i,:)=sqrt(nanmean(nanmean((QVAPOR-QVAPORFNL).^2,2),1));
       RMSEHts(i,:)=sqrt(nanmean(nanmean((GEOPT-GEOPTFNL).^2,2),1));
       RMSEPts(i,:)=sqrt(nanmean(nanmean((PSFC-PSFCFNL).^2,2),1));
       RMSESLPts(i,:)=sqrt(nanmean(nanmean((SLP-SLPFNL).^2,2),1));
       
   
   i=i+1;
   curd=curd+6/24; 
end


       RMSEU=sqrt(RMSEU./n3d);
       RMSEV=sqrt(RMSEV./n3d);
       RMSET=sqrt(RMSET./n3d);
       RMSEQ=sqrt(RMSEQ./n3d);
       RMSEH=sqrt(RMSEH./n3d);
       RMSEP=sqrt(RMSEP./n2d);
       RMSESLP=sqrt(RMSESLP./n2d);
       
       BIASU=BIASU./n3d;
       BIASV=BIASV./n3d;
       BIAST=BIAST./n3d;
       BIASQ=BIASQ./n3d;
       BIASH=BIASH./n3d;
       BIASP=BIASP./n2d;
       BIASSLP=BIASSLP./n2d;
       
    
save([VERIFDIR '/rmse_bias.mat'],'RMSEU','RMSEV','RMSET','RMSEQ','RMSEH','RMSESLP',...
                                 'BIASU','BIASV','BIAST','BIASQ','BIASH','BIASSLP');
                             
if(PLOT)
[lonwrf latwrf]=meshgrid(xdef,ydef);

%RMSE PLOTS
for ilev=1:nz
    %RMSEU
    pcolor(lonwrf,latwrf,RMSEU(:,:,ilev));shading flat
    hold on;plot(long,lat,'k','LineWidth',2)
    caxis([0 6]);run colorbar
    xlabel('Longitude');ylabel('Latitude')
    title(['RMSE U level=' num2str(ilev)]);
    print('-dpng',[VERIFDIR '/RMSU_level_' num2str(ilev) '.png']);
    hold off
    %RMSEV
    pcolor(lonwrf,latwrf,RMSEV(:,:,ilev));shading flat
    hold on;plot(long,lat,'k','LineWidth',2)
    caxis([0 6]);run colorbar
    xlabel('Longitude');ylabel('Latitude')
    title(['RMSE V level=' num2str(ilev)]);
    print('-dpng',[VERIFDIR '/RMSV_level_' num2str(ilev) '.png']);
    hold off
    %RMSET
    pcolor(lonwrf,latwrf,RMSET(:,:,ilev));shading flat
    hold on;plot(long,lat,'k','LineWidth',2)
    caxis([0 4]);run colorbar
    xlabel('Longitude');ylabel('Latitude')
    title(['RMSE T level=' num2str(ilev)]);
    print('-dpng',[VERIFDIR '/RMSET_level_' num2str(ilev) '.png']);
    hold off
    %RMSEQ
    pcolor(lonwrf,latwrf,RMSEQ(:,:,ilev));shading flat
    hold on;plot(long,lat,'k','LineWidth',2)
    caxis([0 1.5e-3]);run colorbar
    xlabel('Longitude');ylabel('Latitude')
    title(['RMSE Q level=' num2str(ilev)]);
    print('-dpng',[VERIFDIR '/RMSEQ_level_' num2str(ilev) '.png']);
    hold off
    %RMSEH
    pcolor(lonwrf,latwrf,RMSEH(:,:,ilev));shading flat
    hold on;plot(long,lat,'k','LineWidth',2)
    caxis([0 200]);run colorbar
    xlabel('Longitude');ylabel('Latitude')
    title(['RMSE H level=' num2str(ilev)]);
    print('-dpng',[VERIFDIR '/RMSEH_level_' num2str(ilev) '.png']); 
    hold off
end
    %RMSEPS
    pcolor(lonwrf,latwrf,RMSEP(:,:));shading flat
    hold on;plot(long,lat,'k','LineWidth',2)
    caxis([0 200]);run colorbar
    xlabel('Longitude');ylabel('Latitude')
    title(['RMSE PS level=' num2str(ilev)]);
    print('-dpng',[VERIFDIR '/RMSEPS_level_' num2str(ilev) '.png']); 
    hold off
    %RMSESLP
    pcolor(lonwrf,latwrf,RMSESLP(:,:));shading flat
    hold on;plot(long,lat,'k','LineWidth',2)
    caxis([0 2]);run colorbar
    xlabel('Longitude');ylabel('Latitude')
    title(['RMSE SLP level=' num2str(ilev)]);
    print('-dpng',[VERIFDIR '/RMSESLP_level_' num2str(ilev) '.png']); 
    hold off

%BIAS PLOTS
for ilev=1:nz
    %BIASU
    pcolor(lonwrf,latwrf,BIASU(:,:,ilev));shading flat
    hold on;plot(long,lat,'k','LineWidth',2)
    caxis([0 1.5]);run colorbar
    xlabel('Longitude');ylabel('Latitude')
    title(['BIAS U level=' num2str(ilev)]);
    print('-dpng',[VERIFDIR '/BIASU_level_' num2str(ilev) '.png']);
    hold off
    %BIASV
    pcolor(lonwrf,latwrf,BIASV(:,:,ilev));shading flat
    hold on;plot(long,lat,'k','LineWidth',2)
    caxis([0 1.5]);run colorbar
    xlabel('Longitude');ylabel('Latitude')
    title(['BIAS V level=' num2str(ilev)]);
    print('-dpng',[VERIFDIR '/BIASV_level_' num2str(ilev) '.png']);
    hold off
    %BIAST
    pcolor(lonwrf,latwrf,BIAST(:,:,ilev));shading flat
    hold on;plot(long,lat,'k','LineWidth',2)
    caxis([0 2]);run colorbar
    xlabel('Longitude');ylabel('Latitude')
    title(['BIAS T level=' num2str(ilev)]);
    print('-dpng',[VERIFDIR '/BIAST_level_' num2str(ilev) '.png']);
    hold off
    %RMSEQ
    pcolor(lonwrf,latwrf,BIASQ(:,:,ilev));shading flat
    hold on;plot(long,lat,'k','LineWidth',2)
    caxis([0 1.5e-3]);run colorbar
    xlabel('Longitude');ylabel('Latitude')
    title(['BIAS Q level=' num2str(ilev)]);
    print('-dpng',[VERIFDIR '/BIASQ_level_' num2str(ilev) '.png']);
    hold off
    %RMSEH
    pcolor(lonwrf,latwrf,BIASH(:,:,ilev));shading flat
    hold on;plot(long,lat,'k','LineWidth',2)
    caxis([0 100]);run colorbar
    xlabel('Longitude');ylabel('Latitude')
    title(['BIAS H level=' num2str(ilev)]);
    print('-dpng',[VERIFDIR '/BIASH_level_' num2str(ilev) '.png']); 
    hold off
end
    %RMSEPS
    pcolor(lonwrf,latwrf,BIASP(:,:));shading flat
    hold on;plot(long,lat,'k','LineWidth',2)
    caxis([0 100]);run colorbar
    xlabel('Longitude');ylabel('Latitude')
    title(['BIAS PS level=' num2str(ilev)]);
    print('-dpng',[VERIFDIR '/BIASPS_level_' num2str(ilev) '.png']); 
    hold off
    %RMSESLP
    pcolor(lonwrf,latwrf,BIASSLP(:,:));shading flat
    hold on;plot(long,lat,'k','LineWidth',2)
    caxis([0 1]);run colorbar
    xlabel('Longitude');ylabel('Latitude')
    title(['BIAS SLP level=' num2str(ilev)]);
    print('-dpng',[VERIFDIR '/BIASSLP_level_' num2str(ilev) '.png']); 
    hold off 
 
    %PLOT AVERAGED RMSE
    pcolor(1:i-1,-(zdef),RMSEUts')
    shading flat;
    xlabel('Cycles');ylabel('-Pressure')
    caxis([0 6]);run colorbar
    print('-dpng',[VERIFDIR '/RMSEUts.png']);
    
    pcolor(1:i-1,-(zdef),RMSEVts')
    shading flat;
    xlabel('Cycles');ylabel('-Pressure')
    caxis([0 6]);run colorbar
    print('-dpng',[VERIFDIR '/RMSEVts.png']);
    
    pcolor(1:i-1,-(zdef),RMSETts')
    shading flat;
    xlabel('Cycles');ylabel('-Pressure')
    caxis([0 2]);run colorbar
    print('-dpng',[VERIFDIR '/RMSETts.png']);
    
    pcolor(1:i-1,-(zdef),RMSEQts')
    shading flat;
    xlabel('Cycles');ylabel('-Pressure')
    caxis([0 1.5e-3]);run colorbar
    print('-dpng',[VERIFDIR '/RMSEQts.png']);
    
    pcolor(1:i-1,-(zdef),RMSEHts')
    shading flat;
    xlabel('Cycles');ylabel('-Pressure')
    caxis([0 200]);run colorbar
    print('-dpng',[VERIFDIR '/RMSEHts.png']);
    
    plot(1:i-1,RMSEPts')
    shading flat;
    xlabel('Cycles');ylabel('RMSE')
    print('-dpng',[VERIFDIR '/RMSEPSts.png']);
    
    plot(1:i-1,RMSESLPts')
    shading flat;
    xlabel('Cycles');ylabel('RMSE')
    caxis([0 1.5e-3]);run colorbar
    print('-dpng',[VERIFDIR '/RMSESLPts.png']);
    
    
end
