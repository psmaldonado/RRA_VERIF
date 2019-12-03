'''
Functions that can be used to manipulate WRF-NPP data
'''
import util as ut
import numpy as np

def read_wrf_npz(filename, dtype='all'):
   data = np.load(filename, mmap_mode='r')

   if dtype != 'all':
      data=data[dtype]
   
   return data

 
def read_wrf_pp(filename):
   '''
   Read lat, lon and pp form WRF-NPP file. 
   Optional: specify the domain to read data from.
   '''
   from netCDF4 import Dataset

   # Open the file
   dataset = Dataset(filename, 'r')

   # Load data
   lat = dataset.variables['XLAT']
   lon = dataset.variables['XLONG']
   pp   = dataset.variables['PP']    #Lon, Lat shape

   return lat, lon, pp

def interpolate2d(field, from_grid, to_grid, neigh=5):

   import pyresample

   orig = pyresample.geometry.SwathDefinition(lons=from_grid[0], lats=from_grid[1])
   targ = pyresample.geometry.SwathDefinition(lons=to_grid[0], lats=to_grid[1])

   wf = lambda r: 1/r**2
   acum_idw = pyresample.kd_tree.resample_custom(orig, field, \
                        targ, radius_of_influence=50000, neighbours=neigh,\
                        weight_funcs=wf, fill_value=None)

   return acum_idw

def wrf_2_imerg(data, from_grid, to_grid):
   '''
   Interpolate WRF data to IMERG lat/lon grid using an inverse distance weight function
   Data is a 2darray or 3darray with dimensions (ens, lat, lon)
   '''
   if data.ndim == 2:
      interp = interpolate2d(data, from_grid, to_grid)
   else:
      nmem = data.shape[0]
      nlat = to_grid[0].shape[0]
      nlon = to_grid[0].shape[1] 

      interp = np.zeros((nmem, nlat, nlon))
      for mem in range(0, nmem):
         interp[mem, :, :] = interpolate2d(data[mem, :, :], from_grid, to_grid)

   return interp 
