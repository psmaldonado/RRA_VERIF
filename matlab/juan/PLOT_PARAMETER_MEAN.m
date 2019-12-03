clear all
close all

%Graficamos los parametros medios y su dispersion...

load('../copy/SENSITIVITY_FLUX_TYPHOON/cost_function_hfx.mat','XLONG_U','XLAT_U');
XLONG=squeeze(XLONG_U(1,:,:));
XLAT=squeeze(XLAT_U(1,:,:));

load ../copy/EXP_40mem_sfflux_ntpar_smooth_fixparinf0.05_qfx/parameter_spe_2008081506_2008093018.mat

MEAN_PARAMETER_QFX=MEAN_PARAMETER;
STD_PARAMETER_QFX=STD_PARAMETER;

pcolor(XLONG,XLAT,MEAN_PARAMETER(2:end,:,2))
xlabel('LONGITUDE')
ylabel('LATITUDE')
title('MOISTURE FLUX CORRECTION FACTOR')
shading flat
caxis([0.5 1.5])
hold on
load coast
plot(long,lat,'-k','LineWidth',2)
colorbar

%load ../copy/EXP_40mem_sfflux_ntpar_smooth_fixparinf0.05_qfxhfx/parameter_spe_2008081506_2008093018.mat

%MEAN_PARAMETER_QFXHFX=MEAN_PARAMETER;
%STD_PARAMETER_QFXHFX=STD_PARAMETER;