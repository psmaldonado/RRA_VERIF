'''
Check if the accumulation performed is OK
'''
import h5py as h5py
import numpy as np
import matplotlib.pyplot as plt
import util_imerg as utimerg

basedir = '/home/paula.maldonado/datosalertar1/RRA_VERIF'
datadir = basedir + '/data/imerg_raw'
filename1 = '3B-HHR-L.MS.MRG.3IMERG.20181110-S200000-E202959.1200.V05B.RT-H5'
filename2 = '3B-HHR-L.MS.MRG.3IMERG.20181110-S203000-E205959.1230.V05B.RT-H5'

filepath1 = datadir + '/' + filename1
filepath2 = datadir + '/' + filename2

lats1, lons1, precip1 = utimerg.read_imerg_pp(filepath1, limits=[-37.95, -26.05, -65.95, -57.05])
lats2, lons2, precip2 = utimerg.read_imerg_pp(filepath2, limits=[-37.95, -26.05, -65.95, -57.05])

acum = precip1 + precip2

lon1, lat1 = np.float32(np.meshgrid(lons1, lats1))
lon2, lat2 = np.float32(np.meshgrid(lons2, lats2))

precip1 = np.ma.masked_where(precip1 < 0, precip1)
precip2 = np.ma.masked_where(precip2 < 0, precip2)
acum = np.ma.masked_where(acum < 0, acum)

npzfile = basedir + '/data/imerg_RRA_1hr_accumulated/20181110210000.npz'
data = np.load(npzfile)
lat = data['lat']
lon = data['lon']
pp = data['pp']
pp = np.ma.masked_where(pp < 0, pp)

ax1 = plt.subplot(221)
pc = ax1.pcolormesh(lon, lat, pp)
plt.colorbar(pc)

ax1 = plt.subplot(222)
pc = ax1.pcolormesh(lon1, lat1, acum)
plt.colorbar(pc)

ax2 = plt.subplot(223)
pc = ax2.pcolormesh(lon1, lat1, precip1)
plt.colorbar(pc)

ax3 = plt.subplot(224)
pc = ax3.pcolormesh(lon2, lat2, precip2)
plt.colorbar(pc)

plt.show()


