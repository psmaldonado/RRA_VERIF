import ftplib

pathout = '../../data/wrf_raw'
ftppath = '/CHEYENNE/POST/NPP'
INIDATE = '201811090000'
ENDDATE = '201812191200'
filenames = '2018*_*F.tgz'

ftp = ftplib.FTP("Server IP") 
ftp.login("UserName", "Password") 
ftp.cwd(path)

inidate = ut.str2date(INIDATE)
enddate = ut.str2date(ENDDATE)
delta = 3600
for date in ut.datespan(inidate, enddate, delta):
   time = date2str(date)
   filename = time '_
   ftp.retrbinary("RETR " + filename ,open(filename, 'wb').write)
ftp.quit()
