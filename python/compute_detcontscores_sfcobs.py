'''
Compute deterministic continous scores for each forecasts initialization.
'''
import os
import sys
import util as ut
import common.util as common
import preprocessing.util_wrf as utwrf
import preprocessing.util_sfcobs as utsfc
import verification.detcontscores as detscores
import time
import numpy as np
import glob
import matplotlib.pyplot as plt
import cartopy
import cartopy.crs as ccrs
from cartopy.mpl.gridliner import LONGITUDE_FORMATTER, LATITUDE_FORMATTER
from cartopy.feature import NaturalEarthFeature
import matplotlib.ticker as mticker

MODEL = 'wrf'               #Experiment: wrf, gfs (noda)
SFC_SRC = 'BOL'
FCST_INITS = ['06']         #Fcst initializations in UTC (Empty list to use all available)
ACUM = 24                   #Period of accumulation in hours
FCSTLENGTH = 36             #Fcst length in hours
# --------------------------------------------------------- #
basedir = '/home/paula.maldonado/datosalertar1/RRA_VERIF'
DATADIR = basedir + '/data/RRA_24hr_accumulated'
OUTDIR = DATADIR.replace("data","verif_data") + '/' + MODEL
os.makedirs(OUTDIR, exist_ok=True)

states = NaturalEarthFeature(category='cultural', scale='10m', facecolor='none', name='admin_1_states_provinces_lines')
countries = NaturalEarthFeature(category='cultural', scale='10m', facecolor='none', name='admin_0_boundary_lines_land')
fs_title = 10
fs_axis = 10
fs_label = 10

# Load WRF lat/lon data
wrf = np.load(basedir + '/data/wrf_lat_lon.npz', mmap_mode='r')
from_grid = [wrf['lon'], wrf['lat']]
wrflon1d = wrf['lon'].ravel()
wrflat1d = wrf['lat'].ravel()

print(wrflon1d.shape)
'''
lon = np.zeros(wrf['lon'].size)
lat = np.zeros(wrf['lon'].size)

k=0
for i in range(wrf['lon'].shape[0]):
  for j in range(wrf['lon'].shape[1]):
    lon[k] = wrf['lon'][i,j]
    lat[k] = wrf['lat'][i,j]
    k += 1
wrf= np.zeros(wrf['lon'].size)
'''

start = time.time()

scores = dict()
BIAS = dict()
RMSE = dict()

for subdir, dirs, files in os.walk(DATADIR):
   for dir_ in sorted(dirs):
      cdir = os.path.join(subdir, dir_)
      print('===============')
      print(dir_)
      print('===============')

      if SFC_SRC == 'SMN':
        files_obs = sorted(glob.glob(cdir + '/sfc_SMN*.npz'))
      if SFC_SRC == 'SGA':
        files_obs = sorted(glob.glob(cdir + '/sfc_SGA*.npz'))
      if SFC_SRC == 'BOL':
        files_obs = sorted(glob.glob(cdir + '/sfc_BOL*.npz'))
      if MODEL == 'gfs':
        files_model = sorted(glob.glob(cdir + '/gfs_*.npz'))
      if MODEL == 'wrf':
        files_model = sorted(glob.glob(cdir + '/wrf_*.npz'))

      # Read obs data
      if files_obs and files_model:
       obs = utsfc.read_sfcobs_npz(files_obs[0])
       station = obs['station']
       obslat = obs['lat']
       obslon = obs['lon']
       obsdata = obs['pp']

       # Read and interpolate wrf data to sfcobs points
       wrfdata = utwrf.read_wrf_npz(files_model[0], 'mean')
       #k=0
       #for i in range(wrfdata.shape[0]):
       #  for j in range(wrfdata.shape[1]):
       #    wrf[k] = wrfdata[i,j]
       #    k += 1
       wrf1d = wrfdata.ravel()
       wrf_interp = utsfc.sfc_2_wrf(wrf1d, [wrflon1d, wrflat1d], [obslon, obslat])

       fig, ax = plt.subplots(1,2, sharey=True, figsize=[10,5], squeeze=True, subplot_kw=dict(projection=ccrs.PlateCarree()))

       for i in range(ax.size):
                 ax[i].add_feature(countries, edgecolor='lightgray', linewidth=1., zorder=1)
                 ax[i].add_feature(states, edgecolor='lightgray', linewidth=1., zorder=1)

                 #Axes format
                 gl = ax[i].gridlines(draw_labels=True) #linewidth=2, color='gray', alpha=0.5, linestyle='--'
                 gl.xlabels_top = False
                 gl.ylabels_right = False

                 #Axes labels
                 gl.xlines = False
                 gl.ylines = False
                 gl.xformatter = LONGITUDE_FORMATTER
                 gl.yformatter = LATITUDE_FORMATTER
                 gl.xlocator = mticker.FixedLocator([-67, -65, -63, -61, -59, -57])
                 gl.ylocator = mticker.FixedLocator([-37, -35, -33, -31, -29, -27, -25])
                 gl.xlabel_style = {'size': fs_axis, 'color': 'k'}
                 gl.ylabel_style = {'size': fs_axis, 'color': 'k'}

       max1 = np.nanmean(obsdata)
       max2 = np.nanmean(wrf_interp)
       maxt = max(max1, max2)
       print(maxt)

       p = ax[0].scatter(obslon, obslat, c=obsdata, s=4, cmap='viridis',vmin=0, vmax=maxt)
       pc = ax[1].scatter(obslon, obslat, c=wrf_interp, s=4, cmap='viridis',vmin=0, vmax=maxt)
       plt.colorbar(p, ax=ax[0])
       ax[0].set_xlim(from_grid[0].min(), from_grid[0].max())
       ax[0].set_ylim(from_grid[1].min(), from_grid[1].max())
       plt.colorbar(pc, ax=ax[1])
       ax[1].set_xlim(from_grid[0].min(), from_grid[0].max())
       ax[1].set_ylim(from_grid[1].min(), from_grid[1].max())
       ax[0].set_title('SFC ' + SFC_SRC + ' OBS')
       ax[1].set_title(MODEL.upper())
       plt.suptitle(common.str2date(files_model[0].split('/')[-1].split('_')[1] + '120000'))
       plt.savefig('./figs_compare/' + MODEL + '_sfc_' + SFC_SRC + '_' +  files_model[0].split('/')[-1].split('_')[1] + '.png')
       plt.close()

       diff = wrf_interp - obsdata
       diff2 = diff**2

       for ist, st in enumerate(station):
          if not st in scores.keys():
              scores[st] = {'lon': obslon[ist] , 'lat': obslat[ist], 'diff': [diff[ist]], 'diff2': [diff2[ist]], 'count': 1}
          else:
              scores[st]['diff'].append(diff[ist])
              scores[st]['diff2'].append(diff2[ist])
              scores[st]['count'] += 1
      

bias = []
rmse = []
lons = []
lats = []
for key in scores.keys():
   bias.append(np.nanmean(scores[key]['diff']))
   rmse.append(np.sqrt(np.nanmean(scores[key]['diff2'])))
   lons.append(scores[key]['lon'])
   lats.append(scores[key]['lat'])

# Write data to npz file
print('--------------------------------------')
print('Writing GRID-POINT CATEGORICAL SCORES ')
print('--------------------------------------')
fileout = OUTDIR + '/rmse_bias_sfc_' + SFC_SRC
print('Writing file:', fileout)
np.savez(fileout, bias=bias, rmse=rmse, lon=lons, lat=lats)

end = time.time()

print('')
print('It took ', end-start, ' seconds')
