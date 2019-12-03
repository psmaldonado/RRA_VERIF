function [U V QVAPOR GEOPT TK ...
 U10M V10M SLP MCAPE MCIN]=read_arwpost_gdas(file,nx,ny,nz) 

  U=NaN(ny,nx,nz);
  V=NaN(ny,nx,nz);
  QVAPOR=NaN(ny,nx,nz);
  GEOPT=NaN(ny,nx,nz);
  TK=NaN(ny,nx,nz);
  U10M=NaN(ny,nx);
  V10M=NaN(ny,nx);
  SLP=NaN(ny,nx);
  MCAPE=NaN(ny,nx);
  MCIN=NaN(ny,nx);


nfile=fopen(file,'r','b');
if(nfile ~= -1)

         for iz=1:nz
            QVAPOR(:,:,iz)=fread(nfile,[nx ny],'single')';
         end
         QVAPOR(QVAPOR>1e15)=NaN;
         fread(nfile,[nx ny],'single')';
         fread(nfile,[nx ny],'single')';
         for iz=1:nz
            GEOPT(:,:,iz)=fread(nfile,[nx ny],'single')';
         end
         GEOPT(GEOPT>1e15)=NaN;
         for iz=1:nz
            TK(:,:,iz)=fread(nfile,[nx ny],'single')';
         end
         TK(TK>1e15)=NaN;
         fread(nfile,[nx ny],'single')';
         for iz=1:nz
            U(:,:,iz)=fread(nfile,[nx ny],'single')';
         end
         U(U>1e15)=NaN;
         for iz=1:nz
            V(:,:,iz)=fread(nfile,[nx ny],'single')';
         end
         V(V>1e15)=NaN;
         U10(:,:)=fread(nfile,[nx ny],'single')';
         U10(U10>1e15)=NaN;
         V10(:,:)=fread(nfile,[nx ny],'single')';
         V10(V10>1e15)=NaN;
         SLP(:,:)=fread(nfile,[nx ny],'single')';
         SLP(SLP>1e15)=NaN;
         MCAPE(:,:)=fread(nfile,[nx ny],'single')';
         MCAPE(MCAPE>1e15)=NaN;
         MCIN(:,:)=fread(nfile,[nx ny],'single')';
         MCIN(MCIN>1e15)=NaN;
         
         fclose(nfile);
end
