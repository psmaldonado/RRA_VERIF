'''
Functions that can be used to manipulate IMERG data
'''
import util as ut
import numpy as np

def read_imerg_npz(filename, dtype='all'):
   data = np.load(filename, mmap_mode='r')
   
   if dtype != 'all':
      data=data[dtype]

   return data

def get_files(datadir, start, end, inc, datafreq):
   '''
   Get a list of files for a corresponding period of time 
   '''
   from collections import defaultdict
   import datetime as dt

   #Get number of files needed to accumulate data
   if inc > datafreq and inc % datafreq == 0:
      nfiles = int(inc/datafreq)

   #Convert to date objects
   inidate = ut.str2date(start)
   enddate = ut.str2date(end)
   acum = dt.timedelta(seconds=inc)
   freq = dt.timedelta(seconds=datafreq)

   # Create dict of lists containing the start times needed
   # for each acumulation period
   filelist= defaultdict()
   for idate, acum_date in enumerate(ut.datespan(inidate, enddate, acum)):
      key = ut.date2str(acum_date + acum)
      inner_list = []

      for idates, dates in enumerate(ut.datespan(acum_date, acum_date+nfiles*freq, freq)):
         time = ut.date2str(dates)
         pattern = '3B-HHR-L.MS.MRG.3IMERG.' + time[:8] + '-S' + time[8:] + '*.V05B.RT-H5'
         inner_list.append(ut.find(pattern, datadir))

      filelist[key] = inner_list

   return filelist

def read_imerg_pp(filename, limits=None):
   '''
   Read lat, lon and pp form IMERG file. 
   Optional: specify the domain to read data from.
   '''
   import h5py

   if limits != None:
      slat = limits[0]
      nlat = limits[1]
      wlon = limits[2]
      elon = limits[3]

   # Open the file
   dataset = h5py.File(filename, 'r')

   # Load data
   lats = dataset['Grid/lat'][:]
   lons = dataset['Grid/lon'][:]
   precip = dataset['Grid/precipitationCal'][:]   #Lon, Lat shape
   precip = np.transpose(precip)

   # Subset of interest
   if limits == None:
      slat_idx = 0
      nlat_idx = -1
      wlon_idx = 0
      elon_idx = -1
   else:
      slat_idx = int(np.where(lats == slat)[0])
      nlat_idx = int(np.where(lats == nlat)[0])
      wlon_idx = int(np.where(lons == wlon)[0])
      elon_idx = int(np.where(lons == elon)[0])

   lat = lats[slat_idx:nlat_idx]
   lon = lons[wlon_idx:elon_idx]
   pp = precip[slat_idx:nlat_idx, wlon_idx:elon_idx]

   return lon, lat, pp





