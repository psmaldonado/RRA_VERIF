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
EXPNAME{2}='QFX';
EXPNAME{3}='QFX & HFX';
EXPNAME{4}='QFX & UST';


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


NEXP=length(ERROR);
NTIMES=size(ERROR(1).BIASH,4);
NLEVS=size(ERROR(1).BIASH,3);

%Calculo el RMSE promediado sobre todo el dominio para los diferentes
%tiempos y niveles
%Tambien calculo la media del valor absoluto del bias (una medida global
%del bias del modelo sobre el dominio.

for ii=1:NEXP
  
      
      RMSEM(ii).SLP=squeeze(nanmean(nanmean(ERROR(ii).RMSESLP(:,:,1),2),1));
      BIASM(ii).SLP=squeeze(nanmean(nanmean(ERROR(ii).BIASSLP(:,:,1),2),1));
      
      for ilev=1:NLEVS
            
          RMSEM(ii).H(ilev)=squeeze(nanmean(nanmean(ERROR(ii).RMSEH(:,:,ilev,1),2),1));
          RMSEM(ii).Q(ilev)=squeeze(nanmean(nanmean(ERROR(ii).RMSEQ(:,:,ilev,1),2),1));
          RMSEM(ii).T(ilev)=squeeze(nanmean(nanmean(ERROR(ii).RMSET(:,:,ilev,1),2),1));
          RMSEM(ii).U(ilev)=squeeze(nanmean(nanmean(ERROR(ii).RMSEU(:,:,ilev,1),2),1));
          RMSEM(ii).V(ilev)=squeeze(nanmean(nanmean(ERROR(ii).RMSEV(:,:,ilev,1),2),1));
          
          ABSBIASM(ii).H(ilev)=squeeze(nanmean(nanmean(abs(ERROR(ii).BIASH(:,:,ilev,1)),2),1));
          ABSBIASM(ii).Q(ilev)=squeeze(nanmean(nanmean(abs(ERROR(ii).BIASQ(:,:,ilev,1)),2),1));
          ABSBIASM(ii).T(ilev)=squeeze(nanmean(nanmean(abs(ERROR(ii).BIAST(:,:,ilev,1)),2),1));
          ABSBIASM(ii).U(ilev)=squeeze(nanmean(nanmean(abs(ERROR(ii).BIASU(:,:,ilev,1)),2),1));
          ABSBIASM(ii).V(ilev)=squeeze(nanmean(nanmean(abs(ERROR(ii).BIASV(:,:,ilev,1)),2),1));
          
          BIASM(ii).H(ilev)=squeeze(nanmean(nanmean((ERROR(ii).BIASH(:,:,ilev,1)),2),1));
          BIASM(ii).Q(ilev)=squeeze(nanmean(nanmean((ERROR(ii).BIASQ(:,:,ilev,1)),2),1));
          BIASM(ii).T(ilev)=squeeze(nanmean(nanmean((ERROR(ii).BIAST(:,:,ilev,1)),2),1));
          BIASM(ii).U(ilev)=squeeze(nanmean(nanmean((ERROR(ii).BIASU(:,:,ilev,1)),2),1));
          BIASM(ii).V(ilev)=squeeze(nanmean(nanmean((ERROR(ii).BIASV(:,:,ilev,1)),2),1));
          
        end
  end



%RMSE VS TIEMPO Y NIVEL, CAMPO TOTAL Y DIFERENCIAS.

times=[0 6 12 18 24 30 36 42 48 54 60 66 72];

%RMSE
figure
subplot(1,3,1)
%T
hold on
plot(RMSEM(1).T,-log(PLEVS),'-bo','LineWidth',3)
plot(RMSEM(2).T,-log(PLEVS),'-go','LineWidth',3)
plot(RMSEM(3).T,-log(PLEVS),'-ro','LineWidth',3)
title(['RMSE T ']);
set(gca,'YTickMode','Manual','YTick',-log(PLEVS(1:2:end)),'YTickLabel',{'1000';'950';'900';'800';'600';'400';'250';'150'},'XGrid','On','YGrid','On')
legend('CONTROL','QFX','QFX & HFX')


subplot(1,3,2)
%Q
hold on
plot(RMSEM(1).Q,-log(PLEVS),'-bo','LineWidth',3)
plot(RMSEM(2).Q,-log(PLEVS),'-go','LineWidth',3)
plot(RMSEM(3).Q,-log(PLEVS),'-ro','LineWidth',3)
title(['RMSE T ']);
set(gca,'YTickMode','Manual','YTick',-log(PLEVS(1:2:end)),'YTickLabel',{'1000';'950';'900';'800';'600';'400';'250';'150'},'XGrid','On','YGrid','On')

%U
subplot(1,3,3)
hold on
plot(RMSEM(1).U,-log(PLEVS),'-bo','LineWidth',3)
plot(RMSEM(2).U,-log(PLEVS),'-go','LineWidth',3)
plot(RMSEM(3).U,-log(PLEVS),'-ro','LineWidth',3)
title(['RMSE T ']);
set(gca,'YTickMode','Manual','YTick',-log(PLEVS(1:2:end)),'YTickLabel',{'1000';'950';'900';'800';'600';'400';'250';'150'},'XGrid','On','YGrid','On')

%BIAS
figure
subplot(1,3,1)
%T
hold on
plot(BIASM(1).T,-log(PLEVS),'-bo','LineWidth',3)
plot(BIASM(2).T,-log(PLEVS),'-go','LineWidth',3)
plot(BIASM(3).T,-log(PLEVS),'-ro','LineWidth',3)
title(['BIAS T ']);
set(gca,'YTickMode','Manual','YTick',-log(PLEVS(1:2:end)),'YTickLabel',{'1000';'950';'900';'800';'600';'400';'250';'150'},'XGrid','On','YGrid','On')
legend('CONTROL','QFX','QFX & HFX')

subplot(1,3,2)
%Q
hold on
plot(BIASM(1).Q,-log(PLEVS),'-bo','LineWidth',3)
plot(BIASM(2).Q,-log(PLEVS),'-go','LineWidth',3)
plot(BIASM(3).Q,-log(PLEVS),'-ro','LineWidth',3)
title(['BIAS Q ']);
set(gca,'YTickMode','Manual','YTick',-log(PLEVS(1:2:end)),'YTickLabel',{'1000';'950';'900';'800';'600';'400';'250';'150'},'XGrid','On','YGrid','On')

%U
subplot(1,3,3)
hold on
plot(BIASM(1).U,-log(PLEVS),'-bo','LineWidth',3)
plot(BIASM(2).U,-log(PLEVS),'-go','LineWidth',3)
plot(BIASM(3).U,-log(PLEVS),'-ro','LineWidth',3)
title(['BIAS U ']);
set(gca,'YTickMode','Manual','YTick',-log(PLEVS(1:2:end)),'YTickLabel',{'1000';'950';'900';'800';'600';'400';'250';'150'},'XGrid','On','YGrid','On')


%ABSBIAS
figure
subplot(1,3,1)
%T
hold on
plot(ABSBIASM(1).T,-log(PLEVS),'-bo','LineWidth',3)
plot(ABSBIASM(2).T,-log(PLEVS),'-go','LineWidth',3)
plot(ABSBIASM(3).T,-log(PLEVS),'-ro','LineWidth',3)
title(['BIAS T ']);
set(gca,'YTickMode','Manual','YTick',-log(PLEVS(1:2:end)),'YTickLabel',{'1000';'950';'900';'800';'600';'400';'250';'150'},'XGrid','On','YGrid','On')
legend('CONTROL','QFX','QFX & HFX')

subplot(1,3,2)
%Q
hold on
plot(ABSBIASM(1).Q,-log(PLEVS),'-bo','LineWidth',3)
plot(ABSBIASM(2).Q,-log(PLEVS),'-go','LineWidth',3)
plot(ABSBIASM(3).Q,-log(PLEVS),'-ro','LineWidth',3)
title(['BIAS Q ']);
set(gca,'YTickMode','Manual','YTick',-log(PLEVS(1:2:end)),'YTickLabel',{'1000';'950';'900';'800';'600';'400';'250';'150'},'XGrid','On','YGrid','On')

%U
subplot(1,3,3)
hold on
plot(ABSBIASM(1).U,-log(PLEVS),'-bo','LineWidth',3)
plot(ABSBIASM(2).U,-log(PLEVS),'-go','LineWidth',3)
plot(ABSBIASM(3).U,-log(PLEVS),'-ro','LineWidth',3)
title(['BIAS U ']);
set(gca,'YTickMode','Manual','YTick',-log(PLEVS(1:2:end)),'YTickLabel',{'1000';'950';'900';'800';'600';'400';'250';'150'},'XGrid','On','YGrid','On')








