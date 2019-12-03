function  [dist]=distll_fun(alon,alat,blon,blat)

pi=3.14159;
re=6371.3e3;

    lon1 = alon * pi /180;
    lon2 = blon * pi /180;
    lat1 = alat * pi /180;
    lat2 = blat * pi /180;

    cosd = sin(lat1)*sin(lat2) + cos(lat1)*cos(lat2)*cos(lon2-lon1);
    cosd = min([ 1.0 cosd]);
    cosd = max([-1.0 cosd]);

    dist = acos( cosd ) * re;

