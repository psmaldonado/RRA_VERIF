'''
Compute IMERG accumulated precipitation for RRA domain.
'''
import os
import util as ut
import util_imerg as utimerg
import time
import h5py as h5py
import numpy as np

INITIME = '20181110000000'
ENDTIME = '20181111000000'
ACUM = 3600 #period of accumulation in seconds
DATAFREQ = 1800 #frequency of files in seconds
DOMAIN = 'RRA'

# --------------------------------------------------------- #
basedir = '/home/paula.maldonado/datosalertar1/RRA_VERIF'
DATADIR = basedir + '/data/imerg_raw'

start = time.time()

#Get a list of files to calculate accumulation 
filelist = utimerg.get_files(DATADIR, INITIME, ENDTIME, ACUM, DATAFREQ)

for key in filelist.keys():
   print('Accumulation time: ', key) 
   acum_pp = 0

   # Compute accumulate
   for ifile, filepath in enumerate(filelist[key]):
      lats, lons, precip = utimerg.read_imerg_pp(filepath, limits=[-37.95, -26.05, -65.95, -57.05]) 
      lon, lat = np.float32(np.meshgrid(lons, lats))
      acum_pp += precip

   # Write data to npz file
   pathout = basedir + '/data/imerg_' + DOMAIN + '_' + str(int(ACUM/3600)) + 'hr_accumulated'
   os.makedirs(pathout, exist_ok=True)
   fileout = pathout + '/' + key
   np.savez(fileout, lat=lat, lon=lon, pp=acum_pp)

end = time.time()

print('')
print('It took ', end-start, ' seconds')

