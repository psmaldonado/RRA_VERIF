import matplotlib.pyplot as plt
import cartopy.crs as ccrs
import plot_util as plot

import numpy as np
from netCDF4 import Dataset
import sys
sys.path.insert(0, '../common/python')
from ncdump import ncdump

datadir = '../../data/wrf_raw'
fcst_date = '20181110_18F'

for i in range(0,36):

  lead = str(i)
  if i < 10:
     lead = '0' + lead
  print(lead)

  wrffile = 'NPP_2018-11-10_18_FC' + lead +'.nc'

  filename = datadir + '/' + fcst_date + '/' + wrffile
  f = Dataset(filename)
  nc_attrs, nc_dims, nc_vars = ncdump(f, verb=False)

  #Load variables
  lat = f.variables['XLAT']
  lon = f.variables['XLONG']
  pp = f.variables['PP']
  dbz = f.variables['REFL1KM']

  #Create projction from npp_file
  proj = plot.get_npp_projection('lambert')

  #Create figure
  fig = plt.figure()

  ax = fig.add_subplot(121)
  #plot.set_env(ax)
  #pc = ax.pcolormesh(lon, lat, pp[0,:,:], transform=ccrs.PlateCarree())
  pc = ax.pcolormesh(lon, lat, pp[0,:,:])
  plt.colorbar(pc)

  ax = fig.add_subplot(122)
  #plot.set_env(ax)
  #pc = ax.pcolormesh(lon[5:-5,5:-5], lat[5:-5,5:-5], pp[0, 5:-5,5:-5], transform=ccrs.PlateCarree())
  pc = ax.pcolormesh(lon[5:-5,5:-5], lat[5:-5,5:-5], pp[0, 5:-5,5:-5])
  plt.colorbar(pc)

  #Axes properties
  #xticks = list(np.arange(-68,-54, 2))
  #yticks = list(np.arange(-40, -22, 2))
  #plot.add_lcc_ticks(xticks, yticks, fig, ax) 

  #plt.savefig('./test.png', bbox_inches='tight')
  plt.show()


