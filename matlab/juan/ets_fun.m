%**************************************************************************
%    FUNCION DE CALCULO DEL ETS (FORMULACION TRADICIONAL) 
%**************************************************************************
function [ets,hit_rate,far]=ets_fun(obs,forecast,umbral)

%**************************************************************************
%           obs= contiene las observaciones (mm)
%           forecast= contiene los pronosticos (tiene tantas columnas como
%           pronosticos queramos verificar. (por ejemplo en la primera columna
%           puedo poner el pronostico a 6 horas y en la segunda columna el 
%           pronostico a 12 horas... ).
%           umb= vector con los umbrales para los cuales vamos a calcular
%           el ets
%           Nan Ready (R).
%**************************************************************************
%INICIO EL CALCULO DE DIVERSOS PARAMETROS PARA LOS UMBRALES SELECCIONADOS.
%Vamos a calcular aciertos, falsas alarmas, ETS y sorpresas.
n_umb=length(umbral); %Vemos cuantos umbrales distintos tenemos.
a=size(forecast);
ens=a(2);

for i_umb=1:n_umb
    
    %Hit rate= hits / (hits + misses)
    for iens=1:ens
    i_hits=find(obs >= umbral(i_umb) & forecast(:,iens) >= umbral(i_umb)); %Vemos los aciertos a 24 horas de pronostico.
    hits(i_umb,iens)=length(i_hits);
    clear i_hits  
    i_for=find(obs >= umbral(i_umb) & forecast(:,iens) >= 0); %Vemos el total de veces que llovio por encima del umbral para 24 horas.
    tot_lluvia(i_umb)=length(i_for); 
    misses(i_umb,iens)=tot_lluvia(i_umb)-hits(i_umb,iens); %Calculo los misses
    clear i_for
    
    if (tot_lluvia(i_umb) ~= 0)
        hit_rate(i_umb,iens)=hits(i_umb,iens)./tot_lluvia(i_umb);
    else
        hit_rate(i_umb,iens)=NaN;
    end
   
    %(FAR) False alarm ratio=false alarms / ( hits + false alarms)
    i_false=find( obs(:,1)  < umbral(i_umb) & forecast(:,iens) >= umbral(i_umb)); %Falsas alarmas
    false_alarm(i_umb,iens)=length(i_false);
    clear i_false
    if(hits(i_umb,iens)+false_alarm(i_umb,iens)~= 0)
    far(i_umb,iens)=false_alarm(i_umb,iens)./(hits(i_umb,iens)+false_alarm(i_umb,iens));
    else
    far(i_umb,iens)=NaN;
    end
    
    %ETS equitable threat score 
    %ETS=( hits - hitsrandom )/ (hits + misses + false alarms - hitsrandom)
    %hitsrandom = (hits+misses)*(hits+false alarms)/(total)
    
    i_nonnan=find(isnan(obs) == 0 & isnan(forecast(:,iens))==0); %Busco todos aquellos que no sean NaN.
    total(iens)=length(i_nonnan); %Calculo el total de pares.
    hits_random(i_umb,iens)=(hits(i_umb,iens) + misses(i_umb,iens))*( hits(i_umb,iens) + false_alarm(i_umb,iens) )./total(iens);
    ets(i_umb,iens)=(hits(i_umb,iens)-hits_random(i_umb,iens))/(hits(i_umb,iens) +  misses(i_umb,iens) + false_alarm(i_umb,iens) - hits_random(i_umb,iens) ); 
    clear i_nonnan
    end
end
