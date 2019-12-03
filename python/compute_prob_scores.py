'''
Compute RMSE with forecast lead time for each initialization.
'''
import os
import sys
import util as ut
import preprocessing.util_wrf as utwrf
import preprocessing.util_imerg as utimerg
import verification.detcontscores as scores
import time
import numpy as np
import datetime as dt
import matplotlib.pyplot as plt

ACUM = 6                    #Period of accumulation in hours
THRESHOLDS = [1, 5, 10, 25] #Precipitation threshold to compute probability
FCST_INITS = ['00', '12']   #Fcst initializations in UTC (Empty list to use all available)
FCSTLENGTH = 36             #Fcst length in hours

# --------------------------------------------------------- #
basedir = '/home/paula.maldonado/datosalertar1/RRA_VERIF'
DATADIR = basedir + '/data/RRA_6hr_accumulated'
OUTDIR = DATADIR.replace("data","verif_data")
os.makedirs(OUTDIR, exist_ok=True)

start = time.time()

# Initialize variables
fcst_leads = [str(i).zfill(2) for i in np.arange(ACUM, FCSTLENGTH+ACUM, int(FCSTLENGTH/ACUM))]
filelist = ut.get_order_files(FCST_INITS, fcst_leads, DATADIR)

fcst_inits = FCST_INITS + ['all']
wrf = ut.init_dict(fcst_inits, fcst_leads)
obs = ut.init_dict(fcst_inits, fcst_leads) 
det_scores = ut.init_dict(fcst_inits, fcst_leads)

# Loop over fcst lead times 
for finit in FCST_INITS:
   print('===============')
   print('INIT:', finit)
   print('===============')

   for flead in fcst_leads:
      print('FC: ', flead)

      for ifile, cfile in enumerate(filelist[finit][flead]):

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
      wrf[finit][flead] = wrf_bind
      obs[finit][flead] = obs_bind

# Add key with all initializations
for flead in fcst_leads:
   wrfarrays = tuple(wrf[i][flead] for i in FCST_INITS)
   obsarrays = tuple(obs[i][flead] for i in FCST_INITS)

   wrf['all'][flead] = np.concatenate(wrfarrays, axis=0)
   obs['all'][flead] = np.concatenate(obsarrays, axis=0)


# Compute some scores using pysteps
print('------------------------------')
print('Computing GRID-POINT SCORES ')
print('------------------------------')

for finit in fcst_inits:
   print('===============')
   print('INIT:', finit)
   print('===============')

   for flead in fcst_leads:
      print('FC: ', flead)

      # With PYSTEPS
      fcst = wrf[finit][flead]
      imerg = obs[finit][flead]
      det_scores[finit][flead] = scores.det_cont_fct(fcst, imerg, scores="")

# Write data to npz file
fileout = OUTDIR + '/det_scores'
print('Writing file: ', fileout)
np.savez(fileout, scores=det_scores)

end = time.time()

print('')
print('It took ', end-start, ' seconds')
