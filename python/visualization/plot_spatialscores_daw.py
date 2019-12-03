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

def plt_env(fig, ax, opts):
   yticks = np.round(np.arange(0,1.2,0.2),1)
   fs = opts['fs']
   fstitle = opts['fstitle']
   plt.subplots_adjust(wspace=0, hspace=0.001)

   # Y-axis 
   ax[0].set_ylabel('FSS \n(' + str(opts['acum']) + 'hr accumulated precipitation)', fontsize=fs)
   ax[0].set_ylim([0 ,1])
   ax[0].set_yticklabels(yticks,fontsize=fs)

   # Subplot title
   for i, iax in enumerate(ax):
      iax.set_title(opts['inits'][i] + ' UTC fcst initialization', fontsize=fstitle)
   ax[2].set_title('ALL fcst initialization', fontsize=fstitle)

   return fig, ax

def plt_fss(plt_type, data, alpha, param, fig, ax, opts):

   inits = [*data.keys()]
   thrs = [*data[inits[0]].keys()]
   scales = [*data[inits[0]][thrs[0]].keys()]

   print(scales)

   fs = opts['fs']
   lw = opts['lw']

   if plt_type == 'boxes': 
      x = opts['leads']
      xticks = x
      xlabel = 'Forecast lead time (hs)'
   elif plt_type == 'leads':
      x = opts['scales']
      xticks = opts['xticks']
      xlabel = 'Spatial scale (km)'

   # Plot
   for i, finit in enumerate(inits):
      if len(inits) == 1:
         iax = ax[i+1]
      else:
         iax = ax[i]
         iax.set_xticklabels(xticks, fontsize=fs)
         iax.set_xlabel(xlabel, fontsize=fs)
      for thr, a in zip(thrs, opts['colors']):
         #iax.set_prop_cycle(cycler(color=opts['colors']))#linestyle=opts['linestyles']))
         for scale, b in zip(scales, ['o', 's']): #['8','4']):
            if len(inits) == 1 and plt_type == 'boxes':
               x = opts['leads'][:-1]
               y = data[finit][thr][scale][1:]
            elif plt_type == 'leads':
               y = data[finit][thr][scale][::-1]
            else:
               y = data[finit][thr][scale]
            iax.plot(x, y, lw=lw, color=a, ls=param, alpha=alpha, marker=b)#, markersize=b, color=a, ls=param, alpha=alpha)

   return fig, ax


MODELS = {'wrf': {'init': ['00', '12', 'all'], 'leads': ['06', '18']},
          'gfs': {'init': ['06'], 'leads': ['12', '24']}
}

SCORES = ['FSS']                       #List of scores to plot
TYPE = 'ens'                           #Type of data used to compute score: det (ensemble mean), ens
SCALES = [88, 8]                       #Spatial scales (in pixels) to plot
THRESHOLDS = [1, 25]                   #Thresholds to plot
ACUM = 6                               #Period of accumulation in hours
FCSTLENGTH = 36                        #Fcst length in hours
FCSTFREQ = 3600                        #Fcst output frequency in seconds
DOMAIN = 'RRA'                         #Predefined domain to interpolate data to
FIGTITLE = 'daw' 
# --------------------------------------------------------- #
basedir = '/home/paula.maldonado/datosalertar1/RRA_VERIF'
basedir = basedir + '/verif_data/RRA_6hr_accumulated'
OUTDIR = basedir.replace("verif_data","figures") + '/scores/' + TYPE + '_' + SCORES[0].lower()
os.makedirs(OUTDIR, exist_ok=True)

# Auxiliary vars
npz = TYPE + '_spatial_scores'
pngout = FIGTITLE + '_' + npz
fcst_leads = [str(i).zfill(2) for i in np.arange(ACUM, FCSTLENGTH+ACUM, int(FCSTLENGTH/ACUM))]

# Plot vars
figsize = [15, 5]
plot_opts = {'colors':['tab:green', 'tab:orange', 'tab:red', 'tab:blue'],
        'linestyles': ['-', '--', '-.', ':'],
        'lw': 2,
        'fs': 12,
        'fstitle': 14,
        'xticks': np.arange(-200,1000,200),
        'acum': ACUM,
        'inits': ['00', '12', 'all'],
        'leads': fcst_leads
}

start = time.time()

# Load data and reorganize it to plot
print('---------------------------')
print('LOADING DATA')
print('---------------------------')
for model in MODELS.keys():
   print(model)

   inits = MODELS[model]['init']
   LEADS = MODELS[model]['leads']

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
   leads = ut.init_dict(inits, THRESHOLDS, LEADS)

   # Get scores to plot for each initialization
   for finit in inits:
      for ithr, thr in zip(idxs_th, THRESHOLDS):
         for iscale, scale in zip(idxs_sc, SCALES):
            boxes[finit][thr][scale] = [data[finit][flead][iscale,ithr] for flead in fcst_leads]
         for flead in LEADS:
            leads[finit][thr][flead] = [data[finit][flead][iscale,ithr] for iscale, scale in enumerate(scales)]

   MODELS[model]['boxes'] = boxes
   MODELS[model]['leads'] = leads

# Begin plot
print('---------------------------')
print('PLOTTING SCORES')
print('---------------------------')
# Create figure with varying BOX SIZE
fig, ax = plt.subplots(1, 3, figsize=figsize, sharey=True)
fig, ax = plt_env(fig, ax, plot_opts)

fig, ax = plt_fss('boxes', MODELS['wrf']['boxes'], 1, '-',fig, ax, plot_opts)
fig, ax = plt_fss('boxes', MODELS['gfs']['boxes'], 0.5, '--', fig, ax, plot_opts)

# Legend
# Extra lines for exps
for ls in plot_opts['linestyles'][:len(THRESHOLDS)]:
   ax[0].plot([], [], color='gray', linewidth=plot_opts['lw'], linestyle=ls)
# Extra lines for exps
for ms in ['o','s']: #[8,4]:#plot_opts['linestyles'][:len(THRESHOLDS)]:
   ax[0].plot([], [], color='gray', linewidth=plot_opts['lw'], linestyle='-', marker=ms)#'o', markersize=ms)
# Extra lines for thresholds
for color in plot_opts['colors'][:len(THRESHOLDS)]:
   ax[0].plot([], [], color=color, linewidth=plot_opts['lw'], linestyle='-') 

lines = ax[0].get_lines()
labels = ['DA', 'NoDA', '880km box-size', '80km box-size', '1mm thr', '25mm thr']# '  5mm thr', '10mm thr', '25mm thr']
idx = np.arange(-6,0).tolist()


ax[2].legend([lines[i] for i in idx], labels,loc=4, handlelength=1.8, prop={'size': plot_opts['fs']}, edgecolor='k', ncol=1)#, bbox_to_anchor=(1.55, 0.6))

# Save figure
fileout = OUTDIR + '/' + pngout + '_boxes'
print('Saving file: ', fileout)
plt.savefig(fileout + '.png', bbox_inches='tight') 
plt.close()




# Create figure with varying FCST LEAD TIME
fig, ax = plt.subplots(1, 3, figsize=figsize, sharey=True)
fig, ax = plt_env(fig, ax, plot_opts)

fig, ax = plt_fss('leads', MODELS['wrf']['leads'], 1, '-',fig, ax, plot_opts)
fig, ax = plt_fss('leads', MODELS['gfs']['leads'], 0.5, '--', fig, ax, plot_opts)

# Legend
# Extra lines for exps
for ls in plot_opts['linestyles'][:len(THRESHOLDS)]:
   ax[0].plot([], [], color='gray', linewidth=plot_opts['lw'], linestyle=ls)
# Extra lines for exps
for ms in ['o','s']: #[8,4]:#plot_opts['linestyles'][:len(THRESHOLDS)]:
   ax[0].plot([], [], color='gray', linewidth=plot_opts['lw'], linestyle='-', marker=ms) #'o', markersize=ms)
# Extra lines for thresholds
for color in plot_opts['colors'][:len(THRESHOLDS)]:
   ax[0].plot([], [], color=color, linewidth=plot_opts['lw'], linestyle='-')

lines = ax[0].get_lines()
labels = ['DA', 'NoDA', '6-hr fcst', '18-hr fcst', '1mm thr', '25mm thr']# '  5mm thr', '10mm thr', '25mm thr']
idx = np.arange(-6,0).tolist()


ax[2].legend([lines[i] for i in idx], labels,loc=4, handlelength=1.8, prop={'size': plot_opts['fs']}, edgecolor='k', ncol=1)#, bbox_to_anchor=(1.55, 0.6))

# Save figure
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
