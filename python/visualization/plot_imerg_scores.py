import numpy as np
import matplotlib.pyplot as plt
import cartopy
import cartopy.crs as ccrs
from cartopy.mpl.gridliner import LONGITUDE_FORMATTER, LATITUDE_FORMATTER
from cartopy.feature import NaturalEarthFeature
import matplotlib.ticker as mticker

MODEL = 'gfs'
basedir = '/home/paula.maldonado/datosalertar1/RRA_VERIF'
DATADIR = basedir + '/verif_data/RRA_24hr_accumulated/' + MODEL + '/rmse_bias_imerg.npz'

# Load scores data
data = np.load(DATADIR)
lons = data['lon']
lats = data['lat']
bias = data['bias']
rmse = data['rmse']
print(bias.shape, lons.shape, lats.shape, rmse.shape)
fs_title = 10
fs_axis = 10 
fs_label = 10

states = NaturalEarthFeature(category='cultural', scale='10m', facecolor='none', name='admin_1_states_provinces_lines')
countries = NaturalEarthFeature(category='cultural', scale='10m', facecolor='none', name='admin_0_boundary_lines_land')

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
   ax[i].set_xlim([lons.min(), lons.max()])
   ax[i].set_ylim([lats.min(), lats.max()])

p = ax[0].pcolormesh(lons, lats, bias, cmap='seismic', vmin=-15, vmax=15, transform=ccrs.PlateCarree())
plt.colorbar(p, ax=ax[0], shrink=0.8)
#ax[0].set_xlim(lons.min(), lons.max())
#ax[0].set_ylim(lats.min(), lats.max())
pc = ax[1].pcolormesh(lons, lats, rmse, cmap='gray_r', vmin=0, vmax=25, transform=ccrs.PlateCarree())
plt.colorbar(pc, ax=ax[1], shrink=0.8)
#ax[1].set_xlim(lons.min(), lats.max())
#ax[1].set_ylim(lons.min(), lats.max())
ax[0].set_title('BIAS')
ax[1].set_title('RMSE')
#plt.show()
plt.savefig('./figs_scores_' + MODEL + '_imerg.png')
plt.close()

