clear all
close all

%Just to test the read obs function

file='../../letkf_lab/guesv.dat';
nbv=4;
[obslon obslat obslev obstime ...
 obselm obstyp obsdat obserr  ...
 hxf]                             =fun_read_letkf_verification(file,nbv);


[verifstruct]=fun_verify_level_obselm_obstype(file,nbv);

% load coast
% hold on
% plot(long,lat)
% plot(obslon,obslat,'o')
% axis([100.57 179.42 0.22 52.99])