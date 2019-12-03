function circle(args)

 clat = subwrd(args,1)
 clon = subwrd(args,2) 
 radius = subwrd(args,3)

 m2deg=1/110574

 deg=radius * m2deg

* find X&Y of circle center
 'q w2xy 'clon' 'clat
 x1=subwrd(result,3)
 y1=subwrd(result,6)

* find X&Y of point center+radius
 radlat=clat+deg
 'q w2xy 'clon' 'radlat
 x2=subwrd(result,3)
 y2=subwrd(result,6)

*circle size = 2 x  radius
 csize=(y2-y1)*2

*draw circle centered on x1,y1 with diameter of csize
 'set line 1 1 8'
 'draw mark 2 'x1' 'y1' 'csize
