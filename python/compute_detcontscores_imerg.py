'''
Compute deterministic continous scores for each forecasts initialization.
'''
import os
import sys
import util as ut
import common.util as common
import preprocessing.util_wrf as utwrf
import preprocessing.util_imerg as utimerg
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
FCST_INITS = ['06']         #Fcst initializations in UTC (Empty list to use all available)
THRESHOLDS = [1, 5, 10, 25] #Precipitation threshold to yes/no event
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

# Load IMERG lat/lon data
imerg = np.load(basedir + '/data/imerg_lat_lon.npz', mmap_mode='r')
to_grid = [imerg['lon'], imerg['lat']]

# Load WRF lat/lon data
wrf = np.load(basedir + '/data/wrf_lat_lon.npz', mmap_mode='r')
from_grid = [wrf['lon'], wrf['lat']]

start = time.time()

scores = dict()
BIAS = dict()
RMSE = dict()

for subdir, dirs, files in os.walk(DATADIR):
   for idir, dir_ in enumerate(sorted(dirs)):
      cdir = os.path.join(subdir, dir_)
      print('===============')
      print(dir_)
      print('===============')
 
      files_obs = sorted(glob.glob(cdir + '/obs_*.npz'))
      if MODEL == 'gfs':
        files_model = sorted(glob.glob(cdir + '/gfs_*.npz'))
      if MODEL == 'wrf':
        files_model = sorted(glob.glob(cdir + '/wrf_*.npz'))

      # Read obs data
      if files_obs and files_model:
       obsdata = utimerg.read_imerg_npz(files_obs[0], 'pp')

       # Read and interpolate wrf data to sfcobs points
       wrfdata = utwrf.read_wrf_npz(files_model[0], 'mean')
       wrf_interp = utwrf.wrf_2_imerg(wrfdata, from_grid, to_grid)

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

       p = ax[0].pcolormesh(to_grid[0], to_grid[1], obsdata, cmap='viridis',vmin=0, vmax=maxt)
       pc = ax[1].pcolormesh(to_grid[0], to_grid[1], wrf_interp, cmap='viridis',vmin=0, vmax=maxt)
       plt.colorbar(p, ax=ax[0])
       ax[0].set_xlim(from_grid[0].min(), from_grid[0].max())
       ax[0].set_ylim(from_grid[1].min(), from_grid[1].max())
       plt.colorbar(pc, ax=ax[1])
       ax[1].set_xlim(from_grid[0].min(), from_grid[0].max())
       ax[1].set_ylim(from_grid[1].min(), from_grid[1].max())
       ax[0].set_title('IMERG')
       ax[1].set_title(MODEL.upper())
       plt.suptitle(common.str2date(files_model[0].split('/')[-1].split('_')[1] + '120000'))
       plt.savefig('./figs_compare/' + MODEL + '_imerg_' +  files_model[0].split('/')[-1].split('_')[1] + '.png')
       plt.close()

       diff = wrf_interp - obsdata
       diff2 = diff**2

       diff = np.expand_dims(diff, axis=2)
       diff2 = np.expand_dims(diff2, axis=2)

       if idir == 0:
         diff_stack = diff
         diff2_stack = diff2
         k = 1
       else:
         diff_stack = np.append(diff_stack, diff, axis=2)
         diff2_stack= np.append(diff2_stack, diff2, axis=2) 


bias = np.nanmean(diff_stack, axis=2)
rmse = np.sqrt(np.nanmean(diff2_stack, axis=2))
lon = to_grid[0]
lat = to_grid[1]

# Write data to npz file
print('--------------------------------------')
print('Writing GRID-POINT CATEGORICAL SCORES ')
print('--------------------------------------')
fileout = OUTDIR + '/rmse_bias_imerg'
print('Writing file:', fileout)
np.savez(fileout, bias=bias, rmse=rmse, lon=lon, lat=lat)

end = time.time()

print('')
print('It took ', end-start, ' seconds')
