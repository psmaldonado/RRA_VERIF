'''
Get lat,lon from IMERG and WRF file and save it to npz file
'''
import numpy as np
import util_imerg as utimerg
import util_wrf as utwrf

imergfile = '3B-HHR-L.MS.MRG.3IMERG.20181110-S200000-E202959.1200.V05B.RT-H5'
wrffile = 'NPP_2018-11-10_00_FC00.nc'


datadir = '/home/paula.maldonado/datosalertar1/RRA_VERIF/data'
imergpath = datadir + '/imerg_raw/' + imergfile
wrfpath = datadir + '/wrf_raw/20181110_00F/' + wrffile

# Read IMERG file and save lat, lon to npz file
lats, lons, precip = utimerg.read_imerg_pp(imergpath, limits=[-37.95, -26.05, -65.95, -57.05])
lon, lat = np.float32(np.meshgrid(lons, lats))
np.savez(datadir + '/imerg_lat_lon.npz', lat=lat, lon=lon)

# Read WRF data and save lat,lon to npz file
lat, lon, pp = utwrf.read_wrf_pp(wrfpath)
np.savez(datadir + '/wrf_lat_lon.npz', lat=lat, lon=lon)

