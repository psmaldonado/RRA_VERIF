'''
Compute deterministic continous scores for each forecasts initialization.
'''
import os
import sys
import util as ut
import preprocessing.util_wrf as utwrf
import preprocessing.util_imerg as utimerg
import verification.detcontscores as detscores
import time
import numpy as np

MODEL = 'wrf'               #Experiment: wrf, gfs (noda)
FCST_INITS = ['00', '12']   #Fcst initializations in UTC (Empty list to use all available)
THRESHOLDS = [1, 5, 10, 25] #Precipitation threshold to yes/no event
ACUM = 6                    #Period of accumulation in hours
FCSTLENGTH = 36             #Fcst length in hours
ORDER_BY = ['lead', 'hour'] #Order fcst data by
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
fcst_dates = [str(i).zfill(2) for i in np.arange(0,24,ACUM)]  

for order in ORDER_BY:
   print('*************')
   print(order)
   print('*************')

   # Initialize variables
   if order == 'lead':
      dict_key2 = fcst_leads
   elif order == 'hour':
      dict_key2 = fcst_dates
   filelist = ut.get_order_files(FCST_INITS, dict_key2, MODEL, DATADIR, order)

   wrf = ut.init_dict(fcst_inits, dict_key2)
   obs = ut.init_dict(fcst_inits, dict_key2) 
   scores = ut.init_dict(fcst_inits, dict_key2)

   # Load data from npz files
   print('------------------------------')
   print('Reading data from npz files   ')
   print('------------------------------')

   for finit in FCST_INITS:
      for flead in dict_key2:
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
   if 'all' in fcst_inits:
      for flead in dict_key2:
         wrfarrays = tuple(wrf[i][flead] for i in FCST_INITS)
         obsarrays = tuple(obs[i][flead] for i in FCST_INITS)

         wrf['all'][flead] = np.concatenate(wrfarrays, axis=0)
         obs['all'][flead] = np.concatenate(obsarrays, axis=0)

   # Compute some scores using pysteps
   print('----------------------------------------')
   print('Computing GRID-POINT CATEGORICAL SCORES ')
   print('----------------------------------------')

   for finit in fcst_inits:
      print('=================')
      print('INIT: ', finit)
      print('=================')

      for flead in dict_key2:
         print('FC: ', flead)

         fcst = wrf[finit][flead]
         imerg = obs[finit][flead]

         scores[finit][flead] = detscores.det_cont_fct(fcst, imerg, scores=["RMSE", "BIAS"]) 

   # Write data to npz file
   print('--------------------------------------')
   print('Writing GRID-POINT CATEGORICAL SCORES ')
   print('--------------------------------------')
   fileout = OUTDIR + '/det_cat_scores_' + order
   print('Writing file:', fileout)
   np.savez(fileout, scores=det_scores)

end = time.time()

print('')
print('It took ', end-start, ' seconds')
