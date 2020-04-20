'''
Compute spatial scores for each parameterization group. 
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

MODEL = 'wrf'                # Experiment: wrf, gfs (noda)
NPARAM = 9                   # Number of parameterization groups
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
group_number = [str(i).zfill(2) for i in range(1, NPARAM+1)] + ['all']
fcst_leads = [str(i).zfill(2) for i in np.arange(ACUM, FCSTLENGTH+ACUM, int(FCSTLENGTH/ACUM))]
filelist = ut.get_order_files(fcst_leads, group_number, MODEL, DATADIR, order='param')

wrf = ut.init_dict(fcst_leads, group_number)
obs = ut.init_dict(fcst_leads, group_number) 
scores = ut.init_dict(group_number, fcst_leads)

# Load data from npz files
print('------------------------------')
print('Reading data from npz files   ')
print('------------------------------')

for flead in fcst_leads:
   print(flead)
   wrf_stack = dict()
   for ifile, cfile in enumerate(filelist[flead]):

      # Load data from npz files
      obsdata = utimerg.read_imerg_npz(cfile[1], 'pp')
      obsdata = np.expand_dims(obsdata, axis=0)
      if ifile == 0:
         obs_stack = obsdata
      else:
         obs_stack = np.concatenate((obs_stack, obsdata), axis=0)

      wrfdata = utwrf.read_wrf_npz(cfile[0], 'pp')
      groups = utwrf.get_param_mems(wrfdata)
      groups['all'] = wrfdata

      for igroup, group in enumerate(groups):
         groups[group] = np.expand_dims(groups[group], axis=0)
  
         key = group_number[igroup]
         # Create bind array 
         if ifile == 0:
            wrf_stack[key] = groups[group]
         else:
            wrf_stack[key] = np.concatenate((wrf_stack[key], groups[group]), axis=0)

   # Save fcst and obs array
   obs[flead] = obs_stack
   wrf[flead] = wrf_stack


# Compute some scores using pysteps
print('------------------------------')
print('Computing SPATIAL SCORES ')
print('------------------------------')

start = time.time()

for flead in fcst_leads:
   print('================')
   print('FC LEAD:', flead)
   print('================')

   for group in group_number:
      print('PARAM GROUP: ', group)

      fcst = wrf[flead][group]
      imerg = obs[flead]
      print(fcst.shape, imerg.shape)

      scores[group][flead] = spatialscores.intensity_scale_3d(fcst, imerg, 'fss', THRESHOLDS, SCALES, ensemble=True)


# Write data to npz file
print('------------------------------')
print('Writing SPATIAL SCORES to: ')
print('------------------------------')

fileout = OUTDIR + '/ens_spatial_scores_parameterization'
print('File:', fileout)
np.savez(fileout, scores=scores, scales=SCALES[::-1], thrs=THRESHOLDS)

end = time.time()

print('')
print('It took ', end-start, ' seconds')
