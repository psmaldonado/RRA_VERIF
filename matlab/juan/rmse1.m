clear all
close all

%To compare the 40 member control against the GDAS.

BASEURL='/home/jruiz/datos/EXPERIMENTS/';
EXPNAME='FORECAST_CONTROL40M_MEMNC';
EXPNAMEFNL='CONTROL_GDAS';
ENSSIZE=40;
FORECAST_LENGTH=72;
INIT_FREC=24;
OUTPUT_FREC=06;

VERIFDIR=[BASEURL '/' EXPNAME '/verification_fnl/'];
system(['mkdir ' VERIFDIR]);

INIDATE='2008082012';
ENDDATE='2008093012';

PLOT=false;

load coast
%==========================================================================
%Dimensions.
[xdef ydef]=def_grid_grads;

%==========================================================================
%Read and plot data
%==========================================================================
nfor=FORECAST_LENGTH/6+1;

inid=datenum(INIDATE,'yyyymmddHH');
endd=datenum(ENDDATE,'yyyymmddHH');

nx=length(xdef);
ny=length(ydef);
nz=13;

MEANMEMBER=ENSSIZE+1;  %El pronostico de la media y la media del analisis esta en el miembro N+1;

%Fields
RMSEU=zeros(ny,nx,nz,nfor);
RMSEV=zeros(ny,nx,nz,nfor);
RMSET=zeros(ny,nx,nz,nfor);
RMSEQ=zeros(ny,nx,nz,nfor);
RMSEH=zeros(ny,nx,nz,nfor);
RMSEP=zeros(ny,nx,nfor);

BIASU=zeros(ny,nx,nz,nfor);
BIASV=zeros(ny,nx,nz,nfor);
BIAST=zeros(ny,nx,nz,nfor);
BIASQ=zeros(ny,nx,nz,nfor);
BIASH=zeros(ny,nx,nz,nfor);
BIASP=zeros(ny,nx,nfor);


RMSERCVU=zeros(ny,nx,nz,nfor);
RMSERCVV=zeros(ny,nx,nz,nfor);
RMSERCVT=zeros(ny,nx,nz,nfor);
RMSERCVQ=zeros(ny,nx,nz,nfor);
RMSERCVH=zeros(ny,nx,nz,nfor);
RMSERCVP=zeros(ny,nx,nfor);

BIASRCVU=zeros(ny,nx,nz,nfor);
BIASRCVV=zeros(ny,nx,nz,nfor);
BIASRCVT=zeros(ny,nx,nz,nfor);
BIASRCVQ=zeros(ny,nx,nz,nfor);
BIASRCVH=zeros(ny,nx,nz,nfor);
BIASRCVP=zeros(ny,nx,nfor);

EMU=zeros(ny,nx,nz,nfor);
EMV=zeros(ny,nx,nz,nfor);
EMT=zeros(ny,nx,nz,nfor);
EMQ=zeros(ny,nx,nz,nfor);
EMH=zeros(ny,nx,nz,nfor);
EMP=zeros(ny,nx,nfor);

SSTDU=zeros(ny,nx,nz,nfor);
SSTDV=zeros(ny,nx,nz,nfor);
SSTDT=zeros(ny,nx,nz,nfor);
SSTDQ=zeros(ny,nx,nz,nfor);
SSTDH=zeros(ny,nx,nz,nfor);
SSTDP=zeros(ny,nx,nfor);

SMU=zeros(ny,nx,nz,nfor);
SMV=zeros(ny,nx,nz,nfor);
SMT=zeros(ny,nx,nz,nfor);
SMQ=zeros(ny,nx,nz,nfor);
SMH=zeros(ny,nx,nz,nfor);
SMP=zeros(ny,nx,nfor);

ESCOVU=zeros(ny,nx,nz,nfor);
ESCOVV=zeros(ny,nx,nz,nfor);
ESCOVT=zeros(ny,nx,nz,nfor);
ESCOVQ=zeros(ny,nx,nz,nfor);
ESCOVH=zeros(ny,nx,nz,nfor);
ESCOVP=zeros(ny,nx,nfor);

curd=inid;
i=1;
n2d=zeros(ny,nx,nfor);
n3d=zeros(ny,nx,nz,nfor);


while(curd <= endd)

      dateinit  =datestr(curd,'yyyymmddHHMM')
      for ifor=1:nfor;
      %Read in letkf analysis ensemble mean.
      lead=(ifor-1)*OUTPUT_FREC;
      if( lead < 10 )
          leadstr=['0' num2str(lead)];
      else
          leadstr=num2str(lead);
      end
      
      file=[BASEURL '/' EXPNAME '/' dateinit '/plev_sprd_f' leadstr '.dat' ];
      [USPRD(:,:,:,ifor) VSPRD(:,:,:,ifor) QSPRD(:,:,:,ifor) HSPRD(:,:,:,ifor) TSPRD(:,:,:,ifor) ...
       U10SPRD(:,:,ifor) V10SPRD(:,:,ifor) PSPRD(:,:,ifor) MCAPESPRD(:,:,ifor) MCINSPRD(:,:,ifor)]=read_arwpost_forecast(file,nx,ny,nz,true); 
 
       file=[BASEURL '/' EXPNAME '/' dateinit '/plev_mean_f' leadstr '.dat' ];
      [U(:,:,:,ifor) V(:,:,:,ifor) Q(:,:,:,ifor) H(:,:,:,ifor) T(:,:,:,ifor) ...
       U10(:,:,ifor) V10(:,:,ifor) P(:,:,ifor) MCAPE(:,:,ifor) MCIN(:,:,ifor)]=read_arwpost_forecast(file,nx,ny,nz,true);

      
      %Read in fnl analysis ensemble mean.
      datefile  =datestr(curd +(ifor-1)*6/24 ,'yyyymmddHHMM');
      file=[BASEURL '/' EXPNAMEFNL '/anal/' datefile '/plev_anal_me.dat'];
      [UFNL(:,:,:,ifor) VFNL(:,:,:,ifor) QFNL(:,:,:,ifor) HFNL(:,:,:,ifor) TFNL(:,:,:,ifor) ...
       U10FNL(:,:,ifor) V10FNL(:,:,ifor) PFNL(:,:,ifor) MCAPEFNL(:,:,ifor) MCINFNL(:,:,ifor)]=read_arwpost_forecast(file,nx,ny,nz,false); 
      end

      %Hay algunos valores negativos muy pequenios que hay que eliminar.
      USPRD(USPRD <= 0)=NaN;
      VSPRD(VSPRD <= 0)=NaN;
      TSPRD(TSPRD <= 0)=NaN;
      QSPRD(QSPRD <= 0)=NaN;
      HSPRD(HSPRD <= 0)=NaN;
      PSPRD(PSPRD <= 0)=NaN;


      USPRD=sqrt(USPRD);
      VSPRD=sqrt(VSPRD);
      QSPRD=sqrt(QSPRD);
      TSPRD=sqrt(TSPRD);
      HSPRD=sqrt(HSPRD);
      PSPRD=sqrt(PSPRD);

   
       index= isnan(U) | isnan(UFNL);  %This index can be used for other variables.
       
       U(index)=0;
       UFNL(index)=0;
       USPRD(index)=0;
       V(index)=0;
       VFNL(index)=0;
       VSPRD(index)=0;
       T(index)=0;
       TFNL(index)=0;
       TSPRD(index)=0;
       Q(index)=0;
       QFNL(index)=0;
       QSPRD(index)=0;
       H(index)=0;
       HFNL(index)=0;
       HSPRD(index)=0;
       n3d=n3d+~index;
       
       index= isnan(P) | isnan(PFNL);
       n2d=n2d+~index;
       P(index)=0;
       PFNL(index)=0;
       PSPRD(index)=0;
   
       RMSEU=RMSEU+(U-UFNL).^2;
       RMSEV=RMSEV+(V-VFNL).^2;
       RMSET=RMSET+(T-TFNL).^2;
       RMSEQ=RMSEQ+(Q-QFNL).^2;
       RMSEH=RMSEH+(H-HFNL).^2;
       RMSEP=RMSEP+(P-PFNL).^2;

       EMU=EMU+abs(U-UFNL);
       EMV=EMV+abs(V-VFNL);
       EMT=EMT+abs(T-TFNL);
       EMQ=EMQ+abs(Q-QFNL);
       EMH=EMH+abs(H-HFNL);
       EMP=EMP+abs(P-PFNL);
       
       ESCOVU=ESCOVU+abs(U-UFNL).*USPRD;
       ESCOVV=ESCOVV+abs(V-VFNL).*VSPRD;
       ESCOVT=ESCOVT+abs(T-TFNL).*TSPRD;
       ESCOVQ=ESCOVQ+abs(Q-QFNL).*QSPRD;
       ESCOVH=ESCOVH+abs(H-HFNL).*HSPRD;
       ESCOVP=ESCOVP+abs(P-PFNL).*PSPRD;

       SMU=SMU+USPRD;
       SMV=SMV+VSPRD;
       SMT=SMT+TSPRD;
       SMQ=SMQ+QSPRD;
       SMH=SMH+HSPRD;
       SMP=SMP+PSPRD;

       SSTDU=SSTDU+USPRD.^2;
       SSTDV=SSTDV+VSPRD.^2;
       SSTDT=SSTDT+TSPRD.^2;
       SSTDQ=SSTDQ+QSPRD.^2;
       SSTDH=SSTDH+HSPRD.^2;
       SSTDP=SSTDP+PSPRD.^2;

       RCVU=(U-UFNL)./USPRD;
       RCVV=(V-VFNL)./VSPRD;
       RCVT=(T-TFNL)./TSPRD;
       RCVQ=(Q-QFNL)./QSPRD;
       RCVH=(H-HFNL)./HSPRD;
       RCVP=(P-PFNL)./PSPRD;       
       
       BIASU=BIASU+(U-UFNL);
       BIASV=BIASV+(V-VFNL);
       BIAST=BIAST+(T-TFNL);
       BIASQ=BIASQ+(Q-QFNL);
       BIASH=BIASH+(H-HFNL);
       BIASP=BIASP+(P-PFNL);

       BIASRCVU=BIASRCVU+(RCVU);
       BIASRCVV=BIASRCVV+(RCVV);
       BIASRCVT=BIASRCVT+(RCVT);
       BIASRCVQ=BIASRCVQ+(RCVQ);
       BIASRCVH=BIASRCVH+(RCVH);
       BIASRCVP=BIASRCVP+(RCVP);

       RMSERCVU=RMSERCVU+(RCVU).^2;
       RMSERCVV=RMSERCVV+(RCVV).^2;
       RMSERCVT=RMSERCVT+(RCVT).^2;
       RMSERCVQ=RMSERCVQ+(RCVQ).^2;
       RMSERCVH=RMSERCVH+(RCVH).^2;
       RMSERCVP=RMSERCVP+(RCVP).^2;
       
       RMSEUts(i,:,:)=sqrt(nanmean(nanmean((U-UFNL).^2,2),1));
       RMSEVts(i,:,:)=sqrt(nanmean(nanmean((V-VFNL).^2,2),1));
       RMSETts(i,:,:)=sqrt(nanmean(nanmean((T-TFNL).^2,2),1));
       RMSEQts(i,:,:)=sqrt(nanmean(nanmean((Q-QFNL).^2,2),1));
       RMSEHts(i,:,:)=sqrt(nanmean(nanmean((H-HFNL).^2,2),1));
       RMSEPts(i,:,:)=sqrt(nanmean(nanmean((P-PFNL).^2,2),1));

       USPRDts(i,:,:)=sqrt(nanmean(nanmean((USPRD).^2,2),1));
       USPRDts(i,:,:)=sqrt(nanmean(nanmean((VSPRD).^2,2),1));
       TSPRDts(i,:,:)=sqrt(nanmean(nanmean((TSPRD).^2,2),1));
       QSPRDts(i,:,:)=sqrt(nanmean(nanmean((QSPRD).^2,2),1));
       HSPRDts(i,:,:)=sqrt(nanmean(nanmean((HSPRD).^2,2),1));
       PSPRDts(i,:,:)=sqrt(nanmean(nanmean((PSPRD).^2,2),1));
       
   
   i=i+1;
   curd=curd+INIT_FREC/24; 
end

       EMU=EMU./n3d;
       EMV=EMV./n3d;
       EMT=EMT./n3d;
       EMQ=EMQ./n3d;
       EMH=EMH./n3d;
       EMP=EMP./n2d;

       ESTDU=sqrt(RMSEU./n3d-EMU.^2);
       ESTDV=sqrt(RMSEV./n3d-EMV.^2);
       ESTDT=sqrt(RMSET./n3d-EMT.^2);
       ESTDQ=sqrt(RMSEQ./n3d-EMQ.^2);
       ESTDH=sqrt(RMSEH./n3d-EMH.^2);
       ESTDP=sqrt(RMSEP./n2d-EMP.^2);
       
       SMU=SMU./n3d;
       SMV=SMV./n3d;
       SMT=SMT./n3d;
       SMQ=SMQ./n3d;
       SMH=SMH./n3d;
       SMP=SMP./n2d;

       ESCOVU=ESCOVU./n3d-SMU.*EMU;
       ESCOVV=ESCOVV./n3d-SMV.*EMV;
       ESCOVT=ESCOVT./n3d-SMT.*EMT;
       ESCOVQ=ESCOVQ./n3d-SMQ.*EMQ;
       ESCOVH=ESCOVH./n3d-SMH.*EMH;
       ESCOVP=ESCOVP./n2d-SMP.*EMP;
       
       SSTDU=sqrt(SSTDU./n3d);
       SSTDV=sqrt(SSTDV./n3d);
       SSTDT=sqrt(SSTDT./n3d);
       SSTDQ=sqrt(SSTDQ./n3d);
       SSTDH=sqrt(SSTDH./n3d);
       SSTDP=sqrt(SSTDP./n2d);

       RESU=ESCOVU./(SSTDU.*ESTDU);
       RESV=ESCOVV./(SSTDV.*ESTDV);
       REST=ESCOVT./(SSTDT.*ESTDT);
       RESQ=ESCOVQ./(SSTDQ.*ESTDQ);
       RESH=ESCOVH./(SSTDH.*ESTDH);
       RESP=ESCOVP./(SSTDP.*ESTDP);
       
       BIASU=BIASU./n3d;
       BIASV=BIASV./n3d;
       BIAST=BIAST./n3d;
       BIASQ=BIASQ./n3d;
       BIASH=BIASH./n3d;
       BIASP=BIASP./n2d;

       RMSEDEBIASU=sqrt((RMSEU./n3d-BIASU.^2));
       RMSEDEBIASV=sqrt((RMSEV./n3d-BIASV.^2));
       RMSEDEBIAST=sqrt((RMSET./n3d-BIAST.^2));
       RMSEDEBIASQ=sqrt((RMSEQ./n3d-BIASQ.^2));
       RMSEDEBIASH=sqrt((RMSEH./n3d-BIASH.^2));
       RMSEDEBIASP=sqrt((RMSEP./n2d-BIASP.^2));

       RMSEU=sqrt(RMSEU./n3d);
       RMSEV=sqrt(RMSEV./n3d);
       RMSET=sqrt(RMSET./n3d);
       RMSEQ=sqrt(RMSEQ./n3d);
       RMSEH=sqrt(RMSEH./n3d);
       RMSEP=sqrt(RMSEP./n2d);

       RMSERCVU=sqrt(RMSERCVU./n3d);
       RMSERCVV=sqrt(RMSERCVV./n3d);
       RMSERCVT=sqrt(RMSERCVT./n3d);
       RMSERCVQ=sqrt(RMSERCVQ./n3d);
       RMSERCVH=sqrt(RMSERCVH./n3d);
       RMSERCVP=sqrt(RMSERCVP./n2d);

       BIASRCVU=BIASRCVU./n3d;
       BIASRCVV=BIASRCVV./n3d;
       BIASRCVT=BIASRCVT./n3d;
       BIASRCVQ=BIASRCVQ./n3d;
       BIASRCVH=BIASRCVH./n3d;
       BIASRCVP=BIASRCVP./n2d;
    
save([VERIFDIR '/rmse_bias.mat'],'RMSEU','RMSEV','RMSET','RMSEQ','RMSEH','RMSEP',...
                                 'BIASU','BIASV','BIAST','BIASQ','BIASH','BIASP',...
                                 'RESU' ,'RESV' ,'REST' ,'RESQ' ,'RESH' ,'RESP',...
                                 'SSTDU','SSTDV','SSTDT','SSTDQ','SSTDH','SSTDP',...
                                 'SMU'  ,'SMV'  ,'SMT'  ,'SMQ'  ,'SMH'  ,'SMP',...
                                 'RMSERCVU','RMSERCVV','RMSERCVT','RMSERCVQ','RMSERCVH','RMSERCVP',...
                                 'BIASRCVU','BIASRCVV','BIASRCVT','BIASRCVQ','BIASRCVH','BIASRCVP',...
                                 'RMSEDEBIASU','RMSEDEBIASV','RMSEDEBIAST','RMSEDEBIASQ','RMSEDEBIASH','RMSEDEBIASP',...
                                 'RMSEUts','RMSEVts','RMSETts','RMSEQts','RMSEHts','RMSEPts','RMSEPts');
                             
if(PLOT)
[lonwrf latwrf]=meshgrid(xdef,ydef);

RMSE PLOTS
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

BIAS PLOTS
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
