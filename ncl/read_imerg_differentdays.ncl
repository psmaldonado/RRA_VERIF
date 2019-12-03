load "lib_ensambleWRF.ncl"  ; cargo librerias

;
;26/12/2018
;----------------------------------------------------------------------
;Acumula datos de IMERG.LR en 24hs entre 00 y 00Z / 06 y 06Z / 12 y 12Z / 18 y 18Z 
; y grafica para verificacion en HM
;
;Me basé en script rayo:/data/RRA/NPP/scripts/npp/read_npp_probability_imerg.ncl (usado para Relampago)
;Otras ideas en https://www.ncl.ucar.edu/Applications/Scripts/gpm_1.ncl
;
;Inputs:
;   1. y (year), m (month), d (day) h (hour) fecha que quiero acumular
;   2. hf (end forecast hour):
;      hf>=0        -> Forecast file
;   3. hfi (initial forecast hour)
;   4. BASEDIR (Environment variable) - ubicacion del script
;   5. PLOTPATH (Environmental variable)
;----------------------------------------------------------------------
;/

begin
  start_cpu_time = get_cpu_time()

;---General resources
  opts            = True
  opts@units      = True
  opts@hf	  = hf
  opts@producto   = "ppacum" + sprinti("%0.2i",hf)

;---Variable Name
varname = "PP"

;---Root directory
  BASEDIR = getenv("BASEDIR")
  PLOTPATH = getenv("PLOTPATH")
  if(ismissing(BASEDIR)) then
    print("BASEDIR not defined, please define it")
  end if
  path_in  = "/home/devel/EXP/FCST_MOD/HIST/POST/NPP/" 
  path_out = PLOTPATH

;---Fecha_in
  if(isvar("y") .and. isvar("m") .and. isvar("d") ) then
    fecha_in = sprinti("%0.4i", y) + \
               sprinti("%0.2i", m) + \
               sprinti("%0.2i", d) 
    opts@basename = fecha_in
    print("fecha_in: " + fecha_in)
  else
    print("Required input: y, m, d, Closing...")
    exit()
  end if

;---Output Filename
  varname_short = get_varname_short(varname,opts)  ; Accumulated_Precipitation
 
  if(opts.and.isatt(opts,"hfi")) then
    hfi = opts@hfi
  else
    hfi = 0
  end if

  hora_in = sprinti("%0.2i", h) 

  time_in = hora_in + "0000" ; HHMMSS inicio de la acumulacion en UTC	
  fhr = sprinti("%0.3i", hf)

  fname_out = "sat.IMERGLR." + fecha_in + "_" + time_in + "." + fhr + "." + opts@producto
  print(fname_out)

;---Variable long Name for figure title
  acuhours = hf-hfi
  output = acuhours + "h Accumulated Precipitation (mm)"
  opts@description = output
  opts@sat = "SAT IMERGLR "


;----------------------------------------------------------------------
; open file:specify desired variable
;----------------------------------------------------------------------
; Abro todos los archivos de esa fecha
; Para no repetir, calculo la fecha de mañana ahora:

      hff=25
      hff@units    = sprinti("hours since %0.4i-", y) + \
                     sprinti("%0.2i-", m) + \
                     sprinti("%0.2i ", d) + \
                     sprinti("%0.2i:00:00", h)
      fdate     = ut_calendar(hff, 0)

      fecha2    = sprinti("%0.4i", tointeger(fdate(:,0))) + \
                 sprinti("%0.2i", tointeger(fdate(:,1))) + \
                 sprinti("%0.2i", tointeger(fdate(:,2)))

  h_in = stringtointeger(hora_in)

  if(h_in.eq.0) then 
    files = systemfunc("ls " + path_in +  fecha_in + "_000000/3B-HHR-L.MS.MRG.3IMERG." + fecha_in + "*.RT-H5")  
    nfiles = dimsizes(files)
 
  else if(h_in.eq.6) then
    ; Incluyo este dq para que pueda entender las comillas adentro de comillas
    dq = str_get_dq()
    secu = "%04g"
    file1 = systemfunc("for arch in $(seq -f "+dq+secu+dq+" 360 30 1410 ); do ls " + path_in +  fecha_in + "_000000/3B-HHR-L.MS.MRG.3IMERG.*.${arch}.*; done")
    file2 = systemfunc("for arch in $(seq -f "+dq+secu+dq+" 0 30 330 ); do ls " + path_in +  fecha2 + "_000000/3B-HHR-L.MS.MRG.3IMERG.*.${arch}.*; done")
    files = array_append_record(file1,file2,0)
    nfiles = dimsizes(files)

  else if(h_in.eq.12) then
    dq = str_get_dq()
    secu = "%04g"
    file1 = systemfunc("for arch in $(seq -f "+dq+secu+dq+" 720 30 1410 ); do ls " + path_in +  fecha_in + "_000000/3B-HHR-L.MS.MRG.3IMERG.*.${arch}.*; done")
    file2 = systemfunc("for arch in $(seq -f "+dq+secu+dq+" 0 30 690 ); do ls " + path_in +  fecha2 + "_000000/3B-HHR-L.MS.MRG.3IMERG.*.${arch}.*; done")
    files = array_append_record(file1,file2,0)
    nfiles = dimsizes(files)

  else if(h_in.eq.18) then
    dq = str_get_dq()
    secu = "%04g"
    file1 = systemfunc("for arch in $(seq -f "+dq+secu+dq+" 1080 30 1410 ); do ls " + path_in +  fecha_in + "_000000/3B-HHR-L.MS.MRG.3IMERG.*.${arch}.*; done")
    file2 = systemfunc("for arch in $(seq -f "+dq+secu+dq+" 0 30 1050 ); do ls " + path_in +  fecha2 + "_000000/3B-HHR-L.MS.MRG.3IMERG.*.${arch}.*; done")
    files = array_append_record(file1,file2,0)
    nfiles = dimsizes(files)

  end if
  end if
  end if
  end if


  var_name = "/Grid/precipitationCal" 

; leo el primer archivo
  fname0 = files(0)
  f0 = addfile(fname0,"r")
  data0 = f0->$var_name$
  pp0 = data0(lat|:,lon|:)             ;NCL expects (lat,lon) order for map plotting: use 'named dimension
  acum = pp0

; leo el resto de los archivos
  do nf=1,nfiles-1 
    fname = files(nf)    
    f     = addfile(fname,"r")
    data  = f->$var_name$
    pp    = data(lat|:,lon|:) 
    acum  = acum + pp
  end do 
  acum = acum*0.5   ; multiplico por 0.5 para obtener mm/h

  acum!0 = "lat"        ; asigno nombres a las coordenadas de acum
  acum!1 = "lon"
  acum&lat = pp0&lat    ; asigno las coordenadas de lat/lon de pp0 a la variable acum
  acum&lon = pp0&lon

  printVarSummary(acum)
  printMinMax(acum,0)

; me quedo con un subset que me interesa:
 subp=acum({-60.05:-14.95},{-80.05:-49.95})
 subp!0="lat"
 subp!1="lon"
 subp&lat = acum&lat(299:750)
 subp&lon = acum&lon(999:1300)
 subp&lat@units = "degrees_north"
 subp&lon@units = "degrees_east"

 printVarSummary(subp)
 printMinMax(subp,0)

;----------------------------------------------------------------------
; create graphical resources
;----------------------------------------------------------------------
  wks_type = "png"
  if(wks_type.eq."png") then
    wks_type@wkWidth  = 2500
    wks_type@wkHeight = 2500
  end if
  if(wks_type.eq."pdf") then
    wks_type@wkPaperHeightF = 40
    wks_type@wkPaperWidthF  = 57
  end if
  wks = gsn_open_wks(wks_type,path_out+fname_out)

  ;print("wks va a escribir en: " + path_out + fname_out)

;---Map plot
  map_res                   = True
  map_res@gsnDraw           = False
  map_res@gsnFrame          = False

  map_res@mpProjection                = "CylindricalEquidistant"
  map_res@mpLimitMode  = "LatLon"
  map_res@mpMinLatF    = min(subp&lat)   ; - 1  
  map_res@mpMaxLatF    = max(subp&lat)   ; + 1  
  map_res@mpMinLonF    = min(subp&lon)   ; - 1
  map_res@mpMaxLonF    = max(subp&lon)   ; + 1

  map_res@mpFillOn                    = False
  map_res@mpOutlineOn                 = True
  map_res@mpDataBaseVersion           = "MediumRes"
  map_res@mpDataSetName               = "Earth..4"
  map_res@mpOutlineDrawOrder          = "PostDraw"

  map_res@mpOutlineBoundarySets       = "National"
  map_res@mpNationalLineColor         = "Black"
  map_res@mpGeophysicalLineColor      = "Black"
  map_res@mpNationalLineThicknessF    = 2.0
  map_res@mpGeophysicalLineThicknessF = 2.0

  map_res@tmXBLabelFontHeightF        = 0.012
  map_res@tmXTLabelFontHeightF        = 0.012
  map_res@tmYLLabelFontHeightF        = 0.012
  map_res@tmYRLabelFontHeightF        = 0.012
  map_res@tmYRLabelJust               = "CenterCenter"
  map_res@tmYLLabelJust               = "CenterCenter"
  map_res@tmYRLabelAngleF             = 90
  map_res@tmYLLabelAngleF             = 90

  map_res@tmBorderThicknessF          = 1.2
  map_res@tmXBMajorThicknessF         = 1.2
  map_res@tmXTMajorThicknessF         = 1.2
  map_res@tmYRMajorThicknessF         = 1.2
  map_res@tmYLMajorThicknessF         = 1.2

  map_res@pmTickMarkDisplayMode       = "Always"

  ; --- Crear el mapa base:
  map     = gsn_csm_map(wks,map_res)

;---Section to add polylines to map.
  lnres                               = True
  lnres@gsLineColor                   = "gray50"
  lnres@gsLineThicknessF              = 1.0

  ; --- Agregar las provincias al mapa base:
  shp     = gsn_add_shapefile_polylines(wks,map,"interprovincial/interprovinciales.shp",lnres)


;---Set some common resources
  res                       = True     ; plot mods desired
  res@gsnMaximize           = True     ; Make plot fit the frame

  res@tfDoNDCOverlay        = False
  res@gsnAddCyclic          = False
  res@gsnDraw               = False             ; do not draw the plot (yet)
  res@gsnFrame              = False             ; do not advance the frame (yet)

;---CONTOUR filled contour plot
  con_res                             = res
  con_res@cnFillOn                    = True ; turn on color fill
  con_res@cnFillMode                  = "RasterFill"
  con_res@cnLinesOn                   = False
  con_res@cnLineLabelsOn              = False
  con_res@cnInfoLabelOn               = False

  con_res@lbLabelBarOn                = True  ;barra de colores
  con_res@lbTitleFontHeightF          = 0.02
  con_res@lbLabelFontHeightF          = 0.015
  con_res@lbOrientation               = "Vertical"
  con_res@lbTitlePosition             = "Right"
  con_res@lbTitleDirection            = "Across"
  con_res@lbTitleAngleF               = 90
  con_res@lbBoxEndCapStyle            = "TriangleBothEnds"
  con_res@lbTitleString               = get_var_description(varname,opts)
  con_res@pmLabelBarWidthF            = 0.2

  set_contour_resources(varname,con_res,opts)

  con_res@tiMainFontHeightF           = 0.016
  con_res@tiMainOffsetYF              = 0.016
  con_res@tiMainString                = get_header(y,m,d,h,opts)

  ;---crear el grafico de los datos y superponerlo con el mapa base:
  contour = gsn_csm_contour(wks,subp,con_res) 
  overlay(map,contour)  ; solo 2 args

  ;---Ahora si, dibujo:
  draw(map)
  frame(wks)

  end_cpu_time = get_cpu_time()
  print(get_script_prefix_name() + " for " +varname+ ": elapsed time = " + (end_cpu_time-start_cpu_time) + " seconds.")

end 
