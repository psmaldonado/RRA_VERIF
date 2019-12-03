import matplotlib.pyplot as plt
#import plot_util as plot

import numpy as np
from netCDF4 import Dataset
import sys
sys.path.insert(0, '../common/python')
#from ncdump import ncdump

import h5py
import pyresample

datadir = '../../../data'

#****************************************#
# LOAD IMERG DATA
#****************************************#
imergfile1 = '3B-HHR-L.MS.MRG.3IMERG.20181110-S210000-E212959.1260.V05B.RT-H5'
imergfile2 = '3B-HHR-L.MS.MRG.3IMERG.20181110-S213000-E215959.1290.V05B.RT-H5'

for i, ifile in enumerate([imergfile1, imergfile2]):

   imergpath = datadir + '/imerg/' + ifile
   dataset = h5py.File(imergpath, 'r')

   # Load lat, lon and precip data
   lats = dataset['Grid/lat'][:]
   lons = dataset['Grid/lon'][:]
   precip = dataset['Grid/precipitationCal'][:]   #Lon, Lat shape
   precip = np.transpose(precip)

   # Subset of interest (defined by lat(-38;-26) - lon(-66;-57)
   slat_idx = int(np.where(lats == -38.05)[0])
   nlat_idx = int(np.where(lats == -26.05)[0])
   wlon_idx = int(np.where(lons == -65.95)[0])
   elon_idx = int(np.where(lons == -57.05)[0])

   lats = lats[slat_idx:nlat_idx]
   lons = lons[wlon_idx:elon_idx]
   precip = precip[slat_idx:nlat_idx, wlon_idx:elon_idx]

   if i == 0:
      acum = precip
   else:
      acum += precip
print(np.nanmin(acum), np.nanmax(acum))

# Get 2D version of lat and lon variables
lon, lat = np.float32(np.meshgrid(lons, lats))

#****************************************#
# LOAD WRF DATA
#****************************************#
fcst_ini_date = '20181110_18F'
lead_time = 4 

for i, ilead in enumerate([4,3]):
   lead = str(ilead)
   if ilead < 10:
      lead = '0' + lead

   wrffile = 'NPP_2018-11-10_18_FC' + lead +'.nc'
   print(wrffile)

   filename = datadir + '/wrf/' + fcst_ini_date + '/' + wrffile
   f = Dataset(filename)
   #nc_attrs, nc_dims, nc_vars = ncdump(f, verb=False)

   #Load variables
   wrflat = f.variables['XLAT']
   wrflon = f.variables['XLONG']
   wrfpp = f.variables['PP']
  
   if i == 0:
      wrfacum = wrfpp[:, :, :] 
   else:
      wrfacum -= wrfpp[:, :, :] 

print(np.nanmin(wrfacum), np.nanmax(wrfacum))


#*****************************************#
# INTERPOLATE WRF TO IMERG
#*****************************************#
orig = pyresample.geometry.SwathDefinition(lons=wrflon, lats=wrflat)
targ = pyresample.geometry.SwathDefinition(lons=lon, lats=lat)

acum_nearest = pyresample.kd_tree.resample_nearest(orig, wrfacum[0,:,:], \
                           targ, radius_of_influence=50000, fill_value=None)

wf = lambda r: 1/r**2
neig = 5
acum_idw = pyresample.kd_tree.resample_custom(orig, wrfacum[0,:,:], \
                           targ, radius_of_influence=50000, neighbours=neig,\
                           weight_funcs=wf, fill_value=None)

acum_gauss = pyresample.kd_tree.resample_gauss(orig, wrfacum[0,:,:], \
                           targ, radius_of_influence=50000, neighbours=neig,\
                           sigmas=25000, fill_value=None)


fig = plt.figure(figsize=(10,10))

ax = fig.add_subplot(221)
plt.pcolormesh(lon, lat, acum_nearest)
ax.set_title("Nearest neighbor")

ax = fig.add_subplot(222)
plt.pcolormesh(lon, lat, acum_idw)
plt.title("IDW of square distance \n using " + str(neig) + " neighbors");

ax = fig.add_subplot(223)
plt.pcolormesh(lon, lat, acum_gauss)
#ax.imshow(acum_gauss,interpolation='nearest')
plt.title("Gauss-shape of distance (sigma=25km)\n using " + str(neig) + " neighbors");

ax = fig.add_subplot(224)
plt.pcolormesh(wrflon, wrflat, wrfacum[0,:,:])
plt.title("WRF ACUM");

plt.savefig('./interp_neigh' + str(neig) + '.png')


quit()

#Create figure
for mem in range(0, 60):

   fig, ax = plt.subplots(1,2, figsize=[10,8], subplot_kw=dict(projection=ccrs.PlateCarree()))
   plot.set_env(ax[0])
   plot.set_env(ax[1])

   acum = np.ma.masked_where(acum < 0, acum)
   pc = ax[0].pcolormesh(lon, lat, acum, vmin=0.5, vmax=20, transform=ccrs.PlateCarree())
   fig.colorbar(pc, ax=ax[0])

   #Create projction from npp_file
   pc = ax[1].pcolormesh(wrflon, wrflat, wrfacum[mem,:,:], vmin=0.5, vmax=20, transform=ccrs.PlateCarree())
   fig.colorbar(pc, ax=ax[1])

   #Axes properties
   xticks = list(np.arange(-80, -50, 2))
   yticks = list(np.arange(-60, -15, 2))
   #plot.add_ticks(xticks, yticks, fig, ax[0])
   #plot.add_ticks(xticks, yticks, fig, ax[1])


   plt.savefig('./mem_' + str(mem) + '.png', bbox_inches='tight')
   #plt.show()
   plt.close()






