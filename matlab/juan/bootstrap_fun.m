%**************************************************************************
%       ESTA FUNCION     VA A SELECCIONAR PUNTOS AL AZAR DEL TOTAL Y GENERAR
%       SUBMUESTRAS. ESTAS SUBMUESTRAS SE VAN A USAR PARA INTENTAR
%       REPRESENTAR LA DISTRIBUCION DE DIVERSOS PARAMETROS QUE HASTA AHORA
%       EST�?BAMOS CALCULANDO A PARTIR DE LA MUESTRA TOTAL.
%**************************************************************************

function [random_index] = bootstrap_fun(n_total,nmuestras)
%**************************************************************************
%Esta funcion genera resamples de la muestra original tomando al azar
%elementos de la misma con repetición. Los resamples son del mismo tamaño
%que la muestra original, pero los cambios de una muestra a otra estan
%dados por los elementos que se repiten y por los que no están presentes.
%La hipotesis fundamental del método de Bootstraping es que este
%procedimiento nos permite estimar la distribucion de la poblacion desde
%donde fue obtenida nuestra muestra. 
%**************************************************************************

random_index=rand(n_total,nmuestras);
random_index=round(random_index.*(n_total-1)+1);

%Hasta aca genere las muestras al azar!!
%**************************************************************************






