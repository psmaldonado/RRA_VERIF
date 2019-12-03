'''
Plot deterministic categorical scores for RRA domain.
'''
import os
import sys
sys.path.insert(0, '..')
import common.util as utcommon
import util as utio
import time
import numpy as np
import matplotlib.pyplot as plt
from cycler import cycler
import datetime

MODEL = 'gfs'                          #Experiment: wrf, gfs (noda)
FCST_INITS = ['06']
FCST_LEADS = ['12', '18', '24', '30']

MODEL = 'wrf'
FCST_INITS = ['12']   #Fcst initializations in UTC (Empty list to use all available)
FCST_LEADS = ['06', '12', '18', '24']  #Fcst lead times to plot
FCST_LEADS = ['12', '24']
SCORES = ['CSI', 'GSS']                #List of scores to plot
TYPE = 'det'                           #Type of data used to compute score: det (ensemble mean), ens
THRESHOLDS = [1, 25]                   #Thresholds to plot
ACUM = 6                    #Period of accumulation in hours
INITIME = '2018110900'      #Initial time
ENDTIME = '2018122100'      #Final time
FCSTLENGTH = 36             #Fcst length in hours
DOMAIN = 'RRA'              #Predefined domain to interpolate data to
FIGTITLE = MODEL
# --------------------------------------------------------- #
basedir = '/home/paula.maldonado/datosalertar1/RRA_VERIF'
basedir = basedir + '/verif_data/RRA_6hr_accumulated'
DATADIR = basedir + '/' + MODEL
OUTDIR = basedir.replace("verif_data","figures") + '/scores/' + TYPE + '_categorical'
os.makedirs(OUTDIR, exist_ok=True)

# Initialize variables
scores = utio.init_dict(SCORES, FCST_LEADS, THRESHOLDS)
fcst_leads = [str(i).zfill(2) for i in np.arange(ACUM, FCSTLENGTH+ACUM, int(FCSTLENGTH/ACUM))]
fcst_dates = utcommon.get_dates([INITIME, ENDTIME, ACUM*3600], '%Y%m%d%H')

# Plot variables
colors = ['tab:green', 'tab:orange', 'tab:red', 'tab:blue']
lw = 2
#xticks = [fcst_dates[0], datetime.datetime(2018, 11, 15, 0, 0), datetime.datetime(2018, 11, 30, 0, 0), datetime.datetime(2018, 12, 15, 0, 0)]
start = time.time()

# Load data from npz file (we are loading a dict!)
filein = DATADIR + '/det_cat_scores_date.npz'
data = np.load(filein, mmap_mode='r', allow_pickle=True)['scores'].item()

# Reorganize data to plot
for score in SCORES:
   # Get scores to plot for each initialization
   for key1 in FCST_LEADS:
       for thr in THRESHOLDS:
          scores[score][key1][thr] = [data[key1][thr][key2][score] for key2 in [*data[key1][thr]]]


# Begin plot
print('---------------------------')
print('PLOTTING SCORES')
print('---------------------------')

for score in scores.keys():
   # Create figure
   fig, ax = plt.subplots(figsize=[15,5])

   for thr, ls in zip(THRESHOLDS, ['-', '--']):
      for flead, color in zip(FCST_LEADS, colors):
         f_dates = [*data[flead][thr]]
         ax.plot(f_dates, scores[score][flead][thr], lw=lw, color=color, ls=ls)

   #Legend
   ax.plot([], [], color='gray', linewidth=lw, linestyle='-')  #1
   ax.plot([], [], color='gray', linewidth=lw, linestyle='--') #25

   lines = ax.get_lines()
   labels = ['FC ' + str(i) + 'hs' for i in scores[score].keys()]
   extralabels = ['Thr=1mm', 'Thr=25mm']
   idx = np.arange(0, len(FCST_LEADS)).tolist() + np.arange(-len(THRESHOLDS),0).tolist()

   ax.legend([lines[i] for i in idx], labels + extralabels, \
                loc=2, prop={'size': 10}, edgecolor='k', ncol=2) #bbox_to_anchor=(1.02, 1.1), prop={'size': 10}, edgecolor='k', ncol=2)

   ax.set_ylim([-1/3, 1])
   ax.set_xlim([fcst_dates[0], fcst_dates[-1]])
   #ax.set_xticklabels(xticks)
   ax.set_xlabel('UTC Time (hs)')
   ax.set_ylabel(score + '\n (' + str(ACUM) + '-hr accumulated precipitation)')
   fig.autofmt_xdate() 
   # Save figure
   fileout = OUTDIR + '/' + score 
   print('Saving file: ', fileout)
   plt.savefig(fileout + '.png', bbox_inches='tight') 

