clear all
close all

BASEURL='/home/jruiz/LETKF_WRF_NEW/wrf/work/';
EXPNAME='TEST';
ENSSIZE=28;

INIDATE='2008081506';
ENDDATE='2008082006';

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
      file=[BASEURL '/' EXPNAME '/gues/' SIENS '/' datefolder '/plev/' datefile '.dat'];
      [U(:,:,:,iens) V(:,:,:,iens) W(:,:,:,iens) PSFC(:,:,iens) QVAPOR(:,:,:,iens) ...
       VEGFRA(:,:,iens) SST(:,:,iens) HGT(:,:,iens) TSK(:,:,iens) RAINC(:,:,iens) RAINNC(:,:,iens) ... 
       GEOPT(:,:,:,iens) HEIGHT(:,:,iens) TK(:,:,:,iens) RH(:,:,:,iens) ...
       RH2(:,:,iens) U10M(:,:,iens) V10M(:,:,iens) SLP(:,:,iens) MCAPE(:,:,iens) MCIN(:,:,iens)]=read_arwpost(file,nx,ny,nz); 
    end
    
    
    %Compute mean and spread.
    UMEAN=nanmean(U,4);
    VMEAN=nanmean(V,4);
    WMEAN=nanmean(W,4);
    PSFCMEAN=nanmean(PSFC,3);
    QVAPORMEAN=nanmean(QVAPOR,4);
    TSKMEAN=nanmean(TSK,3);
    RAINCMEAN=nanmean(RAINC,3);
    RAINNCMEAN=nanmean(RAINNC,3);
    GEOPTMEAN=nanmean(GEOPT,4);
    HEIGTHMEAN=nanmean(HEIGHT,4);
    TKMEAN=nanmean(TK,4);
    RHMEAN=nanmean(RH,4);
    RH2MEAN=nanmean(RH,3);
    U10MMEAN=nanmean(U10M,3);
    V10MMEAN=nanmean(V10M,3);
    SLPMEAN=nanmean(SLP,3);
    MCAPEMEAN=nanmean(MCAPE,3);
    MCINMEAN=nanmean(MCIN,3);
    
    USPRD=nanstd(U,[],4);
    VSPRD=nanstd(V,[],4);
    WSPRD=nanstd(W,[],4);
    PSFCSPRD=nanstd(PSFC,[],3);
    QVAPORSPRD=nanstd(QVAPOR,[],4);
    TSKSPRD=nanstd(TSK,[],3);
    RAINCSPRD=nanstd(RAINC,[],3);
    RAINNCSPRD=nanstd(RAINNC,[],3);
    GEOPTSPRD=nanstd(GEOPT,[],4);
    HEIGTHSPRD=nanstd(HEIGHT,[],4);
    TKSPRD=nanstd(TK,[],4);
    RHSPRD=nanstd(RH,[],4);
    RH2SPRD=nanstd(RH,[],3);
    U10MSPRD=nanstd(U10M,[],3);
    V10MSPRD=nanstd(V10M,[],3);
    SLPSPRD=nanstd(SLP,[],3);
    MCAPESPRD=nanstd(MCAPE,[],3);
    MCINSPRD=nanstd(MCIN,[],3);
    
    
    %plots.
    %==================SPRD PLOTS==========================================
    VAR='USPRD';
    figure
    subplot(2,2,1)
    hold on
    contourf(xdef,ydef,USPRD(:,:,2));
    plot(long,lat,'k-','LineWidth',2)
    title([VAR ' 925'])
    colorbar
    subplot(2,2,2)
    hold on
    contourf(xdef,ydef,USPRD(:,:,5));
    plot(long,lat,'k-','LineWidth',2)
    title([VAR '850'])
    colorbar
    subplot(2,2,3)
    hold on
    contourf(xdef,ydef,USPRD(:,:,9));
    plot(long,lat,'k-','LineWidth',2)
    title([VAR '500'])
    colorbar
    subplot(2,2,4)
    hold on
    contourf(xdef,ydef,USPRD(:,:,13));
    plot(long,lat,'k-','LineWidth',2)
    title([VAR '200'])
    colorbar
    print('-dpng',[BASEURL '/' EXPNAME '/gues/' SIENS '/' datefolder '/plev/ANL_' VAR '.png']);
    
    VAR='VSPRD';
    figure
    subplot(2,2,1)
    hold on
    contourf(xdef,ydef,VSPRD(:,:,2));
    plot(long,lat,'k-','LineWidth',2)
    title([VAR ' 925'])
    colorbar
    subplot(2,2,2)
    hold on
    contourf(xdef,ydef,VSPRD(:,:,5));
    plot(long,lat,'k-','LineWidth',2)
    title([VAR '850'])
    colorbar
    subplot(2,2,3)
    hold on
    contourf(xdef,ydef,VSPRD(:,:,9));
    plot(long,lat,'k-','LineWidth',2)
    title([VAR '500'])
    colorbar
    subplot(2,2,4)
    hold on
    contourf(xdef,ydef,VSPRD(:,:,13));
    plot(long,lat,'k-','LineWidth',2)
    title([VAR '200'])
    colorbar
    print('-dpng',[BASEURL '/' EXPNAME '/gues/' SIENS '/' datefolder '/plev/ANL_' VAR '.png']);
    
    VAR='WSPRD';
    figure
    subplot(2,2,1)
    hold on
    contourf(xdef,ydef,WSPRD(:,:,2));
    plot(long,lat,'k-','LineWidth',2)
    title([VAR ' 925'])
    colorbar
    subplot(2,2,2)
    hold on
    contourf(xdef,ydef,WSPRD(:,:,5));
    plot(long,lat,'k-','LineWidth',2)
    title([VAR '850'])
    colorbar
    subplot(2,2,3)
    hold on
    contourf(xdef,ydef,WSPRD(:,:,9));
    plot(long,lat,'k-','LineWidth',2)
    title([VAR '500'])
    colorbar
    subplot(2,2,4)
    hold on
    contourf(xdef,ydef,WSPRD(:,:,13));
    plot(long,lat,'k-','LineWidth',2)
    title([VAR '200'])
    colorbar
    print('-dpng',[BASEURL '/' EXPNAME '/gues/' SIENS '/' datefolder '/plev/ANL_' VAR '.png']);
    
    VAR='QVAPORSPRD';
    figure
    subplot(2,2,1)
    hold on
    contourf(xdef,ydef,QVAPORSPRD(:,:,2));
    plot(long,lat,'k-','LineWidth',2)
    title([VAR ' 925'])
    colorbar
    subplot(2,2,2)
    hold on
    contourf(xdef,ydef,QVAPORSPRD(:,:,5));
    plot(long,lat,'k-','LineWidth',2)
    title([VAR '850'])
    colorbar
    subplot(2,2,3)
    hold on
    contourf(xdef,ydef,QVAPORSPRD(:,:,9));
    plot(long,lat,'k-','LineWidth',2)
    title([VAR '500'])
    colorbar
    subplot(2,2,4)
    hold on
    contourf(xdef,ydef,QVAPORSPRD(:,:,13));
    plot(long,lat,'k-','LineWidth',2)
    title([VAR '200'])
    colorbar
    print('-dpng',[BASEURL '/' EXPNAME '/gues/' SIENS '/' datefolder '/plev/ANL_' VAR '.png']);
    
    VAR='GEOPTSPRD';
    figure
    subplot(2,2,1)
    hold on
    contourf(xdef,ydef,GEOPTSPRD(:,:,2)/10);
    plot(long,lat,'k-','LineWidth',2)
    title([VAR ' 925'])
    colorbar
    subplot(2,2,2)
    hold on
    contourf(xdef,ydef,GEOPTSPRD(:,:,5)/10);
    plot(long,lat,'k-','LineWidth',2)
    title([VAR '850'])
    colorbar
    subplot(2,2,3)
    hold on
    contourf(xdef,ydef,GEOPTSPRD(:,:,9)/10);
    plot(long,lat,'k-','LineWidth',2)
    title([VAR '500'])
    colorbar
    subplot(2,2,4)
    hold on
    contourf(xdef,ydef,GEOPTSPRD(:,:,13)/10);
    plot(long,lat,'k-','LineWidth',2)
    title([VAR '200'])
    colorbar
    print('-dpng',[BASEURL '/' EXPNAME '/gues/' SIENS '/' datefolder '/plev/ANL_' VAR '.png']);
    
    VAR='TKSPRD';
    figure
    subplot(2,2,1)
    hold on
    contourf(xdef,ydef,TKSPRD(:,:,2));
    plot(long,lat,'k-','LineWidth',2)
    title([VAR ' 925'])
    colorbar
    subplot(2,2,2)
    hold on
    contourf(xdef,ydef,TKSPRD(:,:,5));
    plot(long,lat,'k-','LineWidth',2)
    title([VAR '850'])
    colorbar
    subplot(2,2,3)
    hold on
    contourf(xdef,ydef,TKSPRD(:,:,9));
    plot(long,lat,'k-','LineWidth',2)
    title([VAR '500'])
    colorbar
    subplot(2,2,4)
    hold on
    contourf(xdef,ydef,TKSPRD(:,:,13));
    plot(long,lat,'k-','LineWidth',2)
    title([VAR '200'])
    colorbar
    print('-dpng',[BASEURL '/' EXPNAME '/gues/' SIENS '/' datefolder '/plev/ANL_' VAR '.png']);
    
    figure
    hold on
    contourf(xdef,ydef,SLPSPRD);
    plot(long,lat,'k-','LineWidth',2)
    title(['SLPSPRD 925'])
    colorbar
    print('-dpng',[BASEURL '/' EXPNAME '/gues/' SIENS '/' datefolder '/plev/ANL_SLPSPRD.png']);
    figure
    hold on
    contourf(xdef,ydef,MCAPESPRD);
    plot(long,lat,'k-','LineWidth',2)
    title(['MCAPESPRD 925'])
    colorbar
    print('-dpng',[BASEURL '/' EXPNAME '/gues/' SIENS '/' datefolder '/plev/ANL_MCAPESPRD.png']);
    figure
    hold on
    contourf(xdef,ydef,MCINSPRD);
    plot(long,lat,'k-','LineWidth',2)
    title(['MCINSPRD 925'])
    colorbar
    print('-dpng',[BASEURL '/' EXPNAME '/gues/' SIENS '/' datefolder '/plev/ANL_MCINSPRD.png']);

    
    
    %==================MEAN PLOTS==========================================
    
    
    VAR='UMEAN';
    figure
    subplot(2,2,1)
    hold on
    contourf(xdef,ydef,UMEAN(:,:,2));
    plot(long,lat,'k-','LineWidth',2)
    title([VAR ' 925'])
    colorbar
    subplot(2,2,2)
    hold on
    contourf(xdef,ydef,UMEAN(:,:,5));
    plot(long,lat,'k-','LineWidth',2)
    title([VAR '850'])
    colorbar
    subplot(2,2,3)
    hold on
    contourf(xdef,ydef,UMEAN(:,:,9));
    plot(long,lat,'k-','LineWidth',2)
    title([VAR '500'])
    colorbar
    subplot(2,2,4)
    hold on
    contourf(xdef,ydef,UMEAN(:,:,13));
    plot(long,lat,'k-','LineWidth',2)
    title([VAR '200'])
    colorbar
    print('-dpng',[BASEURL '/' EXPNAME '/gues/' SIENS '/' datefolder '/plev/ANL_' VAR '.png']);
    
    VAR='VMEAN';
    figure
    subplot(2,2,1)
    hold on
    contourf(xdef,ydef,VMEAN(:,:,2));
    plot(long,lat,'k-','LineWidth',2)
    title([VAR ' 925'])
    colorbar
    subplot(2,2,2)
    hold on
    contourf(xdef,ydef,VMEAN(:,:,5));
    plot(long,lat,'k-','LineWidth',2)
    title([VAR '850'])
    colorbar
    subplot(2,2,3)
    hold on
    contourf(xdef,ydef,VMEAN(:,:,9));
    plot(long,lat,'k-','LineWidth',2)
    title([VAR '500'])
    colorbar
    subplot(2,2,4)
    hold on
    contourf(xdef,ydef,VMEAN(:,:,13));
    plot(long,lat,'k-','LineWidth',2)
    title([VAR '200'])
    colorbar
    print('-dpng',[BASEURL '/' EXPNAME '/gues/' SIENS '/' datefolder '/plev/ANL_' VAR '.png']);
    
    VAR='WMEAN';
    figure
    subplot(2,2,1)
    hold on
    contourf(xdef,ydef,WMEAN(:,:,2));
    plot(long,lat,'k-','LineWidth',2)
    title([VAR ' 925'])
    colorbar
    subplot(2,2,2)
    hold on
    contourf(xdef,ydef,WMEAN(:,:,5));
    plot(long,lat,'k-','LineWidth',2)
    title([VAR '850'])
    colorbar
    subplot(2,2,3)
    hold on
    contourf(xdef,ydef,WMEAN(:,:,9));
    plot(long,lat,'k-','LineWidth',2)
    title([VAR '500'])
    colorbar
    subplot(2,2,4)
    hold on
    contourf(xdef,ydef,WMEAN(:,:,13));
    plot(long,lat,'k-','LineWidth',2)
    title([VAR '200'])
    colorbar
    print('-dpng',[BASEURL '/' EXPNAME '/gues/' SIENS '/' datefolder '/plev/ANL_' VAR '.png']);
    
    VAR='QVAPORSPRD';
    figure
    subplot(2,2,1)
    hold on
    contourf(xdef,ydef,QVAPORMEAN(:,:,2));
    plot(long,lat,'k-','LineWidth',2)
    title([VAR ' 925'])
    colorbar
    subplot(2,2,2)
    hold on
    contourf(xdef,ydef,QVAPORMEAN(:,:,5));
    plot(long,lat,'k-','LineWidth',2)
    title([VAR '850'])
    colorbar
    subplot(2,2,3)
    hold on
    contourf(xdef,ydef,QVAPORMEAN(:,:,9));
    plot(long,lat,'k-','LineWidth',2)
    title([VAR '500'])
    colorbar
    subplot(2,2,4)
    hold on
    contourf(xdef,ydef,QVAPORMEAN(:,:,13));
    plot(long,lat,'k-','LineWidth',2)
    title([VAR '200'])
    colorbar
    print('-dpng',[BASEURL '/' EXPNAME '/gues/' SIENS '/' datefolder '/plev/ANL_' VAR '.png']);
    
    VAR='GEOPTSPRD';
    figure
    subplot(2,2,1)
    hold on
    contourf(xdef,ydef,GEOPTMEAN(:,:,2)/10);
    plot(long,lat,'k-','LineWidth',2)
    title([VAR ' 925'])
    colorbar
    subplot(2,2,2)
    hold on
    contourf(xdef,ydef,GEOPTMEAN(:,:,5)/10);
    plot(long,lat,'k-','LineWidth',2)
    title([VAR '850'])
    colorbar
    subplot(2,2,3)
    hold on
    contourf(xdef,ydef,GEOPTMEAN(:,:,9)/10);
    plot(long,lat,'k-','LineWidth',2)
    title([VAR '500'])
    colorbar
    subplot(2,2,4)
    hold on
    contourf(xdef,ydef,GEOPTMEAN(:,:,13)/10);
    plot(long,lat,'k-','LineWidth',2)
    title([VAR '200'])
    colorbar
    print('-dpng',[BASEURL '/' EXPNAME '/gues/' SIENS '/' datefolder '/plev/ANL_' VAR '.png']);
    
    VAR='TKMEAN';
    figure
    subplot(2,2,1)
    hold on
    contourf(xdef,ydef,TKMEAN(:,:,2));
    plot(long,lat,'k-','LineWidth',2)
    title([VAR ' 925'])
    colorbar
    subplot(2,2,2)
    hold on
    contourf(xdef,ydef,TKMEAN(:,:,5));
    plot(long,lat,'k-','LineWidth',2)
    title([VAR '850'])
    colorbar
    subplot(2,2,3)
    hold on
    contourf(xdef,ydef,TKMEAN(:,:,9));
    plot(long,lat,'k-','LineWidth',2)
    title([VAR '500'])
    colorbar
    subplot(2,2,4)
    hold on
    contourf(xdef,ydef,TKMEAN(:,:,13));
    plot(long,lat,'k-','LineWidth',2)
    title([VAR '200'])
    colorbar
    print('-dpng',[BASEURL '/' EXPNAME '/gues/' SIENS '/' datefolder '/plev/ANL_' VAR '.png']);
    
    figure
    hold on
    contourf(xdef,ydef,SLPMEAN);
    plot(long,lat,'k-','LineWidth',2)
    title(['SLPMEAN 925'])
    colorbar
    print('-dpng',[BASEURL '/' EXPNAME '/gues/' SIENS '/' datefolder '/plev/ANL_SLPMEAN.png']);
    figure
    hold on
    contourf(xdef,ydef,MCAPEMEAN);
    plot(long,lat,'k-','LineWidth',2)
    title(['MCAPEMEAN 925'])
    colorbar
    print('-dpng',[BASEURL '/' EXPNAME '/gues/' SIENS '/' datefolder '/plev/ANL_MCAPEMEAN.png']);
    figure
    hold on
    contourf(xdef,ydef,MCINMEAN);
    plot(long,lat,'k-','LineWidth',2)
    title(['MCINMEAN 925'])
    colorbar
    print('-dpng',[BASEURL '/' EXPNAME '/gues/' SIENS '/' datefolder '/plev/ANL_MCINMEAN.png']);
    
    close all
    fclose all
    
    
   curd=curd+6/24; 
end






