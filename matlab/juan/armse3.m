clear all
close all

%To compare the 40 member control against the GDAS.

BASEURL='/home/jruiz/datos/EXPERIMENTS/';
EXPNAME='QFX0DZLOC40M_MEMNC';
EXPNAMEFNL='CONTROL_GDAS';
ENSSIZE=40;
INIT_FREC=6;

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

inid=datenum(INIDATE,'yyyymmddHH');
endd=datenum(ENDDATE,'yyyymmddHH');

nx=length(xdef);
ny=length(ydef);
nz=13;

%Fields
RMSEU=zeros(ny,nx,nz);
RMSEV=zeros(ny,nx,nz);
RMSET=zeros(ny,nx,nz);
RMSEQ=zeros(ny,nx,nz);
RMSEH=zeros(ny,nx,nz);
RMSEP=zeros(ny,nx);

BIASU=zeros(ny,nx,nz);
BIASV=zeros(ny,nx,nz);
BIAST=zeros(ny,nx,nz);
BIASQ=zeros(ny,nx,nz);
BIASH=zeros(ny,nx,nz);
BIASP=zeros(ny,nx);


RMSERCVU=zeros(ny,nx,nz);
RMSERCVV=zeros(ny,nx,nz);
RMSERCVT=zeros(ny,nx,nz);
RMSERCVQ=zeros(ny,nx,nz);
RMSERCVH=zeros(ny,nx,nz);
RMSERCVP=zeros(ny,nx);

BIASRCVU=zeros(ny,nx,nz);
BIASRCVV=zeros(ny,nx,nz);
BIASRCVT=zeros(ny,nx,nz);
BIASRCVQ=zeros(ny,nx,nz);
BIASRCVH=zeros(ny,nx,nz);
BIASRCVP=zeros(ny,nx);

EMU=zeros(ny,nx,nz);
EMV=zeros(ny,nx,nz);
EMT=zeros(ny,nx,nz);
EMQ=zeros(ny,nx,nz);
EMH=zeros(ny,nx,nz);
EMP=zeros(ny,nx);

SSTDU=zeros(ny,nx,nz);
SSTDV=zeros(ny,nx,nz);
SSTDT=zeros(ny,nx,nz);
SSTDQ=zeros(ny,nx,nz);
SSTDH=zeros(ny,nx,nz);
SSTDP=zeros(ny,nx);

SMU=zeros(ny,nx,nz);
SMV=zeros(ny,nx,nz);
SMT=zeros(ny,nx,nz);
SMQ=zeros(ny,nx,nz);
SMH=zeros(ny,nx,nz);
SMP=zeros(ny,nx);

ESCOVU=zeros(ny,nx,nz);
ESCOVV=zeros(ny,nx,nz);
ESCOVT=zeros(ny,nx,nz);
ESCOVQ=zeros(ny,nx,nz);
ESCOVH=zeros(ny,nx,nz);
ESCOVP=zeros(ny,nx);

curd=inid;
i=1;
n2d=zeros(ny,nx);
n3d=zeros(ny,nx,nz);


while(curd <= endd)

      dateinit  =datestr(curd,'yyyymmddHHMM')
      
      file=[BASEURL '/' EXPNAME '/anal/' dateinit '/plev_anal_sprd.dat' ];
      [USPRDtmp(:,:,:) VSPRDtmp(:,:,:) QSPRDtmp(:,:,:) HSPRDtmp(:,:,:) TSPRDtmp(:,:,:) ...
       U10SPRD(:,:) V10SPRD(:,:) PSPRD(:,:) MCAPESPRD(:,:) MCINSPRD(:,:)]=read_arwpost_analysis(file,nx,ny,14,true); 
 
       file=[BASEURL '/' EXPNAME '/anal/' dateinit '/plev_anal_mean.dat' ];
      [Utmp(:,:,:) Vtmp(:,:,:) Qtmp(:,:,:) Htmp(:,:,:) Ttmp(:,:,:) ...
       U10(:,:) V10(:,:) P(:,:) MCAPE(:,:) MCIN(:,:)]=read_arwpost_analysis(file,nx,ny,14,true);

       %La cantidad de niveles verticales en los datos de lanalisis es menor que en los pronosticos
       %el analisis tiene un nivel de mas. Me quedo entonces con los 13 primeros.
       USPRD=USPRDtmp(:,:,1:13);
       VSPRD=VSPRDtmp(:,:,1:13);
       TSPRD=TSPRDtmp(:,:,1:13);
       QSPRD=QSPRDtmp(:,:,1:13);
       HSPRD=HSPRDtmp(:,:,1:13);
       %Hay algunos valores negativos muy pequenios que hay que eliminar.
       USPRD(USPRD <= 0)=NaN;
       VSPRD(VSPRD <= 0)=NaN;
       TSPRD(TSPRD <= 0)=NaN;
       QSPRD(QSPRD <= 0)=NaN;
       HSPRD(HSPRD <= 0)=NaN;  
       PSPRD(PSPRD <= 0)=NaN;

       U    =Utmp(:,:,1:13);
       V    =Vtmp(:,:,1:13);
       T    =Ttmp(:,:,1:13);
       Q    =Qtmp(:,:,1:13);
       H    =Htmp(:,:,1:13);

      
      %Read in fnl analysis ensemble mean.
      datefile  =datestr(curd ,'yyyymmddHHMM');
      file=[BASEURL '/' EXPNAMEFNL '/anal/' datefile '/plev_anal_me.dat'];
      [UFNL(:,:,:) VFNL(:,:,:) QFNL(:,:,:) HFNL(:,:,:) TFNL(:,:,:) ...
       U10FNL(:,:) V10FNL(:,:) PFNL(:,:) MCAPEFNL(:,:) MCINFNL(:,:)]=read_arwpost_forecast(file,nx,ny,nz,false); 
      %end

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
                                 'SMU','SMV','SMT','SMQ','SMH','SMP',...
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
