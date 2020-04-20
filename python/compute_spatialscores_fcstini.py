'''
Compute spatial scores for each forecast initialization.
Using ensemble members.
'''
import os
import sys
import util as ut
import preprocessing.util_wrf as utwrf
import preprocessing.util_imerg as utimerg
import verification.spatialscores as spatialscores
import time
import numpy as np

MODEL = 'wrf'               #Experiment: wrf, gfs (noda)
FCST_INITS = ['00', '06', '12', '18']   #Fcst initializations in UTC (Empty list to use all available)
#MODEL = 'gfs'
#FCST_INITS = ['06']
THRESHOLDS = [1, 5, 10, 25]  # Precipitation threshold to compute probability and fss
SCALES = np.arange(3, 90, 2) # Number of pixels of box to compute fss
ACUM = 6                     # Period of accumulation in hours
FCSTLENGTH = 36              # Fcst length in hours
# --------------------------------------------------------- #
basedir = '/home/paula.maldonado/datosalertar1/RRA_VERIF'
DATADIR = basedir + '/data/RRA_6hr_accumulated'
OUTDIR = DATADIR.replace("data","verif_data") + '/' + MODEL
os.makedirs(OUTDIR, exist_ok=True)

start = time.time()

# Initialize variables
if len(FCST_INITS) != 1:
   fcst_inits = FCST_INITS + ['all']
else:
   fcst_inits = FCST_INITS

fcst_leads = [str(i).zfill(2) for i in np.arange(ACUM, FCSTLENGTH+ACUM, int(FCSTLENGTH/ACUM))]
filelist = ut.get_order_files(FCST_INITS, fcst_leads, MODEL, DATADIR)

wrf = ut.init_dict(fcst_inits, fcst_leads)
obs = ut.init_dict(fcst_inits, fcst_leads) 
scores = ut.init_dict(fcst_inits, fcst_leads)

# Load data from npz files
print('------------------------------')
print('Reading data from npz files   ')
print('------------------------------')

for finit in FCST_INITS:
   for flead in fcst_leads:
      for ifile, cfile in enumerate(filelist[finit][flead]):

         # Load data from npz files
         wrfdata = utwrf.read_wrf_npz(cfile[0], 'pp')
         obsdata = utimerg.read_imerg_npz(cfile[1], 'pp')

         wrfdata = np.expand_dims(wrfdata, axis=0)
         obsdata = np.expand_dims(obsdata, axis=0)
   
         # Create bind array 
         if ifile == 0:
            wrf_stack = wrfdata
            obs_stack = obsdata
         else:
            wrf_stack = np.concatenate((wrf_stack, wrfdata), axis=0)
            obs_stack = np.concatenate((obs_stack, obsdata), axis=0)

      # Save fcst and obs array
      wrf[finit][flead] = wrf_stack
      obs[finit][flead] = obs_stack

# Add key with all initializations
if 'all' in fcst_inits:
   for flead in fcst_leads:
      wrfarrays = tuple(wrf[i][flead] for i in FCST_INITS)
      obsarrays = tuple(obs[i][flead] for i in FCST_INITS)

      wrf['all'][flead] = np.concatenate(wrfarrays, axis=0)
      obs['all'][flead] = np.concatenate(obsarrays, axis=0)

# Compute some scores using pysteps
print('------------------------------')
print('Computing SPATIAL SCORES ')
print('------------------------------')

start = time.time()

for finit in fcst_inits:
   print('===============')
   print('INIT:', finit)
   print('===============')

   for flead in fcst_leads:
      print('FC: ', flead)

      fcst = wrf[finit][flead]
      imerg = obs[finit][flead]

      scores[finit][flead] = spatialscores.intensity_scale_3d(fcst, imerg, 'fss', THRESHOLDS, SCALES, ensemble=True)


# Write data to npz file
print('------------------------------')
print('Writing SPATIAL SCORES to: ')
print('------------------------------')

fileout = OUTDIR + '/ens_spatial_scores_initializations'
print('File:', fileout)
np.savez(fileout, scores=scores, scales=SCALES[::-1], thrs=THRESHOLDS)

end = time.time()

print('')
print('It took ', end-start, ' seconds')
