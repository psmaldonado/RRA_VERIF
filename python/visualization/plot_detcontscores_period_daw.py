'''
Plot deterministic continous scores for RRA domain.
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

MODELS = {'wrf': {'init': ['12'], 'leads': ['18']},
          'gfs': {'init': ['06'], 'leads': ['24']}
}

ORDER = 'date'
SCORES = ['RMSE', 'ME']                #List of scores to plot
TYPE = 'det'                           #Type of data used to compute score: det (ensemble mean), ens
ACUM = 6                               #Period of accumulation in hours
INITIME = '2018110900'                 #Initial time
ENDTIME = '2018122100'                 #Final time
FCSTLENGTH = 36                        #Fcst length in hours
FCSTFREQ = 3600                        #Fcst output frequency in seconds
DOMAIN = 'RRA'                         #Predefined domain to interpolate data to
FIGTITLE = 'daw'
# --------------------------------------------------------- #
basedir = '/home/paula.maldonado/datosalertar1/RRA_VERIF'
basedir = basedir + '/verif_data/RRA_6hr_accumulated'
OUTDIR = basedir.replace("verif_data","figures") + '/scores/' + TYPE + '_continous'
os.makedirs(OUTDIR, exist_ok=True)

# Auxiliary vars
npz = TYPE + '_cont_scores_' + ORDER 
pngout = FIGTITLE + '_' + npz
fcst_dates = utcommon.get_dates([INITIME, ENDTIME, ACUM*3600], '%Y%m%d%H')
xticks = [datetime.date(i.year, i.month, i.day) for i in  fcst_dates[4:-1:4*5]] 
yticks = np.round(np.arange(0,1.2,0.2),1)

# Plot vars
figsize = [15, 5]
colors = ['tab:green', 'tab:orange', 'tab:red', 'tab:blue']
linestyles = ['-', '--', '-.', ':']
lw = 2
fs = 12
fstitle = 14


start = time.time()

# Load data and reorganize it to plot
print('---------------------------')
print('LOADING DATA')
print('---------------------------')
for model in MODELS.keys():
   print(model)

   LEADS = MODELS[model]['leads']

   # Load data from npz file (we are loading a dict!)
   DATADIR = basedir + '/' + model
   filein = DATADIR + '/' + npz + '.npz'

   data = np.load(filein, mmap_mode='r', allow_pickle=True)['scores'].item()

   # Initialize variables
   scores = utio.init_dict(SCORES, LEADS)
   fdates = utio.init_dict(LEADS)

   # Get scores to plot for each initialization
   for score in SCORES:
      for key1 in LEADS:
          fdates[key1] = [*data[key1]]
          scores[score][key1] = [data[key1][key2][score] for key2 in fdates[key1]]

   MODELS[model]['scores'] = scores
   MODELS[model]['fdates'] = fdates

# Begin plot
print('---------------------------')
print('PLOTTING SCORES')
print('---------------------------')
for score in scores.keys():

   # Create figure with varying BOX SIZE
   fig, ax = plt.subplots(figsize=figsize)

   # Plot
   for model, alpha, ls in zip(MODELS.keys(), [1, 0.5], ['-', '--']):
      LEADS = MODELS[model]['leads']
   
      for flead, ms in zip(LEADS, ['o', '*']):
         ax.plot(MODELS[model]['fdates'][flead], MODELS[model]['scores'][score][flead], lw=lw, alpha=alpha, ls=ls, color='tab:blue')#, marker=ms)

   # Legend
   # Extra lines for exps
   for ls in ['-', '--']:
      ax.plot([], [], color='gray', linewidth=lw, linestyle=ls)
   #for ms in ['o', '*']:#[12,6]:
   #   ax.plot([], [], color='gray', linewidth=lw, linestyle='-', marker=ms)
   # Extra lines for thresholds
   #for color in colors[:len(THRESHOLDS)]:
   #   ax.plot([], [], color=color, linewidth=lw, linestyle='-')

   lines = ax.get_lines()
   labels = ['DA', 'NoDA']#, '6-hr fcst', '18-hr fcst']
   idx = np.arange(-len(labels),0).tolist()
   ax.legend([lines[i] for i in idx], labels,loc=4, handlelength=1.8, prop={'size': fs}, edgecolor='k', ncol=1)#, bbox_to_anchor=(1.55, 0.6))

   fig.text(0.14, 0.82, str(MODELS['wrf']['leads'][0]) + ' UTC fcst initialization', fontsize=fstitle, weight='bold')


   ax.tick_params(axis="y", labelsize=fs)
   ax.tick_params(axis="x", labelsize=fs)
   ax.set_xlabel('UTC Time', fontsize=fs)
   ax.set_ylabel(score + '\n (' + str(ACUM) + '-hr accumulated precipitation)', fontsize=fs)
   fig.autofmt_xdate() 
   ax.grid()

   # Save figure
   fileout = OUTDIR + '/' + score 
   print('Saving file: ', fileout)
   plt.savefig(fileout + '.png', bbox_inches='tight') 
   plt.close()
