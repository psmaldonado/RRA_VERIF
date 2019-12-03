%**************************************************************************
%       ESTA FUNCION CALCULA UN RANK HISTOGRAM.
%**************************************************************************

function [bias_area] = biasarea_fun(obs,forecast,umbral)
%**************************************************************************
n_umb=length(umbral)
% obs es un vector columna con las observaciones.
% forecast es una matriz. Cada columna es un pronóstico distinto (un
% miembro del ensemble).
a=size(forecast);
ens=a(2); 

for iumb=1:n_umb
    for iens=1:ens
%Calculo los puntos donde llovio mas que el umbral
iarea_obs=find(obs >= umbral(iumb) & forecast(:,iens) >= 0);
%Calculo los puntos donde al prono le llovio mas que el umbral
iarea_for=find(forecast(:,iens) >= umbral(iumb) & obs >= 0);
if(length(iarea_obs)>0)
    bias(iumb,iens)=length(iarea_for)/length(iarea_obs);
else
    bias(iumb,iens)=NaN;
end
clear iarea_obs iarea_for bias_area inonnan
    end
end

bias_area=bias;

%**************************************************************************






