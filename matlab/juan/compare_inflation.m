clear all
close all


load ../copy/EXP_40mem_CONTROL/inflation_2008081506_2008093018.mat;

INFLATION_MEAN_CONTROL=MEAN_INFLATION(:,:,1:40);
INFLATION_MEAN_SERIE_CONTROL=MEAN_INFLATION_SERIE(:,1:40);

load ../copy/EXP_40mem_sfflux_ntpar_smooth_fixparinf0.05_qfx/inflation_2008081506_2008093018.mat;

INFLATION_MEAN_QFX=MEAN_INFLATION(:,:,1:40);
INFLATION_MEAN_SERIE_QFX=MEAN_INFLATION_SERIE(:,1:40);

load ../copy/EXP_40mem_sfflux_ntpar_smooth_fixparinf0.05_qfxhfx/inflation_2008081506_2008093018.mat;

INFLATION_MEAN_QFXHFX=MEAN_INFLATION(:,:,1:40);
INFLATION_MEAN_SERIE_QFXHFX=MEAN_INFLATION_SERIE(:,1:40);

% load ../copy/EXP_40mem_sfflux_ntpar_smooth_fixparinf0.05_qfxust/inflation_2008081506_2008093018.mat;
% 
% INFLATION_MEAN_QFXUST=MEAN_INFLATION(:,:,1:40);
% INFLATION_MEAN_SERIE_QFXUST=MEAN_INFLATION_SERIE(:,1:40);

%QFX
figure
subplot(2,2,1)
pcolor(INFLATION_MEAN_SERIE_CONTROL(1:4:end,:)'-INFLATION_MEAN_SERIE_QFX(1:4:end,:)')
plot_color_fun([-0.05 -0.04 -0.03 -0.02 -0.01 0.01 0.02 0.03 0.04 0.05 0.06],[38 36 34 32 2 22 24 26 28 29],2)
shading flat
title('QFX 00 UTC')
ylabel('SIGMA LEVELS')
xlabel('ASSIMILATION CYCLES')

subplot(2,2,2)
pcolor(INFLATION_MEAN_SERIE_CONTROL(2:4:end,:)'-INFLATION_MEAN_SERIE_QFX(2:4:end,:)')
plot_color_fun([-0.05 -0.04 -0.03 -0.02 -0.01 0.01 0.02 0.03 0.04 0.05 0.06],[38 36 34 32 2 22 24 26 28 29],2)
shading flat
title('QFX 06 UTC')
ylabel('SIGMA LEVELS')
xlabel('ASSIMILATION CYCLES')

subplot(2,2,3)
pcolor(INFLATION_MEAN_SERIE_CONTROL(3:4:end,:)'-INFLATION_MEAN_SERIE_QFX(3:4:end,:)')
plot_color_fun([-0.05 -0.04 -0.03 -0.02 -0.01 0.01 0.02 0.03 0.04 0.05 0.06],[38 36 34 32 2 22 24 26 28 29],2)
shading flat
title('QFX 12 UTC')
ylabel('SIGMA LEVELS')
xlabel('ASSIMILATION CYCLES')

subplot(2,2,4)
pcolor(INFLATION_MEAN_SERIE_CONTROL(4:4:end,:)'-INFLATION_MEAN_SERIE_QFX(4:4:end,:)')
plot_color_fun([-0.05 -0.04 -0.03 -0.02 -0.01 0.01 0.02 0.03 0.04 0.05 0.06],[38 36 34 32 2 22 24 26 28 29],2)
shading flat
title('QFX 18 UTC')
ylabel('SIGMA LEVELS')
xlabel('ASSIMILATION CYCLES')

%QFXHFX
figure
subplot(2,2,1)
pcolor(INFLATION_MEAN_SERIE_CONTROL(1:4:end,:)'-INFLATION_MEAN_SERIE_QFXHFX(1:4:end,:)')
plot_color_fun([-0.05 -0.04 -0.03 -0.02 -0.01 0.01 0.02 0.03 0.04 0.05 0.06],[38 36 34 32 2 22 24 26 28 29],2)
shading flat
title('QFX & HFX 00 UTC')
ylabel('SIGMA LEVELS')
xlabel('ASSIMILATION CYCLES')

subplot(2,2,2)
pcolor(INFLATION_MEAN_SERIE_CONTROL(2:4:end,:)'-INFLATION_MEAN_SERIE_QFXHFX(2:4:end,:)')
plot_color_fun([-0.05 -0.04 -0.03 -0.02 -0.01 0.01 0.02 0.03 0.04 0.05 0.06],[38 36 34 32 2 22 24 26 28 29],2)
shading flat
title('QFX & HFX 06 UTC')
ylabel('SIGMA LEVELS')
xlabel('ASSIMILATION CYCLES')

subplot(2,2,3)
pcolor(INFLATION_MEAN_SERIE_CONTROL(3:4:end,:)'-INFLATION_MEAN_SERIE_QFXHFX(3:4:end,:)')
plot_color_fun([-0.05 -0.04 -0.03 -0.02 -0.01 0.01 0.02 0.03 0.04 0.05 0.06],[38 36 34 32 2 22 24 26 28 29],2)
shading flat
title('QFX & HFX 12 UTC')
ylabel('SIGMA LEVELS')
xlabel('ASSIMILATION CYCLES')

subplot(2,2,4)
pcolor(INFLATION_MEAN_SERIE_CONTROL(4:4:end,:)'-INFLATION_MEAN_SERIE_QFXHFX(4:4:end,:)')
plot_color_fun([-0.05 -0.04 -0.03 -0.02 -0.01 0.01 0.02 0.03 0.04 0.05 0.06],[38 36 34 32 2 22 24 26 28 29],2)
shading flat
title('QFX & HFX 18 UTC')
ylabel('SIGMA LEVELS')
xlabel('ASSIMILATION CYCLES')

% %QFXUST
% figure
% subplot(2,2,1)
% pcolor(INFLATION_MEAN_SERIE_CONTROL(1:4:end,:)'-INFLATION_MEAN_SERIE_QFXUST(1:4:end,:)')
% plot_color_fun([-0.05 -0.04 -0.03 -0.02 -0.01 0.01 0.02 0.03 0.04 0.05 0.06],[38 36 34 32 2 22 24 26 28 29],2)
% shading flat
% title('QFXUST 00 UTC')
% 
% subplot(2,2,2)
% pcolor(INFLATION_MEAN_SERIE_CONTROL(2:4:end,:)'-INFLATION_MEAN_SERIE_QFXUST(2:4:end,:)')
% plot_color_fun([-0.05 -0.04 -0.03 -0.02 -0.01 0.01 0.02 0.03 0.04 0.05 0.06],[38 36 34 32 2 22 24 26 28 29],2)
% shading flat
% title('QFXUST 06 UTC')
% 
% subplot(2,2,3)
% pcolor(INFLATION_MEAN_SERIE_CONTROL(3:4:end,:)'-INFLATION_MEAN_SERIE_QFXUST(3:4:end,:)')
% plot_color_fun([-0.05 -0.04 -0.03 -0.02 -0.01 0.01 0.02 0.03 0.04 0.05 0.06],[38 36 34 32 2 22 24 26 28 29],2)
% shading flat
% title('QFXUST 12 UTC')
% 
% subplot(2,2,4)
% pcolor(INFLATION_MEAN_SERIE_CONTROL(4:4:end,:)'-INFLATION_MEAN_SERIE_QFXUST(4:4:end,:)')
% plot_color_fun([-0.05 -0.04 -0.03 -0.02 -0.01 0.01 0.02 0.03 0.04 0.05 0.06],[38 36 34 32 2 22 24 26 28 29],2)
% shading flat
% title('QFXUST 18 UTC')




