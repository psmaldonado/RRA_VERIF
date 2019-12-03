clear all
close all

load ../copy/EXP_40mem_sfflux_ntpar_nsmooth_fixparinf_qfx/parameter_spe_2008081506_2008093018.mat;

power_nosmooth=power;

load ../copy/EXP_40mem_sfflux_ntpar_smooth_fixparinf0.05_qfx/parameter_spe_2008081506_2008093018.mat;

power_smooth=power;


armonico_fundamental=107*60;
L=armonico_fundamental./(1:49);

TIEMPOS=size(power_nosmooth,2);
TIEMPOS=(1:TIEMPOS)/4;


figure
subplot(1,2,1)

pcolor(TIEMPOS,2*pi./(L),power_nosmooth(2:50,:,2))
plot_color_fun([0.01 0.02 0.04 0.06 0.08 0.1 0.12 0.14 0.16],[2 21 23 24 25 26 27 28],2)
shading flat
title('SPECTRAL POWER: NO SMOOTH')
xlabel('Number of assimilation cycles')
ylabel('Wave number')

subplot(1,2,2)

pcolor(TIEMPOS,2*pi./(L),power_smooth(2:50,:,2))
plot_color_fun([0.01 0.02 0.04 0.06 0.08 0.1 0.12 0.14 0.16],[2 21 23 24 25 26 27 28],2)
shading flat
title('SPECTRAL POWER: SMOOTH')
xlabel('Number of assimilation cycles')
ylabel('Wave number')