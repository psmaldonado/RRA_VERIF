import argparse
from PIL import Image
import os
from datetime import date, datetime 

def process_images(filelist, out_fname):
    images = []
    for fname in filelist:
      # Load and process the image
      im = Image.open(fname)
      # Pillow can't save RGBA images to pdf,
      # make sure the image is RGB
      if im.mode == "RGBA":
         im = im.convert("RGB")
      # Add the (optionally) processed image to the images list
      images.append(im)

    # Convert the images list to pdf
    images[0].save(out_fname, save_all = True, quality=100, append_images = images[1:])

if __name__ == "__main__":
    # Let the user pass parameters to the code, all parameters are optional have some default values
    # ...

    # Make sure the output file ends with *.pdf*
    # ...

   # Open a file
   FOLDER = ''
   PATTERN = 'RMSE'
   FTYPE = '.png'
   PDFOUT = PATTERN

   today = datetime.strftime(date.today(), "%Y%m%d")
   pathout = '/home/paula.maldonado/datosalertar1/RRA_VERIF/docs'
   pathin = '../../figures/RRA_6hr_accumulated/' + FOLDER

   filelist = [a for a in os.listdir(pathin) if a.endswith(FTYPE) and PATTERN in a]
   filelist.sort()
   for i in range(len(filelist)):
      filelist[i] = os.path.join(pathin, filelist[i])

   fileout = pathout + '/' + PDFOUT + '_' + today + '.pdf'
   process_images(filelist, fileout)
