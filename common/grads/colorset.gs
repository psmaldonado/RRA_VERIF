function colorset(args)

colorset=subwrd(args,1)

if(subwrd(args,1)='')
   help()
   return
endif


if(colorset='NWSRef' | colorset='Reflectivity' | colorset='reflectivity')

*For Reflectivity >= 0
   'set rgb 16 255 255 255'
   'set rgb 17 4 233 231'
   'set rgb 18 1 159 244'
   'set rgb 19 3 0 244'
   'set rgb 20 2 253 2'
   'set rgb 21 1 197 1'
   'set rgb 22 0 142 0'
   'set rgb 23 253 248 2'
   'set rgb 24 229 188 0'
   'set rgb 25 253 149 0'
   'set rgb 26 253 0 0'
   'set rgb 27 212 0 0'
   'set rgb 28 188 0 0'
   'set rgb 29 248 0 253'
   'set rgb 30 152 84 198'
   'set rgb 31 150 17 145'
   'set rgb 32 100 100 100'

   set_plot(-10,70,5)
   
*   say '-------------------------------'
*   say 'Color Scale set to Color Radar Reflectivity.'
*   say '-------------------------------'

endif

if(colorset='NWSVel' | colorset='Velocity' | colorset='velocity')

*Greens
  'set rgbset 16 2 252 2'
  'set rgbset 17 1 228 1'
  'set rgbset 18 1 197 1'
  'set rgbset 19 7 172 4'
  'set rgbset 20 6 143 3'
  'set rgbset 21 4 114 2'
  'set rgbset 22 124 151 123'

*Reds
  'set rgbset 23 152 119 119'
  'set rgbset 24 137 0 0'
  'set rgbset 25 162 0 0'
  'set rgbset 26 185 0 0'
  'set rgbset 27 216 0 0'
  'set rgbset 28 239 0 0'
  'set rgbset 29 254 0 0'

  'set clevs -99 -80 -60 -45 -20 -5 0  5  20 45 60 80 99'
  'set ccols  16  17  18  19  20 21 22 23 24 25 26 27 28 29'

*   say '-------------------------------'
*   say 'Color Scale set to Radial Veloctiy Coloscale.'
*   say '-------------------------------'

endif

if(colorset='Rain' | colorset='rain' | colorset='Wunder1' | colorset='wunder1' | colorset='wunder_rain')

*For Rain
  'set rgb 17 240 240 240'
  'set rgb 18 230 230 230'
  'set rgb 19 220 220 255'
  'set rgb 20 190 190 255'
  'set rgb 21 150 150 255 '
  'set rgb 22 100 100 240 '
  'set rgb 23 70 70 200 '
  'set rgb 24 40 40 150 '
  'set rgb 25 0 120 0 '
  'set rgb 26 0 160 0 '
  'set rgb 27 0 210 0 '
  'set rgb 28 0 240 0'
  'set rgb 29 255 250 0 '
  'set rgb 30 255 200 0 '
  'set rgb 31 255 150 0'
  'set rgb 32 255 70 0'
  'set rgb 33 180 0 0'
  'set rgb 34 90 0 0'
  'set rgb 35 40 0 0'
  'set clevs 0.2 0.5 1 2 3 4 5 6 7 8 9 10 13 16 19 22 25 30'
  'set ccols 0 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35'
*  'set ccols 0 18 20 21 22 23 24 25 26 27 28 29 30'

*   say '-------------------------------'
*   say 'Color Scale set to Rain Coloscale.'
*   say '-------------------------------'

endif

if(colorset='Wrad1' | colorset='wrad1' | colorset='Wunder1' | colorset='wunder1' | colorset='wunder_rain')

*For Reflectivity >= 0

   'set rgb 16 100 100 100'
   'set rgb 17 0 66 11'
   'set rgb 18 2 104 12'
   'set rgb 19 33 152 7'
   'set rgb 20 105 187 7'
   'set rgb 21 176 213 2'
   'set rgb 22 251 253 54'
   'set rgb 23 252 226 2'
   'set rgb 24 255 186 0'
   'set rgb 25 251 136 1'
   'set rgb 26 253 79 3'
   'set rgb 27 245 0 98'
   'set rgb 28 202 12 115'
   'set rgb 29 150 17 145'
   'set rgb 30 115 4 151'
   'set rgb 31 91 1 135'


   set_plot(0,75,5)
   say '-------------------------------'
   say 'Color Scale set to Color Radar Reflectivity (Rain) From Wunderground.'
   say '-------------------------------'

endif

if(colorset='Wrad2' | colorset='wrad2' | colorset='Wunder2' | colorset='wunder2' | colorset='wunder_mix')

*For Reflectivity >= 0

   'set rgb 16 100 100 100'
   'set rgb 17 105 1 82'
   'set rgb 18 119 1 85'
   'set rgb 19 132 1 87'
   'set rgb 20 150 26 105'
   'set rgb 21 168 52 123'
   'set rgb 22 189 71 139'
   'set rgb 23 210 91 156'
   'set rgb 24 220 114 168'
   'set rgb 25 230 137 179'
   'set rgb 26 237 160 193'
   'set rgb 27 245 183 208'
   'set rgb 28 250 201 220'
   'set rgb 29 254 220 232'
   'set rgb 30 254 231 237'
   'set rgb 31 255 238 243'

   set_plot(0,75,5)
   say '-------------------------------'
   say 'Color Scale set to Color Radar Reflectivity (Mixed Precip) From Wunderground.'
   say '-------------------------------'

endif


function set_plot(min,max,int)


    value = min
    cval=16
    c_levs = ''
    c_cols = ''

    while( value <= max )
      c_levs = c_levs ' ' value
      c_cols = c_cols ' ' cval
      value = value + int
      cval=cval+1
    endwhile
    c_cols=c_cols' 'cval-1

*    say '-------------------------------'
*    say 'Contour levels set to: 'c_levs
*    say 'Color Values set to: 'c_cols
*    say '-------------------------------'

    'set clevs 'c_levs
    'set ccols 'c_cols

return

function help()
  say '---------------------------------------------------'
  say '                 colorset v1.2                     '
  say '   New to Version 1.2:                             '
  say '     -Wunderground RADAR reflectivity scales added.'
  say '     -Visible Satellite color scale added.         '
  say '     -Cloud Top Height color scale added.
  say '---------------------------------------------------'
  say 'Usage:'
  say 'colorset scale'
  say 'Required: scale '
  say '          -A call with no specified scale will bring up this help page.'
  say '---------------------------------------------------'
  say ''
  say 'Currently Available Color Scales:'
  say '                 -Watervapor (ucar): Vapor(v)'
  say '                 -Color IR (ucar): Infrared1(IR1)'
  say '                 -Funktop IR (NOAA): Funktop(IR2)'
  say '                 -Color Enhanced IR: Infrared3(IR3)'
  say '                 -AVN IR Scale (NOAA) :AVN (IR4)'
  say '                 -Cloud Top Height (ucar) :CTH (Cloud_Height)'
  say '                 -Visible Satellite Scale (NOAA) :Visible (vis) - CLASS Visible data should be divided by ~175/180 to best fit this scale.'
  say '                 -RADAR Reflectivity (NOAA): Reflectivity (Rad1)'
  say '                 -RADAR Velocity (NOAA): Velocity (Rad2)'
  say '                 -RADAR Reflectivity (Rain) (Wunderground): Wunder1 (Wrad1)'
  say '                 -RADAR Reflectivity (Mix) (Wunderground): Wunder2 (Wrad2)'
  say '                 -RADAR Reflectivity (Snow) (Wunderground): Wunder2 (Wrad3)'
  say ''
  say '---------------------------------------------------'
  say ''
  say 'Example: colorset IR1'
  say '         sets the contour levels and the colors to match the Color IR scale used here: http://weather.rap.ucar.edu/satellite/'
  say 
  say 'Version 1.0: Developed May 2013 | Version 1.2: Updated July 2013'
  say 'Check back at http://gradsaddict.blogspot.com/ in the near future for new color scales'
  say 'Please report any bugs.'
 
**

