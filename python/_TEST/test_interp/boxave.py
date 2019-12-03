import numpy as np
import sys
import os
sys.path.append( './fortran/' )
from cs  import cs   #Fortran code routines.
import matplotlib.pyplot as plt

def compute_grid_boxmean(variable, from_grid, to_grid):
        import numpy.matlib
        """
        Compute the i, j, k for each radar grid point and box-average the data.

        Parameters
        ----------
        variables : list of numpy array
        """

        nx = variable['data'].shape[1]
        ny = variable['data'].shape[0]

        lon_ini = to_grid['lon'][0, 0]
        lat_ini = to_grid['lat'][0, 0]
        dlon = to_grid['dlon']
        dlat = to_grid['dlat']
        nlon = to_grid['nlon']
        nlat = to_grid['nlat']

        local_undef = -8888.0

        #Group all variables that will be "superobbed" into one single array.
        #This is to take advantage of paralellization. Different columns will be processed in parallel.
        datain  = np.zeros((ny*nx))
        latin   = np.zeros((ny*nx))
        lonin   = np.zeros((ny*nx))

        for ix in range(nx) :
           datain[ix*ny:(ix+1)*ny] = variable['data'][:, ix]
           latin[ix*ny:(ix+1)*ny]  = from_grid['lat'][:, ix]
           lonin[ix*ny:(ix+1)*ny]  = from_grid['lon'][:, ix]


        #Change for variable undef into local_undef.
        tmp_mask = ( datain[:] < 0.0 )
        datain[ tmp_mask ] = local_undef

        #The function outputs 
        #data_ave - weigthed average
        #data_max - maximum value
        #data_min - minimum value
        #data_std - standard deviation (can be used to filter some super obbs)
        #data_n   - number of samples  (can be used to filter some super obbs)
        [data_ave , data_max , data_min , data_std , data_n ]=cs.com_interp_boxaverage(
                             xini=lon_ini,dx=dlon,nx=nlon,yini=lat_ini,dy=dlat,ny=nlat,
                             xin=lonin,yin=latin,datain=datain,undef=local_undef,nin=ny*nx)

        #Mask points with local_undef values
        data_ave = np.ma.masked_where(data_n == 0, data_ave)
        print(np.min(data_ave), np.max(data_ave))
      
        return data_ave


