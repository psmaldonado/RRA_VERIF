'''
Compute scores for deterministic continuous forecasts for each initialization.
'''
import os
import sys
import util as ut
import preprocessing.util_wrf as utwrf
import preprocessing.util_imerg as utimerg
import verification.detcontscores as detscores
import time
import numpy as np

ACUM = 6                    #Period of accumulation in hours
THRESHOLDS = [1, 5, 10, 25] #Precipitation threshold to compute probability and fss
SCALES = np.arange(2, np.floor(89/2), 2)  #Number of pixels to compute fss
FCST_INITS = ['00', '12']   #Fcst initializations in UTC (Empty list to use all available)
FCSTLENGTH = 36             #Fcst length in hours

# --------------------------------------------------------- #
basedir = '/home/paula.maldonado/datosalertar1/RRA_VERIF'
DATADIR = basedir + '/data/RRA_6hr_accumulated'
OUTDIR = DATADIR.replace("data","verif_data")
os.makedirs(OUTDIR, exist_ok=True)

start = time.time()

# Initialize variables
fcst_dates = [str(i).zfill(2) for i in np.arange(0,24,6)]  # TODO: hacerlo no a mano
fcst_leads = [str(i).zfill(2) for i in np.arange(ACUM, FCSTLENGTH+ACUM, int(FCSTLENGTH/ACUM))]
filelist = ut.get_order_files(FCST_INITS, fcst_dates, DATADIR, order='hour')

fcst_inits = FCST_INITS + ['all']
wrf = ut.init_dict(fcst_inits, fcst_dates)
obs = ut.init_dict(fcst_inits, fcst_dates) 
wrf_mean = ut.init_dict(fcst_inits, fcst_dates)
obs_mean = ut.init_dict(fcst_inits, fcst_dates)

# Load data from npz files
print('------------------------------')
print('Reading data from npz files   ')
print('------------------------------')

for finit in FCST_INITS:
   for fdate in fcst_dates:
      for ifile, cfile in enumerate(filelist[finit][fdate]):

         # Load data from npz files
         wrfdata = utwrf.read_wrf_npz(cfile[0], 'mean')
         obsdata = utimerg.read_imerg_npz(cfile[1], 'pp')
    
         # Create bind array 
         if ifile == 0:
            wrf_bind = wrfdata
            obs_bind = obsdata
         else:
            wrf_bind = np.concatenate((wrfdata, wrf_bind), axis=0)
            obs_bind = np.concatenate((obsdata, obs_bind), axis=0)

      # Save fcst and obs array
      wrf[finit][fdate] = wrf_bind
      obs[finit][fdate] = obs_bind

# Add key with all initializations
for fdate in fcst_dates:
   wrfarrays = tuple(wrf[i][fdate] for i in FCST_INITS)
   obsarrays = tuple(obs[i][fdate] for i in FCST_INITS)

   wrf['all'][fdate] = np.concatenate(wrfarrays, axis=0)
   obs['all'][fdate] = np.concatenate(obsarrays, axis=0)

# Compute some scores using pysteps
print('------------------------------')
print('Computing PP hourly mean ')
print('------------------------------')

start = time.time()

for finit in fcst_inits:
   print('===============')
   print('INIT:', finit)
   print('===============')

   for fdate in fcst_dates:
      print('FC: ', fdate)

      fcst = wrf[finit][fdate]
      imerg = obs[finit][fdate]

      fcst[fcst < 0.1] = np.nan
      imerg[imerg < 0.1] = np.nan

      wrf_mean[finit][fdate] = np.nanmean(fcst) 
      obs_mean[finit][fdate] = np.nanmean(imerg)

# Write data to npz file
print('------------------------------')
print('Writing GRID-POINT SCORES to: ')
print('------------------------------')

fileout = OUTDIR + '/mean_hour'
print('File:', fileout)
np.savez(fileout, wrf=wrf_mean, obs=obs_mean)

end = time.time()

print('')
print('It took ', end-start, ' seconds')
