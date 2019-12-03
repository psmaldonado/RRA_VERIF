import matplotlib.pyplot as plt
import cartopy.crs as ccrs

import numpy as np
from netCDF4 import Dataset
import sys
sys.path.insert(0, '../../common/python')
sys.path.insert(0, '../')
from ncdump import ncdump
import plot_util as plot

import h5py

import boxave as bave


datadir = '../../../data'

#****************************************#
# LOAD IMERG DATA 1-hr accumulation
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

   # Subset of interest
   #Coincide with WRF domain (smallest)
   #lats = lats[520:643]
   #lons = lons[1135:1233]
   #precip = precip[520:643, 1135:1233]

   lats = lats[518:645]
   lons = lons[1140:1229]
   precip = precip[518:645, 1140:1229]


   if i == 0:
      acum = precip
   else:
      acum += precip

print(np.min(acum), np.max(acum))
#acum = np.ma.masked_where(acum < 0, acum)

# Get 2D version of lat and lon variables
lon, lat = np.float32(np.meshgrid(lons, lats))

#****************************************#
# LOAD WRF DATA 1hr accumulation
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
   wrflat = f.variables['XLAT' ]
   wrflon = f.variables['XLONG']
   wrfpp  = f.variables['PP'   ]
  
   if i == 0:
      wrfacum = wrfpp[:, :, :] 
   else:
      wrfacum -= wrfpp[:, :, :] 

#wrfacum[wrfacum < 0] = 0.0
#print(np.min(wrfacum), np.max(wrfacum))


#*****************************************#
# INTERPOLATE WRF TO IMERG
#*****************************************#
#Create dictionaries with neccesary data for boxave input
to_grid = {'lon': lon,
           'lat': lat,
           'dlon': 0.1,
           'dlat': 0.1,
           'nlon': lon.shape[1],
           'nlat': lat.shape[0]}

from_grid = {'lon': wrflon[5:-5, 5:-5],
             'lat': wrflat[5:-5, 5:-5]}

wrf_interp = np.ones((wrfacum.shape[0], to_grid['nlat'], to_grid['nlon'])) * -9999.0
print(np.min(wrf_interp[:, :, :]))

for ie in range(wrfacum.shape[0]):
   print(ie)
   variable = {'data': wrfacum[ie, 5:-5, 5:-5]}
  
   #print('COMPUTING AVERAGE')
   data_interp = bave.compute_grid_boxmean(variable, from_grid, to_grid)
   wrf_interp[ie, :, :] = data_interp
   wrf_interp[ie, :, :][data_interp.mask]=np.nan
   print(np.nanmin(wrf_interp[ie, :, :]))

   #*****************************************#
   # PLOTS
   #*****************************************#
   xticks = list(np.arange(-80, -50, 2))
   yticks = list(np.arange(-60, -15, 2))
   xlim = [np.min(to_grid['lon']), np.max(to_grid['lon'])]
   ylim = [np.min(to_grid['lat']), np.max(to_grid['lat'])]

   fig = plt.figure(figsize=(10,10))
   ax = fig.add_subplot(221)
   pc =plt.pcolormesh(to_grid['lon'], to_grid['lat'], wrf_interp[ie, :, :])#, vmin=0, vmax=20)
   plt.colorbar(pc)
   ax.set_title("WRF BOX AVERAGE")
   ax.set_xlim(xlim)
   ax.set_ylim(ylim)
   #ax.set_xticks(xticks)
   #ax.set_yticks(yticks)

   ax = fig.add_subplot(222)
   pc = plt.pcolormesh(from_grid['lon'], from_grid['lat'], variable['data'])#, vmin=0, vmax=20)
   plt.colorbar(pc)
   plt.title("WRF ACUM")
   ax.set_xlim([np.min(from_grid['lon']), np.max(from_grid['lon'])])
   ax.set_ylim([np.min(from_grid['lat']), np.max(from_grid['lat'])])
   #ax.set_xticks(xticks)
   #ax.set_yticks(yticks)

   ax = fig.add_subplot(223)
   pc = plt.pcolormesh(to_grid['lon'], to_grid['lat'], acum)#, vmin=0, vmax=20)
   plt.colorbar(pc)
   plt.title("IMERG ACUM ")
   ax.set_xlim(xlim)
   ax.set_ylim(ylim)
   #ax.set_xticks(xticks)
   #ax.set_yticks(yticks)

   ax = fig.add_subplot(224)
   pc = plt.pcolormesh(to_grid['lon'], to_grid['lat'], wrf_interp[ie,:,:]-acum)
   plt.colorbar(pc)
   plt.title("WRF INTERP - IMERG")
   ax.set_xlim(xlim)
   ax.set_ylim(ylim)
   #ax.set_xticks(xticks)
   #ax.set_yticks(yticks)

   plt.savefig('./interp_boxave_mem' + str(ie) + '.png')
   plt.close()

quit()

#Create figure
for mem in range(0, 60):

   fig, ax = plt.subplots(1,2, figsize=[10,8], subplot_kw=dict(projection=ccrs.PlateCarree()))
   plot.set_env(ax[0])

   plot.set_env(ax[1])

   acum = np.ma.masked_where(acum < 0, acum)
   pc = ax[0].pcolormesh(lon, lat, acum, vmin=0.5, vmax=20, transform=ccrs.PlateCarree())
   fig.colorbar(pc, ax=ax[0])

   pc = ax[1].pcolormesh(wrflon, wrflat, wrfacum[mem,:,:], vmin=0.5, vmax=20, transform=ccrs.PlateCarree())
   fig.colorbar(pc, ax=ax[1])

   #Axes properties
   xticks = list(np.arange(-80, -50, 2))
   yticks = list(np.arange(-60, -15, 2))
   ax.set_xticks(xticks)
   ax.set_yticks(yticks)

   #plot.add_ticks(xticks, yticks, fig, ax[0])
   #plot.add_ticks(xticks, yticks, fig, ax[1])


   plt.savefig('./mem_' + str(mem) + '.png', bbox_inches='tight')
   #plt.show()
   plt.close()






