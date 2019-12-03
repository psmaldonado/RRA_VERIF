'''i
Plot fss_ensemble scores for RRA domain.
'''
import os
import sys
sys.path.insert(0, '..')
import util as ut
import util_plot as utplot
import time
import numpy as np
import matplotlib.pyplot as plt
from cycler import cycler

MODEL = 'gfs'                          #Experiment: wrf, gfs (noda)
FCST_INITS = ['06']
FCST_LEADS = ['12', '18', '24', '30']

#MODEL = 'wrf'
#FCST_INITS = ['00', '12', 'all']   #Fcst initializations in UTC (Empty list to use all available)
#FCST_LEADS = ['06', '12', '18', '24']  #Fcst lead times to plot

SCORES = ['FSS']                       #List of scores to plot
TYPE = 'ens'                           #Type of data used to compute score: det (ensemble mean), ens
SCALES = [88, 8]                       #Spatial scales (in pixels) to plot
THRESHOLDS = [1, 25]                   #Thresholds to plot
ACUM = 6                               #Period of accumulation in hours
FCSTLENGTH = 36                        #Fcst length in hours
FCSTFREQ = 3600                        #Fcst output frequency in seconds
DOMAIN = 'RRA'                         #Predefined domain to interpolate data to
FIGTITLE = MODEL
# --------------------------------------------------------- #
basedir = '/home/paula.maldonado/datosalertar1/RRA_VERIF'
basedir = basedir + '/verif_data/RRA_6hr_accumulated'
DATADIR = basedir + '/' + MODEL 
OUTDIR = basedir.replace("verif_data","figures") + '/scores/' + TYPE + '_' + SCORES[0].lower()
os.makedirs(OUTDIR, exist_ok=True)

start = time.time()

# Load data from npz file (we are loading a dict!)
npz = TYPE + '_spatial_scores'
pngout = FIGTITLE + '_' + npz

filein = DATADIR + '/' + npz + '.npz'
data = np.load(filein, mmap_mode='r', allow_pickle=True)['scores'].item()
scales = np.load(filein, mmap_mode='r')['scales']
thrs = np.load(filein, mmap_mode='r')['thrs']
idxs = [scales.tolist().index(i) for i in SCALES]

# Plot variables
colors = ['tab:green', 'tab:orange', 'tab:red', 'tab:blue']
linestyles = ['-', '--', '-.', ':']
lw = 2
fs = 12
fstitle = 14
figsize = [5*len(FCST_INITS), 5]
yticks = np.round(np.arange(0,1.2,0.2),1)
xticks = np.arange(-200,1000,200)

# Initialize variables
fcst_leads = [str(i).zfill(2) for i in np.arange(ACUM, FCSTLENGTH+ACUM, int(FCSTLENGTH/ACUM))]
boxes = ut.init_dict(FCST_INITS, thrs, SCALES)
leads = ut.init_dict(FCST_INITS, thrs, FCST_LEADS)

# Reorganize data to plot
# Get scores to plot for each initialization
for finit in FCST_INITS:
   for ithr, thr in enumerate(thrs):
      for iscale, scale in zip(idxs, SCALES):
         boxes[finit][thr][scale] = [data[finit][flead][iscale,ithr] for flead in fcst_leads]
      for flead in FCST_LEADS:
         leads[finit][thr][flead] = [data[finit][flead][iscale,ithr] for iscale, scale in enumerate(scales)]

# Begin plot
print('---------------------------')
print('PLOTTING SCORES')
print('---------------------------')
# Create figure with varying BOX SIZE
fig, ax = plt.subplots(1, len(FCST_INITS), figsize=figsize, sharey=True)
plt.subplots_adjust(wspace=0, hspace=0.001)
if len(FCST_INITS) == 1:
   ax = np.atleast_1d(ax)
ax[0].set_ylabel('FSS \n(' + str(ACUM) + 'hr accumulated precipitation)', fontsize=fs)
ax[0].set_ylim([0 ,1])
ax[0].set_yticklabels(yticks,fontsize=fs)

for i, iax in enumerate(ax):
   iax.set_xticklabels(fcst_leads, fontsize=fs)
   iax.set_xlabel('Forecast lead time (hs)', fontsize=fs)
   if len(FCST_INITS) != 1 and i == len(FCST_INITS):
      iax.set_title('ALL fcst initialization', fontsize=fstitle)
   else:
      iax.set_title(FCST_INITS[i].upper() + ' UTC fcst initialization', fontsize=fstitle)

# Plot
for i, finit in enumerate(FCST_INITS):
   iax = ax[i]
   for thr, ls in zip(boxes[finit].keys(), linestyles):
      iax.set_prop_cycle(cycler(color=colors))
      for scale in SCALES:
         iax.plot(fcst_leads, boxes[finit][thr][scale], lw=lw, ls=ls)

   # Legend
   for ls in linestyles:
      iax.plot([], [], color='gray', linewidth=lw, linestyle=ls)  #1
   if i == 0:
      lines = iax.get_lines()

labels = [str(i*10).zfill(2) + ' km box-size' for i in SCALES]
extralabels = ['  1mm thr', '  5mm thr', '10mm thr', '25mm thr']
idx = np.arange(0, len(SCALES)).tolist() + np.arange(-4,0).tolist()

if len(FCST_INITS) != 1:
   ax[2].legend([lines[i] for i in idx], labels + extralabels, \
      loc=4, handlelength=1.8, prop={'size': fs}, edgecolor='k', ncol=1)#, bbox_to_anchor=(1.55, 0.6))
else:
   ax[0].legend([lines[i] for i in idx], labels + extralabels, \
      loc=4, handlelength=1.8, prop={'size': fs}, edgecolor='k', ncol=1)#, bbox_to_anchor=(1.55, 0.6))

# Save figure
fileout = OUTDIR + '/' + pngout + '_boxes'
print('Saving file: ', fileout)
plt.savefig(fileout + '.png', bbox_inches='tight') 
plt.close()


# Create figure with varying FCST LEAD TIME
fig, ax = plt.subplots(1, len(FCST_INITS), figsize=figsize, sharey=True)
plt.subplots_adjust(wspace=0, hspace=0.001)
if len(FCST_INITS) == 1:
   ax = np.atleast_1d(ax)
ax[0].set_ylabel('FSS \n(' + str(ACUM) + 'hr accumulated precipitation)', fontsize=fs)
ax[0].set_ylim([0 ,1])
ax[0].set_yticklabels(yticks,fontsize=fs)

for i, iax in enumerate(ax):
   iax.set_xticklabels(xticks, fontsize=fs)
   iax.set_xlabel('Spatial scale (km)', fontsize=fs)
   if len(FCST_INITS) != 1 and i == len(FCST_INITS):
      iax.set_title('ALL fcst initialization', fontsize=fstitle)
   else:
      iax.set_title(FCST_INITS[i].upper() + ' UTC fcst initialization', fontsize=fstitle)


xaxis = [i*10 for i in scales[::-1]]
# Plot
for i, finit in enumerate(FCST_INITS):
   iax = ax[i]
   for thr, color in zip(THRESHOLDS, colors[:len(THRESHOLDS)]):
      iax.set_prop_cycle(cycler(linestyle=linestyles))
      for flead in FCST_LEADS:
          iax.plot(xaxis, leads[finit][thr][flead][::-1], lw=lw, color=color)

   #Legend 
   # Extra lines for fcst lead times
   for ls in linestyles:
      iax.plot([], [], color='gray', linewidth=lw, linestyle=ls) 

   # Extra lines for thresholds
   for color in colors[:len(THRESHOLDS)]:
      iax.plot([], [], color=color, linewidth=lw, linestyle='-') 

   if i ==0:
      lines = iax.get_lines()

labels = [str(i) + '-hr fcst' for i in FCST_LEADS]
extralabels = ['  1mm thr', '25mm thr']
idx = np.arange(-6,0).tolist()

if i == 2:
   ax[2].legend([lines[i] for i in idx], labels + extralabels, \
      loc=4, handlelength=1.8, prop={'size': fs}, edgecolor='k', ncol=1)#, bbox_to_anchor=(1.55, 0.6))
else:
   ax[0].legend([lines[i] for i in idx], labels + extralabels, \
      loc=4, handlelength=1.8, prop={'size': fs}, edgecolor='k', ncol=1)#, bbox_to_anchor=(1.55, 0.6))

# Save figure
fileout = OUTDIR + '/' + pngout + '_leads' 
print('Saving file: ', fileout)
plt.savefig(fileout + '.png', bbox_inches='tight')   
plt.close()

