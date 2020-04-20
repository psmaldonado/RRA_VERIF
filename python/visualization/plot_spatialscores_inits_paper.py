'''i
Plot fss_ensemble scores for RRA domain for different forecast initializations.
'''
import os
import sys
sys.path.insert(0, '..')
from common import util as utcom
import util as ut
import util_plot as utplot
import time
import numpy as np
import matplotlib.pyplot as plt
from cycler import cycler

def plt_env(fig, ax, opts):
   yticks = np.round(np.arange(0,1.2,0.2),1)
   fs = opts['fs']
   letters = opts['letters']
   fstitle = opts['fstitle']
   plt.subplots_adjust(wspace=0, hspace=0.1)

   # Y-axis 
   k = 0
   for i in range(ax.shape[0]):
     ax[i, 0].set_ylabel('FSS', fontsize=fs)
     ax[i, 0].set_yticklabels(yticks,fontsize=fs)
     for j in range(ax.shape[1]):
        ax[i, j].set_ylim([0 ,1])

        # Subplot title
        ax[i, j].set_title(opts['inits'][k] + ' UTC initialization', fontsize=fstitle, weight='bold')
        ax[i, j].grid(which='both', color='lightgray')
        ax[i, j].text(-0.1, 0.98, letters[k], horizontalalignment='left', verticalalignment='top', fontsize=fstitle)
        k += 1

   return fig, ax

def plt_fss(plt_type, data, alpha, param, fig, ax, opts, used=False):

   inits = [*data.keys()]
   thrs = [*data[inits[0]].keys()]
   scales = [*data[inits[0]][thrs[0]].keys()]

   fs = opts['fs']
   lw = opts['lw']

   if plt_type == 'boxes': 
      x = opts['leads']
      xticks = x
      xlabel = 'Forecast lead time (hrs)'
   elif plt_type == 'leads':
      x = opts['scales']
      xticks = opts['xticks']
      xlabel = 'Spatial scale (km)'

   # Plot
   j = 0
   k = 0
   for i, finit in enumerate(inits):
       if len(inits) == 1:
         if not used:
            iax = ax[0, 1]
         else:
            iax = ax[1, 0]

       else:
         if i == ax.shape[1]:
            j = 1
            k = 0
         iax = ax[j, k]
         if j == 1:
            iax.set_xticklabels(xticks, fontsize=fs)
            iax.set_xlabel(xlabel, fontsize=fs)
         k += 1

       for thr, a in zip(thrs, opts['colors']):
         #iax.set_prop_cycle(cycler(color=opts['colors']))#linestyle=opts['linestyles']))
         for scale, b in zip(scales, ['o', 's']): #['8','4']):
            if used and plt_type == 'boxes':
               x = opts['leads'][:-1]
               y = data[finit][thr][scale][1:]
            elif plt_type == 'leads':
               y = data[finit][thr][scale][::-1]
            else:
               y = data[finit][thr][scale]
            iax.plot(x, y, lw=lw, color=a, ls=param, alpha=alpha, marker=b)#, markersize=b, color=a, ls=param, alpha=alpha)

   return fig, ax


MODELS = {'wrf': {'init': ['00', '06', '12', '18'] },
          'gfs': {'init': ['06']}
}

SCORES = ['FSS']                       #List of scores to plot
TYPE = 'ens'                           #Type of data used to compute score: det (ensemble mean), ens
SCALES = [85, 5]                       #Spatial scales (in pixels) to plot
THRESHOLDS = [1, 25]                   #Thresholds to plot
ACUM = 6                               #Period of accumulation in hours
FCSTLENGTH = 36                        #Fcst length in hours
FCSTFREQ = 3600                        #Fcst output frequency in seconds
DOMAIN = 'RRA'                         #Predefined domain to interpolate data to
FIGTITLE = 'paper' 
# --------------------------------------------------------- #
basedir = '/home/paula.maldonado/datosalertar1/RRA_VERIF'
basedir = basedir + '/verif_data/RRA_6hr_accumulated'
OUTDIR = basedir.replace("verif_data","figures") + '/' + FIGTITLE + '/' + TYPE + '_' + SCORES[0].lower()
os.makedirs(OUTDIR, exist_ok=True)

# Auxiliary vars
npz = TYPE + '_spatial_scores_initializations'
pngout = FIGTITLE + '_' + npz + '_2x2'
fcst_leads = [str(i).zfill(2) for i in np.arange(ACUM, FCSTLENGTH+ACUM, int(FCSTLENGTH/ACUM))]

# Plot vars
figsize = [10, 10]
plot_opts = {'colors':['black', 'gray', 'red', 'lightgrey'],
        'linestyles': ['-', '--', '-.', ':'],
        'lw': 2,
        'fs': 12,
        'fstitle': 14,
        'xticks': np.arange(-200,1000,200),
        'acum': ACUM,
        'inits': ['00', '06', '12', '18'],
        'leads': fcst_leads,
        'letters': utcom.get_alphabet(4, 'bracket2')
}

start = time.time()

# Load data and reorganize it to plot
print('---------------------------')
print('LOADING DATA')
print('---------------------------')
for model in MODELS.keys():
   print(model)

   inits = MODELS[model]['init']

   # Load data from npz file (we are loading a dict!)
   DATADIR = basedir + '/' + model 
   filein = DATADIR + '/' + npz + '.npz'

   data = np.load(filein, mmap_mode='r', allow_pickle=True)['scores'].item()
   scales = np.load(filein, mmap_mode='r')['scales']
   thrs = np.load(filein, mmap_mode='r')['thrs']

   idxs_sc = [scales.tolist().index(i) for i in SCALES]
   idxs_th = [thrs.tolist().index(i) for i in THRESHOLDS]
   plot_opts['scales'] = [i*10 for i in scales[::-1]]

   # Initialize variables
   boxes = ut.init_dict(inits, THRESHOLDS, SCALES)

   # Get scores to plot for each initialization
   for finit in inits:
      for ithr, thr in zip(idxs_th, THRESHOLDS):
         for iscale, scale in zip(idxs_sc, SCALES):
            boxes[finit][thr][scale] = [data[finit][flead][iscale,ithr] for flead in fcst_leads]

   MODELS[model]['boxes'] = boxes

# Begin plot
print('---------------------------')
print('PLOTTING SCORES')
print('---------------------------')
# Create figure with varying BOX SIZE
fig, ax = plt.subplots(2, 2, figsize=figsize, sharey='row', sharex='col')
fig, ax = plt_env(fig, ax, plot_opts)

fig, ax = plt_fss('boxes', MODELS['wrf']['boxes'], 1, '-',fig, ax, plot_opts)
fig, ax = plt_fss('boxes', MODELS['gfs']['boxes'], 1, '--', fig, ax, plot_opts)
fig, ax = plt_fss('boxes', MODELS['gfs']['boxes'], 1, '--', fig, ax, plot_opts, used=True)

# Legend
# Extra lines for exps
for ls in plot_opts['linestyles'][:len(THRESHOLDS)]:
   ax[0, 0].plot([], [], color=plot_opts['colors'][3], linewidth=plot_opts['lw'], linestyle=ls)
# Extra lines for exps
for ms in ['o','s']: #[8,4]:#plot_opts['linestyles'][:len(THRESHOLDS)]:
   ax[0, 0].plot([], [], color=plot_opts['colors'][3], linewidth=plot_opts['lw'], linestyle='-', marker=ms)#'o', markersize=ms)
# Extra lines for thresholds
for color in plot_opts['colors'][:len(THRESHOLDS)]:
   ax[0, 0].plot([], [], color=color, linewidth=plot_opts['lw'], linestyle='-') 

lines = ax[0, 0].get_lines()
labels = ['RRAF', 'NoRegDA'] + [str(i) + '0km box-size' for i in SCALES] + ['1mm thr', '25mm thr']# '  5mm thr', '10mm thr', '25mm thr']
idx = np.arange(-6,0).tolist()
ax[1, 1].legend([lines[i] for i in idx], labels,loc=4, handlelength=1.8, prop={'size': plot_opts['fs']}, edgecolor='k', ncol=3)#, bbox_to_anchor=(1.55, 0.6))

# Save figure
fileout = OUTDIR + '/' + pngout + '_boxes'
print('Saving file: ', fileout)
plt.savefig(fileout + '.png', bbox_inches='tight')
plt.savefig(fileout + '.eps', bbox_inches='tight') 
plt.close()

