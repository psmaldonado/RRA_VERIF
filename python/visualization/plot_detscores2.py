'''
Plot det_scores for RRA domain.
'''
import os
import sys
sys.path.insert(0, '..')
import util as utio
import time
import numpy as np
import matplotlib.pyplot as plt
from cycler import cycler

SCORES = ['RMSE']#'ME', 'MAE', 'MSE', 'NMSE', 'DRMSE', 'RMSE', 'RV'] #List of scores to plot
ACUM = 6                    #Period of accumulation in hours
THRESHOLDS = [1, 5, 10, 25] #Precipitation threshold to compute probability
FCST_INITS = ['00', '12', 'all']   #Fcst initializations in UTC (Empty list to use all available)
FCSTLENGTH = 36             #Fcst length in hours
FCSTFREQ = 3600             #Fcst output frequency in seconds
DOMAIN = 'RRA'              #Predefined domain to interpolate data to

# --------------------------------------------------------- #
basedir = '/home/paula.maldonado/datosalertar1/RRA_VERIF'
DATADIR = basedir + '/verif_data/RRA_6hr_accumulated'
OUTDIR = DATADIR.replace("verif_data","figures") + '/scores'
os.makedirs(OUTDIR, exist_ok=True)

# Initialize variables
scores = utio.init_dict(SCORES, FCST_INITS)
fcst_leads = [str(i).zfill(2) for i in np.arange(ACUM, FCSTLENGTH+ACUM, int(FCSTLENGTH/ACUM))]
fcst_dates = [str(i).zfill(2) for i in np.arange(0,24,6)] 

# Plot variables
colors = ['c', 'm', 'k'] 
lw = 2

start = time.time()

# Load data from npz file (we are loading a dict!)
filein = DATADIR + '/det_scores_hour.npz'
data = np.load(filein, mmap_mode='r')['scores'].item()

# Reorganize data to plot
for score in SCORES:
   # Get scores to plot for each initialization
   for finit in FCST_INITS:
      scores[score][finit] = [data[finit][fdate][score] for fdate in fcst_dates]

# Begin plot
print('---------------------------')
print('PLOT SCORES')
print('---------------------------')
hours = np.arange(0,24,6)

for score in scores.keys():
   # Create figure
   fig, ax = plt.subplots(figsize=[7,5])
   ax.set_prop_cycle(cycler('color', colors))

   for finit in scores[score].keys():
      plt.plot(hours, scores[score][finit], lw=lw, label='INIT_'+finit)

   ax.legend()
   plt.xticks(hours) 
   ax.set_xlabel('UTC Time (hour)')
   ax.set_ylabel(str(ACUM) + 'hr accumulated (mm)')
   ax.set_title(score.upper())
  
   # Save figure
   fileout = OUTDIR + '/' + score + '_hour'
   print('Saving file: ', fileout)
   plt.savefig(fileout + '.png', bbox_inches='tight') 

