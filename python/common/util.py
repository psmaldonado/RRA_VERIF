#***************************************************#
# FUNCIONES PARA EL MANEJO DE FECHAS                #
#***************************************************#
def str2date(string, fmt='%Y%m%d%H%M%S'):
    from datetime import datetime as dt
    return dt.strptime(string, fmt)

def date2str(date, fmt='%Y%m%d%H%M%S'):
    ''' Date: a datetime object. '''
    from  datetime import datetime as dt
    return dt.strftime(date, fmt)

def get_dates(times, fmt='%Y%m%d%H%M%S'):
    from datetime import timedelta
    '''
    La funcion devuelve una lista que contiene objetos datetime
    times = [ini, end, freq] : ini, end (str), freq (int in seconds)

    '''
    #Convert to date objects
    inidate = str2date(times[0], fmt)
    enddate = str2date(times[1], fmt)
    delta = timedelta(seconds=times[2])

    dates = []
    #Loop over dates
    for date in datespan(inidate, enddate+delta, delta):
        dates.append(date)
    return dates

def datespan(startDate, endDate, delta):
    '''
    La funcion devuelve un "generator" que contiene un objecto date
    Input:
        starDate (objeto): de la clase datetime que indica la fecha inicial
        endDate (objeto): de la clase datetime que indica la fecha final
        delta (objeto): de la clase datetime que indica el intervalo temporal
    '''
    currentDate = startDate
    while currentDate < endDate:
        yield currentDate
        currentDate += delta

#***************************************************#
# FUNCIONES PARA BARRAS DE COLORES                  #
#***************************************************#
def truncate_colormap(cmap, minval=0.0, maxval=1.0, n=100):
    """Remove colors from python colormap"""
    #https://stackoverflow.com/questions/18926031/how-to-extract-a-subset-of-a-colormap-as-a-new-colormap-in-matplotlib
    import matplotlib.pyplot as plt
    import matplotlib.colors as colors
    import numpy as np
    cmap = plt.get_cmap(cmap)
    new_cmap = colors.LinearSegmentedColormap.from_list(
        'trunc({n},{a:.2f},{b:.2f})'.format(n=cmap.name, a=minval, b=maxval),
        cmap(np.linspace(minval, maxval, n)))
    return new_cmap

def discrete_cmap(N, base_cmap=None):
    """Create an N-bin discrete colormap from the specified input map"""
    # Note that if base_cmap is a string or None, you can simply do
    #    return plt.cm.get_cmap(base_cmap, N)
    # The following works for string, None, or a colormap instance:
    import matplotlib.pyplot as plt
    import numpy as np
    base = plt.cm.get_cmap(base_cmap)
    color_list = base(np.linspace(0, 1, N))
    cmap_name = base.name + str(N)
    return base.from_list(cmap_name, color_list, N)

def colormaps(variable):
    """
    Choose colormap for a radar variable

    variable : str
       Radar variable to define which colormap to use. (e.g. ref,
       dv, zdr..) More to come

    returns : matplotlib ColorList
       A Color List for the specified *variable*.

    """
    import matplotlib.colors as colors

    # Definicion de las disntitas paletas de colores:
    nws_ref_colors =([ [4.0/255.0, 233.0/255.0, 231.0/255.0],
                    [ 1.0/255.0, 159.0/255.0, 244.0/255.0],
                    [  3.0/255.0,   0.0/255.0, 244.0/255.0],
                    [  2.0/255.0, 253.0/255.0,   2.0/255.0],
                    [  1.0/255.0, 197.0/255.0,   1.0/255.0],
                    [  0.0/255.0, 142.0/255.0,   0.0/255.0],
                    [253.0/255.0, 248.0/255.0,   2.0/255.0],
                    [229.0/255.0, 188.0/255.0,   0.0/255.0],
                    [253.0/255.0, 149.0/255.0,   0.0/255.0],
                    #[253.0/255.0,   0.0/255.0,   0.0/255.0],
                    #[212.0/255.0,   0.0/255.0,   0.0/255.0],
                    [188.0/255.0,   0.0/255.0,   0.0/255.0],
                    #[248.0/255.0,   0.0/255.0, 253.0/255.0],
                    [152.0/255.0,  84.0/255.0, 198.0/255.0]
                    ])

    nws_zdr_colors = ([ [  1.0/255.0, 159.0/255.0, 244.0/255.0],
                    [  3.0/255.0,   0.0/255.0, 244.0/255.0],
                    [  2.0/255.0, 253.0/255.0,   2.0/255.0],
                    [  1.0/255.0, 197.0/255.0,   1.0/255.0],
                    [  0.0/255.0, 142.0/255.0,   0.0/255.0],
                    [253.0/255.0, 248.0/255.0,   2.0/255.0],
                    [229.0/255.0, 188.0/255.0,   2.0/255.0],
                    [253.0/255.0, 149.0/255.0,   0.0/255.0],
                    [253.0/255.0,   0.0/255.0,   0.0/255.0],
                    [188.0/255.0,   0.0/255.0,   0.0/255.0],
                    [152.0/255.0,  84.0/255.0, 198.0/255.0]
                    ])

    nws_dv_colors = ([  [0,  1,  1],
                    [0,  0.966666638851166,  1],
                    [0,  0.933333337306976,  1],
                    [0,  0.899999976158142,  1],
                    [0,  0.866666674613953,  1],
                    [0,  0.833333313465118,  1],
                    [0,  0.800000011920929,  1],
                    [0,  0.766666650772095,  1],
                    [0,  0.733333349227905,  1],
                    [0,  0.699999988079071,  1],
                    [0,  0.666666686534882,  1],
                    [0,  0.633333325386047,  1],
                    [0,  0.600000023841858,  1],
                    [0,  0.566666662693024,  1],
                    [0,  0.533333361148834,  1],
                    [0,  0.5,  1],
                    [0,  0.466666668653488,  1],
                    [0,  0.433333337306976,  1],
                    [0,  0.400000005960464,  1],
                    [0,  0.366666674613953,  1],
                    [0,  0.333333343267441,  1],
                    [0,  0.300000011920929,  1],
                    [0,  0.266666680574417,  1],
                    [0,  0.233333334326744,  1],
                    [0,  0.200000002980232,  1],
                    [0,  0.16666667163372,   1],
                    [0,  0.133333340287209,  1],
                    [0,  0.100000001490116,  1],
                    [0,  0.0666666701436043, 1],
                    [0,  0.0333333350718021, 1],
                    [0,  0,  1],
                    [0,  0,  0],
                    [0,  0,  0],
                    [0,  0,  0],
                    [0,  0,  0],
                    [1,  0,  0],
                    [1,  0.0322580635547638, 0],
                    [1,  0.0645161271095276, 0],
                    [1,  0.0967741906642914, 0],
                    [1,  0.129032254219055,  0],
                    [1,  0.161290317773819,  0],
                    [1,  0.193548381328583,  0],
                    [1,  0.225806444883347,  0],
                    [1,  0.25806450843811,   0],
                    [1,  0.290322571992874,  0],
                    [1,  0.322580635547638,  0],
                    [1,  0.354838699102402,  0],
                    [1,  0.387096762657166,  0],
                    [1,  0.419354826211929,  0],
                    [1,  0.451612889766693,  0],
                    [1,  0.483870953321457,  0],
                    [1,  0.516129016876221,  0],
                    [1,  0.548387110233307,  0],
                    [1,  0.580645143985748,  0],
                    [1,  0.612903237342834,  0],
                    [1,  0.645161271095276,  0],
                    [1,  0.677419364452362,  0],
                    [1,  0.709677398204803,  0],
                    [1,  0.74193549156189,   0],
                    [1,  0.774193525314331,  0],
                    [1,  0.806451618671417,  0],
                    [1,  0.838709652423859,  0],
                    [1,  0.870967745780945,  0],
                    [1,  0.903225779533386,  0],
                    [1,  0.935483872890472,  0],
                    [1,  0.967741906642914,  0],
                    [1,  1,  0]   ])


    cmap_nws_ref = colors.ListedColormap(nws_ref_colors)
    cmap_nws_zdr = colors.ListedColormap(nws_zdr_colors)
    cmap_nws_dv = colors.ListedColormap(nws_dv_colors)

    if variable == 'ref':
       return cmap_nws_ref

    if variable == 'zdr':
       return cmap_nws_zdr

    if variable == 'dv':
       return cmap_nws_dv

#***************************************************#
# FUNCIONES PARA ....                               #
#***************************************************#
def get_alphabet(size, format_, start='a'):
    letters = []
    for i in range(ord(start), ord(start)+size):
        if format_ == 'bracket':
            letters.append(chr(i) +')')
        elif format_ == 'bracket2':
            letters.append('(' + chr(i) +')')
        elif format_ == 'dot':
            letters.append(chr(i) +'.')
        else:
            letters.append(chr(i))
    return letters

def check_dir_exists(filename, action=None):
    """Check if directory exists. If no perform a certain action"""
    import os
    import sys
    if not os.path.exists(filename):
        if action == 'create':
            os.makedirs(filename)
        elif action == 'quit':
            print('[IOError]: Directory does not exists')
            print(filename)
            sys.exit()
        else:
            print('Action not coded yet')
    else:
        pass

def time_func(fn, *args, **kwargs):
    """Measure function execution time"""
    import time
    tini = time.time()
    fn(*args, **kwargs)
    tend = time.time()
    print('### Execution time: ' + str(float('{:.4f}'.format(tend-tini))) + ' ###')

def compare_nan_array(func, a, thresh):
    import numpy as np
    out = ~np.isnan(a)
    out[out] = func(a[out], thresh)
    return out

def add_zero(num):
    """Add a zero to a number lower than 10 and return a string"""
    return '0' + str(num) if num < 10 else str(num)

def pyplot_rings(lon_radar,lat_radar,radius, lat_correction=False):
    """
    Calculate lat-lon of the maximum range ring

    lat_radar : float32
       Radar latitude. Positive is north.
    lon_radar : float32
       Radar longitude. Positive is east.
    radius : float32
       Radar range in kilometers.
    lat_correction: bool
       To apply latitude correction. Default: False
    returns : numpy.array
       A 2d array containing the 'radius' range latitudes (lat) and longitudes (lon)
    """
    import numpy as np

    R = 12742./2.
    m = 2.*np.pi*R/360.
    alfa = np.arange(-np.pi, np.pi, 0.0001)

    lat_radius = lat_radar + (radius/m)*np.sin(alfa)
    if lat_correction:
        lon_radius = lon_radar + ((radius/m)*np.cos(alfa)/np.cos(lat_radius*np.pi/180))
    else:
        lon_radius = lon_radar + (radius/m)*np.cos(alfa)
    return lon_radius, lat_radius

def read_arwpost(file):
    """
    Read relevant information from the ARWPOST ctl file and
    return variable data from the ARWPOST dat file.

    Parameters
    -----------
        file (str): full path of filename without extension
    Returns
    -------
        info (dict): relevant parameter values.
            nx (int): dimension in the x-direction
            ny (int): dimension in the y-direction
            nz (int): dimension in the z-direction
            nt (int): time dimension
        variables (dict): available variables
    """
    import sys
    import os
    import numpy as np

    variables = {}
    parsing = False
    file1 = file + '.ctl'
    file2 = file + '.dat'
    if os.path.isfile(file1) and os.path.isfile(file2):
        ctl_file = open(file1, 'r')
        dat_file = open(file2, 'r')
        for line in ctl_file.readlines():
            if line.startswith('pdef'):
                tmp = line.split()
                nx = int(tmp[1])
                ny = int(tmp[2])
            if line.startswith('zdef'):
                tmp = line.split()
                nz = int(tmp[1])
            if line.startswith('tdef'):
                tmp = line.split()
                nt = int(tmp[1])
            if line.startswith('ENDVARS'):
                parsing = False
            if parsing:
                tmp = line.split()
                var = tmp[0]
                var_nz = int(tmp[1])
                if var_nz == 1:
                    vars()[var] = np.empty((nx, ny))

                    tmp = np.fromfile(dat_file, dtype='>f4', count=nx*ny)
                    #print(vars()[var])

                    vars()[var][:, :] = np.reshape(tmp, (nx, ny))
                    variables[var] = (vars()[var])
                else:
                    vars()[var] = np.empty((nx, ny, nz))
                    for iz in range(0, nz):
                        tmp = np.fromfile(dat_file, dtype='>f4', count=nx*ny)
                        vars()[var][:, :, iz] = np.reshape(tmp, (nx, ny))
                        vars()[var][vars()[var] > 1.0E+10] = np.nan
                        variables[var] = (vars()[var])
            if line.startswith('VARS'):
                parsing = True

        return nx, ny, nz, nt, variables

    else:
        sys.exit('File ' + file1 + ' or ' + file2 + ' does not exist')
