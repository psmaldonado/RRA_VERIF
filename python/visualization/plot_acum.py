'''
Plot OBS and WRF acumulated precipitation for RRA domain.
'''
import os
import sys
sys.path.insert(0, '..')
import util as ut
import colormaps as cmaps
import common.util as common
import util_plot as utplot
import time
import numpy as np
import datetime as dt
import matplotlib.pyplot as plt
import cartopy.crs as ccrs

INITIME = '20181109'        #Initial time
ENDTIME = '20181219'        #Final time
MODEL = 'gfs'               #Experiment: wrf, gfs (noda)
ACUM = 6                    #Period of accumulation in hours
THRESHOLDS = [1, 5, 10, 25] #Precipitation threshold to compute probability
FCST_INITS = ['06']#, '12']   #Fcst initializations in UTC (Empty list to use all available)
FCSTLENGTH = 36             #Fcst length in hours
FCSTFREQ = 3600             #Fcst output frequency in seconds
DOMAIN = 'RRA'              #Predefined domain to interpolate data to
# --------------------------------------------------------- #
basedir = '/home/paula.maldonado/datosalertar1/RRA_VERIF'
DATADIR = basedir + '/data/RRA_6hr_accumulated'
OUTDIR = DATADIR.replace("data","figures")

cmap, norm = cmaps.get_colormap('nws_pp')

start = time.time()

# Set default value for FCST_INITS
if not FCST_INITS:
   FCST_INITS = ['00', '03','06', '12', '15', '18', '21']

# Get list of directories in DATADIR
dirs = [subdir[0].split('/')[-1] for subdir in sorted(os.walk(DATADIR))][1:]

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
   for init in FCST_INITS:
      print(init)

      # Check if target directory is present 
      dirname = ctime + '_' + init + 'F'
      if dirname in dirs:
         
         #Get list of files for the ACUM period
         acum_times = list(np.arange(ACUM, FCSTLENGTH+ACUM, int(FCSTLENGTH/ACUM)))
         acum_pattern = ['*FC' + str(i).zfill(2) + '.npz' for i in acum_times]
         path = DATADIR + '/' + dirname

         for i, pattern in enumerate(acum_pattern):
            acum_date = common.date2str(date + dt.timedelta(hours=int(init)) + dt.timedelta(hours=int(pattern[3:5])), '%H:%M:%S %d/%m/%Y')
            print(acum_date)

            filelist = ut.find_by_pattern(pattern, path)

            # Load IMERG and WRF data 
            if MODEL == 'wrf':
               obs = np.load(filelist[0], mmap_mode='r')
               wrf = np.load(filelist[1], mmap_mode='r')
            else:
               obs = np.load(filelist[1], mmap_mode='r')
               wrf = np.load(filelist[0], mmap_mode='r')

            # Create figure
            fig, ax = plt.subplots(1, 2, figsize=[10,6], sharey=True, subplot_kw=dict(projection= ccrs.PlateCarree()))
            
            utplot.set_field(ax[0])
            utplot.set_field(ax[1])

            ax[0].pcolormesh(obs['lon'], obs['lat'], obs['pp'], norm=norm, cmap=cmap)
            ax[0].set_title('OBS - ' +  acum_date)
  
            pc = ax[1].pcolormesh(wrf['lon'], wrf['lat'], wrf['mean'], norm=norm, cmap=cmap)
            ax[1].set_title('WRF - ' + dirname[:-1] + ' ' + pattern[1:5])

            # Add colorbar
            cbaxes = fig.add_axes([0.92, 0.15, 0.015, 0.72])
            cbar = fig.colorbar(pc, cax=cbaxes, extend='both')
            cbar.cmap.set_under('white')
            cbar.cmap.set_over('dimgray')
            cbar.set_label('[mm]', fontsize=10)

            # Save figure
            pathout = OUTDIR + '/' + dirname 
            os.makedirs(pathout, exist_ok=True)
            fileout = pathout + '/' + dirname[:-1] + '_' + pattern[1:5]
            print('Saving file: ', fileout)
            plt.savefig(fileout + '.png', bbox_inches='tight') 
            plt.close()


end = time.time()

print('')
print('It took ', end-start, ' seconds')
