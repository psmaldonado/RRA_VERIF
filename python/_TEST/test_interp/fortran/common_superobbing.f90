MODULE cs
!=======================================================================
!
! [PURPOSE:] Thinning of radar data
!
! [HISTORY:] This version produce a superobing of the observations but
! the data is stored in azimuth , range , elevation. Conversion to the 
! lat , lon , z is performed by the observation operator.
!
!=======================================================================
!$USE OMP_LIB

!-----------------------------------------------------------------------
! Variable size definitions
!-----------------------------------------------------------------------
  INTEGER,PARAMETER :: r_size=kind(0.0d0)
  INTEGER,PARAMETER :: r_dble=kind(0.0d0)
  INTEGER,PARAMETER :: r_sngl=kind(0.0e0)

CONTAINS
!2D interpolation using box average. Destination grid is assumed to be regular.
SUBROUTINE com_interp_boxaverage(xini,dx,nx,yini,dy,ny,xin,yin,datain,undef,nin    &
               &                ,data_ave,data_max,data_min,data_std,data_n)
  IMPLICIT NONE
  INTEGER , INTENT(IN)           :: nx , ny , nin
  REAL(r_sngl),INTENT(IN)        :: dx , dy , xini , yini 
  REAL(r_sngl),INTENT(IN)        :: xin(nin),yin(nin),datain(nin)
  REAL(r_sngl),INTENT(IN)        :: undef
  REAL(r_sngl),INTENT(OUT)       :: data_ave(ny,nx)
  REAL(r_sngl),INTENT(OUT)       :: data_max(ny,nx)
  REAL(r_sngl),INTENT(OUT)       :: data_min(ny,nx)
  REAL(r_sngl),INTENT(OUT)       :: data_std(ny,nx)
  INTEGER,INTENT(OUT)            :: data_n(ny,nx)

  INTEGER                        :: ii , ix , iy 

data_max=undef
data_min=undef
data_ave=undef
data_std=undef
data_n  =0


  DO ii = 1,nin  !Loop over the input data

    !Compute the location of the current point with in grid coordinates (rx,ry)
    ix = int( ( xin(ii) - xini ) / dx ) + 1
    iy = int( ( yin(ii) - yini ) / dy ) + 1

    !Check is the data is within the grid.
    IF( ix <= nx .and. ix >= 1 .and. iy <= ny .and. iy >= 1 .and. datain(ii) /= undef )THEN

      IF(  data_n(iy,ix) == 0 )THEN
        data_max(iy,ix) = datain(ii)
        data_min(iy,ix) = datain(ii)
        data_ave(iy,ix) = datain(ii)
        data_std(iy,ix) = datain(ii) ** 2 
        data_n  (iy,ix) = 1

      ELSE
        data_n(iy,ix) = data_n(iy,ix) + 1
        data_ave(iy,ix) = data_ave(iy,ix) + datain(ii)
        data_std(iy,ix) = data_std(iy,ix) + datain(ii) ** 2 

        IF( datain(ii) > data_max(iy,ix) )THEN
          data_max(iy,ix) = datain(ii)
        ENDIF
        IF( datain(ii) < data_min(iy,ix) )THEN
          data_min(iy,ix) = datain(ii)
        ENDIF

      ENDIF


    ENDIF

  ENDDO

  WHERE( data_n(:,:) > 0)
       data_ave(:,:) = data_ave(:,:) / REAL( data_n(:,:) , r_sngl )
       data_std(:,:) = SQRT( data_std(:,:)/REAL( data_n(:,:) , r_sngl ) - data_ave(:,:) ** 2 )
  ENDWHERE
  

END SUBROUTINE com_interp_boxaverage


END MODULE cs
