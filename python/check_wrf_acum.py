'''
Check if the accumulation performed is OK
'''
import numpy as np
import matplotlib.pyplot as plt
import util_wrf as utwrf

basedir = '/home/paula.maldonado/datosalertar1/RRA_VERIF'
datadir = basedir + '/data/wrf_raw/20181110_00F'
filename1 = 'NPP_2018-11-10_00_FC09.nc'
filename2 = 'NPP_2018-11-10_00_FC10.nc'

filepath1 = datadir + '/' + filename1
filepath2 = datadir + '/' + filename2

lat1, lon1, precip1 = utwrf.read_wrf_pp(filepath1)
lat2, lon2, precip2 = utwrf.read_wrf_pp(filepath2)
acum = precip2[:,:,:] - precip1[:,:,:]

precip1 = np.ma.masked_where(precip1[:,:,:] < 0, precip1[:,:,:])
precip2 = np.ma.masked_where(precip2[:,:,:] < 0, precip2[:,:,:])
acum = np.ma.masked_where(acum < 0, acum)

npzfile = basedir + '/data/wrf_RRA_1hr_accumulated/20181110_00F/20181110_00_FC10.npz'
data = np.load(npzfile)
lat = data['lat']
lon = data['lon']
pp = data['pp']
pp = np.ma.masked_where(pp < 0, pp)

ax1 = plt.subplot(221)
pc = ax1.pcolormesh(lon, lat, pp[0,:,:])
plt.colorbar(pc)

ax1 = plt.subplot(222)
pc = ax1.pcolormesh(lon1, lat1, acum[0,:,:])
plt.colorbar(pc)

ax2 = plt.subplot(223)
pc = ax2.pcolormesh(lon1, lat1, precip1[0,:,:])
plt.colorbar(pc)

ax3 = plt.subplot(224)
pc = ax3.pcolormesh(lon2, lat2, precip2[0,:,:])
plt.colorbar(pc)

plt.show()


