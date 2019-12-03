"""Create projection from npp file parameters"""
import numpy as np
import pyproj
import cartopy.crs as ccrs
import shapely.geometry as sgeom
from copy import copy
#import re  # regular expression
import matplotlib.pyplot as plt

def get_colors(n):
   """Returns a list with `n` colors"""
   import matplotlib.pyplot as plt
   cm = plt.get_cmap('gist_rainbow')
   return [cm(1.*i/n) for i in range(n)]

def set_field(ax):
        from cartopy.mpl.gridliner import LONGITUDE_FORMATTER, LATITUDE_FORMATTER
        import matplotlib.ticker as mticker
        from cartopy.feature import NaturalEarthFeature

        #Graphic paramters
        fs_tick = 12

        #Add states division
        countries = NaturalEarthFeature(category='cultural', scale='10m', facecolor='none', name='admin_0_boundary_lines_land')
        ax.add_feature(countries, edgecolor='k', linewidth=0.8)
        states = NaturalEarthFeature(category='cultural', scale='10m', facecolor='none', name='admin_1_states_provinces_lines')
        ax.add_feature(states, edgecolor='gray', linewidth=1.)

        #Axes format
        gl = ax.gridlines(draw_labels=True)#, linewidth=0.01, color='gray', alpha=0.5, linestyle='--')
        gl.xlabels_top = False
        gl.ylabels_right = False
        gl.xlines = False
        gl.ylines = False
        gl.xformatter = LONGITUDE_FORMATTER
        gl.yformatter = LATITUDE_FORMATTER
        gl.xlocator = mticker.FixedLocator(list(np.arange(-67, -56, 2)))
        gl.ylocator = mticker.FixedLocator(list(np.arange(-39, -24)))
        gl.xlabel_style = {'size': fs_tick, 'color': 'k'}
        gl.ylabel_style = {'size': fs_tick, 'color': 'k'}

        return ax


def set_env(ax):
    from cartopy.feature import NaturalEarthFeature, OCEAN, LAKES

    ax.set_extent([-75.05, -50.05, -45.75, -15.00], crs=ccrs.PlateCarree())
    ax.coastlines('50m', linewidth=0.8)
    #ax.add_feature(OCEAN, edgecolor='k')#, facecolor='deepskyblue')
    #ax.add_feature(LAKES, edgecolor='k')#, facecolor='deepskyblue')
    states = NaturalEarthFeature(category='cultural', scale='10m', facecolor='none', name='admin_1_states_provinces_lines')
    ax.add_feature(states, edgecolor='gray', linewidth=0.5)
    countries = NaturalEarthFeature(category='cultural', scale='10m', facecolor='none', name='admin_0_boundary_lines_land')
    ax.add_feature(countries, edgecolor='k', linewidth=0.8)

def add_ticks(xticks, yticks, fig, ax, lcc=False):
    from cartopy.mpl.gridliner import LONGITUDE_FORMATTER, LATITUDE_FORMATTER

    # *must* call draw in order to get the axis boundary used to add ticks:
    fig.canvas.draw()
    ax.gridlines(xlocs=xticks, ylocs=yticks, linewidth=1, color='silver', alpha=0.5, linestyle=':')
    ax.xaxis.set_major_formatter(LONGITUDE_FORMATTER)
    ax.yaxis.set_major_formatter(LATITUDE_FORMATTER)
    if lcc:
       lambert_xticks(ax, xticks, 12)
       lambert_yticks_left(ax, yticks, 12)
    else:
       ax.xaxis.tick_bottom()
       ax.set_xticks(xticks)
       ax.set_xticklabels([ax.xaxis.get_major_formatter()(xtick) for xtick in xticks], size=12)

       ax.yaxis.tick_left()
       ax.set_ticks(yticks)
       ax.set_yticklabels([ax.yaxis.get_major_formatter()(ytick) for ytick in yticks], size=12)


def get_npp_projection(proj_name):
    # get NPP projection info
    # LCC
    if proj_name=='lambert':
        return get_proj_lcc(npp_file=None)


def get_proj_lcc(npp_file=None):
    #ref_lat = get_wps_param_value(wps_file, 'ref_lat', 1, 'float')
    #ref_lon = get_wps_param_value(wps_file, 'ref_lon', 1, 'float')
    #par_lat1 = get_wps_param_value(wps_file, 'truelat1', 1, 'float')
    #par_lat2 = get_wps_param_value(wps_file, 'truelat2', 1, 'float')
    #standard_lon = get_wps_param_value(wps_file, 'stand_lon', 1, 'float')
    ref_lat = -31.848
    ref_lon = -61.537
    par_lat1 = -31.848
    par_lat2 = -31.848
    standard_lon = -61.537

    lccproj = ccrs.LambertConformal(central_longitude=ref_lon, central_latitude=ref_lat,
                                    standard_parallels=(par_lat1, par_lat2), globe=None, 
                                    cutoff=10)
    return lccproj


# all these functions are necessary only when LCC projection is used.
def find_side(ls, side):
    """
    Given a shapely LineString which is assumed to be rectangular, return the
    line corresponding to a given side of the rectangle.
    """
    minx, miny, maxx, maxy = ls.bounds
    points = {'left': [(minx, miny), (minx, maxy)],
              'right': [(maxx, miny), (maxx, maxy)],
              'bottom': [(minx, miny), (maxx, miny)],
              'top': [(minx, maxy), (maxx, maxy)],}
    return sgeom.LineString(points[side])

def lambert_xticks(ax, ticks, size):
    """Draw ticks on the top x-axis of a Lambert Conformal projection."""
    te = lambda xy: xy[0]
    lc = lambda t, n, b: np.vstack((np.zeros(n) + t, np.linspace(b[2], b[3], n))).T
    xticks, xticklabels = _lambert_ticks(ax, ticks, 'top', lc, te)
    ax.xaxis.tick_top()
    ax.set_xticks(xticks)
    ax.set_xticklabels([ax.xaxis.get_major_formatter()(xtick) for xtick in xticklabels], size=size)

def lambert_yticks_left(ax, ticks, size):
    """Draw ricks on the left y-axis of a Lamber Conformal projection."""
    te = lambda xy: xy[1]
    lc = lambda t, n, b: np.vstack((np.linspace(b[0], b[1], n), np.zeros(n) + t)).T
    yticks, yticklabels = _lambert_ticks(ax, ticks, 'left', lc, te)
    ax.yaxis.tick_left()
    ax.set_yticks(yticks)
    ax.set_yticklabels([ax.yaxis.get_major_formatter()(ytick) for ytick in yticklabels], size=size)

def lambert_yticks_right(ax, ticks, size):
    """Draw ricks on the right y-axis of a Lamber Conformal projection."""
    te = lambda xy: xy[1]
    lc = lambda t, n, b: np.vstack((np.linspace(b[0], b[1], n), np.zeros(n) + t)).T
    yticks, yticklabels = _lambert_ticks(ax, ticks, 'right', lc, te)
    ax.yaxis.tick_right()
    ax.set_yticks(yticks)
    ax.set_yticklabels([ax.yaxis.get_major_formatter()(ytick) for ytick in yticklabels], size=size)

def _lambert_ticks(ax, ticks, tick_location, line_constructor, tick_extractor):
    """Get the tick locations and labels for an axis of a Lambert Conformal projection."""
    outline_patch = sgeom.LineString(ax.outline_patch.get_path().vertices.tolist())
    axis = find_side(outline_patch, tick_location)
    n_steps = 30
    extent = ax.get_extent(ccrs.PlateCarree())
    _ticks = []
    for t in ticks:
        xy = line_constructor(t, n_steps, extent)
        proj_xyz = ax.projection.transform_points(ccrs.Geodetic(), xy[:, 0], xy[:, 1])
        xyt = proj_xyz[..., :2]
        ls = sgeom.LineString(xyt.tolist())
        locs = axis.intersection(ls)
        if not locs:
            tick = [None]
        else:
            tick = tick_extractor(locs.xy)

        _ticks.append(tick[0])
    # Remove ticks that aren't visible:
    ticklabels = copy(ticks)
    while True:
        try:
            index = _ticks.index(None)
        except ValueError:
            break
        _ticks.pop(index)
        ticklabels.pop(index)

    return _ticks, ticklabels


