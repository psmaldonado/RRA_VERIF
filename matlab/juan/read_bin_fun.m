
function [data]=read_bin_fun(nx,ny,nfields,file,endian);

n=fopen(file,'r',endian);


data=NaN(nx,ny,nfields);

if( n >= 0 )

for ii=1:nfields
    data(:,:,ii)=fread(n,[nx ny],'single');
end

end

fclose(n);

end
