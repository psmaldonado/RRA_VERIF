'''
Compute deterministic categorical scores for each forecasts initialization.
'''
import os
import sys
import common.util as utcommon
import util as ut
import preprocessing.util_wrf as utwrf
import preprocessing.util_imerg as utimerg
import verification.detcatscores as detscores
import time
import numpy as np

MODEL = 'gfs'               #Experiment: wrf, gfs (noda)
DATE_INIT = ''            #For date option, specify a single forecast intialization. If empty, FCST_INITS are use.
THRESHOLDS = [1, 5, 10, 25] #Precipitation threshold to yes/no event
ACUM = 6                    #Period of accumulation in hours
INITIME = '2018110900'      #Initial time
ENDTIME = '2018122100'      #Final time
FCSTLENGTH = 36             #Fcst length in hours
ORDER_BY =  ['lead', 'hour', 'date'] #Order fcst data by
# --------------------------------------------------------- #
basedir = '/home/paula.maldonado/datosalertar1/RRA_VERIF'
DATADIR = basedir + '/data/RRA_6hr_accumulated'
OUTDIR = DATADIR.replace("data","verif_data") + '/' + MODEL
os.makedirs(OUTDIR, exist_ok=True)

if MODEL == 'wrf':
   FCST_INITS = ['00', '12']
elif MODEL == 'gfs':
   FCST_INITS = ['06']

start = time.time()

# Initialize variables
if len(FCST_INITS) != 1:
   fcst_inits = FCST_INITS + ['all']
else:
   fcst_inits = FCST_INITS

fcst_leads = [str(i).zfill(2) for i in np.arange(ACUM, FCSTLENGTH+ACUM, int(FCSTLENGTH/ACUM))]
fcst_hours = [str(i).zfill(2) for i in np.arange(0,24,ACUM)]  
fcst_dates = utcommon.get_dates([INITIME, ENDTIME, ACUM*3600], '%Y%m%d%H')
#fcst_dates = [utcommon.date2str(i, '%Y%m%d%H') for i in utcommon.get_dates([INITIME, ENDTIME, ACUM*3600], '%Y%m%d%H')]

for order in ORDER_BY:
   print('*************')
   print(order)
   print('*************')

   # Initialize variables
   dict_key1 = fcst_inits
   if order == 'lead':
      dict_key2 = fcst_leads
   elif order == 'hour':
      dict_key2 = fcst_hours
   elif order == 'date':
      dict_key1 = fcst_leads
      dict_key2 = fcst_dates
      #dict_key2 = None

   if order == 'date' and DATE_INIT:
      filelist = ut.get_order_files(dict_key1, dict_key2, MODEL, DATADIR, order, DATE_INIT)
   else:
      filelist = ut.get_order_files(dict_key1, dict_key2, MODEL, DATADIR, order)

   wrf = ut.init_dict(dict_key1, dict_key2)
   obs = ut.init_dict(dict_key1, dict_key2) 
   scores = ut.init_dict(dict_key1, THRESHOLDS, dict_key2)

   # Load data from npz files
   print('------------------------------')
   print('Reading data from npz files   ')
   print('------------------------------')

   for finit in dict_key1:
      for flead in dict_key2:
         if filelist[finit][flead]:   #Skip if there is no data
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
   if order != 'date' and 'all' in fcst_inits:
      for flead in dict_key2:
         wrfarrays = tuple(wrf[i][flead] for i in FCST_INITS)
         obsarrays = tuple(obs[i][flead] for i in FCST_INITS)

         wrf['all'][flead] = np.concatenate(wrfarrays, axis=0)
         obs['all'][flead] = np.concatenate(obsarrays, axis=0)

   # Compute some scores using pysteps
   print('----------------------------------------')
   print('Computing GRID-POINT CATEGORICAL SCORES ')
   print('----------------------------------------')

   for finit in dict_key1:
      print('=================')
      print('KEY1 : ', finit)
      print('=================')

      for flead in dict_key2:
         if filelist[finit][flead]:   #Skip if there is no data
            print('KEY 2: ', flead)
 
            fcst = wrf[finit][flead]
            imerg = obs[finit][flead]

            for thr in THRESHOLDS:  
               scores[finit][thr][flead] = detscores.det_cat_fct(fcst, imerg, thr, scores=["CSI", "GSS"])

   # Write data to npz file
   print('--------------------------------------')
   print('Writing GRID-POINT CATEGORICAL SCORES ')
   print('--------------------------------------')
   fileout = OUTDIR + '/det_cat_scores_' + order
   print('Writing file:', fileout)
   np.savez(fileout, scores=scores)

end = time.time()

print('')
print('It took ', end-start, ' seconds')
