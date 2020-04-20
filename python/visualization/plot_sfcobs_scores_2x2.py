import os
import sys
sys.path.insert(0, '..')
import numpy as np
import matplotlib.pyplot as plt
import cartopy
import cartopy.crs as ccrs
from cartopy.mpl.gridliner import LONGITUDE_FORMATTER, LATITUDE_FORMATTER
from cartopy.feature import NaturalEarthFeature
import matplotlib.ticker as mticker
from common import util as utcom

MODELS = ['wrf', 'gfs']
SFC_SRC = ['SMN', 'SGA', 'BOL']
LIMITS = [[-66.5, -61], [-35.5, -29.5]]
SFC_SRC = ['SMN']
LIMITS = []

basedir = '/home/paula.maldonado/datosalertar1/RRA_VERIF'
DATADIR = basedir + '/verif_data/RRA_24hr_accumulated'
OUTDIR = DATADIR.replace("verif_data","figures") + '/paper/sfc_scores'
os.makedirs(OUTDIR, exist_ok=True)


# Graphic
size = 8
markers = ['o', '^', 's']
fs_title = 12 
fs_axis = 10 
fs_label = 10
letters = utcom.get_alphabet(4, 'bracket2')

states = NaturalEarthFeature(category='cultural', scale='10m', facecolor='none', name='admin_1_states_provinces_lines')
countries = NaturalEarthFeature(category='cultural', scale='10m', facecolor='none', name='admin_0_countries')

# Load WRF lat/lon data
wrf = np.load(basedir + '/data/wrf_lat_lon.npz', mmap_mode='r')
from_grid = [wrf['lon'], wrf['lat']]
if not LIMITS:
  xlimits = [wrf['lon'].min(), wrf['lon'].max()]
  ylimits = [wrf['lat'].min(), wrf['lat'].max()]
  xticks = [-67, -65, -63, -61, -59, -57]
  yticks = [-37, -35, -33, -31, -29, -27, -25]
  figsize = [8.5, 10]
else:
  xlimits = LIMITS[0]
  ylimits = LIMITS[1]
  xticks = [-66, -64, -62]
  yticks = [-35, -34, -33, -32, -31, -30]
  figsize = [9, 10]

fig, ax = plt.subplots(2, 2, figsize=figsize, subplot_kw=dict(projection=ccrs.PlateCarree()))

for i in range(ax.shape[0]):
 for j in range(ax.shape[1]):
   ax[i, j].add_feature(countries, edgecolor='lightgray', linewidth=1., zorder=1)
   ax[i, j].add_feature(states, edgecolor='lightgray', linewidth=1., zorder=1)

   #Axes format
   if j == 0 and i == ax.shape[0]-1:
      #print(i, j, '')
      gl = ax[i, j].gridlines(draw_labels=True) #linewidth=2, color='gray', alpha=0.5, linestyle='--'
      gl.xlabels_top = False
      gl.ylabels_right = False
   elif j == 0 and i != ax.shape[0]:
      gl = ax[i, j].gridlines(draw_labels=True) #linewidth=2, color='gray', alpha=0.5, linestyle='--'
      gl.xlabels_top = False
      gl.xlabels_bottom = False
      gl.ylabels_right = False
   elif i == ax.shape[0]-1 and j != 0:
      gl = ax[i, j].gridlines(draw_labels=True) #linewidth=2, color='gray', alpha=0.5, linestyle='--'
      gl.xlabels_top = False
      gl.ylabels_left = False
      gl.ylabels_right = False
   else:
      gl = ax[i, j].gridlines(draw_labels=False) #linewidth=2, color='gray', alpha=0.5, linestyle='--'

   #Axes labels
   gl.xlines = False
   gl.ylines = False
   gl.xformatter = LONGITUDE_FORMATTER
   gl.yformatter = LATITUDE_FORMATTER
   gl.xlocator = mticker.FixedLocator(xticks)
   gl.ylocator = mticker.FixedLocator(yticks)
   gl.xlabel_style = {'size': fs_axis, 'color': 'k'}
   gl.ylabel_style = {'size': fs_axis, 'color': 'k'}
   ax[i, j].set_xlim(xlimits)
   ax[i, j].set_ylim(ylimits)

for imodel, model in enumerate(MODELS):

 datadir = DATADIR + '/' + model

 rmse_ave = []
 bias_ave = []
 for src, ms in zip(SFC_SRC, markers):
  # Load scores data
  data = np.load(datadir + '/rmse_bias_sfc_' + src + '.npz')
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

  bias_title = [SFC_SRC[i] + '=' + str(np.round(bias_ave[i],2)) for i in range(len(bias_ave))]
  rmse_title = [SFC_SRC[i] + '=' + str(np.round(rmse_ave[i],2)) for i in range(len(rmse_ave))]
  ax[0, imodel].text(0.025, 0.025, ('\n').join(bias_title), va='bottom', ha='left', bbox=dict(facecolor='white', edgecolor='white'), fontsize=fs_label, fontweight='bold', transform=ax[0, imodel].transAxes)
  ax[1, imodel].text(0.025, 0.025, ('\n').join(rmse_title), va='bottom', ha='left', bbox=dict(facecolor='white', edgecolor='white'), fontweight='bold', fontsize=fs_label, transform=ax[1, imodel].transAxes)

  p = ax[0, imodel].scatter(lons_used, lats_used, c=bias_used, s=size, marker=ms, cmap='seismic', vmin=-10, vmax=10, zorder=5)
  pc = ax[1, imodel].scatter(lons_used, lats_used, c=rmse_used, s=size, marker=ms, cmap='viridis', vmin=0, vmax=15, zorder=5)

 #plt.colorbar(p, ax=ax[imodel, 0], shrink=0.8)
 #plt.colorbar(pc, ax=ax[imodel, 1], shrink=0.8)

#Legends
#cbar_labels = np.arange(1, 36, 5)
cbaxes = fig.add_axes([0.91, 0.52, 0.015, 0.34])
cbar = fig.colorbar(p, cax=cbaxes, extend='both')
cbar.cmap.set_under('black')
cbar.cmap.set_over('darkred')
cbar.set_label('[mm]', fontsize=fs_label)
cbar.ax.tick_params(axis='y', direction='in')

#cbar_labels = np.arange(1, 36, 5)
cbaxes = fig.add_axes([0.91, 0.13, 0.015, 0.34])
cbar = fig.colorbar(pc, cax=cbaxes, extend='max')
cbar.cmap.set_over('goldenrod')
cbar.set_label('[mm]', fontsize=fs_label)
cbar.ax.tick_params(axis='y', direction='in')

#Row and column titles
for ilabel, label in enumerate(['RRRA', 'NoRegDA']):
    ax[0, ilabel].set_title(label, fontsize=fs_title)
for imodel, ypos in zip(['BIAS', 'RMSE'], [0.7, 0.3]):
    fig.text(0.05, ypos, imodel, va='center', ha='right', rotation=90, bbox=dict(facecolor='white', edgecolor='white'), fontsize=fs_title)

#Subplot labels
letters = utcom.get_alphabet(ax.size, 'bracket2')
for i in range(ax.shape[0]):
    for j in range(ax.shape[1]):
        ax[i, j].text(0.01, 0.98, letters[ax.shape[1]*i+j], horizontalalignment='left', verticalalignment='top', transform=ax[i, j].transAxes)


#With space between subplots and save
plt.subplots_adjust(wspace=0.02, hspace=0.03)
if len(SFC_SRC) == 1:
  fileout = 'figs_scores_sfc_'+ src
else:
  fileout = 'figs_scores_sfc_all'
if LIMITS:
  fileout = fileout + '_cba'

fileout = OUTDIR + '/' + fileout
print(fileout)
plt.savefig(fileout + '.png', bbox_inches='tight', dpi=200)
plt.savefig(fileout + '.eps', bbox_inches='tight', dpi=200)

plt.close()

