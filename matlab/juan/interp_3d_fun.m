function [data_cart xv yv zv tmp_elevation tmp_range tmp_radar_data]=interp_3d_fun(radar,data,tmp_elevation,tmp_range,resh,resv)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%resh is the horizontal resolution in meters.
%resv is the horizontal resolution in meters.

max_z=20000;
dz=resv;

tmp_radar_r=radar.Rh(:,1);
tmp_radar_z=0:dz:max_z;
tmp_radar_data=NaN(radar.na,radar.nr,length(tmp_radar_z));

%vertical_ref_grad=NaN(radar.na,radar.nr,length(tmp_radar_z));
[tmp_radar_r tmp_radar_z]=meshgrid(squeeze(tmp_radar_r),squeeze(tmp_radar_z));

[range elevation]=meshgrid(radar.radius,radar.elev);

    %Compute elevation and range of the new grid points so I can
    %interpolate them using regular grid functions.
    if( isempty(tmp_elevation) || isempty(tmp_range) )
    tmp_elevation=griddata(radar.Rh',radar.height',elevation,tmp_radar_r,tmp_radar_z,'linear');
    tmp_range    =griddata(radar.Rh',radar.height',range,tmp_radar_r,tmp_radar_z,'linear');
    end

%warning off %Supress warning about NaN in interpolated fields.
%Loop over elevations

not_nan=~isnan(tmp_elevation) & ~isnan(tmp_range) ;

tmpe=tmp_elevation(not_nan);
tmpr=tmp_range(not_nan);


for ia=1:radar.na
tmp=squeeze(tmp_radar_data(ia,:,:))';
tmp2=interp2(range,elevation,squeeze(data(ia,:,:))',tmpr,tmpe,'bilinear');
tmp(not_nan)=tmp2;
tmp_radar_data(ia,:,:)=tmp';
end


resaz=radar.azimuth(2)-radar.azimuth(1);
max_az=max(radar.azimuth);
min_az=min(radar.azimuth);
resr=radar.radius(2)-radar.radius(1);
max_r=max(radar.radius);
min_r=min(radar.radius);

maxd=max(radar.radius);

xv=-maxd:resh:maxd;
yv=-maxd:resh:maxd;

[x , y]=meshgrid(xv,yv);

nz=size(tmp_radar_z,1);
zv=tmp_radar_z(:,1);

nx=length(xv);
ny=length(yv);

data_cart=NaN(nx,ny,nz);

radius=sqrt( x.^2 + y.^2 );
azimuth=(180/pi)*atan2(x,y);

azimuth(azimuth<0)=360+azimuth(azimuth<0);

for ii=1:nx
    for jj=1:ny

        dj=( (radius(ii,jj)-min_r)/resr );

        di=( (azimuth(ii,jj)-min_az)/resaz );
        
        if( dj >= 0 && dj < radar.nr-1)
          minj=floor(dj)+1;
          maxj=minj+1;
          aj=dj+1-minj;
   
           if( di >= 1 && di < radar.na )
              mini=floor(di)+1;
              maxi=mini+1;
              ai=di+1-mini;
           elseif( di < 1 && di >= 0 )
              mini=radar.na;
              maxi=1;
              ai=di;
           elseif( di >= radar.na )
              mini=radar.na;
              maxi=1;
              ai=di-mini;
           else
              mini=0;
           end
           if( mini ~= 0)
              data_cart(ii,jj,:) = tmp_radar_data(mini,minj,:)*(1-ai)*(1-aj) + tmp_radar_data(maxi,minj,:)*ai*(1-aj) + tmp_radar_data(mini,maxj,: )*(1-ai)*aj + tmp_radar_data(maxi,maxj,: )*ai*aj;
              if( max(data_cart(ii,jj,:)) > 1000)
                 display('Warning: Unrealistic data'); 
                 ai
                 aj
                 [tmp_radar_data(mini,minj,:) tmp_radar_data(maxi,maxj,:) tmp_radar_data(mini,maxj,:) tmp_radar_data(maxi,maxj,:)]
                 
              end
           
           end
        end
      
    end
end





end





