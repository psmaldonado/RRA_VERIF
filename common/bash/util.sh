#!/bin/bash
#-----------------------#
#Edit date
#-----------------------#
date_edit2 () {
(

        if [ $# -lt 2 ]; then
                echo "Usage : date_edit2"
                echo "    date_edit2 [yyyy][mm][dd][hh][mn] [dt(sec)]"
                echo "    ex) date_edit2 201005051200 -60"
                exit
        fi

        CDATEL=$1
        dt=$2

        cy=`echo $CDATEL | cut -c1-4`
        cm=`echo $CDATEL | cut -c5-6`
        cd=`echo $CDATEL | cut -c7-8`
        ch=`echo $CDATEL | cut -c9-10`
        cn=`echo $CDATEL | cut -c11-12`
        cs=`echo $CDATEL | cut -c13-14`

        seconds=`date +%s -d"$cy-$cm-$cd $ch:$cn:$cs UTC"`

        seconds=`expr $seconds + $dt `


        date -u +%Y%m%d%H%M%S -d"@$seconds "


)
}

#----------------------------------------------------#
#Compute the difference in seconds between two dates.
#----------------------------------------------------#
date_diff () {
(

        if [ $# -lt 2 ]; then
                echo "Usage : date_diff"
                echo "    date_diff [yyyy1][mm1][dd1][hh1][mn1] [yyyy2][mm2][dd2][hh2][mn2]"
                echo "    ex) date_edit 201005051200 201005051230"
                exit 1
        fi

        local DATE1=$1
        local DATE2=$2

        cy1=`echo $DATE1 | cut -c1-4`
        cm1=`echo $DATE1 | cut -c5-6`
        cd1=`echo $DATE1 | cut -c7-8`
        ch1=`echo $DATE1 | cut -c9-10`
        cn1=`echo $DATE1 | cut -c11-12`
        cs1=`echo $DATE1 | cut -c13-14`

        seconds1=`date +%s -d"$cy1-$cm1-$cd1 $ch1:$cn1:$cs1 UTC"`

        cy2=`echo $DATE2 | cut -c1-4`
        cm2=`echo $DATE2 | cut -c5-6`
        cd2=`echo $DATE2 | cut -c7-8`
        ch2=`echo $DATE2 | cut -c9-10`
        cn2=`echo $DATE2 | cut -c11-12`
        cs2=`echo $DATE2 | cut -c13-14`

        seconds2=`date +%s -d"$cy2-$cm2-$cd2 $ch2:$cn2:$cs2 UTC"`


        echo ` expr $seconds1 - $seconds2 `
)
}

#-----------------------#
#Change file endianess
#-----------------------#
change_endian () {
(

        if [ $# -lt 1 ]; then
                echo "Usage : change_endian"
                echo "    change_endian [file_in] [file_out]"
                echo "    ex) change_endian ./obs_le.dat ./obs_be.dat"
                exit
        fi

        FILEIN=$1
        FILEOUT=$2

        echo $FILEIN

        hexdump -v -e '1/4 "%08x"' -e '"\n"' ${FILEIN} | xxd -r -p > ${FILEOUT}
)
}

#----------------------------------#
#Get the absolute value of input.
#----------------------------------#
abs_val() {

local value=$1

  if [ $value -lt 0 ] ; then
     result=`expr 0 - $value `
  else
     result=$value
  fi

  echo $result

}

#----------------------------------#
#Add zeros to number
#----------------------------------#
add_zeros() {

local number=$1
local size=$2

local result=`printf "%0${size}d" $number`

echo $result

}
