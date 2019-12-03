'''
Interpolate WRF-NPP data to IMERG grid.
Compute WRF-NPP data acumulated precipitation for RRA domain.
'''
import os
import util as ut
import util_wrf as utwrf
import time
import numpy as np
import sys

INITIME = '20181110'
ENDTIME = '20181111'
ACUM = 3600        #Period of accumulation in seconds
FCSTINIT = 3*3600  #Fcst initialization frequency in seconds
FCSTFREQ = 3600    #Fcst output frequency in seconds
DOMAIN = 'RRA'

# --------------------------------------------------------- #
basedir = '/home/paula.maldonado/datosalertar1/RRA_VERIF'
DATADIR = basedir + '/data/wrf_raw'

start = time.time()

# Load IMERG lat/lon data
imerg = np.load(basedir + '/data/imerg_lat_lon.npz', mmap_mode='r')
to_grid = [imerg['lon'], imerg['lat']]

# Load WRF lat/lon data
wrf = np.load(basedir + '/data/wrf_lat_lon.npz', mmap_mode='r')
from_grid = [wrf['lon'], wrf['lat']]

# Loop over files and directores
for subdir, dirs, files in sorted(os.walk(DATADIR)):
   fcst_init = subdir.split('/')[-1]
   print(fcst_init)

   filelist = []
   # Get files for each forecast initialization
   for filename in sorted(files):
      filelist.append(os.path.join(subdir, filename))

   # Loop over files
   for ifile, filepath in enumerate(filelist):
      print(filepath)
     
      # Read data
      lat, lon, pp = utwrf.read_wrf_pp(filepath)

      # Compute accumulate
      if ifile != 0:
         acum = pp[:, :, :] - old[:, :, :] 
      old = pp

      if ifile !=0:
         # Interpolate to IMERG grid
         acum_interp = utwrf.wrf_2_imerg(acum, from_grid, to_grid)

         # Write data to npz file
         pathout = basedir + '/data/wrf_' + DOMAIN + '_' + str(int(ACUM/3600)) + 'hr_accumulated/' + fcst_init 
         os.makedirs(pathout, exist_ok=True)
         fileout = pathout + '/' + fcst_init[:-1] + '_' + filepath.split('.')[1][-4:] 
         np.savez(fileout, lat=imerg['lat'], lon=imerg['lon'], pp=acum_interp)

end = time.time()

print('')
print('It took ', end-start, ' seconds')
