

path_ensemble='/exports/jruiz/EXPERIMENTS/FORECAST_CONTROL40M_MEMNC/trajectories/2008082212/';

ens_size=40;


figure
hold on

for iens=1:ens_size
   iens 
   load([path_ensemble 'trajectories_' num2str(iens) '.mat']); 
   
   ntraj=size(TrajStruct,2);
   
   for it=1:ntraj
       color=round(rand(3,1));
       plot(TrajStruct(it).minlon,TrajStruct(it).minlat,'-','Color',color')
       
   end
    
end
