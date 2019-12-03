function [CurrentTracks]=get_current_tracks_fun(sf,ef,BestTrack);

ntraj=size(BestTrack,2);

CurrentTracks=[];

cntraj=0;
for ii=1:ntraj
  tlength=length(BestTrack(ii).daten);
  init_traj=false;
  for jj=1:tlength
    tmp=BestTrack(ii).daten(jj);
    if( tmp >= sf && tmp <= ef)
      
      if(~init_traj)
        cntraj=cntraj+1;
        init_traj=true;
        nt=1;
        CurrentTracks(cntraj).name=BestTrack(ii).name;
      end
        CurrentTracks(cntraj).daten(nt)=BestTrack(ii).daten(jj);
        CurrentTracks(cntraj).minlat(nt)=BestTrack(ii).minlat(jj);
        CurrentTracks(cntraj).minlon(nt)=BestTrack(ii).minlon(jj);
        CurrentTracks(cntraj).minanomf(nt)=BestTrack(ii).minanomf(jj);
        CurrentTracks(cntraj).maxwind(nt)=BestTrack(ii).maxwind(jj);
        CurrentTracks(cntraj).uvelf(nt)=BestTrack(ii).uvelf(jj);
        CurrentTracks(cntraj).vvelf(nt)=BestTrack(ii).vvelf(jj);
        nt=nt+1;    
    end
  end
end


end


