'''
Compute IMERG accumulated precipitation for RRA domain.
'''
import os
import sys
import common.util as common
import common.io_archive as io
import util as ut
import preprocessing.util_imerg as utimerg
import time
import numpy as np
import datetime as dt

INITIME = '20181109'        #Initial time
ENDTIME = '20181219'        #Final time
ACUM = 24                    #Period of accumulation in hours
OBSFREQ = 30                #Observation frequency in minutes
INIACUM = 6
ENDACUM = 30
THRESHOLDS = [1, 5, 10, 25] #Precipitation threshold to compute probability
FCST_INITS = ['06']#, '12']   #Fcst initializations in UTC (Empty list to use all available)
FCSTLENGTH = 36             #Fcst length in hours
FCSTFREQ = 3600             #Fcst output frequency in seconds
DOMAIN = 'RRA'              #Predefined domain to interpolate data to

# --------------------------------------------------------- #
basedir = '/home/paula.maldonado/datosalertar1/RRA_VERIF'
DATADIR = basedir + '/data/imerg_raw'
OUTDIR = basedir + '/data/' + DOMAIN + '_' + str(ACUM) + 'hr_accumulated'

fn_pattern = '3B-HHR-L.MS.MRG.3IMERG.%Y%m%d-S%H%M00-E??????.????.V05B'
fn_ext = 'RT-H5'

start = time.time()

# Set default value for FCST_INITS
if not FCST_INITS:
   FCST_INITS = ['00', '03','06', '12', '15', '18', '21']

if INIACUM is None:
   INIACUM = 0
if ENDACUM is None:
   ENDACUM = FCSTLENTGH

# Get list of directories in DATADIR
dirs = [subdir[0].split('/')[-1] for subdir in sorted(os.walk(OUTDIR))][1:]

# Loop over dates
inidate = common.str2date(INITIME, '%Y%m%d')
enddate = common.str2date(ENDTIME, '%Y%m%d')
delta = dt.timedelta(days=1) 
for date in common.datespan(inidate, enddate+delta, delta):
   ctime = common.date2str(date, '%Y%m%d')
   print('====================')
   print(ctime)
   print('====================')
   
   # Loop over forecast initializations
   for init in FCST_INITS:
      print(init)

      # Check if target directory is present 
      dirname = ctime + '_' + init + 'F'
      if dirname in dirs:
         
         acum_times = list(np.arange(INIACUM, ENDACUM+ACUM, ACUM))
         acum_dates = [date + dt.timedelta(hours=int(init)) + dt.timedelta(hours=int(i)) for i in acum_times]
         acum_fcsts = ['FC' + str(i).zfill(2)  for i in acum_times][1:]

         print(acum_times, acum_dates, acum_fcsts)

         #Get list of files for the ACUM period
         for idate, adate in enumerate(acum_dates[:-1]):
            filelist = io.find_by_date(adate, DATADIR, "", fn_pattern, fn_ext, OBSFREQ, num_next_files=ACUM*2-1)

            # Loop over files
            for ifile, filepath in enumerate(filelist[0]):
     
               # Read data
               lon, lat, pp = utimerg.read_imerg_pp(filepath, limits=[-37.95, -26.05, -65.95, -57.05])

               # Compute accumulate
               if ifile == 0:
                  lon, lat = np.float32(np.meshgrid(lon, lat))
                  acum = pp 
               else:
                  acum += pp
 
            # Write data to npz file
            pathout = OUTDIR + '/' + dirname
            os.makedirs(pathout, exist_ok=True)
            fileout = pathout + '/obs_' + dirname[:-1] + '_' + acum_fcsts[idate] 
            print('Writing file: ', fileout)
            np.savez(fileout, lat=lat, lon=lon, pp=acum)


end = time.time()

print('')
print('It took ', end-start, ' seconds')
