'''
- Compute WRF-NPP data acumulated precipitation for RRA domain.
- Compute WRF-NPP ensemble mean.
- Interpolate WRF-NPP data to IMERG grid.
- Compute probability of exceeding certain thresholds.
'''
import os
import sys
import util as ut
import common.util as common
import preprocessing.util_wrf as utwrf
import preprocessing.ens_stats as ens
import time
import numpy as np
import sys
import datetime as dt

INITIME = '20181109'        #Initial time
ENDTIME = '20181219'        #Final time
MODEL = 'wrf'               #Experiment: wrf, gfs (noda)
ACUM = 24                   #Period of accumulation in hours
INIACUM = 6 
ENDACUM = 30
THRESHOLDS = [1, 5, 10, 25] #Precipitation threshold to compute probability
FCST_INITS = ['06']#, '12']   #Fcst initializations in UTC (Empty list to use all available)
FCSTLENGTH = 36             #Fcst length in hours
FCSTFREQ = 3600             #Fcst output frequency in seconds
DOMAIN = 'RRA'              #Predefined domain to interpolate data to

# --------------------------------------------------------- #
basedir = '/home/paula.maldonado/datosalertar1/RRA_VERIF'
DATADIR = basedir + '/data/' + MODEL + '_raw'

start = time.time()

# Set default value for FCST_INITS
if not FCST_INITS:
   FCST_INITS = ['00', '03','06', '12', '15', '18', '21']
if INIACUM is None:
   INIACUM = 0
if ENDACUM is None:
   ENDACUM = FCSTLENTGH

# Load IMERG lat/lon data
imerg = np.load(basedir + '/data/imerg_lat_lon.npz', mmap_mode='r')
to_grid = [imerg['lon'], imerg['lat']]

# Load WRF lat/lon data
wrf = np.load(basedir + '/data/wrf_lat_lon.npz', mmap_mode='r')
from_grid = [wrf['lon'], wrf['lat']]

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
         acum_times = list(np.arange(INIACUM, ENDACUM+ACUM, ACUM))
         acum_pattern = ['*FC' + str(i).zfill(2) + '.nc' for i in acum_times]

         print(acum_times, acum_pattern)

         path = DATADIR + '/' + dirname
         filelist = [ut.find_by_pattern(i, path) for i in acum_pattern]
         filelist = [x for x in filelist if x]

         print(filelist)

         _, _, old = utwrf.read_wrf_pp(filelist[0])
         # Loop over files
         for filepath in filelist[1:]:
            print(filepath) 
            # Read data
            _, _, pp = utwrf.read_wrf_pp(filepath)

            # Compute accumulate
            acum = pp[:, :, :] - old[:, :, :] 

            # Compute ensemble mean accumulate
            mean = ens.mean(acum)

            # Interpolate to IMERG grid
            acum_interp = utwrf.wrf_2_imerg(acum, from_grid, to_grid)
            mean_interp = utwrf.wrf_2_imerg(mean, from_grid, to_grid)
            #acum_interp = acum
            #mean_interp = mean

            # Compute probability exceeding threshold
            prob = ens.excprob(acum_interp, THRESHOLDS)

            # Write data to npz file
            pathout = basedir + '/data/' + DOMAIN + '_' + str(ACUM) + 'hr_accumulated/' + dirname
            os.makedirs(pathout, exist_ok=True)
            fileout = pathout + '/' + MODEL + '_' + dirname[:-1] + '_' + filepath.split('.')[1][-4:]
            print('Writing file: ', fileout)
            #np.savez(fileout, lat=imerg['lat'], lon=imerg['lon'], pp=acum_interp, mean=mean_interp, prob=prob)
            np.savez(fileout, lat=imerg['lat'], lon=imerg['lon'], pp=acum_interp, mean=mean_interp, prob=prob)

            old = pp

end = time.time()

print('')
print('It took ', end-start, ' seconds')
