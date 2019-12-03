load "$NCARG_ROOT/lib/ncarg/nclscripts/contrib/cd_string.ncl"

;--------------------------------------------------------------------------------
; Get namelist of 3d variables
;--------------------------------------------------------------------------------
undef ("get_vars3d")
function get_vars3d()
local output
begin
  output = (/"U","V","W","SPD","Q","T","Z","VNORTH"/)
  return output
end
;--------------------------------------------------------------------------------

;--------------------------------------------------------------------------------
; Get NPP data - For internal purposes
;--------------------------------------------------------------------------------
undef ("get_NPP_data_internal")
function get_NPP_data_internal(nc_file[1]:file, \
                               variable_name[1]:string, \
                               opts[1]:logical)
local data, iz
begin

  if(opts.and.isatt(opts,"iz")) then
    iz = opts@iz
    if (getfilevartypes(nc_file,variable_name).eq."short") then
      data = short2flt( nc_file->$variable_name$(:,iz,:,:) )
    else
      data = nc_file->$variable_name$(:,iz,:,:)
    end if
  else
    if (getfilevartypes(nc_file,variable_name).eq."short") then
      data = short2flt( nc_file->$variable_name$ )
    else
      data = nc_file->$variable_name$
    end if
  end if

  return(data)
end
;--------------------------------------------------------------------------------

;--------------------------------------------------------------------------------
; Get cone for Lambert WRF projection
;--------------------------------------------------------------------------------
undef ("get_lambert_cone")
function get_lambert_cone(nc_file[1]:file)
local true_lat1,true_lat2,pii,radians_per_degree,cone
begin
  true_lat1 = nc_file@TRUELAT1
  true_lat2 = nc_file@TRUELAT2

  pii = 3.14159265
  radians_per_degree = pii/180.

  if( (fabs(true_lat1 - true_lat2) .gt. 0.1) .and.  \
      (fabs(true_lat2 - 90. )      .gt. 0.1)       ) then
      cone = log(cos(true_lat1*radians_per_degree)) \
            -log(cos(true_lat2*radians_per_degree))
      cone = cone/( log(tan(( 45. -fabs(true_lat1/2.))*radians_per_degree)) - \
                    log(tan(( 45. -fabs(true_lat2/2.))*radians_per_degree)) )
  else
      cone = sin(fabs(true_lat1)*radians_per_degree)
  end if

  return(cone)
end

;--------------------------------------------------------------------------------
; Get NPP data
;--------------------------------------------------------------------------------
undef ("get_NPP_data")
function get_NPP_data(nc_file[1]:file, \
                      variable_name[1]:string, \
                      opts[1]:logical)
local data, data2, U, V, cone, cen_long, XLAT, XLONG
begin

  if(variable_name.eq."SPD") then
    U = get_NPP_data_internal(nc_file,"U",opts)
    V = get_NPP_data_internal(nc_file,"V",opts)
    data = sqrt(U^2+V^2)
    copy_VarMeta(U, data)
    data@long_name = "Wind Speed"
  else if(variable_name.eq."SPD10") then
    U = get_NPP_data_internal(nc_file,"U10",opts)
    V = get_NPP_data_internal(nc_file,"V10",opts)
    data = sqrt(U^2+V^2)
    copy_VarMeta(U, data)
    data@long_name = "10-m Wind Speed"
  else if(variable_name.eq."VNORTH") then
    data = get_NPP_data_internal(nc_file,"V",opts)
    data = -1.0 * data 
    data@long_name = "North Wind"
    data@unit      = "m s-1"
  else if(variable_name.eq."UVmet") then
    cone      = get_lambert_cone(nc_file)
    cen_long  = nc_file@STAND_LON
    XLAT  = get_NPP_data_internal(nc_file,"XLAT",opts)
    XLONG = get_NPP_data_internal(nc_file,"XLONG",opts)
    U     = get_NPP_data_internal(nc_file,"U",opts)
    V     = get_NPP_data_internal(nc_file,"V",opts)
    data  = wrf_uvmet( U, V, XLAT, XLONG, cen_long, cone )
  else if(variable_name.eq."PPrate") then
    data = get_NPP_data_internal(nc_file,"PP",opts)
    data@long_name = "Precipitation rate"
    data@unit      = "mm/h"
    if(opts.and.isatt(opts,"hf")) then
      if(opts@hf.gt.0 .and. isatt(opts,"basename")) then
        basename = opts@basename + sprinti("FC%0.2i", opts@hf-1)
        nc_file2 = addfile(basename+".nc","r")
        data2    = get_NPP_data_internal(nc_file2,"PP",opts)
        data     = data - data2
      end if
    else
      print("Error: Required hf att")
      exit()
    end if
  else
    data = get_NPP_data_internal(nc_file,variable_name,opts)
  end if
  end if
  end if
  end if
  end if

  if( any(variable_name.eq.(/"T2","T"/)) ) then
    data = data - 273.15
    data@unit = "C"
  end if

  if( variable_name.eq."CIN" ) then
    data = -1*data
    data@unit = "J Kg-1"
  end if

  return(data)
end
;--------------------------------------------------------------------------------

;--------------------------------------------------------------------------------
; Set Resources for filled contour
;--------------------------------------------------------------------------------
undef("set_contour_resources")
procedure set_contour_resources(variable_name[1]:string, \
                                con_res[1]:logical, \
                                opts[1]:logical)
local cmap,pressure
begin

  if(opts.and.isatt(opts,"pressure")) then
    pressure = opts@pressure
  else
    pressure = 1030.
  end if

;---3D variables: pressure required
  if(variable_name.eq."Q") then
    con_res@cnRasterModeOn       = False
    con_res@cnLevelSelectionMode = "ManualLevels"
    con_res@cnFillPalette        = "MPL_RdYlGn"
    if(pressure.le.500) then
      con_res@cnMinLevelValF     = 0.25
      con_res@cnMaxLevelValF     = 4
      con_res@cnLevelSpacingF    = 0.25
    else
      con_res@cnMinLevelValF     = 1
      con_res@cnMaxLevelValF     = 14
      con_res@cnLevelSpacingF    = 1
    end if
  end if

  if(variable_name.eq."SPD") then
    con_res@cnRasterModeOn       = False
    con_res@cnLevelSelectionMode = "ManualLevels"
    if(pressure.lt.500) then
      con_res@cnMinLevelValF     = 20
      con_res@cnMaxLevelValF     = 60
      con_res@cnLevelSpacingF    = 4
      con_res@cnFillPalette      = "MPL_BuPu"
    else if(pressure.le.850) then
      con_res@cnMinLevelValF     = 2
      con_res@cnMaxLevelValF     = 26
      con_res@cnLevelSpacingF    = 2
      con_res@cnFillPalette      = "MPL_Purples"
    else
      con_res@cnMinLevelValF     = 1
      con_res@cnMaxLevelValF     = 15
      con_res@cnLevelSpacingF    = 1
    end if
    end if
  end if

  if(variable_name.eq."V") then
     con_res@cnRasterModeOn       = False
     con_res@cnLevelSelectionMode = "ManualLevels"
     if(pressure.le.850) then
       con_res@cnMinLevelValF     = -20
       con_res@cnMaxLevelValF     = 20
       con_res@cnLevelSpacingF    = 2
       ;con_res@cnFillPalette      = "sunshine_9lev"
     end if
  end if

  if(variable_name.eq."T") then
    con_res@cnLevelSelectionMode = "ManualLevels"
    con_res@cnFillPalette        = "ncl_default"
    if(pressure.le.300) then
      con_res@cnMinLevelValF     = -70
      con_res@cnMaxLevelValF     = -55
      con_res@cnLevelSpacingF    = 1
    else if(pressure.le.500) then
      con_res@cnMinLevelValF     = -36
      con_res@cnMaxLevelValF     = 0
      con_res@cnLevelSpacingF    = 2
    else if(pressure.le.700) then
      con_res@cnMinLevelValF     = -4
      con_res@cnMaxLevelValF     = 14
      con_res@cnLevelSpacingF    = 1
    else if(pressure.le.850) then
      con_res@cnMinLevelValF     = -1
      con_res@cnMaxLevelValF     = 22
      con_res@cnLevelSpacingF    = 1
    else if(pressure.le.925) then
      con_res@cnMinLevelValF     = 2
      con_res@cnMaxLevelValF     = 26
      con_res@cnLevelSpacingF    = 2
    else
      con_res@cnMinLevelValF     = 6
      con_res@cnMaxLevelValF     = 36
      con_res@cnLevelSpacingF    = 2
    end if
    end if
    end if
    end if
    end if
  end if

  if(variable_name.eq."Z") then
    con_res@cnRasterModeOn       = False
    con_res@cnLevelSelectionMode = "ManualLevels"
    con_res@cnMinLevelValF       = 6
    con_res@cnMaxLevelValF       = 30
    con_res@cnLevelSpacingF      = 2
  end if

  if(variable_name.eq."W") then
    con_res@cnRasterModeOn       = False
    con_res@cnLevelSelectionMode = "ManualLevels"
    con_res@cnMinLevelValF       = -3
    con_res@cnMaxLevelValF       = 3
    con_res@cnLevelSpacingF      = 0.3
    con_res@cnFillPalette        = "temp_diff_18lev"
  end if

;---2D variables
  if(variable_name.eq."PP") then
    con_res@cnRasterModeOn       = False
    con_res@cnLevelSelectionMode = "ManualLevels"
    con_res@cnMinLevelValF       = 5
    con_res@cnMaxLevelValF       = 125
    con_res@cnLevelSpacingF      = 10
    con_res@cnFillPalette        = "precip3_16lev"
  end if

  if(variable_name.eq."PPrate") then
    con_res@cnRasterModeOn       = False
    con_res@cnLevelSelectionMode = "ManualLevels"
    con_res@cnMinLevelValF       = 1
    con_res@cnMaxLevelValF       = 16
    con_res@cnLevelSpacingF      = 1
    con_res@cnFillPalette        = "precip3_16lev"
  end if

  if(variable_name.eq."difPP") then
    con_res@cnRasterModeOn       = False
    con_res@cnLevelSelectionMode = "ManualLevels"
    con_res@cnMinLevelValF       = -120
    con_res@cnMaxLevelValF       = 120
    con_res@cnLevelSpacingF      = 15
    con_res@cnFillPalette        = "GHRSST_anomaly"
  end if

  if( any(variable_name.eq.(/"MDBZ","REFL1KM","REFL4KM"/)) ) then
    cmap = read_colormap_file("./palettes/radar_new.rgb")
    con_res@cnRasterModeOn       = True
    con_res@cnLevelSelectionMode = "ManualLevels"
    con_res@cnMinLevelValF       = 0
    con_res@cnMaxLevelValF       = 70
    con_res@cnLevelSpacingF      = 5.0
    con_res@cnFillPalette        = cmap
  end if

  if(variable_name.eq."Q2") then
    con_res@cnRasterModeOn       = False
    con_res@cnLevelSelectionMode = "ManualLevels"
    con_res@cnMinLevelValF       = 3
    con_res@cnMaxLevelValF       = 16
    con_res@cnLevelSpacingF      = 1
    con_res@cnFillPalette        = "MPL_RdYlGn"
  end if

  if(variable_name.eq."SPD10") then
    con_res@cnRasterModeOn       = False
    con_res@cnLevelSelectionMode = "ManualLevels"
    con_res@cnMinLevelValF       = 1
    con_res@cnMaxLevelValF       = 14
    con_res@cnLevelSpacingF      = 1
    con_res@cnFillPalette        = "MPL_Purples"
  end if

  if(variable_name.eq."T2") then
    con_res@cnRasterModeOn       = False
    con_res@cnLevelSelectionMode = "ManualLevels"
    con_res@cnMinLevelValF       = 0
    con_res@cnMaxLevelValF       = 40
    con_res@cnLevelSpacingF      = 2.0
    con_res@cnFillPalette        = "ncl_default"
  end if

  if(variable_name.eq."PSFC") then
    con_res@cnRasterModeOn       = False
    con_res@cnLevelSelectionMode = "ManualLevels"
    con_res@cnMinLevelValF       = 900
    con_res@cnMaxLevelValF       = 1040
    con_res@cnLevelSpacingF      = 10
    ;con_res@cnFillPalette   = "MPL_viridis"
  end if

  if(variable_name.eq."MCAPE") then
    con_res@cnRasterModeOn       = False
    con_res@cnLevelSelectionMode = "ManualLevels"
    con_res@cnMinLevelValF       = 400
    con_res@cnMaxLevelValF       = 4000
    con_res@cnLevelSpacingF      = 200
    con_res@cnFillPalette        = "WhBlGrYeRe"
  end if

  if(variable_name.eq."CIN") then
    cmap = read_colormap_file("MPL_Oranges")
    cmap = cmap(::-1,:)
    con_res@cnRasterModeOn       = False
    con_res@cnLevelSelectionMode = "ManualLevels"
    con_res@cnMinLevelValF       = -500
    con_res@cnMaxLevelValF       = 0
    con_res@cnLevelSpacingF      = 50
    con_res@cnFillPalette        = cmap
  end if

  if(variable_name.eq."spread") then
    con_res@cnRasterModeOn       = False
    con_res@cnLevelSelectionMode = "AutomaticLevels"
    con_res@cnFillPalette        = "MPL_RdPu"
  end if

  if(variable_name.eq."probability") then
    con_res@cnRasterModeOn       = False
    con_res@cnLevelSelectionMode = "ManualLevels"
    con_res@cnFillPalette        = "WhiteBlueGreenYellowRed"
    con_res@cnMinLevelValF       = 10
    con_res@cnMaxLevelValF       = 90
    con_res@cnLevelSpacingF      = 10
  end if

end
;--------------------------------------------------------------------------------

;--------------------------------------------------------------------------------
; Set Resources for filled contour for differences
;--------------------------------------------------------------------------------
undef("set_contour_resources_diff")
procedure set_contour_resources_diff(variable_name[1]:string, \
                                     con_res[1]:logical, \
                                     opts[1]:logical)
local cmap,pressure
begin

  if(opts.and.isatt(opts,"pressure")) then
    pressure = opts@pressure
  else
    pressure = 1030.
  end if

;---3D variables: pressure required
  if(variable_name.eq."Q") then
    con_res@cnRasterModeOn       = False
    con_res@cnLevelSelectionMode = "ManualLevels"
    con_res@cnFillPalette        = "hotcold_18lev"
    if(pressure.le.500) then
      con_res@cnMinLevelValF     = -11
      con_res@cnMaxLevelValF     = 11
      con_res@cnLevelSpacingF    = 2
    else
      con_res@cnMinLevelValF     = -11
      con_res@cnMaxLevelValF     = 11
      con_res@cnLevelSpacingF    = 2
    end if
  end if

  if(variable_name.eq."T") then
    con_res@cnRasterModeOn       = False
    con_res@cnLevelSelectionMode = "ManualLevels"
    con_res@cnFillPalette        = "hotcold_18lev"
    if(pressure.le.300) then
      con_res@cnMinLevelValF     = -15
      con_res@cnMaxLevelValF     = 15
      con_res@cnLevelSpacingF    = 2
    else if(pressure.le.500) then
      con_res@cnMinLevelValF     = -15
      con_res@cnMaxLevelValF     = 15
      con_res@cnLevelSpacingF    = 2
    else if(pressure.le.700) then
      con_res@cnMinLevelValF     = -15
      con_res@cnMaxLevelValF     = 15
      con_res@cnLevelSpacingF    = 2
    else if(pressure.le.850) then
      con_res@cnMinLevelValF     = -15
      con_res@cnMaxLevelValF     = 15
      con_res@cnLevelSpacingF    = 2
    else if(pressure.le.925) then
      con_res@cnMinLevelValF     = -15
      con_res@cnMaxLevelValF     = 15
      con_res@cnLevelSpacingF    = 2
    else
      con_res@cnMinLevelValF     = -15
      con_res@cnMaxLevelValF     = 15
      con_res@cnLevelSpacingF    = 2
    end if
    end if
    end if
    end if
    end if
  end if

  if(variable_name.eq."SPD") then
    con_res@cnRasterModeOn       = False
    con_res@cnLevelSelectionMode = "ManualLevels"
    con_res@cnFillPalette        = "hotcold_18lev"
    con_res@cnMinLevelValF       = -11
    con_res@cnMaxLevelValF       = 11
    con_res@cnLevelSpacingF      = 2
  end if

  if( variable_name.eq."W" ) then
    con_res@cnRasterModeOn       = False
    con_res@cnLevelSelectionMode = "ManualLevels"
    con_res@cnFillPalette        = "hotcold_18lev"
    con_res@cnMinLevelValF       = -0.85
    con_res@cnMaxLevelValF       = 0.85
    con_res@cnLevelSpacingF      = 0.1
  end if

  if( variable_name.eq."SPD10" ) then
    con_res@cnRasterModeOn       = False
    con_res@cnLevelSelectionMode = "ManualLevels"
    con_res@cnFillPalette        = "hotcold_18lev"
    con_res@cnMinLevelValF       = -11
    con_res@cnMaxLevelValF       = 11
    con_res@cnLevelSpacingF      = 2
  end if

  if(variable_name.eq."Q2") then
    con_res@cnRasterModeOn       = False
    con_res@cnLevelSelectionMode = "ManualLevels"
    con_res@cnFillPalette        = "hotcold_18lev"
    con_res@cnMinLevelValF       = -11
    con_res@cnMaxLevelValF       = 11
    con_res@cnLevelSpacingF      = 2
  end if

  if(variable_name.eq."T2") then
    con_res@cnRasterModeOn       = False
    con_res@cnLevelSelectionMode = "ManualLevels"
    con_res@cnFillPalette        = "hotcold_18lev"
    con_res@cnMinLevelValF       = -15
    con_res@cnMaxLevelValF       = 15
    con_res@cnLevelSpacingF      = 2
  end if

  if( any(variable_name.eq.(/"MDBZ","REFL1KM","REFL4KM"/)) ) then
    con_res@cnRasterModeOn       = True
    con_res@cnLevelSelectionMode = "ManualLevels"
    con_res@cnFillPalette        = "hotcold_18lev"
    con_res@cnMinLevelValF       = -30
    con_res@cnMaxLevelValF       = 30
    con_res@cnLevelSpacingF      = 4
  end if

  if( variable_name.eq."MCAPE" ) then
    con_res@cnRasterModeOn       = False
    con_res@cnLevelSelectionMode = "ManualLevels"
    con_res@cnFillPalette        = "hotcold_18lev"
    con_res@cnMinLevelValF       = -1000
    con_res@cnMaxLevelValF       = 1000
    con_res@cnLevelSpacingF      = 100
  end if

end
;--------------------------------------------------------------------------------

;--------------------------------------------------------------------------------
; Set Resources for map
;--------------------------------------------------------------------------------
undef("map_resourcesx1")
procedure map_resourcesx1(nc_file:file, opt_arg[1]:logical)
begin

  opt_arg@mpProjection                = "LambertConformal"
  opt_arg@mpLambertParallel1F         = nc_file@TRUELAT1
  opt_arg@mpLambertParallel2F         = nc_file@TRUELAT2
  opt_arg@mpLambertMeridianF          = nc_file@STAND_LON
  opt_arg@mpLimitMode                 = "Corners"
  opt_arg@mpLeftCornerLatF            = nc_file@start_lat
  opt_arg@mpLeftCornerLonF            = nc_file@start_lon
  opt_arg@mpRightCornerLatF           = nc_file@end_lat
  opt_arg@mpRightCornerLonF           = nc_file@end_lon

  opt_arg@mpFillOn                    = False
  opt_arg@mpOutlineOn                 = True
  opt_arg@mpDataBaseVersion           = "MediumRes"
  opt_arg@mpDataSetName               = "Earth..4"
  opt_arg@mpOutlineDrawOrder          = "PostDraw"

  opt_arg@mpOutlineBoundarySets       = "National"
  opt_arg@mpNationalLineColor         = "Black"
  opt_arg@mpGeophysicalLineColor      = "Black"
  opt_arg@mpNationalLineThicknessF    = 2.0
  opt_arg@mpGeophysicalLineThicknessF = 2.0
  ;opt_arg@mpMaskOutlineSpecifiers     = "Argentina"

  opt_arg@tmXBLabelFontHeightF        = 0.012
  opt_arg@tmXTLabelFontHeightF        = 0.012
  opt_arg@tmYLLabelFontHeightF        = 0.012
  opt_arg@tmYRLabelFontHeightF        = 0.012
  opt_arg@tmYRLabelJust               = "CenterCenter"
  opt_arg@tmYLLabelJust               = "CenterCenter"
  opt_arg@tmYRLabelAngleF             = 90
  opt_arg@tmYLLabelAngleF             = 90

  opt_arg@tmBorderThicknessF          = 1.2
  opt_arg@tmXBMajorThicknessF         = 1.2
  opt_arg@tmXTMajorThicknessF         = 1.2
  opt_arg@tmYRMajorThicknessF         = 1.2
  opt_arg@tmYLMajorThicknessF         = 1.2

  opt_arg@pmTickMarkDisplayMode       = "Always"

end
;--------------------------------------------------------------------------------

;--------------------------------------------------------------------------------
; Set Resources for map - Panel x60 version
;--------------------------------------------------------------------------------
undef("map_resourcesx60")
procedure map_resourcesx60(nc_file:file, opt_arg[1]:logical)
begin

  opt_arg@mpProjection                = "LambertConformal"
  opt_arg@mpLambertParallel1F         = nc_file@TRUELAT1
  opt_arg@mpLambertParallel2F         = nc_file@TRUELAT2
  opt_arg@mpLambertMeridianF          = nc_file@STAND_LON
  opt_arg@mpLimitMode                 = "Corners"
  opt_arg@mpLeftCornerLatF            = nc_file@start_lat
  opt_arg@mpLeftCornerLonF            = nc_file@start_lon
  opt_arg@mpRightCornerLatF           = nc_file@end_lat
  opt_arg@mpRightCornerLonF           = nc_file@end_lon

  opt_arg@mpFillOn                    = False
  opt_arg@mpOutlineOn                 = True
  opt_arg@mpDataBaseVersion           = "MediumRes"
  opt_arg@mpDataSetName               = "Earth..4"
  opt_arg@mpOutlineDrawOrder          = "PostDraw"

  opt_arg@mpOutlineBoundarySets       = "National"
  opt_arg@mpNationalLineColor         = "Black"
  opt_arg@mpGeophysicalLineColor      = "Black"
  opt_arg@mpNationalLineThicknessF    = 1.5
  opt_arg@mpGeophysicalLineThicknessF = 1.5
  ;opt_arg@mpMaskOutlineSpecifiers     = "Argentina"

  opt_arg@tmXBLabelFontHeightF        = 0.012
  opt_arg@tmXTLabelFontHeightF        = 0.012
  opt_arg@tmYLLabelFontHeightF        = 0.012
  opt_arg@tmYRLabelFontHeightF        = 0.012
  opt_arg@tmYRLabelJust               = "CenterCenter"
  opt_arg@tmYLLabelJust               = "CenterCenter"
  opt_arg@tmYRLabelAngleF             = 90
  opt_arg@tmYLLabelAngleF             = 90

  opt_arg@tmBorderThicknessF          = 0.1
  opt_arg@tmXBMajorThicknessF         = 0.1
  opt_arg@tmXTMajorThicknessF         = 0.1
  opt_arg@tmYRMajorThicknessF         = 0.1
  opt_arg@tmYLMajorThicknessF         = 0.1

  opt_arg@pmTickMarkDisplayMode       = "Always"

end
;--------------------------------------------------------------------------------

;--------------------------------------------------------------------------------
; Load IMERG data in a 2D array
;--------------------------------------------------------------------------------
undef ("LoadIMERG")
function LoadIMERG(fname:string)
local nlat, nlon, lat1d, lon1d, temp1D, temp2D
begin
  nlat  = 132
  nlon  = 122
  data  = asciiread(fname,(/nlat*nlon,3/),"float")

  lat1d = data(::nlon,1)
  lon1d = data(0:nlon-1,0)

  temp1D = data(:,2)
  temp2D = onedtond(temp1D,(/nlat,nlon/))

  temp2D!0 = "lat"
  temp2D!1 = "lon"

  temp2D&lat = lat1d
  temp2D&lon = lon1d

  temp2D = smth9_Wrap(temp2D, 0.50, 0.25, True)

  return temp2D
end
;--------------------------------------------------------------------------------

;--------------------------------------------------------------------------------
; Get Ensamble WRF-ARW file list
;--------------------------------------------------------------------------------
undef ("get_filelist_analysis")
function get_filelist_analysis(BASEDIR[1]:string, \
                               nens:numeric, \
                               y:numeric, \
                               m:numeric, \
                               d:numeric, \
                               h:numeric )
local files,path_in,dd
begin
  dd      = ispan(1,nens,1)
  path_in = sprinti("%0.4i-", y) + \
            sprinti("%0.2i-", m) + \
            sprinti("%0.2i_", d) + \
            sprinti("%0.2i_00_00/", h)
  files   = BASEDIR + "/ANA/" + \
            path_in + \
            sprinti("anal%0.5i", dd)
  return files
end

undef ("get_filelist_forecast")
function get_filelist_forecast(BASEDIR[1]:string, \
                               mini:numeric, \
                               mfin:numeric, \
                               y:numeric, \
                               m:numeric, \
                               d:numeric, \
                               h:numeric, \
                               hf:numeric)
local files,path_in,fname_in,dd,fdate, \
      y_start,m_start,d_start,h_start, \
      y_end,m_end,d_end,h_end
begin
  hf@units    = sprinti("hours since %0.4i-", y) + \
                sprinti("%0.2i-", m) + \
                sprinti("%0.2i ", d) + \
                sprinti("%0.2i:00:00", h)
  dd          = ispan(mini,mfin,1)
  if(hf.lt.0) then
    ;---Guess Case
    hf        = -1
    fdate     = ut_calendar(hf, 0)
    y_start   = tointeger(fdate(:,0))
    m_start   = tointeger(fdate(:,1))
    d_start   = tointeger(fdate(:,2))
    h_start   = tointeger(fdate(:,3))
    y_end     = y
    m_end     = m
    d_end     = d
    h_end     = h
  else
    ;---Forecast Case
    y_start   = y
    m_start   = m
    d_start   = d
    h_start   = h
    fdate     = ut_calendar(hf, 0)
    y_end     = tointeger(fdate(:,0))
    m_end     = tointeger(fdate(:,1))
    d_end     = tointeger(fdate(:,2))
    h_end     = tointeger(fdate(:,3))
  end if
  path_in   = sprinti("%0.4i", y_start) + \
              sprinti("%0.2i", m_start) + \
              sprinti("%0.2i_", d_start) + \
              sprinti("%0.2i0000/", h_start)
  fname_in  = "wrfout_d01_" + \
              sprinti("%0.4i-", y_end) + \
              sprinti("%0.2i-", m_end) + \
              sprinti("%0.2i_", d_end) + \
              sprinti("%0.2i_00_00", h_end)
  files     = BASEDIR + "/FCST/" + \
              path_in + \
              sprinti("%0.2i/", dd) + \
              fname_in
  return files
end

undef ("get_filelist_forecast_mem")
function get_filelist_forecast_mem(BASEDIR[1]:string, \
                               mem:numeric, \
                               y:numeric, \
                               m:numeric, \
                               d:numeric, \
                               h:numeric, \
                               hf:numeric)
local files,path_in,fname_in,dd,fdate, \
      y_start,m_start,d_start,h_start, \
      y_end,m_end,d_end,h_end
begin
  hf@units    = sprinti("hours since %0.4i-", y) + \
                sprinti("%0.2i-", m) + \
                sprinti("%0.2i ", d) + \
                sprinti("%0.2i:00:00", h)
  dd          = mem
  if(hf.lt.0) then
    ;---Guess Case
    hf        = -1
    fdate     = ut_calendar(hf, 0)
    y_start   = tointeger(fdate(:,0))
    m_start   = tointeger(fdate(:,1))
    d_start   = tointeger(fdate(:,2))
    h_start   = tointeger(fdate(:,3))
    y_end     = y
    m_end     = m
    d_end     = d
    h_end     = h
  else
    ;---Forecast Case
    y_start   = y
    m_start   = m
    d_start   = d
    h_start   = h
    fdate     = ut_calendar(hf, 0)
    y_end     = tointeger(fdate(:,0))
    m_end     = tointeger(fdate(:,1))
    d_end     = tointeger(fdate(:,2))
    h_end     = tointeger(fdate(:,3))
  end if
  path_in   = sprinti("%0.4i", y_start) + \
              sprinti("%0.2i", m_start) + \
              sprinti("%0.2i_", d_start) + \
              sprinti("%0.2i0000/", h_start)
  fname_in  = "wrfout_d01_" + \
              sprinti("%0.4i-", y_end) + \
              sprinti("%0.2i-", m_end) + \
              sprinti("%0.2i_", d_end) + \
              sprinti("%0.2i_00_00", h_end)
  files     = BASEDIR + "/FCST/" + \
              path_in + \
              sprinti("%0.2i/", dd) + \
              fname_in
  return files
end




;--------------------------------------------------------------------------------

;--------------------------------------------------------------------------------
; Get Ensamble WRF-ARW file
;--------------------------------------------------------------------------------
undef ("get_file_analysis")
function get_file_analysis(BASEDIR[1]:string, \
                           nens:numeric, \
                           y:numeric, \
                           m:numeric, \
                           d:numeric, \
                           h:numeric )
local files,path_in
begin
  path_in = sprinti("%0.4i-", y) + \
            sprinti("%0.2i-", m) + \
            sprinti("%0.2i_", d) + \
            sprinti("%0.2i_00_00/", h)
  files   = BASEDIR + "/ANA/" + \
            path_in + \
            sprinti("anal%0.5i", nens)
  return files
end

undef ("get_file_forecast")
function get_file_forecast(BASEDIR[1]:string, \
                           nens:numeric, \
                           y:numeric, \
                           m:numeric, \
                           d:numeric, \
                           h:numeric, \
                           hf:numeric)
local files,path_in,fname_in,fdate, \
      y_start,m_start,d_start,h_start, \
      y_end,m_end,d_end,h_end
begin
  hf@units    = sprinti("hours since %0.4i-", y) + \
                sprinti("%0.2i-", m) + \
                sprinti("%0.2i ", d) + \
                sprinti("%0.2i:00:00", h)
  if(hf.lt.0) then
    ;---Guess Case
    hf        = -1
    fdate     = ut_calendar(hf, 0)
    y_start   = tointeger(fdate(:,0))
    m_start   = tointeger(fdate(:,1))
    d_start   = tointeger(fdate(:,2))
    h_start   = tointeger(fdate(:,3))
    y_end     = y
    m_end     = m
    d_end     = d
    h_end     = h
  else
    ;---Forecast Case
    y_start   = y
    m_start   = m
    d_start   = d
    h_start   = h
    fdate     = ut_calendar(hf, 0)
    y_end     = tointeger(fdate(:,0))
    m_end     = tointeger(fdate(:,1))
    d_end     = tointeger(fdate(:,2))
    h_end     = tointeger(fdate(:,3))
  end if
  path_in   = sprinti("%0.4i-", y_start) + \
              sprinti("%0.2i-", m_start) + \
              sprinti("%0.2i_", d_start) + \
              sprinti("%0.2i_00_00/", h_start)
  fname_in  = "wrfout_d01_" + \
              sprinti("%0.4i-", y_end) + \
              sprinti("%0.2i-", m_end) + \
              sprinti("%0.2i_", d_end) + \
              sprinti("%0.2i:00:00", h_end)
  files     = BASEDIR + "/FCST/" + \
              path_in + \
              sprinti("%0.2i/", nens) + \
              fname_in
  return files
end
;--------------------------------------------------------------------------------

;--------------------------------------------------------------------------------
; Function to calculate percentile values
;--------------------------------------------------------------------------------
undef("percent_to_value")
function percent_to_value( \
  i_data           : numeric, \
  i_percentiles[*] : numeric  \
)
local None
begin

  retVal = new( dimsizes(i_percentiles), float )

  data1d = ndtooned( i_data )
  notMissing = data1d( ind(.not.ismissing(data1d) ) )

  qsort(notMissing)

  do p = 0, dimsizes(i_percentiles)-1
;   pInd = round( i_percentiles(p) * .01 * dimsizes(notMissing) + 0.5, 3 ) -1
;   pInd = where( pInd.ge.dimsizes(notMissing), dimsizes(notMissing)-1, pInd )
    floatInd = i_percentiles(p) * .01 * dimsizes(notMissing) - 0.5
    floorInd = toint( floor(floatInd) )
    floorInd = where( floorInd.lt.0, 0, floorInd )
    ceilInd = toint( ceil(floatInd) )
    ceilInd = where( ceilInd.ge.dimsizes(notMissing), \
        dimsizes(notMissing)-1, ceilInd )
;   print(pInd + " " + dimsizes(notMissing))
    if( ceilInd.eq.floorInd ) then
      retVal(p) = notMissing(floorInd)
    else
      retVal(p) = notMissing(floorInd) * ( ceilInd - floatInd ) \
          + notMissing(ceilInd) * ( floatInd - floorInd )
    end if
  end do

  return(retVal)
end ; percent_to_value
;--------------------------------------------------------------------------------

;--------------------------------------------------------------------------------
; Get variable description
;--------------------------------------------------------------------------------
undef("get_var_description")
function get_var_description(variable_name[1]:string, \
                             opts[1]:logical)
local output

begin
  output = ""

  if(variable_name.eq."Q") then
    output = "Specific Humidity"
  end if

  if(variable_name.eq."SPD") then
    output = "Wind speed"
  end if

  if(variable_name.eq."T") then
    output = "Temperature"
  end if

  if(variable_name.eq."Z") then
    output = "Geopotential Height"
  end if

  if(variable_name.eq."U") then
    output = "Wind component U"
  end if

  if(variable_name.eq."Umet") then
    output = "Zonal Wind Component"
  end if

  if(variable_name.eq."V") then
    output = "Wind component V"
  end if

  if(variable_name.eq."Vmet") then
    output = "Meridional Wind Component"
  end if

  if(variable_name.eq."W") then
    output = "Vertical velocity"
  end if

  if(variable_name.eq."VNORTH") then
    output = "North Wind"
  end if

  if(variable_name.eq."MDBZ") then
    output = "Max Reflectivity"
  end if

  if(variable_name.eq."REFL1KM") then
    output = "Reflectivity at 1km agl"
  end if

  if(variable_name.eq."REFL4KM") then
    output = "Reflectivity at 4km agl"
  end if

  if(variable_name.eq."PP") then
    output = "Accumulated Precipitation"
    if(opts.and.isatt(opts,"hf")) then
      output = opts@hf + "-h " + output
    end if
  end if

  if(variable_name.eq."PPrate") then
    output = "Precipitation Rate"
  end if

  if(variable_name.eq."PSFC") then
    output = "Surface Pressure"
  end if

  if(variable_name.eq."Q2") then
    output = "2-m Specific Humidity"
  end if

  if(variable_name.eq."SPD10") then
    output = "10-m Wind speed"
  end if

  if(variable_name.eq."T2") then
    output = "2-m Temperature"
  end if

  if(variable_name.eq."MCAPE") then
    output = "Max. Convective Avail. Potential Energy"
  end if

  if(variable_name.eq."CIN") then
    output = "Max. Convective Inhibition"
  end if

  if(variable_name.eq."BULK") then
    output = "0-6km Bulk wind difference"
  end if

  if(variable_name.eq."HELI") then
    output = "0-1km Storm Relative Helicity"
  end if

  if(variable_name.eq."spread") then
    output = "Spread"
  end if

  if(variable_name.eq."probability") then
    output = "Probability"
  end if

;---Pressure level
  if(opts.and.isatt(opts,"pressure")) then
    output = output + " at " + opts@pressure + " hPa"
  end if

;---Units
  if(opts.and.isatt(opts,"units")) then
    if(any(variable_name.eq.(/"Q","Q2"/))) then
      output = output + " (g/kg)"
    end if

    if(any(variable_name.eq.(/"SPD","SPD10","U","V","W","VNORTH"/))) then
      output = output + " (m/s)"
    end if

    if(any(variable_name.eq.(/"T","T2"/))) then
      output = output + " (~F34~0~F~C)"
    end if

    if(variable_name.eq."Z") then
      output = output + " (gpm)"
    end if

    if(any(variable_name.eq.(/"MDBZ","REFL1KM","REFL4KM"/))) then
      output = output + " (dBZ)"
    end if

    if(variable_name.eq."PP") then
      output = output + " (mm)"
    end if

    if(variable_name.eq."PPrate") then
      output = output + " (mm/h)"
    end if

    if(variable_name.eq."PSFC") then
      output = output + " (hPa)"
    end if

    if(any(variable_name.eq.(/"MCAPE","CIN"/))) then
      output = output + " (J/Kg)"
    end if

    if(variable_name.eq."BULK") then
      output = output + " (m/s)"
    end if

    if(variable_name.eq."HELI") then
      output = output + " (m2/s2)"
    end if

    if(variable_name.eq."probability") then
      output = output + " (%)"
    end if
  end if

  return output
end
;--------------------------------------------------------------------------------

;--------------------------------------------------------------------------------
; Get variable shortname
;--------------------------------------------------------------------------------
undef("get_varname_short")
function get_varname_short(variable_name[1]:string, \
                           opts[1]:logical)
local output

begin
  output = variable_name

  if(variable_name.eq."T") then
    output = "Temperature"
  end if

  if(variable_name.eq."Q") then
    output = "Specific_Humidity"
  end if

  if(variable_name.eq."Z") then
    output = "Geopotential"
  end if

  if(variable_name.eq."SPD") then
    output = "Isotachs"
  end if

  if(variable_name.eq."U") then
    output = "U_Wind"
  end if

  if(variable_name.eq."V") then
    output = "V_Wind"
  end if

  if(variable_name.eq."VNORTH") then
    output = "North_Wind"
  end if

  if(variable_name.eq."W") then
    output = "Vertical_Velocity"
  end if

  if(variable_name.eq."T2") then
    output = "2m_Temperature"
  end if

  if(variable_name.eq."Q2") then
    output = "2m_Specific_Humidity"
  end if

  if(variable_name.eq."PSFC") then
    output = "Surface_Pressure"
  end if

  if(variable_name.eq."SPD10") then
    output = "10m_Wind_Speed"
  end if

  if(variable_name.eq."PP") then
    output = "Accumulated_Precipitation"
  end if

  if(variable_name.eq."PPrate") then
    output = "Hourly_Precipitation"
  end if

  if(variable_name.eq."MDBZ") then
    output = "Max_Reflectivity"
  end if

  if(variable_name.eq."REFL1KM") then
    output = "1km_Reflectivity"
  end if

  if(variable_name.eq."REFL4KM") then
    output = "4km_Reflectivity"
  end if

  if(variable_name.eq."HELI") then
    output = "0-1km_Storm_Relative_Helicity"
  end if

  if(variable_name.eq."BULK") then
    output = "0-6km_Wind_Shear"
  end if

  if(variable_name.eq."MCAPE") then
    output = "Max_CAPE"
  end if

  if(variable_name.eq."CIN") then
    output = "Max_CIN"
  end if

;---Stations
  if( isStrSubset(variable_name,"cordoba") ) then
    output = "Cordoba"
  end if

  if( isStrSubset(variable_name,"yacanto") ) then
    output = "Villa_Yacanto"
  end if

  if( isStrSubset(variable_name,"dolores") ) then
    output = "Villa_Dolores"
  end if

  if( isStrSubset(variable_name,"pilar") ) then
    output = "Pilar"
  end if

;---Pressure level
  if(opts.and.isatt(opts,"pressure")) then
    output = opts@pressure + "hPa" + "_" + output
  end if

  return output
end
;--------------------------------------------------------------------------------

;--------------------------------------------------------------------------------
; Get general title
;--------------------------------------------------------------------------------
undef("get_header")
function get_header( y:numeric, \
                     m:numeric, \
                     d:numeric, \
                     h:numeric, \
                     opts:logical)
local format, time, time1_str, time2_str, header
begin
  format     = "%Y-%N-%D %H:%MZ"
  time       = 0
  time@units = "hours since " + \
               sprinti("%0.4i-", y) + \
               sprinti("%0.2i-", m) + \
               sprinti("%0.2i ", d) + \
               sprinti("%0.2i:00:00", h)
  time1_str  = cd_string(time, format)

  if(opts.and.isatt(opts,"hf")) then
    time = opts@hf
  end if
  time2_str  = cd_string(time, format)

  if(isatt(opts,"model").and.isatt(opts,"description")) then
    header = opts@model + " - " + opts@description + "~C~"
  else if (isatt(opts,"sat").and.isatt(opts,"description")) then
    header = opts@sat + " - " + opts@description + "~C~"
  else
    header = ""
  end if
  end if

  header = header + \
           "Initialized: " + time1_str + \
           " Forecast hour: " + sprinti("%0.3i", time) + \
           " Valid: " + time2_str
  return header
end
;--------------------------------------------------------------------------------

;--------------------------------------------------------------------------------
; Get output filename
;--------------------------------------------------------------------------------
undef("get_fname_out")
function get_fname_out( varname:string, \
                        y:numeric, \
                        m:numeric, \
                        d:numeric, \
                        h:numeric, \
                        opts:logical)
local hf,datetime,producto,fname_out
begin
;---Forecast hour
  if(opts.and.isatt(opts,"hf")) then
    hf = opts@hf
  else
    hf = 0
  end if

;---Datetime
  datetime = sprinti("%0.4i", y) + \
             sprinti("%0.2i", m) + \
             sprinti("%0.2i", d) + \
	     "_" + \
             sprinti("%0.2i", h) + \
             sprinti("%0.2i", 0) + \
             sprinti("%0.2i", 0) + \
             "." + \
             sprinti("%0.3i", hf)

;---Product
  if(opts.and.isatt(opts,"producto")) then
    producto = opts@producto + "_" + varname
  else
    producto = varname
  end if

;---Threshold
  if(opts.and.isatt(opts,"threshold")) then
    producto = producto + "_gt_" + opts@threshold
  end if

;---Output Filename
  category = "model"
  fname_out = category

  if(opts.and.isatt(opts,"platform")) then
    fname_out = fname_out + "." + opts@platform
  end if

  fname_out = fname_out + "." + \
              datetime + "." + \
              producto

  return fname_out
end
;--------------------------------------------------------------------------------

;--------------------------------------------------------------------------------
; Create array for boxplot
;--------------------------------------------------------------------------------
undef("create_boxplot_array")
function create_boxplot_array( y0:numeric )
local dims,ntim,it,data1d,percentil,ybox,ymin,ymax,ymedian
begin
  dims      = dimsizes(y0)
  ntim      = dims(0)
  ybox      = new((/ntim,5/),float)

  ymin      = dim_min_n(y0,1)
  ymax      = dim_max_n(y0,1)
  ymedian   = dim_median_n(y0,1)

  ybox(:,0) = ymin
  ybox(:,2) = ymedian
  ybox(:,4) = ymax

  do it=0,ntim-1
    data1d     = y0(it,:)
    percentil  = percent_to_value(data1d,(/10,90/) )
    ybox(it,1) = percentil(0)
    ybox(it,3) = percentil(1)
  end do

  return(ybox)
end
;--------------------------------------------------------------------------------
