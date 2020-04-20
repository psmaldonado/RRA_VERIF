import os, fnmatch
import common.util as common
import datetime as dt

def find_all(name, path):
    result = []
    for root, dirs, files in os.walk(path):
        if name in files:
            result.append(os.path.join(root, name))
    return result

def find_by_pattern(pattern, path):
   result = []
   for root, dirs, files in sorted(os.walk(path)):
       for name in sorted(files):
           if fnmatch.fnmatch(name, pattern):
               result.append(os.path.join(root, name))
   if len(result) == 1:
      result = result[0]

   return result

def init_dict(key1, key2=None, key3=None):
   '''
   Initialize a dictionary of dictionaries.
   '''

   from collections import defaultdict
   out = defaultdict(dict)

   for key_1 in key1:
      if key2 is None:
         out[key_1] = list()
      else:
         for key_2 in key2:
            if key3 is None:
               out[key_1][key_2] = list()
            else:
               out[key_1][key_2] = defaultdict(list)

   return out

def get_order_files(key1, key2, model, path, order='lead', date_init=None):

   # Initialize output variable
   if order == 'param':
      data = init_dict(key1)
   else:
      data = init_dict(key1, key2)

   # Find all files for each forecast lead
   if order == 'date' and date_init != None:
      obs = find_by_pattern('obs*_' + date_init + '_*.npz', path)
      wrf = find_by_pattern(model + '*_' + date_init + '_*.npz', path)
   else:
      obs = find_by_pattern('obs*.npz', path)
      wrf = find_by_pattern(model + '*.npz', path)

   for name in wrf:
      init = name.split('_')[-2]
      lead = name.split('_')[-1][2:4]
      time = name.split('_')[-3]
      date = common.str2date(time, '%Y%m%d') + dt.timedelta(hours=int(init)) + dt.timedelta(hours=int(lead))
      hour = str(date.hour).zfill(2)

      obspath = name.replace(model, 'obs')
      if os.path.isfile(obspath):
         path = [name, obspath]
         if order == 'lead':
            data[init][lead].append(path)
         elif order == 'hour':
            data[init][hour].append(path)
         elif order == 'date':
            data[lead][date].append(path)
         elif order == 'param':
            data[lead].append(path)

   return data

