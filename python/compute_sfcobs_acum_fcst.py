'''
Compute SFC OBS accumulated precipitation for RRA domain.
'''
import os
import sys
import common.util as common
import common.io_archive as io
import util as ut
import preprocessing.util_sfcobs as utsfc
import time
import numpy as np
import datetime as dt
import matplotlib.pyplot as plt
import matplotlib
import cartopy
import cartopy.crs as ccrs
from cartopy.mpl.gridliner import LONGITUDE_FORMATTER, LATITUDE_FORMATTER
from cartopy.feature import NaturalEarthFeature
import matplotlib.ticker as mticker

SFC_SRC = ['SMN', 'SGA', 'BOL']
INITIME = '20181109'        #Initial time
ENDTIME = '20181219'        #Final time
ACUM = 24                   #Period of accumulation in hours
INIACUM = 6
ENDACUM = 30
OBSFREQ = 24*60             #Observation frequency in minutes
FCST_INITS = ['06']        #Fcst initializations in UTC (Empty list to use all available)
FCSTLENGTH = 36             #Fcst length in hours
FCSTFREQ = 3600             #Fcst output frequency in seconds
DOMAIN = 'RRA'              #Predefined domain to interpolate data to

# --------------------------------------------------------- #
basedir = '/home/paula.maldonado/datosalertar1/RRA_VERIF'
DATADIR = basedir + '/data/sfcobs_raw'
OUTDIR = basedir + '/data/' + DOMAIN + '_' + str(ACUM) + 'hr_accumulated'

fs_title = 10
fs_axis = 10
fs_label = 10

start = time.time()

# Set default value for FCST_INITS
if INIACUM is None:
   INIACUM = 0
if ENDACUM is None:
   ENDACUM = FCSTLENGTH

fn_pattern = '%Y%m%d'
fn_extension = 'txt'

# Get list of directories in DATADIR
dirs = [subdir[0].split('/')[-1] for subdir in sorted(os.walk(OUTDIR))][1:]

# Load WRF lat/lon data
wrf = np.load(basedir + '/data/wrf_lat_lon.npz', mmap_mode='r')
to_grid = [wrf['lon'], wrf['lat']]

states = NaturalEarthFeature(category='cultural', scale='10m', facecolor='none', name='admin_1_states_provinces_lines')
countries = NaturalEarthFeature(category='cultural', scale='10m', facecolor='none', name='admin_0_boundary_lines_land')

# Loop over dates
inidate = common.str2date(INITIME, '%Y%m%d')
enddate = common.str2date(ENDTIME, '%Y%m%d')
delta = dt.timedelta(days=1) 
for date in common.datespan(inidate, enddate+delta, delta):
   ctime = common.date2str(date, '%Y%m%d')
   print('====================')
   print(ctime)
   print('====================')
   
   # Loop over forecast initializations
   for src in SFC_SRC:
      print(src)

      # Check if target directory is present
      init = FCST_INITS[0]
      dirname = ctime + '_' + init + 'F'
      if dirname in dirs:
         
         acum_times = list(np.arange(INIACUM, ENDACUM+ACUM, ACUM))
         acum_dates = [date + dt.timedelta(hours=int(init)) + dt.timedelta(hours=int(i)) for i in acum_times]
         acum_fcsts = ['FC' + str(i).zfill(2)  for i in acum_times][1:]

         print(acum_times, acum_dates, acum_fcsts)

         #Get list of files for the ACUM period
         for idate, adate in enumerate(acum_dates[:-1]):
            print(adate)
            filelist = io.find_by_date(adate, DATADIR + '/Datos' + src + '/verif', "", fn_pattern, fn_extension, OBSFREQ)

            # Loop over files
            if filelist[0][0] != None:
             for ifile, filepath in enumerate(filelist[0]):
     
               # Read data
               station, lat, lon, pp = utsfc.read_sfcobs_pp(filepath) # limits=[-37.95, -26.05, -65.95, -57.05])

               # Interpolate to WRF grid
               pp_interp = utsfc.sfc_2_wrf(pp, [lon, lat], to_grid)

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


               p = ax[0].scatter(lon, lat, c=pp, cmap='viridis')
               plt.colorbar(p, ax=ax[0])
               ax[0].set_xlim(to_grid[0].min(), to_grid[0].max())
               ax[0].set_ylim(to_grid[1].min(), to_grid[1].max())
               pc = ax[1].pcolormesh(to_grid[0], to_grid[1], pp_interp)
               plt.colorbar(pc, ax=ax[1])
               ax[1].set_xlim(to_grid[0].min(), to_grid[0].max())
               ax[1].set_ylim(to_grid[1].min(), to_grid[1].max())
               plt.suptitle(acum_dates[1])
               #plt.show()
               plt.savefig('./figs_obs/' + src + '_' + common.date2str(acum_dates[1]) + '.png')
               plt.close()

               # Write data to npz file
               pathout = OUTDIR + '/' + dirname
               os.makedirs(pathout, exist_ok=True)
               fileout = pathout + '/sfc_' + src + '_' + dirname[:-1] + '_' + acum_fcsts[idate]
               print('Writing file: ', fileout)
               np.savez(fileout, station=station, lat=lat, lon=lon, pp=pp)

end = time.time()

print('')
print('It took ', end-start, ' seconds')
