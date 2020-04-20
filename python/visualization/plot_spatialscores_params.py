'''i
Plot fss_ensemble scores for RRA domain.
'''
import os
import sys
sys.path.insert(0, '..')
import util as ut
from common import util as utcom
import util_plot as utplot
import time
import numpy as np
import matplotlib.pyplot as plt
from cycler import cycler

def plt_env(fig, ax, opts):
   yticks = np.round(np.arange(0,1.2,0.2),1)
   fs = opts['fs']
   fstitle = opts['fstitle']
   letters = opts['letters']
   plt.subplots_adjust(wspace=0, hspace=0.001)

   # Y-axis 
   k = 0
   for i in range(ax.shape[0]):
     ax[i, 0].set_ylabel('FSS', fontsize=fs)
     ax[i, 0].set_yticklabels(yticks,fontsize=fs)
     for j in range(ax.shape[1]):
        ax[i, j].set_ylim([0 ,1])

        # Subplot title
        ax[i, j].set_title(opts['params'][k], fontsize=fstitle, weight='bold')
        ax[i, j].grid(which='both', color='lightgray')
        ax[i, j].text(-0.1, 0.98, letters[k], horizontalalignment='left', verticalalignment='top', fontsize=fstitle)
        
        k += 1

   return fig, ax

def plt_fss(plt_type, data, alpha, param, fig, ax, opts):

   groups = [*data.keys()]
   thrs = [*data[groups[0]].keys()]
   scales = [*data[groups[0]][thrs[0]].keys()]

   print(scales)

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
   j = 0 # row idx
   k = 0 # col idx
   for i, group in enumerate(groups):
      if len(groups) == 1:
         iax = ax[i+1]
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
            if len(groups) == 1 and plt_type == 'boxes':
               x = opts['leads'][:-1]
               y = data[group][thr][scale][1:]
            elif plt_type == 'leads':
               y = data[group][thr][scale][::-1]
            else:
               y = data[group][thr][scale]
            iax.plot(x, y, lw=lw, color=a, ls=param, alpha=alpha, marker=b)#, markersize=b, color=a, ls=param, alpha=alpha)

   return fig, ax

MODEL = 'wrf'                          #Model run to plot: wrf, gfs
NPARAM = 9                             #Number of parameterization subgroups
SCORES = ['FSS']                       #List of scores to plot
TYPE = 'ens'                           #Type of data used to compute score: det (ensemble mean), ens
LEADS = ['12', '24']                   #Fcst leads times to plot
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
npz = TYPE + '_spatial_scores_parameterization'
pngout = FIGTITLE + '_' + npz
fcst_leads = [str(i).zfill(2) for i in np.arange(ACUM, FCSTLENGTH+ACUM, int(FCSTLENGTH/ACUM))]
group_number = [str(i).zfill(2) for i in range(1, NPARAM+1)] + ['all']

# Plot vars
figsize = [16, 8]
plot_opts = {'colors':['black', 'gray', 'red', 'lightgrey'],
        'linestyles': ['-', '--', '-.', ':'],
        'lw': 2,
        'fs': 12,
        'fstitle': 14,
        'xticks': np.arange(-200,1000,200),
        'acum': ACUM,
        'params': ['KF-YSU', 'BMJ-YSU', 'GF-YSU', 'KF-MYJ', 'BMJ-MYJ', 'GF-MYJ', 'KF-MYNN2', 'BMJ-MYNN2', 'GF-MYNN2', 'ALL'],
        'leads': fcst_leads,
        'letters': utcom.get_alphabet(10, 'bracket2')
}

start = time.time()

# Load data and reorganize it to plot
print('---------------------------')
print('LOADING DATA')
print('---------------------------')

# Load data from npz file (we are loading a dict!)
DATADIR = basedir + '/' + MODEL 
filein = DATADIR + '/' + npz + '.npz'

data = np.load(filein, mmap_mode='r', allow_pickle=True)['scores'].item()
scales = np.load(filein, mmap_mode='r')['scales']
thrs = np.load(filein, mmap_mode='r')['thrs']
print(data.keys())
sys.exit()

idxs_sc = [scales.tolist().index(i) for i in SCALES]
idxs_th = [thrs.tolist().index(i) for i in THRESHOLDS]
plot_opts['scales'] = [i*10 for i in scales[::-1]]

# Initialize variables
boxes = ut.init_dict(group_number, THRESHOLDS, SCALES)
leads = ut.init_dict(group_number, THRESHOLDS, LEADS)

# Get scores to plot for each initialization
for group in group_number:
   for ithr, thr in zip(idxs_th, THRESHOLDS):
      for iscale, scale in zip(idxs_sc, SCALES):
         boxes[group][thr][scale] = [data[group][flead][iscale,ithr] for flead in fcst_leads]
      for flead in LEADS:
         leads[group][thr][flead] = [data[group][flead][iscale,ithr] for iscale, scale in enumerate(scales)]


# Begin plot
print('---------------------------')
print('PLOTTING SCORES')
print('---------------------------')
# Create figure with varying BOX SIZE
fig, ax = plt.subplots(2, 5, figsize=figsize, sharey='row', sharex='col')
fig, ax = plt_env(fig, ax, plot_opts)
fig, ax = plt_fss('boxes', boxes, 1, '-',fig, ax, plot_opts)

# Legend
# Extra lines for exps
#for ls in plot_opts['linestyles'][:len(THRESHOLDS)]:
#   ax[0].plot([], [], color='gray', linewidth=plot_opts['lw'], linestyle=ls)
# Extra lines for exps
for ms in ['o','s']: #[8,4]:#plot_opts['linestyles'][:len(THRESHOLDS)]:
   ax[0, 0].plot([], [], color='lightgray', linewidth=plot_opts['lw'], linestyle='-', marker=ms)#'o', markersize=ms)
# Extra lines for thresholds
for color in plot_opts['colors'][:len(THRESHOLDS)]:
   ax[0, 0].plot([], [], color=color, linewidth=plot_opts['lw'], linestyle='-') 

lines = ax[0, 0].get_lines()
labels = [str(i) + '0km box-size' for i in SCALES] + ['1mm thr', '25mm thr']
idx = np.arange(-4,0).tolist()
ax[1, 4].legend([lines[i] for i in idx], labels,loc=4, handlelength=1.8, prop={'size': plot_opts['fs']}, edgecolor='k', ncol=2)#, bbox_to_anchor=(1.55, 0.6))

# Save figure
plt.subplots_adjust(wspace=0.1, hspace=0.2)
fileout = OUTDIR + '/' + pngout + '_boxes'
print('Saving file: ', fileout)
plt.savefig(fileout + '.png', bbox_inches='tight') 
plt.savefig(fileout + '.eps', bbox_inches='tight')
plt.close()


# Create figure with varying FCST LEAD TIME
fig, ax = plt.subplots(2, 5, figsize=figsize, sharey='row', sharex='col')
fig, ax = plt_env(fig, ax, plot_opts)
fig, ax = plt_fss('leads', leads, 1, '-',fig, ax, plot_opts)

# Legend
# Extra lines for exps
#for ls in plot_opts['linestyles'][:len(THRESHOLDS)]:
#   ax[0].plot([], [], color='gray', linewidth=plot_opts['lw'], linestyle=ls)
# Extra lines for exps
for ms in ['o','s']: #[8,4]:#plot_opts['linestyles'][:len(THRESHOLDS)]:
   ax[0, 0].plot([], [], color='gray', linewidth=plot_opts['lw'], linestyle='-', marker=ms) #'o', markersize=ms)
# Extra lines for thresholds
for color in plot_opts['colors'][:len(THRESHOLDS)]:
   ax[0, 0].plot([], [], color=color, linewidth=plot_opts['lw'], linestyle='-')

lines = ax[0, 0].get_lines()
labels = ['6-hr fcst', '18-hr fcst', '1mm thr', '25mm thr']# '  5mm thr', '10mm thr', '25mm thr']
idx = np.arange(-4,0).tolist()
ax[1, 0].legend([lines[i] for i in idx], labels,loc=4, handlelength=1.8, prop={'size': plot_opts['fs']}, edgecolor='k', ncol=1)#, bbox_to_anchor=(1.55, 0.6))

# Save figure
plt.subplots_adjust(wspace=0.1, hspace=0.2)
fileout = OUTDIR + '/' + pngout + '_leads'
print('Saving file: ', fileout)
plt.savefig(fileout + '.png', bbox_inches='tight') 
plt.close()



'''
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
'''