clear all
close all

BASEURL='/home/jruiz/LETKF_WRF_NEW/wrf/work/';
EXPNAME='TEST';
ENSSIZE=28;

INIDATE='2008081506';
ENDDATE='2008081506';

load coast
%==========================================================================
%Dimensions.
xdef = [ 100.5704  
   101.1545    
   101.7386    
   102.3228    
   102.9069    
   103.4911    
   104.0752    
   104.6594    
   105.2435    
   105.8276    
   106.4118    
   106.9959    
   107.5801    
   108.1642    
   108.7484    
   109.3325    
   109.9166    
   110.5008    
   111.0849    
   111.6691    
   112.2532    
   112.8374    
   113.4215    
   114.0056    
   114.5898    
   115.1739    
   115.7581    
   116.3422    
   116.9264    
   117.5105    
   118.0946    
   118.6788    
   119.2629    
   119.8471    
   120.4312    
   121.0154    
   121.5995    
   122.1836    
   122.7678    
   123.3519    
   123.9361    
   124.5202    
   125.1044    
   125.6885    
   126.2726    
   126.8568    
   127.4409    
   128.0251    
   128.6092    
   129.1934    
   129.7775    
   130.3616    
   130.9458    
   131.5299    
   132.1141    
   132.6982    
   133.2824    
   133.8665    
   134.4506    
   135.0348    
   135.6189    
   136.2031    
   136.7872    
   137.3714    
   137.9555    
   138.5396    
   139.1238    
   139.7079    
   140.2921    
   140.8762    
   141.4604    
   142.0445    
   142.6286    
   143.2128    
   143.7969    
   144.3811    
   144.9652    
   145.5494    
   146.1335    
   146.7176    
   147.3018    
   147.8859    
   148.4701    
   149.0542    
   149.6384    
   150.2225    
   150.8066    
   151.3908    
   151.9749    
   152.5591    
   153.1432    
   153.7274    
   154.3115    
   154.8956    
   155.4798    
   156.0639    
   156.6481    
   157.2322    
   157.8164    
   158.4005    
   158.9846    
   159.5688    
   160.1529    
   160.7371    
   161.3212    
   161.9054    
   162.4895    
   163.0736    
   163.6578    
   164.2419    
   164.8261    
   165.4102    
   165.9944    
   166.5785    
   167.1626    
   167.7468    
   168.3309    
   168.9151    
   169.4992    
   170.0834    
   170.6675    
   171.2516    
   171.8358    
   172.4199    
   173.0041    
   173.5882    
   174.1724    
   174.7565    
   175.3406    
   175.9248    
   176.5089    
   177.0931    
   177.6772    
   178.2614    
   178.8455    
   179.4296 ];   
ydef =[ 0.2212753    
  0.8053894    
   1.389427    
   1.973312    
   2.556992    
   3.140419    
   3.723511    
   4.306221    
   4.888474    
   5.470238    
   6.051422    
   6.631996    
   7.211868    
   7.791016    
   8.369354    
   8.946831    
   9.523407    
   10.09901    
   10.67358    
   11.24706    
   11.81940    
   12.39056    
   12.96046    
   13.52907    
   14.09631    
   14.66216    
   15.22653    
   15.78941    
   16.35072    
   16.91042    
   17.46848    
   18.02482    
   18.57941    
   19.13219    
   19.68314    
   20.23221    
   20.77933    
   21.32449    
   21.86762    
   22.40870    
   22.94767    
   23.48451    
   24.01917    
   24.55162    
   25.08183    
   25.60973    
   26.13532    
   26.65856    
   27.17941    
   27.69783    
   28.21381    
   28.72730    
   29.23830    
   29.74673    
   30.25262    
   30.75591    
   31.25658    
   31.75460    
   32.24997    
   32.74266    
   33.23263    
   33.71986    
   34.20435    
   34.68607    
   35.16502    
   35.64113    
   36.11445    
   36.58492    
   37.05255    
   37.51730    
   37.97919    
   38.43819    
   38.89429    
   39.34746    
   39.79773    
   40.24506    
   40.68947    
   41.13092    
   41.56943    
   42.00499    
   42.43756    
   42.86719    
   43.29384    
   43.71751    
   44.13821    
   44.55595    
   44.97070    
   45.38248    
   45.79128    
   46.19710    
   46.59993    
   46.99980    
   47.39671    
   47.79065    
   48.18163    
   48.56963    
   48.95468    
   49.33678    
   49.71596    
   50.09218    
   50.46547    
   50.83585    
   51.20329    
   51.56784    
   51.92949    
   52.28824    
   52.64412    
   52.99712];    
zdef = [ 1000.00000
 975.00000
 950.00000
 925.00000
 900.00000
 850.00000
 800.00000
 700.00000
 600.00000
 500.00000
 400.00000
 300.00000
 250.00000
 200.00000
 150.00000
 100.00000 ];

%==========================================================================
%Read and plot data
%==========================================================================

inid=datenum(INIDATE,'yyyymmddHH');
endd=datenum(ENDDATE,'yyyymmddHH');

nx=length(xdef);
ny=length(ydef);
nz=length(zdef);

curd=inid;
while(curd <= endd)
    
    
    for iens=1:ENSSIZE
      SIENS=num2str(1000+iens);SIENS=SIENS(2:end);
      datefolder=datestr(curd+6/24,'yyyymmddHHMM');
      datefile  =datestr(curd     ,'yyyymmddHHMM');
      fileanl=[BASEURL '/' EXPNAME '/gues/' SIENS '/' datefolder '/plev/' datefile '.dat'];
      nfileanl=fopen(fileanl,'r','b');
         %Read fields
         for iz=1:nz
            U(:,:,iz,iens)=fread(nfileanl,[nx ny],'single')';
         end
         U(U>1e15)=NaN;
         for iz=1:nz
            V(:,:,iz,iens)=fread(nfileanl,[nx ny],'single')';
         end
         V(V>1e15)=NaN;
         for iz=1:nz
            W(:,:,iz,iens)=fread(nfileanl,[nx ny],'single')';
         end
         W(W>1e15)=NaN;
         PSFC(:,:,iens)=fread(nfileanl,[nx ny],'single')';
         PSFC(PSFC>1e15)=NaN;
         for iz=1:nz
            QVAPOR(:,:,iz,iens)=fread(nfileanl,[nx ny],'single')';
         end
         QVAPOR(QVAPOR>1e15)=NaN;
         VEGFRA(:,:,iens)=fread(nfileanl,[nx ny],'single')';
         VEGFRA(VEGFRA>1e15)=NaN;
         SST(:,:,iens)=fread(nfileanl,[nx ny],'single')';
         SST(SST>1e15)=NaN;
         HGT(:,:,iens)=fread(nfileanl,[nx ny],'single')';
         HGT(HGT>1e15)=NaN;
         TSK(:,:,iens)=fread(nfileanl,[nx ny],'single')';
         TSK(TSK>1e15)=NaN;
         RAINC(:,:,iens)=fread(nfileanl,[nx ny],'single')';
         RAINC(RAINC>1e15)=NaN;
         RAINNC(:,:,iens)=fread(nfileanl,[nx ny],'single')';
         RAINNC(RAINNC>1e15)=NaN;
         for iz=1:nz
            GEOPT(:,:,iz,iens)=fread(nfileanl,[nx ny],'single')';
         end
         GEOPT(GEOPT>1e15)=NaN;
         for iz=1:nz
            HEIGHT(:,:,iz,iens)=fread(nfileanl,[nx ny],'single')';
         end
         HEIGHT(HEIGHT>1e15)=NaN;
         for iz=1:nz
            TK(:,:,iz,iens)=fread(nfileanl,[nx ny],'single')';
         end
         TK(TK>1e15)=NaN;
         for iz=1:nz
            RH(:,:,iz,iens)=fread(nfileanl,[nx ny],'single')';
         end
         RH(RH>1e15)=NaN;
         RH2(:,:,iens)=fread(nfileanl,[nx ny],'single')';
         RH2(RH2>1e15)=NaN;
         U10M(:,:,iens)=fread(nfileanl,[nx ny],'single')';
         U10M(U10M>1e15)=NaN;
         V10M(:,:,iens)=fread(nfileanl,[nx ny],'single')';
         V10M(V10M>1e15)=NaN;
         SLP(:,:,iens)=fread(nfileanl,[nx ny],'single')';
         SLP(SLP>1e15)=NaN;
         MCAPE(:,:,iens)=fread(nfileanl,[nx ny],'single')';
         MCAPE(MCAPE>1e15)=NaN;
         MCIN(:,:,iens)=fread(nfileanl,[nx ny],'single')'; 
         MCIN(MCIN>1e15)=NaN;
    end
    
    
    %Compute mean and spread.
    UANL=nanmean(U,4);
    VANL=nanmean(V,4);
    WANL=nanmean(W,4);
    PSFCANL=nanmean(PSFC,3);
    QVAPORANL=nanmean(QVAPOR,4);
    TSKANL=nanmean(TSK,3);
    RAINCANL=nanmean(RAINC,3);
    RAINNCANL=nanmean(RAINNC,3);
    GEOPTANL=nanmean(GEOPT,4);
    HEIGTHANL=nanmean(HEIGHT,4);
    TKANL=nanmean(TK,4);
    RHANL=nanmean(RH,4);
    RH2ANL=nanmean(RH,3);
    U10MANL=nanmean(U10M,3);
    V10MANL=nanmean(V10M,3);
    SLPANL=nanmean(SLP,3);
    MCAPEANL=nanmean(MCAPE,3);
    MCINANL=nanmean(MCIN,3);
    
    
    
    for iens=1:ENSSIZE
      SIENS=num2str(1000+iens);SIENS=SIENS(2:end);
      datefolder=datestr(curd+6/24,'yyyymmddHHMM');
      datefolderfor=datestr(curd,'yyyymmddHHMM');
      datefile  =datestr(curd     ,'yyyymmddHHMM');
      filefor=[BASEURL '/' EXPNAME '/gues/' SIENS '/' datefolderfor '/plev/' datefile '.dat'];
      nfilefor=fopen(filefor,'r','b');
         %Read fields
         for iz=1:nz
            U(:,:,iz,iens)=fread(nfilefor,[nx ny],'single')';
         end
         U(U>1e15)=NaN;
         for iz=1:nz
            V(:,:,iz,iens)=fread(nfilefor,[nx ny],'single')';
         end
         V(V>1e15)=NaN;
         for iz=1:nz
            W(:,:,iz,iens)=fread(nfilefor,[nx ny],'single')';
         end
         W(W>1e15)=NaN;
         PSFC(:,:,iens)=fread(nfilefor,[nx ny],'single')';
         PSFC(PSFC>1e15)=NaN;
         for iz=1:nz
            QVAPOR(:,:,iz,iens)=fread(nfilefor,[nx ny],'single')';
         end
         QVAPOR(QVAPOR>1e15)=NaN;
         VEGFRA(:,:,iens)=fread(nfilefor,[nx ny],'single')';
         VEGFRA(VEGFRA>1e15)=NaN;
         SST(:,:,iens)=fread(nfilefor,[nx ny],'single')';
         SST(SST>1e15)=NaN;
         HGT(:,:,iens)=fread(nfilefor,[nx ny],'single')';
         HGT(HGT>1e15)=NaN;
         TSK(:,:,iens)=fread(nfilefor,[nx ny],'single')';
         TSK(TSK>1e15)=NaN;
         RAINC(:,:,iens)=fread(nfilefor,[nx ny],'single')';
         RAINC(RAINC>1e15)=NaN;
         RAINNC(:,:,iens)=fread(nfilefor,[nx ny],'single')';
         RAINNC(RAINNC>1e15)=NaN;
         for iz=1:nz
            GEOPT(:,:,iz,iens)=fread(nfilefor,[nx ny],'single')';
         end
         GEOPT(GEOPT>1e15)=NaN;
         for iz=1:nz
            HEIGHT(:,:,iz,iens)=fread(nfilefor,[nx ny],'single')';
         end
         HEIGHT(HEIGHT>1e15)=NaN;
         for iz=1:nz
            TK(:,:,iz,iens)=fread(nfilefor,[nx ny],'single')';
         end
         TK(TK>1e15)=NaN;
         for iz=1:nz
            RH(:,:,iz,iens)=fread(nfilefor,[nx ny],'single')';
         end
         RH(RH>1e15)=NaN;
         RH2(:,:,iens)=fread(nfilefor,[nx ny],'single')';
         RH2(RH2>1e15)=NaN;
         U10M(:,:,iens)=fread(nfilefor,[nx ny],'single')';
         U10M(U10M>1e15)=NaN;
         V10M(:,:,iens)=fread(nfilefor,[nx ny],'single')';
         V10M(V10M>1e15)=NaN;
         SLP(:,:,iens)=fread(nfilefor,[nx ny],'single')';
         SLP(SLP>1e15)=NaN;
         MCAPE(:,:,iens)=fread(nfilefor,[nx ny],'single')';
         MCAPE(MCAPE>1e15)=NaN;
         MCIN(:,:,iens)=fread(nfilefor,[nx ny],'single')'; 
         MCIN(MCIN>1e15)=NaN;
    end
    
    
    %Compute mean and spread.
    UFOR=nanmean(U,4);
    VFOR=nanmean(V,4);
    WFOR=nanmean(W,4);
    PSFCFOR=nanmean(PSFC,3);
    QVAPORFOR=nanmean(QVAPOR,4);
    TSKFOR=nanmean(TSK,3);
    RAINCFOR=nanmean(RAINC,3);
    RAINNCFOR=nanmean(RAINNC,3);
    GEOPTFOR=nanmean(GEOPT,4);
    HEIGTHFOR=nanmean(HEIGHT,4);
    TKFOR=nanmean(TK,4);
    RHFOR=nanmean(RH,4);
    RH2FOR=nanmean(RH,3);
    U10MFOR=nanmean(U10M,3);
    V10MFOR=nanmean(V10M,3);
    SLPFOR=nanmean(SLP,3);
    MCAPEFOR=nanmean(MCAPE,3);
    MCINFOR=nanmean(MCIN,3);
    
    %Compute update
    UUDP=UFOR-UANL;
    VUDP=VFOR-VANL;
    WUDP=WFOR-WANL;
    PSFCUDP=PSFCFOR-PSFCANL;
    QVAPORUDP=QVAPORFOR-QVAPORANL;
    TSKUDP=TSKFOR-TSKANL;
    GEOPTUDP=GEOPTFOR-GEOPTANL;
    TKUDP=TKFOR-TKANL;
    RHUDP=RHFOR-RHANL;
    RH2UDP=RH2FOR-RH2ANL;
    U10MUDP=U10MFOR-U10MANL;
    V10MUDP=V10MFOR-V10MANL;
    SLPUDP=SLPFOR-SLPANL;
    MCAPEUDP=MCAPEFOR-MCAPEANL;
    MCINUDP=MCINFOR-MCINANL;
    
    
    
    %plots.
    %==================SPRD PLOTS==========================================
    VAR='UUDP';
    figure
    subplot(2,2,1)
    hold on
    contourf(xdef,ydef,UUDP(:,:,2));
    plot(long,lat,'k-','LineWidth',2)
    title([VAR ' 925'])
    colorbar
    subplot(2,2,2)
    hold on
    contourf(xdef,ydef,UUDP(:,:,5));
    plot(long,lat,'k-','LineWidth',2)
    title([VAR '850'])
    colorbar
    subplot(2,2,3)
    hold on
    contourf(xdef,ydef,UUDP(:,:,9));
    plot(long,lat,'k-','LineWidth',2)
    title([VAR '500'])
    colorbar
    subplot(2,2,4)
    hold on
    contourf(xdef,ydef,UUDP(:,:,13));
    plot(long,lat,'k-','LineWidth',2)
    title([VAR '200'])
    colorbar
    print('-dpng',[BASEURL '/' EXPNAME '/gues/' SIENS '/' datefolder '/plev/ANL_' VAR '.png']);
    
    VAR='VUDP';
    figure
    subplot(2,2,1)
    hold on
    contourf(xdef,ydef,VUDP(:,:,2));
    plot(long,lat,'k-','LineWidth',2)
    title([VAR ' 925'])
    colorbar
    subplot(2,2,2)
    hold on
    contourf(xdef,ydef,VUDP(:,:,5));
    plot(long,lat,'k-','LineWidth',2)
    title([VAR '850'])
    colorbar
    subplot(2,2,3)
    hold on
    contourf(xdef,ydef,VUDP(:,:,9));
    plot(long,lat,'k-','LineWidth',2)
    title([VAR '500'])
    colorbar
    subplot(2,2,4)
    hold on
    contourf(xdef,ydef,VUDP(:,:,13));
    plot(long,lat,'k-','LineWidth',2)
    title([VAR '200'])
    colorbar
    print('-dpng',[BASEURL '/' EXPNAME '/gues/' SIENS '/' datefolder '/plev/ANL_' VAR '.png']);
    
    VAR='WUDP';
    figure
    subplot(2,2,1)
    hold on
    contourf(xdef,ydef,WUDP(:,:,2));
    plot(long,lat,'k-','LineWidth',2)
    title([VAR ' 925'])
    colorbar
    subplot(2,2,2)
    hold on
    contourf(xdef,ydef,WUDP(:,:,5));
    plot(long,lat,'k-','LineWidth',2)
    title([VAR '850'])
    colorbar
    subplot(2,2,3)
    hold on
    contourf(xdef,ydef,WUDP(:,:,9));
    plot(long,lat,'k-','LineWidth',2)
    title([VAR '500'])
    colorbar
    subplot(2,2,4)
    hold on
    contourf(xdef,ydef,WUDP(:,:,13));
    plot(long,lat,'k-','LineWidth',2)
    title([VAR '200'])
    colorbar
    print('-dpng',[BASEURL '/' EXPNAME '/gues/' SIENS '/' datefolder '/plev/ANL_' VAR '.png']);
    
    VAR='QVAPORUDP';
    figure
    subplot(2,2,1)
    hold on
    contourf(xdef,ydef,QVAPORUDP(:,:,2));
    plot(long,lat,'k-','LineWidth',2)
    title([VAR ' 925'])
    colorbar
    subplot(2,2,2)
    hold on
    contourf(xdef,ydef,QVAPORUDP(:,:,5));
    plot(long,lat,'k-','LineWidth',2)
    title([VAR '850'])
    colorbar
    subplot(2,2,3)
    hold on
    contourf(xdef,ydef,QVAPORUDP(:,:,9));
    plot(long,lat,'k-','LineWidth',2)
    title([VAR '500'])
    colorbar
    subplot(2,2,4)
    hold on
    contourf(xdef,ydef,QVAPORUDP(:,:,13));
    plot(long,lat,'k-','LineWidth',2)
    title([VAR '200'])
    colorbar
    print('-dpng',[BASEURL '/' EXPNAME '/gues/' SIENS '/' datefolder '/plev/ANL_' VAR '.png']);
    
    VAR='GEOPTUDP';
    figure
    subplot(2,2,1)
    hold on
    contourf(xdef,ydef,GEOPTUDP(:,:,2)/10);
    plot(long,lat,'k-','LineWidth',2)
    title([VAR ' 925'])
    colorbar
    subplot(2,2,2)
    hold on
    contourf(xdef,ydef,GEOPTUDP(:,:,5)/10);
    plot(long,lat,'k-','LineWidth',2)
    title([VAR '850'])
    colorbar
    subplot(2,2,3)
    hold on
    contourf(xdef,ydef,GEOPTUDP(:,:,9)/10);
    plot(long,lat,'k-','LineWidth',2)
    title([VAR '500'])
    colorbar
    subplot(2,2,4)
    hold on
    contourf(xdef,ydef,GEOPTUDP(:,:,13)/10);
    plot(long,lat,'k-','LineWidth',2)
    title([VAR '200'])
    colorbar
    print('-dpng',[BASEURL '/' EXPNAME '/gues/' SIENS '/' datefolder '/plev/ANL_' VAR '.png']);
    
    VAR='TKUDP';
    figure
    subplot(2,2,1)
    hold on
    contourf(xdef,ydef,TKUDP(:,:,2));
    plot(long,lat,'k-','LineWidth',2)
    title([VAR ' 925'])
    colorbar
    subplot(2,2,2)
    hold on
    contourf(xdef,ydef,TKUDP(:,:,5));
    plot(long,lat,'k-','LineWidth',2)
    title([VAR '850'])
    colorbar
    subplot(2,2,3)
    hold on
    contourf(xdef,ydef,TKUDP(:,:,9));
    plot(long,lat,'k-','LineWidth',2)
    title([VAR '500'])
    colorbar
    subplot(2,2,4)
    hold on
    contourf(xdef,ydef,TKUDP(:,:,13));
    plot(long,lat,'k-','LineWidth',2)
    title([VAR '200'])
    colorbar
    print('-dpng',[BASEURL '/' EXPNAME '/gues/' SIENS '/' datefolder '/plev/ANL_' VAR '.png']);
    
    figure
    hold on
    contourf(xdef,ydef,SLPUDP);
    plot(long,lat,'k-','LineWidth',2)
    title(['SLPUDP 925'])
    colorbar
    print('-dpng',[BASEURL '/' EXPNAME '/gues/' SIENS '/' datefolder '/plev/ANL_SLPSPRD.png']);
    figure
    hold on
    contourf(xdef,ydef,MCAPEUDP);
    plot(long,lat,'k-','LineWidth',2)
    title(['MCAPEUDP 925'])
    colorbar
    print('-dpng',[BASEURL '/' EXPNAME '/gues/' SIENS '/' datefolder '/plev/ANL_MCAPESPRD.png']);
    figure
    hold on
    contourf(xdef,ydef,MCINUDP);
    plot(long,lat,'k-','LineWidth',2)
    title(['MCINUDP 925'])
    colorbar
    print('-dpng',[BASEURL '/' EXPNAME '/gues/' SIENS '/' datefolder '/plev/ANL_MCINSPRD.png']);

    
    
    close all
    fclose all
    
    
   curd=curd+6/24; 
end






