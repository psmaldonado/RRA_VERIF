'''
Plot deterministic categorical scores for RRA domain.
'''
import os
import sys
sys.path.insert(0, '..')
import util as utio
import time
import numpy as np
import matplotlib.pyplot as plt
from cycler import cycler

SCORES = ['CSI', 'GSS']     #List of scores to plot
ACUM = 6                    #Period of accumulation in hours
THRESHOLDS = [1, 5, 10, 25] #Precipitation threshold to compute probability
FCST_INITS = ['00', '12', 'all']   #Fcst initializations in UTC (Empty list to use all available)
FCSTLENGTH = 36             #Fcst length in hours
FCSTFREQ = 3600             #Fcst output frequency in seconds
DOMAIN = 'RRA'              #Predefined domain to interpolate data to

# --------------------------------------------------------- #
basedir = '/home/paula.maldonado/datosalertar1/RRA_VERIF'
DATADIR = basedir + '/verif_data/RRA_6hr_accumulated'
OUTDIR = DATADIR.replace("verif_data","figures") + '/scores/categorical'
os.makedirs(OUTDIR, exist_ok=True)

# Initialize variables
scores = utio.init_dict(SCORES, FCST_INITS, THRESHOLDS)
fcst_leads = [str(i).zfill(2) for i in np.arange(ACUM, FCSTLENGTH+ACUM, int(FCSTLENGTH/ACUM))]

# Plot variables
colors = ['royalblue', 'tomato', 'k'] 
lw = 2

start = time.time()

# Load data from npz file (we are loading a dict!)
filein = DATADIR + '/det_cat_scores.npz'
data = np.load(filein, mmap_mode='r', allow_pickle=True)['scores'].item()

# Reorganize data to plot
for score in SCORES:
   # Get scores to plot for each initialization
   for finit in FCST_INITS:
       for thr in THRESHOLDS:
          scores[score][finit][thr] = [data[finit][flead][thr][score] for flead in fcst_leads]

# Begin plot
for score in scores.keys():
   # Create figure
   fig, ax = plt.subplots(figsize=[7,5])
   ax.set_prop_cycle(cycler('color', colors))

   for finit in scores[score].keys():
       for thr, ls in zip(scores[score][finit].keys(), ['-', '--', ':', '-.']):
         plt.plot(scores[score][finit][thr], lw=lw, ls=ls)

   #Legend
   ax.plot([], [], color='gray', linewidth=lw, linestyle='-')  #1
   ax.plot([], [], color='gray', linewidth=lw, linestyle='--') #5
   ax.plot([], [], color='gray', linewidth=lw, linestyle=':')  #10
   ax.plot([], [], color='gray', linewidth=lw, linestyle='-.') #25

   lines = ax.get_lines()
   labels = ['INIT ' + str(i) for i in scores[score].keys()]
   extralabels = ['Thr=1mm', 'Thr=5mm', 'Thr=10mm', 'Thr=25mm']
   idx = np.arange(0, len(scores[score].keys())).tolist() + np.arange(-4,0).tolist()

   ax.legend([lines[i] for i in idx], labels + extralabels, \
                loc=2, prop={'size': 10}, edgecolor='k', ncol=2) #bbox_to_anchor=(1.02, 1.1), prop={'size': 10}, edgecolor='k', ncol=2)

   ax.set_ylim([0, 0.7])
   ax.set_xticklabels(['00'] + fcst_leads)
   ax.set_xlabel('Forecast lead time')
   #ax.set_ylabel(str(ACUM) + 'hr accumulated (mm)')
   ax.set_title(score.upper())
  
   # Save figure
   fileout = OUTDIR + '/' + score 
   print('Saving file: ', fileout)
   plt.savefig(fileout + '.png', bbox_inches='tight') 

