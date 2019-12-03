clear all
close all

%Vamos a comparar los pronosticos obtenidos con las diferentes versiones de
%la estimacion de parametros del WRF. Para diferentes variables y niveles.
%La verificacion se hace contra los analisis del GFS.

PLEVS=[1000.00000 975.00000 950.00000 925.00000 900.00000 850.00000 800.00000 700.00000 ...
   600.0000  500.00000  400.00000  300.00000 250.00000  200.00000  150.00000 100.00000];


%Cargamos los pronosticos....
pathf='../copy/';

EXPNAME{1}='CONTROL';
EXPNAME{2}='NO SMOOTH';
EXPNAME{3}='SMOOTH';



load ([pathf '/FORECAST_EXP_40mem_CONTROL/verification_fnl/rmse_bias.mat' ]);

ERROR(1).BIASH=BIASH;
ERROR(1).BIASQ=BIASQ;
ERROR(1).BIASSLP=BIASSLP;
ERROR(1).BIAST=BIAST;
ERROR(1).BIASU=BIASU;
ERROR(1).BIASV=BIASV;
ERROR(1).RMSEH=RMSEH;
ERROR(1).RMSEQ=RMSEQ;
ERROR(1).RMSESLP=RMSESLP;
ERROR(1).RMSET=RMSET;
ERROR(1).RMSEU=RMSEU;
ERROR(1).RMSEV=RMSEV;

load ([pathf '/FORECAST_EXP_40mem_sfflux_ntpar_nsmooth_fixparinf_qfx/verification_fnl/rmse_bias.mat' ]);

ERROR(2).BIASH=BIASH;
ERROR(2).BIASQ=BIASQ;
ERROR(2).BIASSLP=BIASSLP;
ERROR(2).BIAST=BIAST;
ERROR(2).BIASU=BIASU;
ERROR(2).BIASV=BIASV;
ERROR(2).RMSEH=RMSEH;
ERROR(2).RMSEQ=RMSEQ;
ERROR(2).RMSESLP=RMSESLP;
ERROR(2).RMSET=RMSET;
ERROR(2).RMSEU=RMSEU;
ERROR(2).RMSEV=RMSEV;

load ([pathf '/FORECAST_EXP_40mem_sfflux_ntpar_smooth_fixparinf0.05_qfx/verification_fnl/rmse_bias.mat' ]);

ERROR(3).BIASH=BIASH;
ERROR(3).BIASQ=BIASQ;
ERROR(3).BIASSLP=BIASSLP;
ERROR(3).BIAST=BIAST;
ERROR(3).BIASU=BIASU;
ERROR(3).BIASV=BIASV;
ERROR(3).RMSEH=RMSEH;
ERROR(3).RMSEQ=RMSEQ;
ERROR(3).RMSESLP=RMSESLP;
ERROR(3).RMSET=RMSET;
ERROR(3).RMSEU=RMSEU;
ERROR(3).RMSEV=RMSEV;

NFORECAST=length(ERROR);
NTIMES=size(ERROR(1).BIASH,4);
NLEVS=size(ERROR(1).BIASH,3);

%Calculo el RMSE promediado sobre todo el dominio para los diferentes
%tiempos y niveles
%Tambien calculo la media del valor absoluto del bias (una medida global
%del bias del modelo sobre el dominio.

for ii=1:NFORECAST

  for ifor=1:NTIMES
      
      RMSEM(ii).SLP(ifor)=squeeze(nanmean(nanmean(ERROR(ii).RMSESLP(:,:,ifor),2),1));
      BIASM(ii).SLP(ifor)=squeeze(nanmean(nanmean(ERROR(ii).BIASSLP(:,:,ifor),2),1));
      
      for ilev=1:NLEVS
            
          RMSEM(ii).H(ilev,ifor)=squeeze(nanmean(nanmean(ERROR(ii).RMSEH(:,:,ilev,ifor),2),1));
          RMSEM(ii).Q(ilev,ifor)=squeeze(nanmean(nanmean(ERROR(ii).RMSEQ(:,:,ilev,ifor),2),1));
          RMSEM(ii).T(ilev,ifor)=squeeze(nanmean(nanmean(ERROR(ii).RMSET(:,:,ilev,ifor),2),1));
          RMSEM(ii).U(ilev,ifor)=squeeze(nanmean(nanmean(ERROR(ii).RMSEU(:,:,ilev,ifor),2),1));
          RMSEM(ii).V(ilev,ifor)=squeeze(nanmean(nanmean(ERROR(ii).RMSEV(:,:,ilev,ifor),2),1));
          
          BIASM(ii).H(ilev,ifor)=squeeze(nanmean(nanmean(abs(ERROR(ii).BIASH(:,:,ilev,ifor)),2),1));
          BIASM(ii).Q(ilev,ifor)=squeeze(nanmean(nanmean(abs(ERROR(ii).BIASQ(:,:,ilev,ifor)),2),1));
          BIASM(ii).T(ilev,ifor)=squeeze(nanmean(nanmean(abs(ERROR(ii).BIAST(:,:,ilev,ifor)),2),1));
          BIASM(ii).U(ilev,ifor)=squeeze(nanmean(nanmean(abs(ERROR(ii).BIASU(:,:,ilev,ifor)),2),1));
          BIASM(ii).V(ilev,ifor)=squeeze(nanmean(nanmean(abs(ERROR(ii).BIASV(:,:,ilev,ifor)),2),1));
          
        end
    end

end


%RMSE VS TIEMPO Y NIVEL, CAMPO TOTAL Y DIFERENCIAS.

times=[0 6 12 18 24 30 36 42 48 54 60 66 72];

%T
figure
for iexp=1:NFORECAST

subplot(1,NFORECAST,iexp)
contourf(times,-log(PLEVS),RMSEM(iexp).T)
title(['RMSE T ' EXPNAME{iexp}]);
set(gca,'YTickMode','Manual','YTick',-log(PLEVS(1:2:end)),'YTickLabel',{'1000';'950';'900';'800';'600';'400';'250';'150'})
shading flat
plot_color_fun([0 0.3 0.6 0.9 1.2 1.5 1.8 2.1],[2 21 22 23 24 25 26 28],2);


end

%Q
figure
for iexp=1:NFORECAST

subplot(1,NFORECAST,iexp)
contourf(times,-log(PLEVS),RMSEM(iexp).Q)
title(['RMSE Q ' EXPNAME{iexp}]);
set(gca,'YTickMode','Manual','YTick',-log(PLEVS(1:2:end)),'YTickLabel',{'1000';'950';'900';'800';'600';'400';'250';'150'})
shading flat
plot_color_fun(1e-3*[0 0.3 0.6 0.9 1.2 1.5 1.8 2.1],[2 21 22 23 24 25 26 28],2);

end

%U
figure
for iexp=1:NFORECAST

subplot(1,NFORECAST,iexp)
contourf(times,-log(PLEVS),RMSEM(iexp).U)
title(['RMSE U ' EXPNAME{iexp}]);
set(gca,'YTickMode','Manual','YTick',-log(PLEVS(1:2:end)),'YTickLabel',{'1000';'950';'900';'800';'600';'400';'250';'150'})
shading flat
plot_color_fun(3*[0 0.3 0.6 0.9 1.2 1.5 1.8 2.1],[2 21 22 23 24 25 26 28],2);


end

%V
figure
for iexp=1:NFORECAST

subplot(1,NFORECAST,iexp)
contourf(times,-log(PLEVS),RMSEM(iexp).V)
title(['RMSE V ' EXPNAME{iexp}]);
set(gca,'YTickMode','Manual','YTick',-log(PLEVS(1:2:end)),'YTickLabel',{'1000';'950';'900';'800';'600';'400';'250';'150'})
shading flat
plot_color_fun(3*[0 0.3 0.6 0.9 1.2 1.5 1.8 2.1],[2 21 22 23 24 25 26 28],2);


end


%T
figure
for iexp=1:NFORECAST-1

subplot(1,NFORECAST-1,iexp)
contourf(times,-log(PLEVS),RMSEM(1).T-RMSEM(iexp+1).T)
title(['RMSE T ' EXPNAME{iexp+1}]);
set(gca,'YTickMode','Manual','YTick',-log(PLEVS(1:2:end)),'YTickLabel',{'1000';'950';'900';'800';'600';'400';'250';'150'})
shading flat
plot_color_fun([-0.5 -0.4 -0.3 -0.2 -0.1 0.1 0.2 0.3 0.4 0.5],[48 46 44 42 2 22 24 26 28],2);

end

%Q
figure
for iexp=1:NFORECAST-1

subplot(1,NFORECAST-1,iexp)
contourf(times,-log(PLEVS),RMSEM(1).Q-RMSEM(iexp+1).Q)
title(['RMSE Q ' EXPNAME{iexp+1}]);
set(gca,'YTickMode','Manual','YTick',-log(PLEVS(1:2:end)),'YTickLabel',{'1000';'950';'900';'800';'600';'400';'250';'150'})
shading flat
plot_color_fun(1e-3*[-0.4 -0.3 -0.2 -0.1 -0.05 0.05 0.1 0.2 0.3 0.4],[48 46 44 42 2 22 24 26 28],2);

end

%U
figure
for iexp=1:NFORECAST-1

subplot(1,NFORECAST-1,iexp)
contourf(times,-log(PLEVS),RMSEM(1).U-RMSEM(iexp+1).U)
title(['RMSE U ' EXPNAME{iexp+1}]);
set(gca,'YTickMode','Manual','YTick',-log(PLEVS(1:2:end)),'YTickLabel',{'1000';'950';'900';'800';'600';'400';'250';'150'})
shading flat
plot_color_fun(1.5*[-0.4 -0.3 -0.2 -0.1 -0.05 0.05 0.1 0.2 0.3 0.4],[48 46 44 42 2 22 24 26 28],2);

end

%V
figure
for iexp=1:NFORECAST-1

subplot(1,NFORECAST-1,iexp)
contourf(times,-log(PLEVS),RMSEM(1).V-RMSEM(iexp+1).V)
title(['RMSE V ' EXPNAME{iexp+1}]);
set(gca,'YTickMode','Manual','YTick',-log(PLEVS(1:2:end)),'YTickLabel',{'1000';'950';'900';'800';'600';'400';'250';'150'})
shading flat
plot_color_fun(1.5*[-0.4 -0.3 -0.2 -0.1 -0.05 0.05 0.1 0.2 0.3 0.4],[48 46 44 42 2 22 24 26 28],2);

end


%BIAS VS TIEMPO Y NIVEL, CAMPO TOTAL Y DIFERENCIAS.

times=[0 6 12 18 24 30 36 42 48 54 60 66 72];

%T
figure
for iexp=1:NFORECAST

subplot(1,NFORECAST,iexp)
contourf(times,-log(PLEVS),BIASM(iexp).T)
title(['BIAS T ' EXPNAME{iexp}]);
set(gca,'YTickMode','Manual','YTick',-log(PLEVS(1:2:end)),'YTickLabel',{'1000';'950';'900';'800';'600';'400';'250';'150'})
shading flat
plot_color_fun(0.5*[0 0.3 0.6 0.9 1.2 1.5 1.8 2.1],[2 21 22 23 24 25 26 28],2);


end

%Q
figure
for iexp=1:NFORECAST

subplot(1,NFORECAST,iexp)
contourf(times,-log(PLEVS),BIASM(iexp).Q)
title(['BIAS Q ' EXPNAME{iexp}]);
set(gca,'YTickMode','Manual','YTick',-log(PLEVS(1:2:end)),'YTickLabel',{'1000';'950';'900';'800';'600';'400';'250';'150'})
shading flat
plot_color_fun(0.5e-3*[0 0.3 0.6 0.9 1.2 1.5 1.8 2.1],[2 21 22 23 24 25 26 28],2);

end

%U
figure
for iexp=1:NFORECAST

subplot(1,NFORECAST,iexp)
contourf(times,-log(PLEVS),BIASM(iexp).U)
title(['BIAS U ' EXPNAME{iexp}]);
set(gca,'YTickMode','Manual','YTick',-log(PLEVS(1:2:end)),'YTickLabel',{'1000';'950';'900';'800';'600';'400';'250';'150'})
shading flat
plot_color_fun(1.5*[0 0.3 0.6 0.9 1.2 1.5 1.8 2.1],[2 21 22 23 24 25 26 28],2);


end

%V
figure
for iexp=1:NFORECAST

subplot(1,NFORECAST,iexp)
contourf(times,-log(PLEVS),BIASM(iexp).V)
title(['BIAS V ' EXPNAME{iexp}]);
set(gca,'YTickMode','Manual','YTick',-log(PLEVS(1:2:end)),'YTickLabel',{'1000';'950';'900';'800';'600';'400';'250';'150'})
shading flat
plot_color_fun(1.5*[0 0.3 0.6 0.9 1.2 1.5 1.8 2.1],[2 21 22 23 24 25 26 28],2);


end


%T
figure
for iexp=1:NFORECAST-1

subplot(1,NFORECAST-1,iexp)
contourf(times,-log(PLEVS),BIASM(1).T-BIASM(iexp+1).T)
title(['BIAS T ' EXPNAME{iexp+1}]);
set(gca,'YTickMode','Manual','YTick',-log(PLEVS(1:2:end)),'YTickLabel',{'1000';'950';'900';'800';'600';'400';'250';'150'})
shading flat
plot_color_fun([-0.5 -0.4 -0.3 -0.2 -0.1 0.1 0.2 0.3 0.4 0.5],[48 46 44 42 2 22 24 26 28],2);

end

%Q
figure
for iexp=1:NFORECAST-1

subplot(1,NFORECAST-1,iexp)
contourf(times,-log(PLEVS),BIASM(1).Q-BIASM(iexp+1).Q)
title(['BIAS Q ' EXPNAME{iexp+1}]);
set(gca,'YTickMode','Manual','YTick',-log(PLEVS(1:2:end)),'YTickLabel',{'1000';'950';'900';'800';'600';'400';'250';'150'})
shading flat
plot_color_fun(1e-3*[-0.4 -0.3 -0.2 -0.1 -0.05 0.05 0.1 0.2 0.3 0.4],[48 46 44 42 2 22 24 26 28],2);

end

%U
figure
for iexp=1:NFORECAST-1

subplot(1,NFORECAST-1,iexp)
contourf(times,-log(PLEVS),BIASM(1).U-BIASM(iexp+1).U)
title(['BIAS U ' EXPNAME{iexp+1}]);
set(gca,'YTickMode','Manual','YTick',-log(PLEVS(1:2:end)),'YTickLabel',{'1000';'950';'900';'800';'600';'400';'250';'150'})
shading flat
plot_color_fun(1.5*[-0.4 -0.3 -0.2 -0.1 -0.05 0.05 0.1 0.2 0.3 0.4],[48 46 44 42 2 22 24 26 28],2);

end

%V
figure
for iexp=1:NFORECAST-1

subplot(1,NFORECAST-1,iexp)
contourf(times,-log(PLEVS),BIASM(1).V-BIASM(iexp+1).V)
title(['BIAS V ' EXPNAME{iexp+1}]);
set(gca,'YTickMode','Manual','YTick',-log(PLEVS(1:2:end)),'YTickLabel',{'1000';'950';'900';'800';'600';'400';'250';'150'})
shading flat
plot_color_fun(1.5*[-0.4 -0.3 -0.2 -0.1 -0.05 0.05 0.1 0.2 0.3 0.4],[48 46 44 42 2 22 24 26 28],2);

end


