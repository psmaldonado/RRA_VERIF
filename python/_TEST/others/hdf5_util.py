def readGrid( fileName, varName, grid ) :
  #------------------------------------
  #  
  #------------------------------------
  print 'readGrid: ' + fileName
  #
  # --- verify that requested variable is available
  #
  fileHandle = h5py.File( fileName, 'r' )
  varExists = varName in fileHandle
  if varExists == False :
    print 'Error: requested variable does not exist in file'
    print '  ', fileName
    print '  ', varName
    return
  #
  # --- read data
  #
  grid['data'] = fileHandle[ varName ]

def listContents( fileName, outputFile=None ) :
  '''
  Obtain a text list of the variables in an HDF5 file.
  '''
  #------------------------------------
  #  
  #------------------------------------
  print 'listContents: ' + fileName
  global GLOBALoutputFile
  #
  GLOBALoutputFile = outputFile
  #
  if GLOBALoutputFile != None :
    print 'writing output to ', GLOBALoutputFile
    outputTextFile = open( GLOBALoutputFile, 'w' )
    outputTextFile.write( 'file: ' + fileName +'\n\n' )
    outputTextFile.close( )
  #
  fileHandle = h5py.File( fileName, 'r' )
  fileHandle.visititems( listNode )


