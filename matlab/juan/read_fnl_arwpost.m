function [U V W PSFC QVAPOR VEGFRA SST HGT TSK RAINC RAINNC GEOPT HEIGHT TK RH ...
 RH2 U10M V10M SLP MCAPE MCIN]=read_arwpost(file,nx,ny,nz) 


nfile=fopen(file,'r','b');
if(nfile ~= -1)
    
         %Read fields
         for iz=1:nz
            U(:,:,iz)=fread(nfile,[nx ny],'single')';
         end
         U(U>1e15)=NaN;
         for iz=1:nz
            V(:,:,iz)=fread(nfile,[nx ny],'single')';
         end
         V(V>1e15)=NaN;
         for iz=1:nz
            W(:,:,iz)=fread(nfile,[nx ny],'single')';
         end
         W(W>1e15)=NaN;
         PSFC(:,:)=fread(nfile,[nx ny],'single')';
         PSFC(PSFC>1e15)=NaN;
         for iz=1:nz
            QVAPOR(:,:,iz)=fread(nfile,[nx ny],'single')';
         end
         QVAPOR(QVAPOR>1e15)=NaN;
         VEGFRA(:,:)=fread(nfile,[nx ny],'single')';
         VEGFRA(VEGFRA>1e15)=NaN;
         SST(:,:)=fread(nfile,[nx ny],'single')';
         SST(SST>1e15)=NaN;
         HGT(:,:)=fread(nfile,[nx ny],'single')';
         HGT(HGT>1e15)=NaN;
         TSK(:,:)=fread(nfile,[nx ny],'single')';
         TSK(TSK>1e15)=NaN;
         %RAINC(:,:)=fread(nfile,[nx ny],'single')';
         %RAINC(RAINC>1e15)=NaN;
         %RAINNC(:,:)=fread(nfile,[nx ny],'single')';
         %RAINNC(RAINNC>1e15)=NaN;
         RAINC=NaN(ny,nx);
         RAINNC=NaN(ny,nx);
         for iz=1:nz
            GEOPT(:,:,iz)=fread(nfile,[nx ny],'single')';
         end
         GEOPT(GEOPT>1e15)=NaN;
         for iz=1:nz
            HEIGHT(:,:,iz)=fread(nfile,[nx ny],'single')';
         end
         HEIGHT(HEIGHT>1e15)=NaN;
         for iz=1:nz
            TK(:,:,iz)=fread(nfile,[nx ny],'single')';
         end
         TK(TK>1e15)=NaN;
         for iz=1:nz
            RH(:,:,iz)=fread(nfile,[nx ny],'single')';
         end
         RH(RH>1e15)=NaN;
         RH2(:,:)=fread(nfile,[nx ny],'single')';
         RH2(RH2>1e15)=NaN;
         U10M(:,:)=fread(nfile,[nx ny],'single')';
         U10M(U10M>1e15)=NaN;
         V10M(:,:)=fread(nfile,[nx ny],'single')';
         V10M(V10M>1e15)=NaN;
         SLP(:,:)=fread(nfile,[nx ny],'single')';
         SLP(SLP>1e15)=NaN;
         MCAPE(:,:)=fread(nfile,[nx ny],'single')';
         MCAPE(MCAPE>1e15)=NaN;
         MCIN(:,:)=fread(nfile,[nx ny],'single')'; 
         MCIN(MCIN>1e15)=NaN;
         
         fclose(nfile);
else
  U=NaN(ny,nx,nz);
  V=NaN(ny,nx,nz);
  W=NaN(ny,nx,nz);
  PSFC=NaN(ny,nx);
  QVAPOR=NaN(ny,nx,nz);
  VEGFRA=NaN(ny,nx);
  SST=NaN(ny,nx);
  HGT=NaN(ny,nx);
  TSK=NaN(ny,nx);
  RAINC=NaN(ny,nx);
  RAINNC=NaN(ny,nx);
  GEOPT=NaN(ny,nx,nz);
  HEIGHT=NaN(ny,nx);
  TK=NaN(ny,nx,nz);
  RH=NaN(ny,nx,nz);
  RH2=NaN(ny,nx);
  U10M=NaN(ny,nx);
  V10M=NaN(ny,nx);
  SLP=NaN(ny,nx);
  MCAPE=NaN(ny,nx);
  MCIN=NaN(ny,nx);  
         
end     
end