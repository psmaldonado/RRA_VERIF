load "lib_ensambleWRF.ncl"

/;
; ----------------------------------------------------------------
Genera mapas para todos los miembros del ensamble
para la resta del modelo y el IMERG.LR para la 
precipitacion acumulada en el periodo (hf-hfi)

Inputs:
   1. y (year), m (month), d (day), h (hour)
   2. hf (end forecast hour):
      hf>=0        -> Forecast file
   3. hfi (initial forecast hour)
   4. BASEDIR (Environment variable)
   5. mini (nro member_ini)
   6. mfin (nro member_fin)
   7. nrows (nro filas para el grafico)
   8. PLOTPATH (Environment variable)
; -----------------------------------------------------------------
;/

begin
  start_cpu_time = get_cpu_time()

;---General resources
opts            = True
opts@units      = True
opts@hfi        = hfi

;---Variable Name
varname = "PP"

if(opts.and.isatt(opts,"hfi")) then
    hfi = opts@hfi
else
    hfi = 0
end if

acuhours = hf - hfi

;---Root directory
  BASEDIR = getenv("BASEDIR")
  PLOTPATH = getenv("PLOTPATH")
  if(ismissing(BASEDIR)) then
    print("BASEDIR not defined, please define it")
  end if
  path     = BASEDIR + "/HIST/POST/NPP/"
  path_out = PLOTPATH
  path_in = "/home/devel/EXP/FCST_MOD/HIST/POST/NPP/"

;---Filename to open
  if(isvar("y") .and. isvar("m") .and. isvar("d") .and. isvar("h")) then
    fname = "model.WRF_SMN_4km."               + \
            sprinti("%0.4i", y) + \
            sprinti("%0.2i", m) + \
            sprinti("%0.2i_", d) + \
            sprinti("%0.2i0000.", h)
    opts@basename = path + fname

    fechadir = sprinti("%0.4i", y) + \
               sprinti("%0.2i", m) + \
               sprinti("%0.2i_", d) + \
               sprinti("%0.2i0000/", h)

    hora_in = sprinti("%0.2i", h)

    ; calculo fecha para imerglr
    ; Esta fecha_in es desde donde parto, y luego voy a definir la fecha2 a partir de esta
    ; con lo cual aca estoy resolviendo el tema de fcst a 24 o 48h

    if(hf.le.24) then
      fecha_in = sprinti("%0.4i", y) + \
               sprinti("%0.2i", m) + \
               sprinti("%0.2i", d)
    else if((hf.gt.24) .and. (hf.le.48)) then
      hff=25
      hff@units    = sprinti("hours since %0.4i-", y) + \
                     sprinti("%0.2i-", m) + \
                     sprinti("%0.2i ", d) + \
                     sprinti("%0.2i:00:00", h)
      fdate     = ut_calendar(hff, 0)

      fecha_in = sprinti("%0.4i", tointeger(fdate(:,0))) + \
                 sprinti("%0.2i", tointeger(fdate(:,1))) + \
                 sprinti("%0.2i", tointeger(fdate(:,2)))

;      fechadir_im = fecha_in + "_000000/"

    end if
    end if

  else
    print("Required input: y, m, d, h. Closing...")
    exit()
  end if

;---Checking for end forecast hour
  if(isvar("hf")) then
    if(hf.ge.0) then
      opts@model    = "ENS.FCST WRF 4km"
      opts@platform = "WRF_SMN_4km"
      opts@hf       = hf
      fnamef        = fname + sprinti("%0.3i", hf) + \
                      ".nppmi" + sprinti("%0.2i", mini) + \
                      "mf" + sprinti("%0.2i", mfin) + ".nc"
    end if
  end if

;---Checking for initial forecast hour
  if(isvar("hfi")) then
      fnamei        = fname + sprinti("%0.3i", hfi) + \
                      ".nppmi" + sprinti("%0.2i", mini) + \
                      "mf" + sprinti("%0.2i", mfin) + ".nc"
  end if

;---Open npp-WRF files using addfiles
  f = addfile(path+fechadir+fnamef,"r")
  fi = addfile(path+fechadir+fnamei,"r")

;--- Open IMERGLR files (de script Cynthia)
; Abro todos los archivos de esa fecha
; Acumula datos de IMERG.LR en 24hs entre 00 y 00Z / 06 y 06Z / 12 y 12Z / 18 y 18Z

; Calculo la fecha de mañana (a partir de fecha_in)

  dia = stringtointeger(fecha_in)
  hff=25
  hff@units    = sprinti("hours since %0.8i", dia)
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



;  time_in = "000000" ; HHMMSS inicio de la acumulacion en UTC
;  fhr = sprinti("%0.3i", hf)
;  files = systemfunc("ls " + path_imerg +  fechadir_im + "3B-HHR-L.MS.MRG.3IMERG." + fecha_in + "*.RT-H5")
;  nfiles = dimsizes(files)

  var_name = "/Grid/precipitationCal"

; leo el primer archivo
  fname0 = files(0)
  f0 = addfile(fname0,"r")
  data0 = f0->$var_name$
  pp0 = data0(lat|:,lon|:)             ;NCL expects (lat,lon) order for map plotting: use 'named dimension
  acum = pp0

; leo el resto de los archivos
  do nf=1,nfiles-1
    fname_imerg = files(nf)
    f_imerg     = addfile(fname_imerg,"r")
    data_imerg  = f_imerg->$var_name$
    pp_imerg    = data_imerg(lat|:,lon|:)
    acum        = acum + pp_imerg
  end do
  acum = acum*0.5   ; multiplico por 0.5 para obtener mm/h

  acum!0 = "lat"        ; asigno nombres a las coordenadas de acum
  acum!1 = "lon"
  acum&lat = pp0&lat    ; asigno las coordenadas de lat/lon de pp0 a la variable acum
  acum&lon = pp0&lon

; me quedo con un subset que me interesa:
 subp=acum({-60.05:-14.95},{-80.05:-49.95})
 subp!0="lat"
 subp!1="lon"
 subp&lat = acum&lat(299:750)
 subp&lon = acum&lon(999:1300)

 printVarSummary(subp)
 printMinMax(subp,0)

;---Output Filename
  varname_short = "ppacum" + sprinti("%0.2i", acuhours)

;---Armo el name aca para incluir info del tiempo acumulado -> preparo para los 3 graficos
  fname_out = get_fname_out(varname_short,y,m,d,h,opts)

  fname_out_ens = fname_out + "_mi" + sprinti("%0.2i", mini) + "mf" + sprinti("%0.2i", mfin)
  fname_out_dif = fname_out + "_difmi" + sprinti("%0.2i", mini) + "mf" + sprinti("%0.2i", mfin) + "-IMERGLR"
;  fname_out_ime = "sat.IMERGLR." + fecha_in + "_" + time_in + "." + fhr + ".ppacum" + sprinti("%0.2i",hf)

;---Get variables to be read from WRF
  data = get_NPP_data(f,varname,opts)
  datai = get_NPP_data(fi,varname,opts)

  ; obtengo la precip entre hf y hfi:
  data = data - datai

  printVarSummary(data)
  printMinMax(data,0)

  npplat = f->XLAT
  npplon = f->XLONG

;---- Interpolo de WRF NPP a IMERG (mayor resolucion a menor resolucion) (reticula curvilinea a rectangular)
; https://www.ncl.ucar.edu/Document/Functions/Built-in/rcm2rgrid.shtml

  npp_inter=rcm2rgrid(npplat,npplon,data,subp&lat,subp&lon,1)

  printVarSummary(npp_inter)
  printMinMax(npp_inter,0)

;########------------------------------------
;######## Figura 1: Diferencia WRF-IMERGLR 
;########------------------------------------

;---Variable long Name for figure title
    output = acuhours + "h Accumulated Precipitation (mm) Dif"
    output = output + " mi" + sprinti("%0.2i", mini) + "mf" + sprinti("%0.2i", mfin) + "-IMERGLR"
    opts@description = output

;---Open workstation
  wks_type = "png"
  if(wks_type.eq."png") then
    wks_type@wkWidth  = 2500
    wks_type@wkHeight = 2500
  end if
  if(wks_type.eq."pdf") then
    wks_type@wkPaperHeightF = 40
    wks_type@wkPaperWidthF  = 57
  end if
  wks = gsn_open_wks(wks_type,path_out+fname_out_dif)

;---Section to add polylines to map.
    lnres                               = True
    lnres@gsLineColor                   = "gray50"
    lnres@gsLineThicknessF              = 1.0

;---Panel resources
  pnlres                              = True
  pnlres@gsnPanelMainString           = get_header(y,m,d,h,opts)
  pnlres@gsnPanelMainFontHeightF      = 0.012
  pnlres@gsnPanelLabelBar             = True

  pnlres@lbLabelBarOn                 = True
  pnlres@lbTitleString                = get_var_description(varname,opts)
  pnlres@lbTitleFontHeightF           = 0.012
  pnlres@lbLabelFontHeightF           = 0.01
  pnlres@lbBoxEndCapStyle             = "TriangleBothEnds"

  pnlres@pmLabelBarWidthF             = 0.35
  pnlres@pmLabelBarHeightF            = 0.07
  pnlres@pmLabelBarOrthogonalPosF     = -0.02
  pnlres@gsnPanelRight                = 0.992
  pnlres@gsnPanelBottom               = 0.1
  pnlres@gsnPanelDebug                = False

;  pnlres@trGridType            = "TriangularMesh"

;---Set some common resources
  res                       = True
  res@gsnDraw               = False
  res@gsnFrame              = False
  res@tfDoNDCOverlay        = False
  res@gsnAddCyclic          = False
  res@trGridType	    = "TriangularMesh"

;---CONTOUR filled contour plot
  con_res                             = res
  con_res@cnFillOn                    = True
  con_res@cnLinesOn                   = False
  con_res@cnLineLabelsOn              = False
  con_res@cnInfoLabelOn               = False
  con_res@lbLabelBarOn                = False

  set_contour_resources("difPP",con_res,opts)

;---- Obtengo las dimensiones para los graficos:

  dims    = dimsizes(npp_inter)
  nm      = dims(0)
  ny      = dims(1)
  nx      = dims(2)

  map     = new(nm,graphic)
  contour = new(nm,graphic)
  shp     = new(nm,graphic)

  dif     = new((/nm,ny,nx/),float)

  ; hay que especificar lat lon de la variable "dif" que es la que vamos a graficar
  dif!0="ens"      
  dif!1="lat"      
  dif&lat=subp&lat
  dif!2="lon"      
  dif&lon=subp&lon 
  dif&lat@units = "degrees_north"
  dif&lon@units = "degrees_east"



;---Calculate number of columns
  ncols   = nm/nrows
  if(nm%nrows .gt. 0) then
    ncols = ncols + 1
  end if

;---Loop through each member, calculate the difference and draw a panel

  do it=0,nm-1

	; ----Map plot para paneles de ensamble
	  map_res                   = True
	  map_res@gsnDraw           = False
	  map_res@gsnFrame          = False

	  map_res@mpProjection                = "CylindricalEquidistant"
	  map_res@mpLimitMode  = "LatLon"
	  map_res@mpMinLatF    = min(dif&lat)   ; - 1
	  map_res@mpMaxLatF    = max(dif&lat)   ; + 1
	  map_res@mpMinLonF    = min(dif&lon)   ; - 1
	  map_res@mpMaxLonF    = max(dif&lon)   ; + 1

	  map_res@mpFillOn                    = False
	  map_res@mpOutlineOn                 = True
	  map_res@mpDataBaseVersion           = "MediumRes"
	  map_res@mpDataSetName               = "Earth..4"
	  map_res@mpOutlineDrawOrder          = "PostDraw"

	  map_res@mpOutlineBoundarySets       = "National"
	  map_res@mpNationalLineColor         = "Black"
	  map_res@mpGeophysicalLineColor      = "Black"
	  map_res@mpNationalLineThicknessF    = 1.5
	  map_res@mpGeophysicalLineThicknessF = 1.5

	  map_res@tmXBLabelFontHeightF        = 0.012
	  map_res@tmXTLabelFontHeightF        = 0.012
	  map_res@tmYLLabelFontHeightF        = 0.012
	  map_res@tmYRLabelFontHeightF        = 0.012
	  map_res@tmYRLabelJust               = "CenterCenter"
	  map_res@tmYLLabelJust               = "CenterCenter"
	  map_res@tmYRLabelAngleF             = 90
	  map_res@tmYLLabelAngleF             = 90

	  map_res@tmBorderThicknessF          = 0.1
	  map_res@tmXBMajorThicknessF         = 0.1
	  map_res@tmXTMajorThicknessF         = 0.1
	  map_res@tmYRMajorThicknessF         = 0.1
	  map_res@tmYLMajorThicknessF         = 0.1

	  map_res@pmTickMarkDisplayMode       = "Always"


    if (it .lt. ncols) then
      map_res@tmXTLabelsOn = True
      map_res@tmXTOn       = True
    else
      map_res@tmXTLabelsOn = False
      map_res@tmXTOn       = False
    end if

    if (it .ge. ncols*(nrows-1)) then
      map_res@tmXBLabelsOn = True
      map_res@tmXBOn       = True
    else
      map_res@tmXBLabelsOn = False
      map_res@tmXBOn       = False
    end if

    if (it%ncols .eq. 0) then
      map_res@tmYLLabelsOn = True
      map_res@tmYLOn       = True
    else
      map_res@tmYLLabelsOn = False
      map_res@tmYLOn       = False
    end if

    if (it%ncols .eq. ncols-1 .or. it .eq. nm-1) then
      map_res@tmYRLabelsOn = True
      map_res@tmYROn       = True
    else
      map_res@tmYRLabelsOn = False
      map_res@tmYROn       = False
    end if

    dif(it,:,:)     = npp_inter(it,:,:)-subp

    map(it)     = gsn_csm_map(wks,map_res)

    shp(it)     = gsn_add_shapefile_polylines(wks,map(it),"interprovincial/interprovinciales.shp",lnres)
    contour(it) = gsn_csm_contour(wks,dif(it,:,:),con_res)

    ;---Overlay plots on map and draw.
    overlay(map(it),contour(it))
  end do

  gsn_panel(wks,map,(/nrows,ncols/),pnlres)

  if(wks_type.eq."png") then
    system("convert -trim "           + \
           path_out+fname_out_dif+".png " + \
           path_out+fname_out_dif+".png ")
  end if

;########------------------------------------
;######## Figura 2: WRF ens
;########------------------------------------

;---Variable long Name for figure title
    output = acuhours + "h Accumulated Precipitation (mm)"
    output = output + " mi" + sprinti("%0.2i", mini) + "mf" + sprinti("%0.2i", mfin)
    opts@description = output

;---Open workstation
  wks_type = "png"
  if(wks_type.eq."png") then
    wks_type@wkWidth  = 2500
    wks_type@wkHeight = 2500
  end if
  if(wks_type.eq."pdf") then
    wks_type@wkPaperHeightF = 40
    wks_type@wkPaperWidthF  = 57
  end if
  wks = gsn_open_wks(wks_type,path_out+fname_out_ens)

;---Set some common resources
  res                       = True
  res@gsnDraw               = False
  res@gsnFrame              = False

;---Using Native projection
  res@tfDoNDCOverlay        = True
  res@gsnAddCyclic          = False

  res@gsnLeftString         = ""
  res@gsnRightString        = ""
  res@gsnCenterString       = ""

;---Map plot
  map_res                   = True
  map_res@gsnDraw           = False
  map_res@gsnFrame          = False
  map_resourcesx60(f,map_res)

;---CONTOUR filled contour plot
  con_res                             = res
  con_res@cnFillOn                    = True
  con_res@cnLinesOn                   = False
  con_res@cnLineLabelsOn              = False
  con_res@cnInfoLabelOn               = False

  con_res@lbLabelBarOn                = False

  set_contour_resources(varname,con_res,opts)

;---Panel resources
  pnlres                              = True
  pnlres@gsnPanelMainString           = get_header(y,m,d,h,opts)
  pnlres@gsnPanelMainFontHeightF      = 0.012
  pnlres@gsnPanelLabelBar             = True

  pnlres@lbLabelBarOn                 = True
  pnlres@lbTitleString                = get_var_description(varname,opts)
  pnlres@lbTitleFontHeightF           = 0.012
  pnlres@lbLabelFontHeightF           = 0.01
  pnlres@lbBoxEndCapStyle             = "TriangleBothEnds"

  pnlres@pmLabelBarWidthF             = 0.35
  pnlres@pmLabelBarHeightF            = 0.07
  pnlres@pmLabelBarOrthogonalPosF     = -0.02
  pnlres@gsnPanelRight                = 0.992
  pnlres@gsnPanelBottom               = 0.1
  pnlres@gsnPanelDebug                = False

;---Section to add polylines to map.
  lnres                               = True
  lnres@gsLineColor                   = "gray50"
  lnres@gsLineThicknessF              = 1.0

  dim_ens    = dimsizes(data)
  nmm        = dim_ens(0)
  nyy        = dim_ens(1)
  nxx        = dim_ens(2)

  map     = new(nmm,graphic)
  contour = new(nmm,graphic)
  shp     = new(nmm,graphic)

;---Calculate number of columns
  ncols   = nmm/nrows
  if(nmm%nrows .gt. 0) then
    ncols = ncols + 1
  end if

;---Loop through each member and draw a panel
  do it=0,nmm-1
    if (it .lt. ncols) then
      map_res@tmXTLabelsOn = True
      map_res@tmXTOn       = True
    else
      map_res@tmXTLabelsOn = False
      map_res@tmXTOn       = False
    end if

    if (it .ge. ncols*(nrows-1)) then
      map_res@tmXBLabelsOn = True
      map_res@tmXBOn       = True
    else
      map_res@tmXBLabelsOn = False
      map_res@tmXBOn       = False
    end if

    if (it%ncols .eq. 0) then
      map_res@tmYLLabelsOn = True
      map_res@tmYLOn       = True
    else
      map_res@tmYLLabelsOn = False
      map_res@tmYLOn       = False
    end if

    if (it%ncols .eq. ncols-1 .or. it .eq. nmm-1) then
      map_res@tmYRLabelsOn = True
      map_res@tmYROn       = True
    else
      map_res@tmYRLabelsOn = False
      map_res@tmYROn       = False
    end if

    map(it)     = gsn_csm_map(wks,map_res)
    contour(it) = gsn_csm_contour(wks,data(it,:,:),con_res)
    shp(it)     = gsn_add_shapefile_polylines(wks,map(it),"interprovincial/interprovinciales.shp",lnres)

    ;---Overlay plots on map and draw.
    overlay(map(it),contour(it))
  end do

  gsn_panel(wks,map,(/nrows,ncols/),pnlres)

  if(wks_type.eq."png") then
    system("convert -trim "           + \
           path_out+fname_out_ens+".png " + \
           path_out+fname_out_ens+".png ")
  end if


;##### LISTO! #####

  end_cpu_time = get_cpu_time()
  print(get_script_prefix_name() + " for " +varname+ ": elapsed time = " + (end_cpu_time-start_cpu_time) + " seconds.")
end
