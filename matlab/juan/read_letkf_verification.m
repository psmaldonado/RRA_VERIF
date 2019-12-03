
function  []=read_letkf_verification(file,nbv)

%This function read a LETKF verification file and generates different
%arrays with the data.
% File is the name of the file that is going to be read.
% nbv is the number of ensemble members in the experiment.


readbufrl=8+nbv;    %Elements in bufr for read.
