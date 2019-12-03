import sys

def read_cfrad(filename):
   import pyart
   return pyart.io.read(filename)

def get_ref_name(radar):
   namelist = ['TH', 'DBZH', 'ZH', 'CZH']
   names = [] 
   for name in namelist:
      if name in radar.fields:
         names.append(name)
   return names

def get_dv_name(radar):
   namelist = ['V', 'VRAD', 'CVRAD']
   names = []
   for name in namelist:
      if name in radar.fields:
         names.append(name)
   return names        
  
