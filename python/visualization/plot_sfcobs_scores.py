import numpy as np
import matplotlib.pyplot as plt
import cartopy
import cartopy.crs as ccrs
from cartopy.mpl.gridliner import LONGITUDE_FORMATTER, LATITUDE_FORMATTER
from cartopy.feature import NaturalEarthFeature
import matplotlib.ticker as mticker

MODEL = 'gfs'
SFC_SRC = ['SMN', 'SGA']#, 'BOL']
LIMITS = [[-66.5, -61], [-35.5, -29.5]]
LIMITS = []
basedir = '/home/paula.maldonado/datosalertar1/RRA_VERIF'
DATADIR = basedir + '/verif_data/RRA_24hr_accumulated/' + MODEL

# Graphic
size = 8
markers = ['o', '^', 's']
fs_title = 10
fs_axis = 10 
fs_label = 10

states = NaturalEarthFeature(category='cultural', scale='10m', facecolor='none', name='admin_1_states_provinces_lines')
countries = NaturalEarthFeature(category='cultural', scale='10m', facecolor='none', name='admin_0_countries')

fig, ax = plt.subplots(1,2, sharey=True, figsize=[10,5], squeeze=True, subplot_kw=dict(projection=ccrs.PlateCarree()))

# Load WRF lat/lon data
wrf = np.load(basedir + '/data/wrf_lat_lon.npz', mmap_mode='r')
from_grid = [wrf['lon'], wrf['lat']]
if not LIMITS:
  xlimits = [wrf['lon'].min(), wrf['lon'].max()]
  ylimits = [wrf['lat'].min(), wrf['lat'].max()]
  xticks = [-67, -65, -63, -61, -59, -57]
  yticks = [-37, -35, -33, -31, -29, -27, -25]
else:
  xlimits = LIMITS[0]
  ylimits = LIMITS[1]
  xticks = [-66, -64, -62]
  yticks = [-35, -34, -33, -32, -31, -30]

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
   gl.xlocator = mticker.FixedLocator(xticks)
   gl.ylocator = mticker.FixedLocator(yticks)
   gl.xlabel_style = {'size': fs_axis, 'color': 'k'}
   gl.ylabel_style = {'size': fs_axis, 'color': 'k'}
   ax[i].set_xlim(xlimits)
   ax[i].set_ylim(ylimits)

rmse_ave = []
bias_ave = []
for src, ms in zip(SFC_SRC, markers):
  # Load scores data
  data = np.load(DATADIR + '/rmse_bias_sfc_' + src + '.npz')
  lons = data['lon']
  lats = data['lat']
  bias = data['bias']
  rmse = data['rmse']

  if LIMITS:
     bias_used = []
     rmse_used = []
     lons_used = []
     lats_used = []
     for i in range(lons.size):
        if (lons[i] > LIMITS[0][0] and lons[i] < LIMITS[0][1]) and (lats[i] > LIMITS[1][0] and lats[i] < LIMITS[1][1]):
           bias_used.append(bias[i])
           rmse_used.append(rmse[i])
           lons_used.append(lons[i])
           lats_used.append(lats[i])
  else:
     bias_used = bias
     rmse_used = rmse
     lons_used = lons
     lats_used = lats

  rmse_ave.append(np.nanmean(rmse_used))
  bias_ave.append(np.nanmean(bias_used))


  p = ax[0].scatter(lons_used, lats_used, c=bias_used, s=size, marker=ms, cmap='seismic', vmin=-10, vmax=10, zorder=5)
  pc = ax[1].scatter(lons_used, lats_used, c=rmse_used, s=size, marker=ms, cmap='viridis', vmin=0, vmax=20, zorder=5)

plt.colorbar(p, ax=ax[0], shrink=0.8)
plt.colorbar(pc, ax=ax[1], shrink=0.8)
bias_title = [SFC_SRC[i] + '=' + str(np.round(bias_ave[i],2)) for i in range(len(bias_ave))]
rmse_title = [SFC_SRC[i] + '=' + str(np.round(rmse_ave[i],2)) for i in range(len(rmse_ave))]
ax[0].set_title('BIAS \n '+ ('; ').join(bias_title))
ax[1].set_title('RMSE \n '+ ('; ').join(rmse_title))

if len(SFC_SRC) == 1:
  fileout = './figs_scores_' + MODEL + '_sfc_'+ src
else:
  fileout = './figs_scores_' + MODEL + '_sfc_all'

if LIMITS:
  fileout = fileout + '_cba.png'
else:
  fileout = fileout + '.png'

plt.savefig(fileout)
plt.close()

