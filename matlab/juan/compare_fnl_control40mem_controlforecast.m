clear all
close all

%To compare the 40 member control against the GDAS.

BASEURL='/data/letkf02/jruiz/';
EXPNAME='FORECAST_EXP_40mem_CONTROL';
EXPNAMEFNL='FNL_ANALYSIS';
ENSSIZE=40;
FORECAST_LENGTH=72;
INIT_FREC=12;

VERIFDIR=[BASEURL '/' EXPNAME '/verification_fnl/'];
system(['mkdir ' VERIFDIR]);

INIDATE='2008082100';
ENDDATE='2008093000';


PLOT=false;

load coast
%==========================================================================
%Dimensions.
[xdef ydef zdef]=def_grid_grads;

%==========================================================================
%Read and plot data
%==========================================================================
nfor=FORECAST_LENGTH/6+1;

inid=datenum(INIDATE,'yyyymmddHH');
endd=datenum(ENDDATE,'yyyymmddHH');

nx=length(xdef);
ny=length(ydef);
nz=length(zdef);

MEANMEMBER=ENSSIZE+1;  %El pronostico de la media y la media del analisis esta en el miembro N+1;

%Fields
RMSEU=zeros(ny,nx,nz,nfor);
RMSEV=zeros(ny,nx,nz,nfor);
RMSET=zeros(ny,nx,nz,nfor);
RMSEQ=zeros(ny,nx,nz,nfor);
RMSEH=zeros(ny,nx,nz,nfor);
RMSEP=zeros(ny,nx,nfor);
RMSESLP=zeros(ny,nx,nfor);

BIASU=zeros(ny,nx,nz,nfor);
BIASV=zeros(ny,nx,nz,nfor);
BIAST=zeros(ny,nx,nz,nfor);
BIASQ=zeros(ny,nx,nz,nfor);
BIASH=zeros(ny,nx,nz,nfor);
BIASP=zeros(ny,nx,nfor);
BIASSLP=zeros(ny,nx,nfor);

curd=inid;
i=1;
n2d=zeros(ny,nx,nfor);
n3d=zeros(ny,nx,nz,nfor);



while(curd <= endd)

      dateinit  =datestr(curd                ,'yyyymmddHHMM')
      for ifor=1:nfor;
      %Read in letkf analysis ensemble mean.
      iens=MEANMEMBER;
      datefile  =datestr(curd +(ifor-1)*6/24 ,'yyyymmddHHMM');
      
      file=[BASEURL '/' EXPNAME '/gues/control/' dateinit '/plev/' datefile '.dat'];
      [U(:,:,:,ifor) V(:,:,:,ifor) W(:,:,:,ifor) PSFC(:,:,ifor) QVAPOR(:,:,:,ifor) HGT(:,:,ifor) RAINC(:,:,ifor) RAINNC(:,:,ifor) GEOPT(:,:,:,ifor) HEIGHT T(:,:,:,ifor) RH(:,:,:,ifor) ...
       RH2(:,:,ifor) U10M(:,:,ifor) V10M(:,:,ifor) SLP(:,:,ifor) MCAPE(:,:,ifor) MCIN(:,:,ifor)]=read_arwpost_controlforecast(file,nx,ny,nz); 
      
      %Read in fnl analysis ensemble mean.
      datefile  =datestr(curd +(ifor-1)*6/24 ,'yyyymmddHHMM');
      file=[BASEURL '/' EXPNAMEFNL '/' datefile '/plev/' datefile '.dat'];
      [UFNL(:,:,:,ifor) VFNL(:,:,:,ifor) WFNL(:,:,:,ifor) PSFCFNL(:,:,ifor) QVAPORFNL(:,:,:,ifor) VEGFRAFNL(:,:,ifor) SSTFNL(:,:,ifor) HGTFNL(:,:,ifor) TSKFNL(:,:,ifor) RAINC(:,:,ifor) RAINNC(:,:,ifor) GEOPTFNL(:,:,:,ifor) HEIGHT TFNL(:,:,:,ifor) RHFNL(:,:,:,ifor) ...
       RH2FNL(:,:,ifor) U10MFNL(:,:,ifor) V10MFNL(:,:,ifor) SLPFNL(:,:,ifor) MCAPEFNL(:,:,ifor) MCINFNL(:,:,ifor)]=read_fnl_arwpost(file,nx,ny,nz); 
      end

   
       index= isnan(U) | isnan(UFNL);  %This index can be used for other variables.
       U(index)=0;
       UFNL(index)=0;
       V(index)=0;
       VFNL(index)=0;
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
       
       RMSEUts(i,:,:)=sqrt(nanmean(nanmean((U-UFNL).^2,2),1));
       RMSEVts(i,:,:)=sqrt(nanmean(nanmean((V-VFNL).^2,2),1));
       RMSETts(i,:,:)=sqrt(nanmean(nanmean((T-TFNL).^2,2),1));
       RMSEQts(i,:,:)=sqrt(nanmean(nanmean((QVAPOR-QVAPORFNL).^2,2),1));
       RMSEHts(i,:,:)=sqrt(nanmean(nanmean((GEOPT-GEOPTFNL).^2,2),1));
       RMSEPts(i,:,:)=sqrt(nanmean(nanmean((PSFC-PSFCFNL).^2,2),1));
       RMSESLPts(i,:,:)=sqrt(nanmean(nanmean((SLP-SLPFNL).^2,2),1));
       
   
   i=i+1;
   curd=curd+INIT_FREC/24; 
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
                                 'BIASU','BIASV','BIAST','BIASQ','BIASH','BIASSLP',...
                                 'RMSEUts','RMSEVts','RMSETts','RMSEQts','RMSEHts','RMSEPts','RMSESLPts');
                             
if(PLOT)
[lonwrf latwrf]=meshgrid(xdef,ydef);

%RMSE PLOTS
%for ilev=1:nz
%    %RMSEU
%    pcolor(lonwrf,latwrf,RMSEU(:,:,ilev));shading flat
%    hold on;plot(long,lat,'k','LineWidth',2)
%    caxis([0 6]);run colorbar
%    xlabel('Longitude');ylabel('Latitude')
%    title(['RMSE U level=' num2str(ilev)]);
%    print('-dpng',[VERIFDIR '/RMSU_level_' num2str(ilev) '.png']);
%    hold off
%    %RMSEV
%    pcolor(lonwrf,latwrf,RMSEV(:,:,ilev));shading flat
%    hold on;plot(long,lat,'k','LineWidth',2)
%    caxis([0 6]);run colorbar
%    xlabel('Longitude');ylabel('Latitude')
%    title(['RMSE V level=' num2str(ilev)]);
%    print('-dpng',[VERIFDIR '/RMSV_level_' num2str(ilev) '.png']);
%    hold off
%    %RMSET
%    pcolor(lonwrf,latwrf,RMSET(:,:,ilev));shading flat
%    hold on;plot(long,lat,'k','LineWidth',2)
%    caxis([0 4]);run colorbar
%    xlabel('Longitude');ylabel('Latitude')
%    title(['RMSE T level=' num2str(ilev)]);
%    print('-dpng',[VERIFDIR '/RMSET_level_' num2str(ilev) '.png']);
%    hold off
%    %RMSEQ
%    pcolor(lonwrf,latwrf,RMSEQ(:,:,ilev));shading flat
%    hold on;plot(long,lat,'k','LineWidth',2)
%    caxis([0 1.5e-3]);run colorbar
%    xlabel('Longitude');ylabel('Latitude')
%    title(['RMSE Q level=' num2str(ilev)]);
%    print('-dpng',[VERIFDIR '/RMSEQ_level_' num2str(ilev) '.png']);
%    hold off
%    %RMSEH
%    pcolor(lonwrf,latwrf,RMSEH(:,:,ilev));shading flat
%    hold on;plot(long,lat,'k','LineWidth',2)
%    caxis([0 200]);run colorbar
%    xlabel('Longitude');ylabel('Latitude')
%    title(['RMSE H level=' num2str(ilev)]);
%    print('-dpng',[VERIFDIR '/RMSEH_level_' num2str(ilev) '.png']); 
%    hold off
%end
%    %RMSEPS
%    pcolor(lonwrf,latwrf,RMSEP(:,:));shading flat
%    hold on;plot(long,lat,'k','LineWidth',2)
%    caxis([0 200]);run colorbar
%    xlabel('Longitude');ylabel('Latitude')
%    title(['RMSE PS level=' num2str(ilev)]);
%    print('-dpng',[VERIFDIR '/RMSEPS_level_' num2str(ilev) '.png']); 
%    hold off
%    %RMSESLP
%    pcolor(lonwrf,latwrf,RMSESLP(:,:));shading flat
%    hold on;plot(long,lat,'k','LineWidth',2)
%    caxis([0 2]);run colorbar
%    xlabel('Longitude');ylabel('Latitude')
%    title(['RMSE SLP level=' num2str(ilev)]);
%    print('-dpng',[VERIFDIR '/RMSESLP_level_' num2str(ilev) '.png']); 
%    hold off

%BIAS PLOTS
%for ilev=1:nz
%    %BIASU
%    pcolor(lonwrf,latwrf,BIASU(:,:,ilev));shading flat
%    hold on;plot(long,lat,'k','LineWidth',2)
%    caxis([0 1.5]);run colorbar
%    xlabel('Longitude');ylabel('Latitude')
%    title(['BIAS U level=' num2str(ilev)]);
%    print('-dpng',[VERIFDIR '/BIASU_level_' num2str(ilev) '.png']);
%    hold off
%    %BIASV
%    pcolor(lonwrf,latwrf,BIASV(:,:,ilev));shading flat
%    hold on;plot(long,lat,'k','LineWidth',2)
%    caxis([0 1.5]);run colorbar
%    xlabel('Longitude');ylabel('Latitude')
%    title(['BIAS V level=' num2str(ilev)]);
%    print('-dpng',[VERIFDIR '/BIASV_level_' num2str(ilev) '.png']);
%    hold off
%    %BIAST
%    pcolor(lonwrf,latwrf,BIAST(:,:,ilev));shading flat
%    hold on;plot(long,lat,'k','LineWidth',2)
%    caxis([0 2]);run colorbar
%    xlabel('Longitude');ylabel('Latitude')
%    title(['BIAS T level=' num2str(ilev)]);
%    print('-dpng',[VERIFDIR '/BIAST_level_' num2str(ilev) '.png']);
%    hold off
%    %RMSEQ
%    pcolor(lonwrf,latwrf,BIASQ(:,:,ilev));shading flat
%    hold on;plot(long,lat,'k','LineWidth',2)
%    caxis([0 1.5e-3]);run colorbar
%    xlabel('Longitude');ylabel('Latitude')
%    title(['BIAS Q level=' num2str(ilev)]);
%    print('-dpng',[VERIFDIR '/BIASQ_level_' num2str(ilev) '.png']);
%    hold off
%    %RMSEH
%    pcolor(lonwrf,latwrf,BIASH(:,:,ilev));shading flat
%    hold on;plot(long,lat,'k','LineWidth',2)
%    caxis([0 100]);run colorbar
%    xlabel('Longitude');ylabel('Latitude')
%    title(['BIAS H level=' num2str(ilev)]);
%    print('-dpng',[VERIFDIR '/BIASH_level_' num2str(ilev) '.png']); 
%    hold off
%end
%    %RMSEPS
%    pcolor(lonwrf,latwrf,BIASP(:,:));shading flat
%    hold on;plot(long,lat,'k','LineWidth',2)
%    caxis([0 100]);run colorbar
%    xlabel('Longitude');ylabel('Latitude')
%    title(['BIAS PS level=' num2str(ilev)]);
%    print('-dpng',[VERIFDIR '/BIASPS_level_' num2str(ilev) '.png']); 
%    hold off
%    %RMSESLP
%    pcolor(lonwrf,latwrf,BIASSLP(:,:));shading flat
%    hold on;plot(long,lat,'k','LineWidth',2)
%    caxis([0 1]);run colorbar
%    xlabel('Longitude');ylabel('Latitude')
%    title(['BIAS SLP level=' num2str(ilev)]);
%    print('-dpng',[VERIFDIR '/BIASSLP_level_' num2str(ilev) '.png']); 
%    hold off 
 
%    %PLOT AVERAGED RMSE
%    pcolor(1:i-1,-(zdef),RMSEUts')
%    shading flat;
%    xlabel('Cycles');ylabel('-Pressure')
%    caxis([0 6]);run colorbar
%    print('-dpng',[VERIFDIR '/RMSEUts.png']);
    
%    pcolor(1:i-1,-(zdef),RMSEVts')
%    shading flat;
%    xlabel('Cycles');ylabel('-Pressure')
%    caxis([0 6]);run colorbar
%    print('-dpng',[VERIFDIR '/RMSEVts.png']);
%    
%    pcolor(1:i-1,-(zdef),RMSETts')
%    shading flat;
%    xlabel('Cycles');ylabel('-Pressure')
%    caxis([0 2]);run colorbar
%    print('-dpng',[VERIFDIR '/RMSETts.png']);
%    
%    pcolor(1:i-1,-(zdef),RMSEQts')
%    shading flat;
%    xlabel('Cycles');ylabel('-Pressure')
%    caxis([0 1.5e-3]);run colorbar
%    print('-dpng',[VERIFDIR '/RMSEQts.png']);
%    
%    pcolor(1:i-1,-(zdef),RMSEHts')
%    shading flat;
%    xlabel('Cycles');ylabel('-Pressure')
%    caxis([0 200]);run colorbar
%    print('-dpng',[VERIFDIR '/RMSEHts.png']);
%    
%    plot(1:i-1,RMSEPts')
%    shading flat;
%    xlabel('Cycles');ylabel('RMSE')
%    print('-dpng',[VERIFDIR '/RMSEPSts.png']);
%    
%    plot(1:i-1,RMSESLPts')
%    shading flat;
%    xlabel('Cycles');ylabel('RMSE')
%    caxis([0 1.5e-3]);run colorbar
%    print('-dpng',[VERIFDIR '/RMSESLPts.png']);
%    
%end
