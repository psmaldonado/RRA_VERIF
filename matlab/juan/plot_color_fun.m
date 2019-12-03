
function [colores] = plot_color_fun(v,vcol,colorbar_flag)
%**************************************************************************
%       ESTA FUNCION CONSTRUYE UN MAPA DE COLORES PARA APLICAR A UNA FIGURA
%**************************************************************************
% USO: PLOT_JRCOL(V,VCOL) DONDE V ES UN VECTOR QUE CONTIENE LOS LIMITES DE
% LOS INTERVALOS QUE QUEREMOS PLOTEAR. Y VCOL SON LOS NUMEROS DE LOS
% COLORES QUE QUEREMOS ASIGNAR A CADA INTERVALO. LOS CODIGOS DE COLORES
% UTILIZADOS EN VCOL SON LOS MISMOS QUE LOS DEFINIDOS EN EL SCRIPT DE GRADS
% JAECOL.
% COLORES=PLOT_JRCOL(V,VCOL) DEVUELVE EL MAPA DE COLORES QUE ESTA DE
% ACUERDO CON LOS INTERVALOS Y LOS CODIGOS DE COLORES SELECCIONADOS.
% LA CANTIDAD DE ELEMENTOS DE COLORES, DEBE SER UNA MENOS QUE LA DE V, Y
% LOS COLORES SE ASIGNAN DE LA SIGUIENTE MANERA: SI V ES (0 0.1 0.2 ...0.9
% 1) EL PRIMER CODIGO DE COLOR EN VCOL SE ASIGNA AL INTERVALO 0 0.1 Y ASI
% CONSECUTIVAMENTE HASTA EL INTERVALO 0.9 1). SI V NO ESTA ORDENADO DE
% MENOR A MAYOR EL SCRIPT LO ORDENA PERO EL ORDEN DE LOS COLORES SE VERA
% ALTERADO.
% LOS LIMITES DE LA ESCALA SE FIJAN ENTRE EL MINIMO DE V Y EL MAXIMO DE V.

jrcol(1,:)= [ 0    0    0];
jrcol(2,:)= [ 255 255 255];
jrcol(21,:)=[ 255 250 170];
jrcol(22,:)=[ 255 232 120];
jrcol(23,:)=[ 255 192  60];
jrcol(24,:)=[ 255 160   0];
jrcol(25,:)=[ 255  96   0];
jrcol(26,:)=[ 255  50   0];
jrcol(27,:)=[ 225  20   0];
jrcol(28,:)=[ 192   0   0];
jrcol(29,:)=[ 165   0   0];
jrcol(31,:)=[ 230 255 225];
jrcol(32,:)=[ 200 255 190];
jrcol(33,:)=[ 180 250 170];
jrcol(34,:)=[ 150 245 140];
jrcol(35,:)=[ 120 245 115];
jrcol(36,:)=[  80 240  80];
jrcol(37,:)=[  55 210  60];
jrcol(38,:)=[  30 180  30];
jrcol(39,:)=[  15 160  15];
jrcol(41,:)=[ 200 255 255];
jrcol(42,:)=[ 175 240 255];
jrcol(43,:)=[ 130 210 255];
jrcol(44,:)=[  95 190 250];
jrcol(45,:)=[  75 180 240];
jrcol(46,:)=[  60 170 230];
jrcol(47,:)=[  40 150 210];
jrcol(48,:)=[  30 140 200];
jrcol(49,:)=[  20 130 190];
jrcol(51,:)=[ 220 220 255];
jrcol(52,:)=[ 192 180 255];
jrcol(53,:)=[ 160 140 255];
jrcol(54,:)=[ 128 112 235];
jrcol(55,:)=[ 112  96 220];
jrcol(56,:)=[  72  60 200];
jrcol(57,:)=[  60  40 180];
jrcol(58,:)=[  45  30 165];
jrcol(59,:)=[  40   0 160];
jrcol(61,:)=[ 255 230 230];
jrcol(62,:)=[ 255 200 200];
jrcol(63,:)=[ 248 160 160];
jrcol(64,:)=[ 230 140 140];
jrcol(65,:)=[ 230 112 112];
jrcol(66,:)=[ 230  80  80];
jrcol(67,:)=[ 200  60  60];
jrcol(68,:)=[ 180  40  40];
jrcol(69,:)=[ 164  32  32];
jrcol(71,:)=[ 250 250 250];
jrcol(72,:)=[ 225 225 225];
jrcol(73,:)=[ 200 200 200];
jrcol(74,:)=[ 180 180 180];
jrcol(75,:)=[ 160 160 160];
jrcol(76,:)=[ 150 150 150];
jrcol(77,:)=[ 140 140 140];
jrcol(78,:)=[ 124 124 124];
jrcol(79,:)=[ 112 112 112];
jrcol(80,:)=[  92  92  92];
jrcol(81,:)=[  80  80  80];
jrcol(82,:)=[  70  70  70];
jrcol(83,:)=[  60  60  60];
jrcol(84,:)=[  50  50  50];
jrcol(85,:)=[  40  40  40];
jrcol(86,:)=[  36  36  36];
jrcol(87,:)=[  32  32  32];
jrcol=jrcol/255;

colores_size=1500;
v=sort(v);
colores=zeros(colores_size,3);
ncolores=length(v)-1;  %Esto deber???a conicidir con length de colores.

minv=min(v);
maxv=max(v);

indices=round((colores_size-1)*(v(:)-minv)/(maxv-minv)+1);

for icol=1:ncolores

    for ii=indices(icol):indices(icol+1)
    colores(ii,:)=jrcol(vcol(icol),:);
    end
end


colormap(colores)
caxis([minv maxv]);
if(colorbar_flag==2)
%colorbar
colorbar('YTick',v);
end










