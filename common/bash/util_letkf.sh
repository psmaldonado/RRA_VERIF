#!/bin/bash
# =======================================================================
#
#       Utility Shell Finctions for WRF_LETKF
#
#                                                   2010.05.11 M.Kunii
# =======================================================================

# -----------------------------
#    date_edit
# -----------------------------
date_edit () {
(

        if [ $# -lt 7 ]; then
                echo "Usage : date_edit"
                echo "    date_edit [yyyy] [mm] [dd] [hh] [mn] [dt(min)]"
                echo "    ex) date_edit 201005051200 -180"
                exit
        fi

        yy=$1
        mm=$2
        dd=$3
        hh=$4
        mn=$5
        ss=$6
        dt=$7

        echo $yy-$mm-$dd $hh:$mn:$ss

        seconds=`date +%s -d"$yy-$mm-$dd $hh:$mn:$ss UTC"`

        seconds=`expr $seconds + $dt \* 60 `


        date -u +%Y%m%d%H%M%S -d"@$seconds "


)
}


date_edit2 () {
(

        if [ $# -lt 2 ]; then
                echo "Usage : date_edit"
                echo "    date_edit [yyyy][mm][dd][hh][mn] [dt(sec)]"
                echo "    ex) date_edit 201005051200 -60"
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

date_edit3 () {
(

        if [ $# -lt 2 ]; then
                echo "Usage : date_edit"
                echo "    date_edit [yyyy][mm][dd][hh][mn] [dt(min)]"
                echo "    ex) date_edit 201005051200 -180"
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

        seconds=`expr $seconds + $dt \* 60 `


        date -u +%Y\ %m\ %d\ %H\ %M\ %S -d"@$seconds "

)
}

#Compute the difference in seconds between two dates.
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

#Given a date and a time interval get the lower closest date which is a multiple of the interval.
date_floor () {
        if [ $# -lt 2 ]; then
                echo "Usage : date_floor"
                echo "    date_floor [yyyy][mm][dd][hh][mn] [interval(seconds)]"
                echo "    ex) date_edit 201005051200 3600"
                exit 1
        fi

        local DATE=$1
        local INTERVAL=$2

        cy1=`echo $DATE | cut -c1-4`
        cm1=`echo $DATE | cut -c5-6`
        cd1=`echo $DATE | cut -c7-8`
        ch1=`echo $DATE | cut -c9-10`
        cn1=`echo $DATE | cut -c11-12`
        cs1=`echo $DATE | cut -c13-14`

        seconds1=`date +%s -d"$cy1-$cm1-$cd1 $ch1:$cn1:$cs1 UTC"`
        mod=`expr $seconds1 % $INTERVAL `

        DATEFLOOR=`date_edit2 $DATE -$mod `
        echo $DATEFLOOR
}

#Get the absolute value of input.
abs_val() {

local value=$1

  if [ $value -lt 0 ] ; then
     result=`expr 0 - $value `
  else
     result=$value
  fi

  echo $result

}


add_zeros() {

local number=$1
local size=$2

local result=`printf "%0${size}d" $number`

echo $result

}

ens_member () {

local    MEMBER="$1"
local    MEMBER_STR=$MEMBER
   
    echo `add_zeros $1 5 `
}

forecast_lead () {

local    FLEADT="$1"
local    FLEADT_STR=$FLEADT


    if test $FLEADT -lt 1000000
    then
      FLEADT_STR=0$FLEADT_STR
    fi
    if test $FLEADT -lt 100000
    then
      FLEADT_STR=0$FLEADT_STR
    fi
    if test $FLEADT -lt 10000
    then
      FLEADT_STR=0$FLEADT_STR
    fi
    if test $FLEADT -lt 1000
    then
      FLEADT_STR=0$FLEADT_STR
    fi
    if test $FLEADT -lt 100
    then
      FLEADT_STR=0$FLEADT_STR
    fi
    if test $FLEADT -lt 10
    then
      FLEADT_STR=0$FLEADT_STR
    fi

    echo $FLEADT_STR
}

maximum_common_divisor () {

   local n1=$1
   local n2=$2
   local gcd=0
   if test $n1 -gt $n2 ; then
      local i=1
      while test $i -le $n1 ; do
        local a=`expr $n1 % $i`
        local b=`expr $n2 % $i`
        if test $a -eq 0 -a $b -eq 0 ; then
	   if test $gcd -lt $i ; then
             gcd=$i
           fi
        fi
        i=`expr $i + 1`
      done
   fi
   if test $n2 -gt $n1 ; then
      i=1
      while test $i -le $n2 ; do
        a=`expr $n1 % $i`
        b=`expr $n2 % $i`
        if test $a -eq 0 -a $b -eq 0 ; then
           if test $gcd -lt $i ; then
             gcd=$i
           fi
        fi
        i=`expr $i + 1`
      done
   fi
   if test $n2 -eq $n1 ; then
     gcd=$n2
   fi

   echo $gcd
}


#slot_number () {
#
#local SLOT=$1
#local SLOT_STR=$SLOT
#   if test $SLOT -lt 10
#   then
#     SLOT_STR=0$SLOT_STR
#   fi
#
#   echo $SLOT_STR
#
#}


ungrib_file_name () {
local DATE="$1"
local PREFIX="$2"

    cy=`echo $DATE | cut -c1-4`
    cm=`echo $DATE | cut -c5-6`
    cd=`echo $DATE | cut -c7-8`
    ch=`echo $DATE | cut -c9-10`
    cn=`echo $DATE | cut -c11-12`
    cs=`echo $DATE | cut -c13-14`

    echo ${PREFIX}:${cy}-${cm}-${cd}_${ch}:${cn}
}

met_em_file_name () {

local    DATE="$1"
local    DOMAIN="$2"
  
    cy=`echo $DATE | cut -c1-4`
    cm=`echo $DATE | cut -c5-6`
    cd=`echo $DATE | cut -c7-8`
    ch=`echo $DATE | cut -c9-10`
    cn=`echo $DATE | cut -c11-12`
    cs=`echo $DATE | cut -c13-14`

    echo met_em.d${DOMAIN}.${cy}-${cm}-${cd}_${ch}:${cn}:${cs}.nc
}

wrfout_file_name () {

local    DATE="$1"
local    DOMAIN="$2"
  
    cy=`echo $DATE | cut -c1-4`
    cm=`echo $DATE | cut -c5-6`
    cd=`echo $DATE | cut -c7-8`
    ch=`echo $DATE | cut -c9-10`
    cn=`echo $DATE | cut -c11-12`
    cs=`echo $DATE | cut -c13-14`

    echo wrfout_d${DOMAIN}_${cy}-${cm}-${cd}_${ch}:${cn}:${cs}
}

date_in_wrf_format() {


local    DATE="$1"

    cy=`echo $DATE | cut -c1-4`
    cm=`echo $DATE | cut -c5-6`
    cd=`echo $DATE | cut -c7-8`
    ch=`echo $DATE | cut -c9-10`
    cn=`echo $DATE | cut -c11-12`
    cs=`echo $DATE | cut -c13-14`

    echo ${cy}-${cm}-${cd}_${ch}:${cn}:${cs}

}

edit_namelist_input () {

local    NAMELIST=$1
local    IDATE=$2
local    EDATE=$3
local    OUTPUT_FREQ=$4                      #In seconds
local    BOUNDARY_DATA_FREQ=$5               #In seconds

    iy=`echo $IDATE | cut -c1-4`
    im=`echo $IDATE | cut -c5-6`
    id=`echo $IDATE | cut -c7-8`
    ih=`echo $IDATE | cut -c9-10`
    in=`echo $IDATE | cut -c11-12`
    is=`echo $IDATE | cut -c13-14`

    ey=`echo $EDATE | cut -c1-4`
    em=`echo $EDATE | cut -c5-6`
    ed=`echo $EDATE | cut -c7-8`
    eh=`echo $EDATE | cut -c9-10`
    en=`echo $EDATE | cut -c11-12`
    es=`echo $EDATE | cut -c13-14`

    sed -i 's/SYYYY/'${iy}'/g'                   $NAMELIST
    sed -i 's/SMM/'${im}'/g'                     $NAMELIST
    sed -i 's/SDD/'${id}'/g'                     $NAMELIST
    sed -i 's/SHH/'${ih}'/g'                     $NAMELIST
    sed -i 's/SMN/'${in}'/g'                     $NAMELIST
    sed -i 's/SSS/'${is}'/g'                     $NAMELIST
    sed -i 's/EYYYY/'${ey}'/g'                   $NAMELIST
    sed -i 's/EMM/'${em}'/g'                     $NAMELIST
    sed -i 's/EDD/'${ed}'/g'                     $NAMELIST
    sed -i 's/EHH/'${eh}'/g'                     $NAMELIST
    sed -i 's/EMN/'${en}'/g'                     $NAMELIST
    sed -i 's/ESS/'${es}'/g'                     $NAMELIST
    sed -i 's/OUTPUTFREQ/'${OUTPUT_FREQ}'/g'     $NAMELIST
    sed -i 's/BDYFREQ/'${BOUNDARY_DATA_FREQ}'/g' $NAMELIST
    sed -i 's/MAX_DOM/'${MAX_DOM}'/g'            $NAMELIST
    sed -i 's/NVERTEXP/'${NVERTEXP}'/g'          $NAMELIST

}

edit_namelist_wps () {

local    NAMELIST=$1
local    IDATE=$2
local    EDATE=$3
local    BOUNDARY_DATA_FREQ=$4         #In seconds


    iy=`echo $IDATE | cut -c1-4`
    im=`echo $IDATE | cut -c5-6`
    id=`echo $IDATE | cut -c7-8`
    ih=`echo $IDATE | cut -c9-10`
    in=`echo $IDATE | cut -c11-12`
    is=`echo $IDATE | cut -c13-14`

    ey=`echo $EDATE | cut -c1-4`
    em=`echo $EDATE | cut -c5-6`
    ed=`echo $EDATE | cut -c7-8`
    eh=`echo $EDATE | cut -c9-10`
    en=`echo $EDATE | cut -c11-12`
    es=`echo $EDATE | cut -c13-14`

    sed -i 's/SYYYY/'${iy}'/g'                   $NAMELIST
    sed -i 's/SMM/'${im}'/g'                     $NAMELIST
    sed -i 's/SDD/'${id}'/g'                     $NAMELIST
    sed -i 's/SHH/'${ih}'/g'                     $NAMELIST
    sed -i 's/SMN/'${in}'/g'                     $NAMELIST
    sed -i 's/SSS/'${is}'/g'                     $NAMELIST
    sed -i 's/EYYYY/'${ey}'/g'                   $NAMELIST
    sed -i 's/EMM/'${em}'/g'                     $NAMELIST
    sed -i 's/EDD/'${ed}'/g'                     $NAMELIST
    sed -i 's/EHH/'${eh}'/g'                     $NAMELIST
    sed -i 's/EMN/'${en}'/g'                     $NAMELIST
    sed -i 's/ESS/'${es}'/g'                     $NAMELIST
    sed -i 's/BDYFREQ/'${BOUNDARY_DATA_FREQ}'/g' $NAMELIST
    sed -i 's/MAX_DOM/'${MAX_DOM}'/g'            $NAMELIST

}

edit_namelist_letkf () {

        NAMELIST=$1

    #For LETKF

    sed -i 's/@NBV@/'${MEMBER}'/g'                                  $NAMELIST
    sed -i 's/@NSLOTS@/'${NSLOTS}'/g'                               $NAMELIST
    sed -i 's/@NBSLOT@/'${NBSLOT}'/g'                               $NAMELIST
    sed -i 's/@SIGMA_OBS@/'${SIGMA_OBS}'/g'                         $NAMELIST
    sed -i 's/@SIGMA_OBSV@/'${SIGMA_OBSV}'/g'                       $NAMELIST
    sed -i 's/@SIGMA_OBSZ@/'${SIGMA_OBSZ}'/g'                       $NAMELIST
    sed -i 's/@SIGMA_OBST@/'${SIGMA_OBST}'/g'                       $NAMELIST
    sed -i 's/@GROSS_ERROR@/'${GROSS_ERROR}'/g'                     $NAMELIST
    sed -i 's/@COV_INFL_MUL@/'${COV_INFL_MUL}'/g'                   $NAMELIST
    sed -i 's/@SP_INFL_ADD@/'${SP_INFL_ADD}'/g'                     $NAMELIST
    sed -i 's/@RELAX_ALPHA_SPREAD@/'${RELAX_ALPHA_SPREAD}'/g'       $NAMELIST
    sed -i 's/@RELAX_ALPHA@/'${RELAX_ALPHA}'/g'                     $NAMELIST

}


edit_namelist_pertmetem () {

    NAMELIST=$1

    sed -i 's/@PERTURB_ATMOSPHERE@/'${PERTURB_ATMOSPHERE}'/g'       $NAMELIST
    sed -i 's/@PERTURB_SST@/'${PERTURB_SST}'/g'                     $NAMELIST
    sed -i 's/@PERTURB_SOIL@/'${PERTURB_SOIL}'/g'                   $NAMELIST

#    sed -i 's/@AMP_FACTOR@/'${AMP_FACTOR}'/g'                       $NAMELIST
#    sed -i 's/@CURRENT_TIME@/'${CURRENT_TIME}'/g'                   $NAMELIST
#    sed -i 's/@MAX_TIME@/'${MAX_TIME}'/g'                           $NAMELIST

    sed -i 's/@PERTURB_T@/'${PERTURB_T}'/g'                         $NAMELIST
    sed -i 's/@PERTURB_RH@/'${PERTURB_RH}'/g'                       $NAMELIST
    sed -i 's/@PERTURB_WIND@/'${PERTURB_WIND}'/g'                   $NAMELIST

    sed -i 's/@PERTURB_T_AMP@/'${PERTURB_T_AMP}'/g'                 $NAMELIST
    sed -i 's/@PERTURB_RH_AMP@/'${PERTURB_RH_AMP}'/g'               $NAMELIST
    sed -i 's/@PERTURB_WIND_AMP@/'${PERTURB_WIND_AMP}'/g'           $NAMELIST

#    sed -i 's/@RANDOM_AMP_FACTOR@/'${RANDOM_AMP_FACTOR}'/g'         $NAMELIST

    sed -i 's/@PERTURB_T_SCLH@/'${PERTURB_T_SCLH}'/g'               $NAMELIST
    sed -i 's/@PERTURB_RH_SCLH@/'${PERTURB_RH_SCLH}'/g'             $NAMELIST
    sed -i 's/@PERTURB_WIND_SCLH@/'${PERTURB_WIND_SCLH}'/g'         $NAMELIST

    sed -i 's/@PERTURB_T_SCLV@/'${PERTURB_T_SCLV}'/g'               $NAMELIST
    sed -i 's/@PERTURB_RH_SCLV@/'${PERTURB_RH_SCLV}'/g'             $NAMELIST
    sed -i 's/@PERTURB_WIND_SCLV@/'${PERTURB_WIND_SCLV}'/g'         $NAMELIST

}


edit_namelist_obsope () {

        NAMELIST=$1

    sed -i 's/@NBV@/'${MEMBER}'/g'                                  $NAMELIST
    sed -i 's/@NSLOTS@/'${NSLOTS}'/g'                               $NAMELIST
    sed -i 's/@NBSLOT@/'${NBSLOT}'/g'                               $NAMELIST
    sed -i 's/@GROSS_ERROR@/'${GROSS_ERROR}'/g'                     $NAMELIST
    sed -i 's/@SLOTSTEP@/'${SLOTSTEP}'/g'                           $NAMELIST
    sed -i 's/@SLOTOFFSET@/'${SLOTOFFSET}'/g'                       $NAMELIST
    sed -i 's/@DO_OBSGRID@/'${DO_OBSGRID}'/g'                       $NAMELIST
    sed -i 's/@REGRID_RES@/'${REGRID_RES}'/g'                       $NAMELIST 
    sed -i 's/@REGRID_VERT_RES@/'${REGRID_VERT_RES}'/g'             $NAMELIST
    sed -i 's/@REGRID_VERT_ZRES@/'${REGRID_VERT_ZRES}'/g'           $NAMELIST
    sed -i 's/@NAREA@/'${NAREA}'/g'                                 $NAMELIST
    sed -i 's/@VLON1@/'${VLON1}'/g'                                 $NAMELIST
    sed -i 's/@VLON2@/'${VLON2}'/g'                                 $NAMELIST
    sed -i 's/@VLAT1@/'${VLAT1}'/g'                                 $NAMELIST
    sed -i 's/@VLAT2@/'${VLAT2}'/g'                                 $NAMELIST
 
}



edit_namelist_arwpost () {

local NAMELIST=$1
local IDATE=$2
local EDATE=$3
local LOCALOUTPUTFREQ=$4 #In seconds


LOCALDATE=$IDATE
while [ $LOCALDATE -le $EDATE ] ; do

    ARWEDATE=$LOCALDATE
    LOCALDATE=` date_edit2 $LOCALDATE $LOCALOUTPUTFREQ `

done

    iy=`echo $IDATE | cut -c1-4`
    im=`echo $IDATE | cut -c5-6`
    id=`echo $IDATE | cut -c7-8`
    ih=`echo $IDATE | cut -c9-10`
    in=`echo $IDATE | cut -c11-12`
    is=`echo $IDATE | cut -c13-14`

    ey=`echo $ARWEDATE | cut -c1-4`
    em=`echo $ARWEDATE | cut -c5-6`
    ed=`echo $ARWEDATE | cut -c7-8`
    eh=`echo $ARWEDATE | cut -c9-10`
    en=`echo $ARWEDATE | cut -c11-12`
    es=`echo $ARWEDATE | cut -c13-14`

    sed -i 's/SYYYY/'${iy}'/g'                   $NAMELIST
    sed -i 's/SMM/'${im}'/g'                     $NAMELIST
    sed -i 's/SDD/'${id}'/g'                     $NAMELIST
    sed -i 's/SHH/'${ih}'/g'                     $NAMELIST
    sed -i 's/SMN/'${in}'/g'                     $NAMELIST
    sed -i 's/SSS/'${is}'/g'                     $NAMELIST
    sed -i 's/EYYYY/'${ey}'/g'                   $NAMELIST
    sed -i 's/EMM/'${em}'/g'                     $NAMELIST
    sed -i 's/EDD/'${ed}'/g'                     $NAMELIST
    sed -i 's/EHH/'${eh}'/g'                     $NAMELIST
    sed -i 's/EMN/'${en}'/g'                     $NAMELIST
    sed -i 's/ESS/'${es}'/g'                     $NAMELIST
    sed -i 's/OUTPUTFREQ/'${LOCALOUTPUTFREQ}'/g'           $NAMELIST
    sed -i 's/INPUT_ROOT_NAME/'${INPUT_ROOT_NAME}'/g'      $NAMELIST
    sed -i 's/OUTPUT_ROOT_NAME/'${OUTPUT_ROOT_NAME}'/g'    $NAMELIST    
    sed -i 's/OUTPUTVARS/'${OUTVARS}'/g'                   $NAMELIST  
    sed -i 's/OUTPUTLEVS/'${OUTLEVS}'/g'                   $NAMELIST 
    sed -i 's/INTERP_METHOD/'${INTERP_METHOD}'/g'          $NAMELIST 
    
}

edit_wrf_wrf () {

local SCRIPT=$1
echo "#!/bin/bash                                           "   > $SCRIPT
echo "set -x                                                "  >> $SCRIPT
echo "export LD_LIBRARY_PATH=$RUNTIMELIBS:\$LD_LIBRARY_PATH "  >> $SCRIPT
echo "WORKDIR=\$1                                           "  >> $SCRIPT
echo "                                                      "  >> $SCRIPT
echo "cd \$WORKDIR                                          "  >> $SCRIPT
if [ $SYSTEM -eq 1 ] ; then 
echo "ulimit -s unlimited                                   "  >> $SCRIPT
fi                     
echo "./wrf.exe                                             "  >> $SCRIPT

chmod 766 $SCRIPT

}

edit_wrf_real () {

local SCRIPT=$1
echo "#!/bin/bash                                           "   > $SCRIPT
echo "set -x                                                "  >> $SCRIPT
echo "export LD_LIBRARY_PATH=$RUNTIMELIBS:\$LD_LIBRARY_PATH "  >> $SCRIPT
echo "WORKDIR=\$1                                           "  >> $SCRIPT
echo "                                                      "  >> $SCRIPT
echo "cd \$WORKDIR                                          "  >> $SCRIPT
if [ $SYSTEM -eq 1 ] ; then 
echo "ulimit -s unlimited                                   "  >> $SCRIPT
fi                     
echo "./real.exe                                            " >> $SCRIPT

chmod 766 $SCRIPT

}

edit_wrf_interpana () {

#Run real using LETKF anal met_em as input to generate wrinput in the forecast grid 
#(only if the LETKF analysis and forecast grids are different)

#Wrfinput and wrfbdy that are previously generated from perturbed gfs outpust are preserved
#as wrfinput_d01.tmp and wrfbdy_d01.tmp and restored at the end.
#The wrfinput_d01 generated from the LETKF analysis file is stored as anal (as in the LETKF cycle).

local SCRIPT=$1
if [ $FORECAST -eq 1 -a $INTERPANA -eq 1 ] ; then  #Forecast and analysis have different grids.
 echo "#!/bin/bash                                           "  > $SCRIPT
 echo "set -x                                                " >> $SCRIPT
 echo "export LD_LIBRARY_PATH=$RUNTIMELIBS:\$LD_LIBRARY_PATH " >> $SCRIPT
 echo "WORKDIR=\$1                                           " >> $SCRIPT
 echo "                                                      " >> $SCRIPT
 echo "cd \$WORKDIR                                          " >> $SCRIPT
 if [ $SYSTEM -eq 1 ] ; then
  echo "ulimit -s unlimited                                  " >> $SCRIPT
 fi
 echo "mv wrfbdy_d01   wrfbdy_d01.tmp                        " >> $SCRIPT
 echo "mv wrfinput_d01 wrfinput_d01.tmp                      " >> $SCRIPT
 echo "cp ../WRF/namelist.input.real2 ./namelist.input       " >> $SCRIPT
 met_em_file=met_em_file_name $CDATE 01
 echo "mv ${met_em_file}.anal ${met_em_file}                 " >> $SCRIPT
 echo "./real.exe                                            " >> $SCRIPT
 echo "cp wrfinput_d01.gfs ./anal                            " >> $SCRIPT
 echo "ln -sf ./wrfinput_d01 ./input1.nc                     " >> $SCRIPT
 echo "ln -sf ./anal         ./input2.nc                     " >> $SCRIPT
 echo "../WRF/merge_wrfinput.exe  > ./merge_wrfinput.log     " >> $SCRIPT
 echo "mv wrfbdy_d01.tmp wrfbdy_d01                          " >> $SCRIPT
 echo "mv wrfinput_d01.tmp wrfinput_d01                      " >> $SCRIPT

 chmod 766 $SCRIPT
fi

}

edit_wrf_pre () {

local SCRIPT=$1
echo "#!/bin/bash                                                         "  > $SCRIPT
echo "set -x                                                              " >> $SCRIPT
echo "export LD_LIBRARY_PATH=$RUNTIMELIBS:\$LD_LIBRARY_PATH               " >> $SCRIPT
echo "WORKDIR=\$1                                                         " >> $SCRIPT
echo "MEM=\$2                                                             " >> $SCRIPT
echo "echo \$WORKDIR                                                      " >> $SCRIPT
echo "cd \$WORKDIR                                                        " >> $SCRIPT
if [ $SYSTEM -eq 0 ] ; then
echo "../SPAWN/dummy-mpi                                                  " >> $SCRIPT
fi
if [ $SYSTEM -eq 1 ] ; then
echo "ulimit -s unlimited                                                 " >> $SCRIPT
fi
#MERGE AND UPDATE LATERAL AND LOW BOUNDARY CONDITIONS           
echo "mv wrfinput_d01 wrfinput_d01.gfs                                    " >> $SCRIPT
echo "mv anal wrfinput_d01                                                " >> $SCRIPT
echo "echo \"&control_param                           \" > parame.in      " >> $SCRIPT
echo "echo \"da_file='./wrfinput_d01'                 \" >> parame.in     " >> $SCRIPT
echo "echo \"wrf_bdy_file='./wrfbdy_d01'              \" >> parame.in     " >> $SCRIPT
echo "echo \"wrf_input='./wrfinput_d01.gfs'           \" >> parame.in     " >> $SCRIPT
echo "echo \"debug=.true.                             \" >> parame.in     " >> $SCRIPT
echo "echo \"update_lateral_bdy=.true.                \" >> parame.in     " >> $SCRIPT
echo "echo \"update_low_bdy=.true.                    \" >> parame.in     " >> $SCRIPT
echo "echo \"update_lsm=.true.                        \" >> parame.in     " >> $SCRIPT
echo "echo \"iswater=16                               \" >> parame.in     " >> $SCRIPT
echo "echo \"/                                        \" >> parame.in     " >> $SCRIPT
echo "                                                                    " >> $SCRIPT
echo "./da_update_bc.exe > daupdatebc\${MEM}.log                          " >> $SCRIPT

chmod 766 $SCRIPT

}


#-------------------------------------------------------------------------------
# Edit multiple cycle script.
#-------------------------------------------------------------------------------
edit_multiplecycle () {

local SCRIPT=$1

local CONFFILE="${TMPDIR}/configuration/configuration.sh"
local MCONFFILE="${TMPDIR}/configuration/machine_configuration.sh"

#Set multiple cycle script.
sed -i 's/@@NODES@@/'${TOTAL_NODES_FORECAST}'/g'     $SCRIPT
sed -i 's/@@PPN@@/'${PROC_PER_NODE}'/g'              $SCRIPT
#For some reason pipe is requiered in this case or an error can occour.
sed -i 's|@@CONFFILE@@|'${CONFFILE}'|g'              $SCRIPT
sed -i 's|@@MCONFFILE@@|'${MCONFFILE}'|g'            $SCRIPT
sed -i 's/@@RESTART@@/'${RESTART}'/g'                $SCRIPT
sed -i 's/@@RESTARTDATE@@/'${RESTARTDATE}'/g'        $SCRIPT
sed -i 's/@@CONFIGURATION@@/'${CONFIGURATION}'/g'    $SCRIPT

#These are only for the logs.
sed -i 's/@@MYHOST@@/'${MYHOST}'/g'                  $SCRIPT
sed -i 's/@@PID@@/'${PID}'/g'                        $SCRIPT
sed -i 's/@@MYSCRIPT@@/'${MYSCRIPT}'/g'              $SCRIPT

sed -i 's/@@OUTPUTDIR@@/'${OUTPUTDIR}'/g'            $SCRIPT
sed -i 's/@@TMPDIR@@/'${TMPDIR}'/g'                  $SCRIPT

sed -i 's/@@GROUP@@/'${GROUP}'/g'                    $SCRIPT
sed -i 's/@@ELAPSE@@/'${ELAPSE}'/g'                  $SCRIPT
sed -i 's/@@QUEUE@@/'${QUEUE}'/g'                    $SCRIPT

}




safe_rm_tmpdir () {
#-------------------------------------------------------------------------------
# Safely remove a temporary directory
#
# Usage: safe_rm_tmpdir DIRNAME
#
#   DIRNAME  The temporary directory
#-------------------------------------------------------------------------------

local DIRNAME="$1"

#-------------------------------------------------------------------------------

if [ -z "$DIRNAME" ]; then
  echo "[Error] $FUNCNAME: '\$DIRNAME' is not set." >&2
  exit 1
fi
if [ ! -e "$DIRNAME" ]; then
  return 0
fi
if [ ! -d "$DIRNAME" ]; then
  echo "[Error] $FUNCNAME: '$DIRNAME' is not a directory." >&2
  exit 1
fi
if [ ! -O "$DIRNAME" -a $SYSTEM -eq 0 ]; then
  echo "[Error] $FUNCNAME: '$DIRNAME' is not owned by you." >&2
  exit 1
fi

rm -fr $DIRNAME
res=$? && ((res != 0)) && exit $res

#-------------------------------------------------------------------------------
}

safe_init_tmpdir () {
#-------------------------------------------------------------------------------
# Safely initialize a temporary directory
#
# Usage: safe_init_tmpdir DIRNAME
#
#   DIRNAME  The temporary directory
#-------------------------------------------------------------------------------

local DIRNAME="$1"

#-------------------------------------------------------------------------------

if [ -z "$DIRNAME" ]; then
  echo "[Warning] $FUNCNAME: '\$DIRNAME' is not set." 
  exit 1
fi

mkdir -p $DIRNAME
res=$? && ((res != 0)) && exit $res

if [ ! -d "$DIRNAME" ]; then
  echo "[Error] $FUNCNAME: '$DIRNAME' is not a directory." 
  exit 1
fi
if [ ! -O "$DIRNAME" -a $SYSTEM -eq 0 ]; then
  echo "[Error] $FUNCNAME: '$DIRNAME' is not owned by you." 
  exit 1
fi

rm -fr $DIRNAME/*
res=$? && ((res != 0)) && exit $res

mkdir -p $DIRNAME/LETKF
mkdir -p $DIRNAME/SCRIPTS

mkdir -p $DIRNAME/verification
mkdir -p $DIRNAME/WRF
mkdir -p $DIRNAME/UPP
mkdir -p $DIRNAME/add_pert
mkdir -p $DIRNAME/OBS
mkdir -p $DIRNAME/BOUNDARY
mkdir -p $DIRNAME/SPAWN
mkdir -p $DIRNAME/NAMELIST
mkdir -p $DIRNAME/POSTPROC
#Aditional executables for forecast jobs.
#if [ $FORECAST -eq 1 ] ; then
mkdir -p $DIRNAME/WPS
#mkdir -p $DIRNAME/wrf_to_wps
#fi


#-------------------------------------------------------------------------------
}

safe_init_outputdir () {
#-------------------------------------------------------------------------------
# Safely initialize a temporary directory
#
# Usage: safe_init_tmpdir DIRNAME
#
#   DIRNAME  The temporary directory
#-------------------------------------------------------------------------------

local DIRNAME="$1"

#-------------------------------------------------------------------------------
if [ $ANALYSIS -eq 1  ] ; then
 if [ -z "$DIRNAME" ]; then
   echo "[Warning] $FUNCNAME: '\$DIRNAME' is not set." 
   exit 1
 fi
 if [ -e "$DIRNAME" -a $RESTART -eq 0 ]; then
    echo "[Error] $DIRNAME exists: Please remove it manually to avoid data loss"
    exit 1
 fi
 if [ ! -e "$DIRNAME" -a $RESTART -eq 1 ]; then
    echo "[Error] $DIRNAME does not exist"
    exit 1
 fi
 if [ -e "$DIRNAME" -a $RESTART -eq 1 ]; then
   echo "[Warning] This is a restart experiment -> Using the previous output directory (data can be partially overwritten) " 
 fi
fi

if [ $FORECAST -eq 1  ] ; then
 if [ -z "$DIRNAME" ]; then
   echo "[Warning] $FUNCNAME: '\$DIRNAME' is not set."
   exit 1
 fi
 if [ -e "$DIRNAME" -a $RESTART -eq 1 ]; then
   echo "[Warning] This is a restart experiment -> Using the previous output directory (data can be partially overwritten) "
 fi
fi



mkdir -p $DIRNAME
res=$? && ((res != 0)) && exit $res

if [ ! -d "$DIRNAME" ]; then
  echo "[Error] $FUNCNAME: '$DIRNAME' is not a directory." 
  exit 1
fi
if [ ! -O "$DIRNAME" -a $SYSTEM -eq 0 ]; then
  echo "[Error] $FUNCNAME: '$DIRNAME' is not owned by you." 
  exit 1
fi

 if [ $RESTART -eq 0 ]  ; then 
   echo "This is a new experiment -> Building output directory from scracth"
 fi

 if [ $ANALYSIS -eq 1 ] ; then

 mkdir -p $DIRNAME/gues
 mkdir -p $DIRNAME/anal
 fi

 if [ $FORECAST -eq 1 ] ; then
   mkdir -p $DIRNAME/forecast/
 fi

 mkdir -p $DIRNAME/configuration
 mkdir -p $DIRNAME/joblogs


#-------------------------------------------------------------------------------
}

set_my_log () {

 local cont=1
 while [ $cont -ge 1  ] ; do
   if [ ! -e $OUTPUTDIR/log${cont}.log ] ; then
     my_log=$OUTPUTDIR/log${cont}.log
     cont=0
   else 
     cont=`expr $cont + 1 `
   fi
 done

}


generate_machinefile () {
#Generate machiene files (torque).

local TMPDIRL=$1    #Work directory
local NODEFILE=$2   #Current nodefile for this job
local max_jobs=$3   #Maximum simultaneous runs in this job
local ppm=$4        #Procs per member

if [ $SYSTEM -eq 1  ]; then  #TORQUE CLUSTER

  CONT=1
  JOB=1
  while read a ; do
   #Compute ensemble member prefix
   if [ $JOB -gt $max_jobs ] ; then
      echo "[Warning]: Maximum simultaneous job limit reached, some nodes will be unused"
      break
   fi
  
   if [ $CONT -gt 1 ] ; then
      echo $a >> $TMPDIRL/machinefile.$JOB
   else
      echo $a > $TMPDIRL/machinefile.$JOB
   fi

   CONT=`expr $CONT + 1 `
   if [ $CONT -gt $ppm  ] ; then
    CONT=1
    JOB=`expr $JOB + 1 `
   fi

  done  <  $NODEFILE

fi

if [ $SYSTEM -eq 0  ] ; then #K COMPUTER

 NODE=0
 JOB=1

  while [ $JOB -le $max_jobs ] ; do

   MNODE=1
   rm -fr $TMPDIRL/machinefile.${JOB}
   while [ $MNODE -le $NODES_PER_MEMBER ]; do
    echo "( $NODE ) " >> $TMPDIRL/machinefile.${JOB}
    MNODE=`expr $MNODE + 1 `
    NODE=`expr $NODE + 1 `
   done
   JOB=`expr $JOB + 1 `

  done

fi

}

get_node_list() {

 #NODELIST is an array containing the name of each avialable node
 #repeated the number of cores available in this node.


 if [  $SYSTEM -eq 2 ] ; then

  NNODES=1
  NODELIST[$NNODES]=$PPSSERVER

 fi

 if [  $SYSTEM -eq 1 ] ; then

  #Get the list of nodes.
  NNODES=1
  while read mynode  ; do
    NODELIST[$NNODES]=$mynode
    NNODES=`expr $NNODES + 1`
  done  <  $PBS_NODEFILE
  NNODES=`expr $NNODES - 1`

 fi

 if [ $SYSTEM -eq 0 ] ; then

  #Generate a list of nodes. This list will count several time each node
  #Each node will appera $PROC_PER_NODE times in the list. 
  NNODES=1
  local CNODES=1
  local CPROC=1

  while [ $CPROC -le $PROC_PER_NODE ] ; do
    while [ $CNODE -le $TOTAL_NODES_FORECAST ] ; do

      NODELIST[$NNODES]=$CNODE

      CNODE=`expr $CNODE + 1 `

      NNODES=`expr $NNODES + 1 `

    done

    CPROC=`expr $CPROC + 1 `

  done

  NNODES=`expr $NNODES - 1 `

 fi 

}

copy_data () {

#COPY LETKF
cp $LETKF $TMPDIR/LETKF/letkf.exe
cp $NAMELISTLETKF     $TMPDIR/NAMELIST/letkf.namelist.template
cp $NAMELISTPERTMETEM $TMPDIR/NAMELIST/pertmetem.namelist.template

#COPY WRF
cp $WRFMODEL/run/*         $TMPDIR/WRF/
rm -f $TMPDIR/WRF/*.exe    $TMPDIR/NAMELIST/namelist.input
cp $WRFMODEL/main/wrf.exe  $TMPDIR/WRF/
cp $WRFMODEL/main/real.exe $TMPDIR/WRF/
cp $ARWPOST/ARWpost.exe    $TMPDIR/WRF/
cp -r $ARWPOST/src         $TMPDIR/WRF/
cp $UPDATEBC               $TMPDIR/WRF/da_update_bc.exe
cp $NAMELISTWRF            $TMPDIR/NAMELIST/namelist.input.template
cp $NAMELISTARWPOST        $TMPDIR/NAMELIST/namelist.ARWpost.template

cp $INI_PERT_DATE_FILE     $TMPDIR/NAMELIST/ini_pert_date_file

#In case pps and computing nodes are different (as in K computer)
#then copy both wrf and real.
cp $WRFMODELPPS/main/real.exe $TMPDIR/WRF/realpps.exe
cp $WRFMODELPPS/main/wrf.exe  $TMPDIR/WRF/wrfpps.exe


if [ $SYSTEM -eq 0 ];then
#COPY SPAWN
cp $SPAWN/dummy-mpi $TMPDIR/SPAWN
cp $SPAWN/spawn     $TMPDIR/SPAWN
fi

#COPY PERTURBATION COMPUTATION CODE
cp $WRF/add_pert/*              $TMPDIR/add_pert/
#COPY OFFLINE OBSERBATION OPERATOR
cp $WRF/verification/obsope/obsope.exe $TMPDIR/verification/obsope.exe 
#COPY GRIDED VERIFICATION CODE
cp $WRF/verification/verify/verify.exe       $TMPDIR/verification/verify.exe

#ssh $PPSSERVER " cd $TMPDIR/add_pert && ./make_compute_pert_metem.sh >  $TMPDIR/add_pert/compile.log "

#COPY BASH SCRIPTS
cp $UTIL        $TMPDIR/SCRIPTS/util.sh
chmod 766 $TMPDIR/SCRIPTS/*.sh

#if [ $FORECAST -eq 1 -a $INTERPANA -eq 1 ] ; then
#COPY WPS
cp $NAMELISTWPS $TMPDIR/NAMELIST/namelist.wps.template
cp -r $WPS/* $TMPDIR/WPS/
mkdir $TMPDIR/WPS/GEOG
ln -sf $GEOG/* $TMPDIR/WPS/GEOG
rm -fr $TMPDIR/WPS/namelist*
#fi

 if [ ! -n "$RUN_CHEM" ] ; then
   RUN_CHEM=0
 fi
 if [ ! -n "$ENABLE_UPP" ] ; then
   ENABLE_UPP=0
 fi

 if [ $RUN_CHEM -eq 1 ] ; then
    cp $CHEM_DATA/* $TMPDIR/WRF/
 fi

#FOR UNIFIED POST PROCESSING
if [ $ENABLE_UPP -eq 1  ]; then

 cp ${WRFMODEL}/run/ETAMPNEW_DATA ${TMPDIR}/UPP/nam_micro_lookup.dat
 cp ${WRFMODEL}/run/ETAMPNEW_DATA.expanded_rain ${TMPDIR}/UPP/hires_micro_lookup.dat
  
 cp ${UPP}/bin/unipost.exe                                       ${TMPDIR}/UPP/

  CRTMDIR=${UPP}/src/lib/crtm2/src/fix
  cp $CRTMDIR/EmisCoeff/Big_Endian/EmisCoeff.bin                 ${TMPDIR}/UPP/
  cp $CRTMDIR/AerosolCoeff/Big_Endian/AerosolCoeff.bin           ${TMPDIR}/UPP/
  cp $CRTMDIR/CloudCoeff/Big_Endian/CloudCoeff.bin               ${TMPDIR}/UPP/
  cp $CRTMDIR/SpcCoeff/Big_Endian/imgr_g11.SpcCoeff.bin          ${TMPDIR}/UPP/
  cp $CRTMDIR/TauCoeff/ODPS/Big_Endian/imgr_g11.TauCoeff.bin     ${TMPDIR}/UPP/
  cp $CRTMDIR/SpcCoeff/Big_Endian/imgr_g12.SpcCoeff.bin          ${TMPDIR}/UPP/
  cp $CRTMDIR/TauCoeff/ODPS/Big_Endian/imgr_g12.TauCoeff.bin     ${TMPDIR}/UPP/
  cp $CRTMDIR/SpcCoeff/Big_Endian/imgr_g13.SpcCoeff.bin          ${TMPDIR}/UPP/
  cp $CRTMDIR/TauCoeff/ODPS/Big_Endian/imgr_g13.TauCoeff.bin     ${TMPDIR}/UPP/
  cp $CRTMDIR/SpcCoeff/Big_Endian/imgr_g15.SpcCoeff.bin          ${TMPDIR}/UPP/
  cp $CRTMDIR/TauCoeff/ODPS/Big_Endian/imgr_g15.TauCoeff.bin     ${TMPDIR}/UPP/
  cp $CRTMDIR/SpcCoeff/Big_Endian/imgr_mt1r.SpcCoeff.bin         ${TMPDIR}/UPP/
  cp $CRTMDIR/TauCoeff/ODPS/Big_Endian/imgr_mt1r.TauCoeff.bin    ${TMPDIR}/UPP/
  cp $CRTMDIR/SpcCoeff/Big_Endian/imgr_mt2.SpcCoeff.bin          ${TMPDIR}/UPP/
  cp $CRTMDIR/TauCoeff/ODPS/Big_Endian/imgr_mt2.TauCoeff.bin     ${TMPDIR}/UPP/
  cp $CRTMDIR/SpcCoeff/Big_Endian/imgr_insat3d.SpcCoeff.bin      ${TMPDIR}/UPP/
  cp $CRTMDIR/TauCoeff/ODPS/Big_Endian/imgr_insat3d.TauCoeff.bin ${TMPDIR}/UPP/
  cp $CRTMDIR/SpcCoeff/Big_Endian/amsre_aqua.SpcCoeff.bin        ${TMPDIR}/UPP/
  cp $CRTMDIR/TauCoeff/ODPS/Big_Endian/amsre_aqua.TauCoeff.bin   ${TMPDIR}/UPP/
  cp $CRTMDIR/SpcCoeff/Big_Endian/tmi_trmm.SpcCoeff.bin          ${TMPDIR}/UPP/
  cp $CRTMDIR/TauCoeff/ODPS/Big_Endian/tmi_trmm.TauCoeff.bin     ${TMPDIR}/UPP/
  cp $CRTMDIR/SpcCoeff/Big_Endian/ssmi_f13.SpcCoeff.bin          ${TMPDIR}/UPP/
  cp $CRTMDIR/TauCoeff/ODPS/Big_Endian/ssmi_f13.TauCoeff.bin     ${TMPDIR}/UPP/
  cp $CRTMDIR/SpcCoeff/Big_Endian/ssmi_f14.SpcCoeff.bin          ${TMPDIR}/UPP/
  cp $CRTMDIR/TauCoeff/ODPS/Big_Endian/ssmi_f14.TauCoeff.bin     ${TMPDIR}/UPP/
  cp $CRTMDIR/SpcCoeff/Big_Endian/ssmi_f15.SpcCoeff.bin          ${TMPDIR}/UPP/
  cp $CRTMDIR/TauCoeff/ODPS/Big_Endian/ssmi_f15.TauCoeff.bin     ${TMPDIR}/UPP/
  cp $CRTMDIR/SpcCoeff/Big_Endian/ssmis_f16.SpcCoeff.bin         ${TMPDIR}/UPP/
  cp $CRTMDIR/TauCoeff/ODPS/Big_Endian/ssmis_f16.TauCoeff.bin    ${TMPDIR}/UPP/
  cp $CRTMDIR/SpcCoeff/Big_Endian/ssmis_f17.SpcCoeff.bin         ${TMPDIR}/UPP/
  cp $CRTMDIR/TauCoeff/ODPS/Big_Endian/ssmis_f17.TauCoeff.bin    ${TMPDIR}/UPP/
  cp $CRTMDIR/SpcCoeff/Big_Endian/ssmis_f18.SpcCoeff.bin         ${TMPDIR}/UPP/
  cp $CRTMDIR/TauCoeff/ODPS/Big_Endian/ssmis_f18.TauCoeff.bin    ${TMPDIR}/UPP/
  cp $CRTMDIR/SpcCoeff/Big_Endian/ssmis_f19.SpcCoeff.bin         ${TMPDIR}/UPP/
  cp $CRTMDIR/TauCoeff/ODPS/Big_Endian/ssmis_f19.TauCoeff.bin    ${TMPDIR}/UPP/
  cp $CRTMDIR/SpcCoeff/Big_Endian/ssmis_f20.SpcCoeff.bin         ${TMPDIR}/UPP/
  cp $CRTMDIR/TauCoeff/ODPS/Big_Endian/ssmis_f20.TauCoeff.bin    ${TMPDIR}/UPP/ 
  cp $CRTMDIR/SpcCoeff/Big_Endian/seviri_m10.SpcCoeff.bin        ${TMPDIR}/UPP/
  cp $CRTMDIR/TauCoeff/ODPS/Big_Endian/seviri_m10.TauCoeff.bin   ${TMPDIR}/UPP/
  cp $CRTMDIR/SpcCoeff/Big_Endian/v.seviri_m10.SpcCoeff.bin      ${TMPDIR}/UPP/

  cp $NAMELISTUPP   ${TMPDIR}/UPP/

fi



}


copy_data_multiplecycles () {

#COPY GRIB
mkdir -p $TMPDIR/GRIB
mkdir -p $TMPDIR/PERTGRIB

cp -r $GRIBDIR/*     $TMPDIR/GRIB/
cp -r $PERTGRIBDIR/* $TMPDIR/PERTGRIB/

#COPY OBS 
#TODO copiar solo el rango de fechas del experimento.

if [ ! -z "$OBS" ] ; then
   echo "Copying $OBSDIR"
   mkdir -p $TMPDIR/OBS/
   cp $OBSDIR/obs_*.dat       $TMPDIR/OBS/  
fi

if [ ! -z "$RADAROBS" ] ; then
   echo "Copying $RADAROBSDIR"
   mkdir -p $TMPDIR/RADAROBS/
   cp -r $RADAROBSDIR/*.dat $TMPDIR/RADAROBS/
fi

#COPY RESTART DATA
if [ $RESTART -eq 1 ] ; then
 mkdir -p $TMPDIR/output
 mkdir -p $TMPDIR/output/anal

 cp -r $OUTPUTDIR/anal/$RESTARTDATE   $TMPDIR/output/anal/
 cp -r $OUTPUTDIR/*.log                $TMPDIR/output/
 cp    $OUTPUTDIR/initial_random_dates $TMPDIR/output/
fi

#COPY JOB SCRIPT ACCORDING TO JOB TYPE AND SYSTEM TYPE

if [ $FORECAST -eq 1 ] ; then

 if [ $SYSTEM -eq 1 ] ; then
  cp $CDIR/H_run_multiple_forecasts.sh                       $TMPDIR/SCRIPTS/
 fi
 if [ $SYSTEM -eq 0 ] ; then
  cp $CDIR/K_run_multiple_forecasts.sh                       $TMPDIR/SCRIPTS/
 fi

else
 if [ $SYSTEM -eq 1 ] ; then
  cp $CDIR/H_run_multiple_cycles.sh                       $TMPDIR/SCRIPTS/
 fi
 if [ $SYSTEM -eq 0 ] ; then
  cp $CDIR/K_run_multiple_cycles.sh                       $TMPDIR/SCRIPTS/ 
 fi
fi

#Save the current configuration files in the output directory.
mkdir -p $TMPDIR/configuration/

if [ $FORECAST -eq 1 ] ; then

 cp $CDIR/configuration/forecast_conf/${CONFIGURATION}.sh  $TMPDIR/configuration/configuration.sh  #Save experiment conf.

else

 cp $CDIR/configuration/analysis_conf/${CONFIGURATION}.sh  $TMPDIR/configuration/configuration.sh  #Save experiment conf.

fi

cp $CDIR/configuration/machine_conf/${MCONFIGURATION}.sh   $TMPDIR/configuration/machine_configuration.sh  #Save machine conf.

#Additional files to copy for forecast.

if [ $FORECAST -eq 1 ] ; then

   #Create directory to store analysis
   mkdir -p $TMPDIR/input/anal/

   #Copy the list of dates used to generate balanced perturbations in the analysis cycle.
   cp    $ANALYSIS_SOURCE/initial_random_dates $TMPDIR/NAMELIST/
   INPUT_PERT_DATES_FROM_FILE=1

   CDATE=$IDATE

   #Copy the LETKF-WRF initial conditions
   while [ $CDATE -le $EDATE  ] ; do
      cp -r $ANALYSIS_SOURCE/anal/$CDATE $TMPDIR/input/anal/
      CDATE=` date_edit2 $CDATE $WINDOW `
   done   

fi

}


set_cycle_dates () {

#DEFINE IMORTANT DATES FOR THE CURRENT CYCLE (YYYYMMDDHHNNSS)M
FDATE=`date_edit2 $CDATE $GUESFT `           #Forecast end date
ADATE=`date_edit2 $CDATE $WINDOW `           #Analysis date for the current cycle
WSDATE=`date_edit2 $CDATE $WINDOW_START `    #Assimilation window start date
WEDATE=`date_edit2 $CDATE $WINDOW_END   `    #Assimilation window end   date
#BDYDATE=`date_edit2 $CDATE $DINC   `         #Dummy date for boundary data preparation.


echo ">>> IMPORTANT DATES DEFINED IN THIS CYCLE"

echo ">>> FDATE=   $FDATE "
echo ">>> ADATE=   $ADATE "
echo ">>> WSDATE=  $WSDATE"
echo ">>> WEDATE=  $WEDATE"
#echo ">>> BDYDATE= $BDYDATE"

}


set_pre_processing_intervals ()  {

#Set the right frequencyes for the met_em_files generated from grib files.
#If the variable is not set then try to estimate a proper value.
if [ ! -n "$METEM_DATA_FREQ" ] ; then

 METEM_DATA_FREQ=`maximum_common_divisor $GUESFT $BOUNDARY_DATA_FREQ ` 

 #if [  $METEM_DATA_FREQ -eq 0 ] ; then
 #   METEM_DATA_FREQ=$BOUNDARY_DATA_FREQ
 #fi

fi

#TODO> This parameter should be removed.
#Compute DUMMY increment for boundary data preparation.
rest=`expr $GUESFT % $BOUNDARY_DATA_FREQ `
 if [ $rest -ne 0 ] ; then
  DINC=$GUESFT
 else
  DINC=`expr $GUESFT + $BOUNDARY_DATA_FREQ - $rest `
 fi


}


get_queue () {

local INPUT_NODE=$1

if [ $SYSTEM -eq 0  ] ; then

#Total nodes can be set in the configuration file (TOTAL_NODES_FORECAST / TOTAL_NODES_LETKF )or can be estimated here according to the number of ensemble members
#and procs per nodes.
   if [ $INPUT_NODE -ge 364 ] ; then
      local QEUE="large"
   fi
   if [ $INPUT_NODE -lt 364 ] ; then
      local QEUE="small" 
   fi

fi

echo $QEUE

}

save_configuration () {

local MYSCRPT=$1
local DESTDIR=$OUTPUTDIR/configuration/

#Save the current configuration files in the output directory.
if [ $FORECAST -eq 1 ] ; then

 cp $CDIR/configuration/forecast_conf/${CONFIGURATION}.sh  $DESTDIR/configuration.sh  #Save experiment conf.

else

 cp $CDIR/configuration/analysis_conf/${CONFIGURATION}.sh  $DESTDIR/configuration.sh  #Save experiment conf.

fi

cp $CDIR/configuration/machine_conf/${MCONFIGURATION}.sh  $DESTDIR/machine_configuration.sh  #Save machine conf.
cp -r $CDIR/configuration/domain_conf/$DOMAINCONF         $DESTDIR  #Save domain conf.
cp -r $MYSCRIPT                                           $DESTDIR  #Save main script.

}

run_ensemble_forecast_noqueue () {

#=====================================================================
# This function submits and waits for the ensemble forecast jobs.
# If one or more jobs fails then the jobs are re-done up to max_redo 
# times.
# If the number of ensemble members is larger than the maximum number
# of members per job (MAX_MEMBER_PER_JOB) then the job is splitted into
# several smaller jobs.
# Split jobs are submitted to the queue. There are a maximum of 
# MAX_SUBMITT_JOB simultaneous submissions.
#=====================================================================

max_redo=3   #Maximum number of retries.
my_redo=0 

while [ $my_redo -le $max_redo  ] ; do 

 echo "This is attemp number $my_redo to run the ensemble forecast"

 #Prepare and submit the jobs

 if [ $RUN_ONLY_MEAN -eq 1 ] ; then
  SINIMEMBER=$MEANMEMBER
  ENDMEMBER=$MEANMEMBER
 else
  INIMEMBER=1
  ENDMEMBER=$MEMBER
 fi
 

   
 #echo $INIMEMBER $ENDMEMBER $MEANMEMBER


 local IM=$INIMEMBER
 local EM=$ENDMEMBER
 local WORKDIR=$TMPDIR/run/wrf/

    tmp_mem=1
    my_test=0
    while [ $tmp_mem -le $EM ] ; do
      tmp_mem=`ens_member $tmp_mem`
      grep "SUCCESS COMPLETE WRF" ${WORKDIR}/wrf${tmp_mem}.log > /dev/null 2>&1
      tmp_test=$?
      if [ $tmp_test -ne 0 ]; then
        my_test=1
      fi
      tmp_mem=`expr $tmp_mem + 1 `
    done

    if [ $my_test -ne 0 ] ; then
#      run_forecast_script=rf_scr.sh

      echo "Calling run_forecast_sub that will run ensemble members from $IM to $EM " 
      run_forecast_sub $WORKDIR $IM $EM

	    
    fi


	 #Check how the jobs finished

	 error_check=0


	 IM=$INIMEMBER
	 EM=$ENDMEMBER
	 uy_job=1
	   
	   error_check=`check_forecast $WORKDIR $IM $EM `
   
	 #Take action according to forecast error check

	 if [ $error_check -eq 0 ] ; then
	    my_redo=`expr $max_redo + 1 ` #Break the cycle we are done!
	 else
           echo "[Warnning]: Ensemble run corresponding to ens member from $IM to $EM failed"
	   my_redo=`expr $my_redo + 1 `   #At least one job fail: redo!
	   if [ $my_redo -gt $max_redo ] ; then
	     #We cannot continue with the cycle
	     echo "[Error] : Forecast job fails more than $max_redo times "
	     echo "CYCLE ABNORMAL END -> ABORT EXECUTION "
	     exit 1
	   fi
	 fi


	done

	#Move the forecast to its final destination.

	move_forecast_data

}


move_forecast_data(){
#Copy data from the temporal directory to the final destination.
#Take into accoutn job split.

 if [ $RUN_ONLY_MEAN -eq 1 ] ; then
  INIMEMBER=$MEANMEMBER
  ENDMEMBER=$MEANMEMBER
 else
  INIMEMBER=1
  ENDMEMBER=$MEMBER
 fi



   WORKDIR=$TMPDIR/run/wrf/

   if [ $FORECAST -eq 1 ] ; then
      M=$INIMEMBER
      while [ $M -le $ENDMEMBER ] ; do
        MEM=`ens_member $M`
        mkdir -p ${RESULTDIRG}/${MEM}/
        cat ${WORKDIR}/WRF${MEM}/rsl.error.* > ${RESULTDIRG}/wrf${MEM}.log       
        mv  ${WORKDIR}/WRF${MEM}/daupdatebc${MEM}.log   ${RESULTDIRG}/
        mv  ${WORKDIR}/WRF${MEM}/wrfout* ${RESULTDIRG}/${MEM}/   
        M=`expr $M + 1 `
      done
   fi

   if [ $ANALYSIS -eq 1 ] ; then

    local LOCAL_OUTFREC=$WINDOW_FREC

    M=$INIMEMBER
    while [ $M -le $ENDMEMBER ] ; do

     MEM=`ens_member $M `

     local CDATEL=$WSDATE
     local it=1
     while [ ${CDATEL} -le ${WEDATE} ] ; do
       it=`add_zeros $it 2 `
       MYDOM=1
       #while [ $MYDOM -le $MAX_DOM ] ; do
         MYDOM=`add_zeros $MYDOM 2 `
         local_file=` wrfout_file_name $CDATEL $MYDOM`
         mv ${WORKDIR}/WRF${MEM}/$local_file $TMPDIR/LETKF/gs${it}${MEM}
       #done
       CDATEL=`date_edit2 $CDATEL $LOCAL_OUTFREC ` 
       it=`expr ${it} + 1`
     done
  
     cat ${WORKDIR}/WRF${MEM}/rsl.error.* > ${RESULTDIRG}/wrf${MEM}.log 
     mv  ${WORKDIR}/WRF${MEM}/daupdatebc${MEM}.log   ${RESULTDIRG}/
     rm  ${WORKDIR}/WRF${MEM}/wrfout*              
     
     cp ${TMPDIR}/LETKF/gs${NBSLOT}${MEM}   ${RESULTDIRG}/gues${MEM} 
     M=`expr $M + 1 `
    done
   fi

}


run_forecast_sub () {

   local WORKDIR=$1        #Work directory where scripts will be generated(optional)
   local INIMEMBER=$2      #Initialensemble member to be run in this job (optional)
   local ENDMEMBER=$3      #End ensemble member to be run in this job.    (optional)

   #echo "Scripts for ensemble members $INIMEMBER to $ENDMEMBER "
   #echo "will be generated in $WORKDIR "
   
      #Default ensemble range is the full ensemble
      if [ ! -n "$INIMEMBER" ] ; then
       INIMEMBER=1
      fi
      if [ ! -n "$ENDMEMBER" ] ; then
       ENDMEMBER=$MEMBER
      fi
      if [ $RUN_ONLY_MEAN -eq 1 ] ; then
       INIMEMBER=$MEANMEMBER
       ENDMEMBER=$MEANMEMBER
      fi
      #Default workdir is TMPDIR/SCRIPTS
      if [ ! -n "$WORKDIR"  ] ; then
       WORKDIR=$TMPDIR/run/
      fi

      mkdir -p $WORKDIR
#      local_script=$WORKDIR/$local_script 

   #CREATE THE SCRIPT TO BE SUBMITED TO K COMPUTER
   # CREATE NAMELIST FOR REAL AND WRF
   rm -fr $WORKDIR/namelist.input*
 
   cp $TMPDIR/NAMELIST/namelist.input.template $WORKDIR/namelist.input

   edit_namelist_input $WORKDIR/namelist.input $CDATE $FDATE $WINDOW_FREC $METEM_DATA_FREQ  #For wrf

   #cp $WORKDIR/namelist.input $WORKDIR/namelist.input $RESULTDIRG

   # CREATE AUXILIARY RUNNING SCRIPTS
   edit_wrf_pre  $WORKDIR/WRF_PRE.sh
   edit_wrf_real $WORKDIR/WRF_REAL.sh
   edit_wrf_wrf  $WORKDIR/WRF_WRF.sh

      
      if [ ! -n "$ELAPSE_FORECAST" ] ; then
       ELAPSE_FORECAST=$ELAPSE
      fi
      if [ ! -n "$TOTAL_PROC_FORECAST" ] ; then
       TOTAL_PROC_FORECAST=$TOTAL_NODES
      fi
      if [ ! -n "$TOTAL_NODES_FORECAST" ] ; then
       TOTAL_NODES_FORECAST=$TOTAL_NODES
      fi
      if [ ! -n "$USE_ANALYSIS_IC" ] ; then
       USE_ANALYSIS_IC=0
       echo "[Warning]: USE_ANALYSIS_IC is not set will asume 0 and use LETKF analysis as IC data."
      fi

      local do_wrf_pre=0
      if [ $USE_ANALYSIS_IC -eq 0 -a $FORECAST -eq 1 ] ; then
          do_wrf_pre=1
      fi
      if [ $USE_ANALYSIS_IC -eq 0 -a $ANALYSIS -eq 1 ] ; then
        if [ $ITER -gt 1 ] ; then
          do_wrf_pre=1
        fi
      fi
      TOTAL_PROCS_FORECAST=`expr $TOTAL_NODES_FORECAST \* $PROC_PER_NODE ` 
      MAX_SIMULTANEOUS_JOBS=`expr $TOTAL_PROCS_FORECAST \/ $PROC_PER_MEMBER `

      if [ $MAX_SIMULTANEOUS_JOBS -gt $MAX_BACKGROUND_JOBS  ] ; then
         echo "[Error]: The number of requested nodes is too many!"
         echo "We can't use them all to run the ensemble"
         echo "Please revise configuration accordingly"
         echo "MAX_SIMULTANEOUS_JOBS=$MAX_SIMULTANEOUS_JOBS"
         echo "MAX_BACKGROUND_JOBS=$MAX_BACKGROUND_JOBS"
         exit 1
       fi


      #Prepare run directory.
      if [ $ANALYSIS -eq 1 ] ; then
         local local_dir="$OUTPUTDIR/anal/${CDATE}/"
      fi
      if [ $FORECAST -eq 1 ] ; then 
         local local_dir="$ANALYSIS_SOURCE/anal/${CDATE}/"
      fi

      M=$INIMEMBER
      while [ $M -le $ENDMEMBER ] ; do
         MEM=`ens_member $M`
         mkdir -p $WORKDIR/WRF$MEM/
         ln -sf $TMPDIR/WRF/* $WORKDIR/WRF$MEM/
         M=`expr $M + 1 `
      done

      #Link boundary data.
      M=$INIMEMBER
      while [ $M -le $ENDMEMBER ] ; do
       MEM=`ens_member $M`
       ln -sf $TMPDIR/BOUNDARY/INPUT/${MEM}/*  $WORKDIR/WRF$MEM/  
       M=`expr $M + 1 `
      done
      #Link initial conditions
      if [ $ANALYSIS -eq 1 ] ; then
         local local_dir="$OUTPUTDIR/anal/${CDATE}/"
      fi
      if [ $FORECAST -eq 1 ] ; then
         local local_dir="$ANALYSIS_SOURCE/anal/${CDATE}/"
      fi

      if [ $ITER -gt 1 -o $FORECAST -eq 1 ] ; then
        if [ $USE_ANALYSIS_IC -eq 0 ] ; then
        M=$INIMEMBER
        while [ $M -le $ENDMEMBER ] ; do
         MEM=`ens_member $M`
         cp ${local_dir}/anal$MEM  $WORKDIR/WRF$MEM/anal 
         M=`expr $M + 1 `
        done
       fi
      fi


      if [ $SYSTEM -eq 1 ] ; then 
       generate_machinefile $WORKDIR $PBS_NODEFILE $MAX_SIMULTANEOUS_JOBS $PROC_PER_MEMBER 
      fi
      if [ $SYSTEM -eq 0 ] ; then
       generate_machinefile $WORKDIR null $MAX_SIMULTANEOUS_JOBS $NODES_PER_MEMBER 
      fi
      cd $WORKDIR                                             
      #export LD_LIBRARY_PATH=$LD_LIBRARY_PATH       
 
      M=$INIMEMBER
      while [  $M -le $ENDMEMBER ] ; do
       MEM=`ens_member $M `
        cp ${WORKDIR}/namelist.input  ${WORKDIR}/WRF${MEM}/namelist.input 
       M=`expr $M + 1 `
      done
  
     M=$INIMEMBER
     while [  $M -le $ENDMEMBER ] ; do
      JOB=1
      while [  $JOB -le $MAX_SIMULTANEOUS_JOBS -a $M -le $ENDMEMBER ] ; do
      MEM=`ens_member $M `
         sleep 0.5
         if [ $SYSTEM -eq 1 ] ; then
           $MPIBIN -np ${PROC_PER_MEMBER} -f $WORKDIR/machinefile.${JOB} $WORKDIR/WRF_REAL.sh $WORKDIR/WRF${MEM}/ > $WORKDIR/WRF${MEM}/real.log & 
           #$MPIBIN -np ${PROC_PER_MEMBER} -f $PBS_NODEFILE $WORKDIR/WRF_REAL.sh $WORKDIR/WRF${MEM}/ > $WORKDIR/WRF${MEM}/real.log &
         fi
         if [  $SYSTEM -eq 0 ] ; then
           $MPIBIN -np ${NODE_PER_MEMBER} --vcoordfile $WORKDIR/machinefile.${JOB} $WORKDIR/WRF_REAL.sh $WORKDIR/WRF${MEM}/ > $WORKDIR/WRF${MEM}/real.log & 
         fi 
         JOB=`expr $JOB + 1 `
         M=`expr $M + 1 `
      done
      time wait 
     done

 
     if [ $do_wrf_pre -eq 1 ] ; then #Update lateral and lower boundary conditions.
      M=$INIMEMBER
      while [  $M -le $ENDMEMBER ];do
       JOB=1
       while [  $JOB -le $MAX_SIMULTANEOUS_JOBS -a $M -le $ENDMEMBER ];do
       MEM=`ens_member $M `
         sleep 0.5
         if [ $SYSTEM -eq 1 ] ; then
           $MPIBIN -np 1 -f $WORKDIR/machinefile.${JOB}  $WORKDIR/WRF_PRE.sh $WORKDIR/WRF${MEM} ${MEM} &
           #$MPIBIN -np 1 -f $PBS_NODEFILE  $WORKDIR/WRF_PRE.sh $WORKDIR/WRF${MEM} ${MEM} &
         fi
         if [  $SYSTEM -eq 0 ] ; then
           echo ${NODELIST[$MYNODE]} > ./tmp_machinefile
           $MPIBIN -np 1 --vcoordfile $WORKDIR/machinefile.${JOB} $WORKDIR/WRF_PRE.sh $WORKDIR/WRF${MEM} ${MEM}  &
         fi
         #$WORKDIR/WRF_PRE.sh $WORKDIR/WRF${MEM} ${MEM} & 
         JOB=`expr $JOB + 1 `
         M=`expr $M + 1 `
       done
       time wait
      done      
     fi
        
     M=$INIMEMBER
     while [  $M -le $ENDMEMBER ] ; do
      JOB=1
      while [  $JOB -le $MAX_SIMULTANEOUS_JOBS -a $M -le $ENDMEMBER ] ; do
      MEM=`ens_member $M `
         sleep 0.5
         if [ $SYSTEM -eq 1 ] ; then
          $MPIBIN -np ${PROC_PER_MEMBER} -f ${WORKDIR}/machinefile.${JOB} ${WORKDIR}/WRF_WRF.sh ${WORKDIR}/WRF${MEM} > ${WORKDIR}/WRF${MEM}/wrf.log &  
          #$MPIBIN -np 1 -f $PBS_NODEFILE  ${WORKDIR}/WRF_WRF.sh ${WORKDIR}/WRF${MEM} > ${WORKDIR}/WRF${MEM}/wrf.log &
         fi
         if [ $SYSTEM -eq 0 ] ; then
          $MPIBIN -np ${NODE_PER_MEMBER} --vcoordfile $WORKDIR/machinefile.${JOB} $WORKDIR/WRF_WRF.sh $WORKDIR/WRF${MEM} > $WORKDIR/WRF${MEM}/wrf.log &
         fi
         JOB=`expr $JOB + 1 `
         M=`expr $M + 1 `
      done
      time wait 
     done 


}

run_letkf_noqueue () {


#=====================================================================
# This function runs letkf but assuming not queue is necessary.
# Usually this function will be used in a multiple cycle job.
#=====================================================================

      #Link the observations

      rm $TMPDIR/LETKF/obs*.dat

      get_observations $TMPDIR/LETKF

      #Prepare and run the jobs

#      local_script=$1

      # CREATE NAMELIST FOR LETKF
      rm -fr $TMPDIR/LETKF/letkf.namelist

      cp $TMPDIR/NAMELIST/letkf.namelist.template $TMPDIR/LETKF/letkf.namelist
      edit_namelist_letkf $TMPDIR/LETKF/letkf.namelist
 
      # COPY NAMELIST TO OUTPUT DIRECTORY
      cp $TMPDIR/LETKF/letkf.namelist $RESULTDIRA

      if [ ! -n "$ELAPSE_LETKF" ] ; then
       ELAPSE_LETKF=$ELAPSE
      fi
      if [ ! -n "$TOTAL_NODES_LETKF" ] ; then
       TOTAL_NODES_LETKF=$TOTAL_NODES
      fi
      if [ ! -n "$USE_ADAPTIVE_INFLATION" ] ; then
       USE_ADAPTIVE_INFLATION=0
      fi
      if [ $USE_ADAPTIVE_INFLATION -eq 1 ] ; then
       if [ $ITER -gt 4 ] ; then
         inflation_date=`date_edit2 $ADATE -86400 `
         INFLATION_FILE=$OUTPUTDIR/anal/${inflation_date}/infl_mul.grd 
       else
         inflation_date=`echo $CDATE | cut -c9-14 `
         INFLATION_FILE=$INPUTDIR/initial_inf/${inflation_date}/infl_mul.grd
       fi
      fi

      TOTAL_PROC_LETKF=`expr $TOTAL_NODES_LETKF \* $PROC_PER_NODE `

      if [ $USE_ADAPTIVE_INFLATION -eq 1 ] ; then
        cp ${INFLATION_FILE}  $TMPDIR/LETKF/   
      fi
  
      #In order to set ulimit -s unlimited on each working node we need to wrap the executable into this run script that 
      #will be called by mpiexec. 
      echo "#!/bin/bash                                                                   " >  $TMPDIR/LETKF/run_letkf.sh
      echo "ulimit -s unlimited                                                           " >> $TMPDIR/LETKF/run_letkf.sh
      echo "export LD_LIBRARY_PATH=$RUNTIMELIBS:\$LD_LIBRARY_PATH                         " >> $TMPDIR/LETKF/run_letkf.sh
      echo "./letkf.exe                                                                   " >> $TMPDIR/LETKF/run_letkf.sh
      chmod 755 $TMPDIR/LETKF/run_letkf.sh
 

#      echo "#!/bin/bash                                                                                       " >  $local_script
#      echo "SYSTEM=$SYSTEM                                                                                    " >> $local_script
      cd $TMPDIR/LETKF       
      #export LD_LIBRARY_PATH=$LD_LIBRARY_PATH    
      MM=`ens_member ${MEANMEMBER}`
      MEM=`ens_member ${MEMBER}`
      #CREATE THE FILES WHERE THE GUES AND ANAL ENSEMBLE MEANS WILL BE STORED.
      cp gs${NBSLOT}${MEM} gues${MM}   
      cp gs${NBSLOT}${MEM} anal${MM}  
      if [ $SYSTEM -eq 1 ] ; then
       generate_machinefile $TMPDIR/LETKF/ $PBS_NODEFILE 1 $TOTAL_PROC_LETKF   
       time $MPIBIN -np ${TOTAL_PROC_LETKF} -f $TMPDIR/LETKF/machinefile.1 $TMPDIR/LETKF/run_letkf.sh 
      fi
      if [ $SYSTEM -eq 0 ] ; then
       generate_machinefile $TMPDIR/LETKF/ null 1 $TOTAL_PROC_LETKF     
       time $MPIBIN -np ${TOTAL_NODE_LETKF} --vcoordfile $TMPDIR/LETKF/machinefile.1 $TMPDIR/LETKF/run_letkf.sh  
      fi

   #COPY DATA TO THE FINAL DESTINATION DIR.
   M=1
   while [ $M -le $MEMBER ] ; do
     MEM=`ens_member $M`
     mv $TMPDIR/LETKF/gs${NBSLOT}${MEM}   ${RESULTDIRA}/anal${MEM}
     M=`expr $M + 1 `
   done
   MEM=`ens_member ${MEANMEMBER}`
   mv ${TMPDIR}/LETKF/gues${MEM}            ${RESULTDIRG}/
   mv ${TMPDIR}/LETKF/anal${MEM}            ${RESULTDIRA}/
   mv ${TMPDIR}/LETKF/NOUT*                 ${RESULTDIRA}/

   if [ $USE_ADAPTIVE_INFLATION -eq 1 ] ; then
     mv $TMPDIR/LETKF/infl_mul.grd          ${RESULTDIRA}/
   fi


   #Check how the jobs finished
   local error_check=0
   local MMS=`ens_member $MEANMEMBER`
   if [ ! -e ${RESULTDIRA}/anal$MMS ] ; then
     echo "[Error]: Cannot find analysis ensemble mean."
     error_check=1
   fi
   grep  "PARTIAL OBSERVATIONAL DEPARTURE" ${RESULTDIRA}/NOUT-000 > null
   if [ $? -ne 0  ] ; then
    echo "[Error]: LETKF do not finish properly."
    tail ${RESULTDIRA}/NOUT-000
    error_check=1
   fi

   if [ $error_check -ne 0 ] ; then
     echo "[Warning] : Letkf-DA attemp $my_redo fails." 
     echo "CYCLE ABNORMAL END -> ABORT EXECUTION "
     exit 1
   fi

      
}

get_observations() {

#Go trough all possible observation types (incorporated into this system)
#and link them to the corresponding folder.

local DESTDIR=$1

if [ ! -n "$OBS" ] ; then
  echo "[Warning]: OBS not set we will continue without conventional obs"

else
 
  get_conventional_observations $DESTDIR

fi

if [ ! -n "$RADAROBS" ] ; then
  echo "[Warning]: RADAROBS not set we will continue without radar obs"
else

  get_radar_observations $DESTDIR

fi

}

get_conventional_observations () {

 local DESTDIR=$1

 local CDATEL=$WSDATE

 local it=1
 while [ ${CDATEL} -le ${WEDATE}  ] ; do
   it=`add_zeros $it 2 `
   OBSFILE=$OBSDIR/obs_${CDATEL}.dat
   echo $OBSFILE
   echo cp -f $OBSFILE $DESTDIR/obs${it}.dat
   if [ -e $OBSFILE ] ; then
    cp -f $OBSFILE $DESTDIR/obs${it}.dat
    echo cp -f $OBSFILE $DESTDIR/obs${it}.dat
   fi
   it=`expr ${it} + 1 `
   CDATEL=`date_edit2 ${CDATEL} ${WINDOW_FREC}`
 done

}


get_radar_observations () {

local DESTDIR=$1

local CDATEL=$WSDATE

local itradar=1

while [ $itradar -le $NRADARS  ] ; do
if [ $itradar -lt 10 ] ; then
  itradar=0$itradar
fi

  local it=1
  while [ ${CDATEL} -le ${WEDATE}  ] ; do    
   it=`add_zeros $it 2 `
 
   OBSFILE=$RADAROBSDIR/radar${itradar}_${CDATEL}.dat

  if [ -e $OBSFILE ] ; then
   cp -f $OBSFILE $DESTDIR/rad${it}${itradar}.dat
   echo $OBSFILE
  fi

  it=`expr ${it} + 1 `
  CDATEL=`date_edit2 ${CDATEL} ${WINDOW_FREC}`
done

itradar=`expr ${itradar} + 1`
done

}



get_domain() {

local WORKDIR=$TMPDIR/domain
local DUMMYDATE=20000101000000

mkdir -p $WORKDIR

local local_script=$WORKDIR/get_domain.sh

cd $WORKDIR

#GENERATE THE SCRIPT TO GENERATE STATIC FIELDS.
echo "#!/bin/bash                                                               "  > $local_script            
echo "set -x                                                                    " >> $local_script
echo "MAX_DOM=$MAX_DOM                                                          " >> $local_script
echo "DATE=$DUMMYDATE               #DUMMY DATE                                 " >> $local_script
echo "BOUNDARY_DATA_FREQ=$BOUNDARY_DATA_FREQ #Boundary data frequency (seconds) " >> $local_script
echo "source $TMPDIR/SCRIPTS/util.sh                                            " >> $local_script

echo "ulimit -s unlimited                                                       " >> $local_script
echo "export LD_LIBRARY_PATH=$RUNTIMELIBS:\$LD_LIBRARY_PATH                     " >> $local_script
echo "mkdir -p $WORKDIR                                                         " >> $local_script
echo "cd $WORKDIR                                                               " >> $local_script
echo "rm -fr  $WORKDIR/geo_em*                                                  " >> $local_script

#################################################
#   CYCLE TO CREATE GEO_EM FOR DIFFERENT DOMAINS
#################################################

echo "   ln -sf  $TMPDIR/WPS/*             ./                                  " >> $local_script
echo "   rm ./namelist.wps                                                     " >> $local_script
echo "   cp $TMPDIR/NAMELIST/namelist.wps.template ./namelist.wps              " >> $local_script
echo "   edit_namelist_wps ./namelist.wps \$DATE \$DATE \$BOUNDARY_DATA_FREQ   " >> $local_script
echo "   ./geogrid.exe > ./geogrid.log                                         " >> $local_script

#We are done!
chmod 766 $local_script

echo " Generating domain "

ssh $PPSSERVER " $local_script > $TMPDIR/domain/get_domain.log  2>&1 " 

}


get_met_em_from_grib_noqueue () {

#This function generates the unperturbed met_em files from grib data.
#It can generate a met_em file for an arbitrary time by time interpolationg met_em files

local EXEC=$TMPDIR/add_pert/time_interp_metem.exe

if [ ! -n "$MEMBER_BDY" ] ; then
   MEMBER_BDY=1
   echo "[Warning]: Number of boundary conditions ensemble members not set. Assuming NENS_BDY=1"
fi

if [ $RUN_ONLY_MEAN -eq 1 ] ; then
   local INIMEMBER=$MEANMEMBER  #Run only the last member.
   local ENDMEMBER=$MEANMEMBER
   local INIMEMBER_BDY=$MEANMEMBER_BDY
   local ENDMEMBER_BYD=$MEANMEMBER_BDY
else
   local INIMEMBER=1
   local ENDMEMBER=$MEMBER
   local INIMEMBER_BDY=1
   if [ $MEMBER_BDY -ge $MEMBER  ];then
      local ENDMEMBER_BDY=$MEMBER
   else
      local ENDMEMBER_BDY=$MEMBER_BDY
   fi
fi


if [ ! -n "$USE_ANALYSIS_BC" ] ; then
   USE_ANALYSIS_BC=1
  echo "[Warning]: USE_ANALYSIS_BC is not set will asume 1 and use global analaysis as BC data."
fi

if [ $USE_ANALYSIS_BC -eq 1 ] ; then
   local GRIBDIR=$GRIBDIR/
   echo " Using global analysis as Boundary conditions "
fi
if [ $USE_ANALYSIS_BC -eq 0 ] ; then
   local GRIBDIR=$GRIBDIR/$CDATE/
   echo " Using global forecast as Boundary conditions "
fi

if [ ! -e $GRIBDIR ] ; then
   echo "[Error]: Can not find BC data in $GRIBDIR "
   exit
fi

#CHECK IF WE HAVE geo_em.d?? IF NOT CREATE THEM.
		
if [ ! -e $TMPDIR/domain/geo_em.d01.nc ] ; then
   get_domain
fi


#FIRST STEP: GENERATE MET_EMS FROM THE NENS_BDY BOUNDARY CONDITIONS ENSEMBLE MEMBERS.

METEMDIR=$TMPDIR/BOUNDARY/INPUT_ORIG/

mkdir -p $METEMDIR

cd $METEMDIR

local local_script=$METEMDIR/get_met_em_from_grib.sh

#GENERATE THE SCRIPT TO GET UNPERTURBED MET_EM FILE FOR THE CURRENT TIME.
echo "#!/bin/bash                                                                 "  > $local_script            
echo "set -x                                                                      " >> $local_script
echo "source $TMPDIR/SCRIPTS/util.sh                                              " >> $local_script
echo "ulimit -s unlimited                                                         " >> $local_script
echo "export LD_LIBRARY_PATH=$RUNTIMELIBS:\$LD_LIBRARY_PATH                       " >> $local_script
echo "MEM=\$1                                                                     " >> $local_script
echo "mkdir -p $METEMDIR/\${MEM}/WORK                                             " >> $local_script
echo "cd $METEMDIR/\${MEM}/WORK                                                   " >> $local_script
if [ $SYSTEM -eq 0 ] ; then
  echo "$TMPDIR/SPAWN/dummy-mpi                                                   " >> $local_script
fi

#################################################
#   CYCLE TO CREATE THE UNPERTURBED MET_EM
#################################################
#TODO: This function will be much more efficient if time interpolation is performed for the 
#intermediate file format and not with the met_em format.

 echo "CDATE=$CDATE                                                               " >> $local_script
 echo "MAX_DOM=$MAX_DOM                                                           " >> $local_script
 echo "while [  \$CDATE -le $FDATE ] ; do                                         " >> $local_script
 echo "CFILE=\`met_em_file_name \$CDATE 01 \`                                     " >> $local_script
 echo "CDATE1=\`date_floor \$CDATE  $BOUNDARY_DATA_FREQ \`                        " >> $local_script 
 echo "CDATE2=\`date_edit2 \$CDATE1 $BOUNDARY_DATA_FREQ \`                        " >> $local_script

 echo "TMPFILE1=\`met_em_file_name \$CDATE1 01 \`                                 " >> $local_script
 echo "TMPFILE2=\`met_em_file_name \$CDATE2 01 \`                                 " >> $local_script
    #IF perturbed met_ems are not present generate them                            
    echo "if [  ! -e  \$TMPFILE1 ] ; then                                          " >> $local_script                                                              
    echo "   ln -sf  $TMPDIR/WPS/*             ./                                  " >> $local_script
    echo "   ln -sf  $TMPDIR/domain/*.nc       ./                                  " >> $local_script
    echo "   rm ./namelist.wps                                                     " >> $local_script
    echo "   cp $TMPDIR/NAMELIST/namelist.wps.template ./namelist.wps              " >> $local_script
    echo "   edit_namelist_wps ./namelist.wps \$CDATE1 \$CDATE1 $BOUNDARY_DATA_FREQ   " >> $local_script
    echo "   ./link_grib.csh $GRIBDIR/\${MEM}/\${CDATE1}.grb                       " >> $local_script
    echo "   rm ./Vtable ; ln -sf ./ungrib/Variable_Tables/$GRIBTABLE  ./Vtable    " >> $local_script
    echo "   ./ungrib.exe > ./ungrib.log                                           " >> $local_script
    echo "   ./metgrid.exe > ./metgrid.log                                         " >> $local_script
    echo "fi                                                                       " >> $local_script

    echo "if [ ! -e  \$TMPFILE2 ] ; then                                           " >> $local_script
    echo "   ln -sf  $TMPDIR/WPS/*                     ./                          " >> $local_script
    echo "   ln -sf  $TMPDIR/domain/*.nc               ./                          " >> $local_script
    echo "   rm ./namelist.wps                                                     " >> $local_script
    echo "   cp $TMPDIR/NAMELIST/namelist.wps.template ./namelist.wps              " >> $local_script
    echo "   edit_namelist_wps ./namelist.wps \$CDATE2 \$CDATE2 $BOUNDARY_DATA_FREQ   " >> $local_script
    echo "   ./link_grib.csh $GRIBDIR/\${MEM}/\${CDATE2}.grb                       " >> $local_script
    echo "   rm ./Vtable ; ln -sf ./ungrib/Variable_Tables/$GRIBTABLE  ./Vtable    " >> $local_script
    echo "   ./ungrib.exe > ./ungrib.log                                           " >> $local_script
    echo "   ./metgrid.exe > ./metgrid.log                                         " >> $local_script
    echo "fi                                                                       " >> $local_script
    echo "rm $TMPDIR/FILE*                                                       " >> $local_script
    #Copy the unperturbed met_em file (this one will be modified).

local my_domain=1

while [ $my_domain -le $MAX_DOM ] ; do

    my_domain=`add_zeros $my_domain 2 `
    echo "CFILE=\`met_em_file_name \$CDATE $my_domain \`                           " >> $local_script
    echo "if [  ! -e  $METEMDIR/\${MEM}/\$CFILE ] ; then                           " >> $local_script  #If CFILE is present we can go to the next time.
    echo "TMPFILE1=\`met_em_file_name \$CDATE1 $my_domain \`                       " >> $local_script
    echo "TMPFILE2=\`met_em_file_name \$CDATE2 $my_domain \`                       " >> $local_script
    echo "   cp \$TMPFILE1  \$CFILE                                                " >> $local_script
    echo "   ln -sf \$CFILE ./ctrl_met_em.nc                                       " >> $local_script
    echo "   ln -sf \$TMPFILE1 ./input_file1.nc                                    " >> $local_script
    echo "   ln -sf \$TMPFILE2 ./input_file2.nc                                    " >> $local_script
    echo "   chmod 766 ./ctrl_met_em.nc                                            " >> $local_script
    echo "   CDATEWRF=\`date_in_wrf_format \$CDATE \`                              " >> $local_script
    echo "   $EXEC \$CDATEWRF                                                      " >> $local_script
    echo "   mv  \$CFILE $METEMDIR/\${MEM}/                                        " >> $local_script
    echo "fi                                                                       " >> $local_script  #End if over CFILE existance

    my_domain=`expr $my_domain + 1 `
done

    echo "CDATE=\`date_edit2 \$CDATE $METEM_DATA_FREQ \`                           " >> $local_script
    echo "done                                                                     " >> $local_script  #End do for time loop


 chmod 766 $local_script


 M=$INIMEMBER_BDY
 while [ $M -le $ENDMEMBER_BDY ] ; do
  RUNNING=0
  while [ $RUNNING -le $MAX_RUNNING -a $M -le $ENDMEMBER_BDY ] ; do
    sleep  0.3
    MEM=`ens_member $M `

    ssh ${PPSSERVER} "${WORKDIR}/$local_script $MEM  2>&1 " &

    M=`expr $M + 1`
    RUNNING=`expr $RUNNING + 1`

  done 

  time wait

 done


 echo "Finish coputation of unperturbed met_em"

#SO FAR WE HAVE INTERPOLATED BDY CONDITIONS FILES TO THE REQUIRED TIME AND FOR EACH BDY ENSEMBLE MEMBER. 
#IF THE BDY ENSEMBLE SIZE IS SMALLER THAN THE REQUIRED ENSEMBLE SIZE THEN WE NEED TO MAP THE BDY ENSEMBLE TO THE NESTED 
#ENSEMBLE SIZE. WE DO THIS BY REPEATING SOME ENSEMBLE MEMBERS.
#NOTE THAT IF SOME ENSEMBLE MEMBERS ARE REPEATED, THEN OTHER PERTURBATION METHODS NEEDS TO BE IMPLEMENTED IN ORDER TO GENERATE DIFFERENCES AMONG THE DUPLICATED MEMBERS.

if [ $RUN_ONLY_MEAN -eq  1  ] ; then

    #In this case we rename the output
    MEMB=`ens_member $MEANMEMBER_BDY `
    MEMM=`ens_member $MEANMEMBER `
    mv $METEMDIR/$MEMB $METEMDIR/$MEMM

else

 if [  $ENDMEMBER_BDY -lt $ENDMEMBER  ] ; then
 #We need to map the BDY ensemble to the NESTED ensemble.

  local INIMEMBER=`expr $ENDMEMBER_BDY + 1`
  MEM=$INIMEMBER     
  while [ $MEM -le $ENDMEMBER  ] ;  do
      BDY_MEM=1
      while [ $BDY_MEM -le $ENDMEMBER_BDY -a $MEM -le $ENDMEMBER ] ; do
          MEMB=`ens_member $BDY_MEM `
          MEMM=`ens_member $MEM `
          mkdir -p $METEMDIR/$MEMM
          TMPDATE=$CDATE
          while [  $TMPDATE -le $FDATE ] ; do 
               local my_domain=1 
               while [ $my_domain -le $MAX_DOM ] ; do
                  my_domain=`add_zeros $my_domain 2 `
                  CFILE=`met_em_file_name $TMPDATE $my_domain`
                  cp $METEMDIR/$MEMB/$CFILE $METEMDIR/$MEMM/
                  my_domain=`expr $my_domain + 1 `
               done
               TMPDATE=`date_edit2 $TMPDATE $METEM_DATA_FREQ `
          done 
          BDY_MEM=`expr $BDY_MEM + 1 `
          MEM=`expr $MEM + 1 `
      done
   done

 fi

fi

}


perturb_met_em_from_grib_noqueue () {

local EXEC=$TMPDIR/add_pert/compute_pert_metem.exe
local EXECTI=$TMPDIR/add_pert/time_interp_metem.exe


if [ $RUN_ONLY_MEAN -eq 1 ] ; then
   local INIMEMBER=$MEANMEMBER  #Run only the last member.
   local ENDMEMBER=$MEANMEMBER
else
   local INIMEMBER=1
   local ENDMEMBER=$MEMBER
fi

if [ ! -n "$USE_ANALYSIS_BC" ] ; then
   USE_ANALYSIS_BC=1
   echo "[Warning]: USE_ANALYSIS_BC is not set will asume 1 and use global analaysis as BC data."
fi
if [ ! -n "$PERTURB_ONLY_MOAD" ] ; then
   PERTURB_ONLY_MOAD=1
fi

local PERTDATEDIR=$INPUTDIR/pert_date

local PERTGRIBDIR=$PERTGRIBDIR/

if [ ! -e $PERTGRIBDIR -a $PERTURB_BOUNDARY -eq 1 ] ; then
   echo "[Error]: Can not find BC data in $PERTGRIBDIR "
   exit
fi

#Define in which cases perturbation will be applied.
local perturb_met_em=0
if [ $PERTURB_BOUNDARY -eq 1 ] ; then
   perturb_met_em=1
   echo "[Warning]: Only MOAD will be perturbed"
fi
if [ $ANALYSIS -eq 1 -a $ITER -eq 1 ] ; then
   perturb_met_em=1
fi

if [ $PERTURB_ONLY_MOAD -eq 1 ] ; then
   PMAX_DOM=1
   else
   PMAX_DOM=$MAX_DOM
fi

PERTMETEMDIR=$TMPDIR/BOUNDARY/INPUT/

mkdir -p $PERTMETEMDIR

PERTMETEMDB=$PERTMETEMDIR/met_em_db/

mkdir -p $PERTMETEMDB

local local_script=$PERTMETEMDIR/perturb_met_em_from_grib.sh

#Fill some of the variables of the namelist.
cp $TMPDIR/NAMELIST/pertmetem.namelist.template $PERTMETEMDIR/pertmetem.namelist.template
edit_namelist_pertmetem $PERTMETEMDIR/pertmetem.namelist.template

#GENERATE THE SCRIPT TO GET PERTURBED MET_EM FILE FOR THE CURRENT TIME.                     
echo "#!/bin/bash                                                               "  > $local_script            
echo "#set -x                                                                    " >> $local_script
#This script perturbs met_em files.
#To avoid perturbing again the same met_em file for the same ensemble member
#First the script checks wether the perturbed met_em file exists and if it do not
#exist the script creates the file.
echo "MEM=\$1                       #Ensemble member                            " >> $local_script
echo "DATEP1=\$2  #Perturbation date A                                          " >> $local_script
echo "DATEP2=\$3  #Perturbation date B                                          " >> $local_script
echo "WORKDIR=$PERTMETEMDIR/\$MEM/WORK  #Temporary work directory               " >> $local_script
echo "source $TMPDIR/SCRIPTS/util.sh                                            " >> $local_script

echo "ulimit -s unlimited                                                       " >> $local_script
echo "export LD_LIBRARY_PATH=$RUNTIMELIBS:\$LD_LIBRARY_PATH                     " >> $local_script
echo "mkdir -p \$WORKDIR                                                        " >> $local_script
echo "cd \$WORKDIR                                                              " >> $local_script

#Insert scale factors within ths running script, but take into account the meanmember that should not
#be perturbed.
echo "AMP_FACTOR=$AMP_FACTOR                                                " >> $local_script
echo "RANDOM_AMP_FACTOR=$RANDOM_AMP_FACTOR                                  " >> $local_script
echo "if [ \$MEM -eq $MEANMEMBER  ] ; then                                      " >> $local_script
echo "   AMP_FACTOR=0.0                                                       " >> $local_script
echo "   RANDOM_AMP_FACTOR=0.0                                                " >> $local_script
echo "fi                                                                        " >> $local_script

if [ $SYSTEM -eq 0 ] ; then
  #Dummy call to mpi init and mpi finalize
  echo "$TMPDIR/SPAWN/dummy-mpi                                             " >> $local_script

fi

#################################################
#   CYCLE TO CREATE THE PERTURBATIONS
#################################################

THEDATE=$CDATE

local my_max_dom=` add_zeros $MAX_DOM 2 `

while [ $THEDATE -le $FDATE  ] ; do

   if [ $perturb_met_em -eq 1 ] ; then

   echo "CFILE=\`met_em_file_name $THEDATE 01 \`                                     " >> $local_script
   echo "MAX_DOM=$my_max_dom                                                         " >> $local_script
   #We have the initial random dates, we have to compute the random date corresponding to the current
   #time. So we compute the difference between the current date and the initial date.
   echo "LDATE=\`date_floor $THEDATE $BOUNDARY_DATA_PERTURBATION_FREQ \`             " >> $local_script
   echo "l_time_diff=\`date_diff \$LDATE $PERTREFDATE \`                             " >> $local_script
   echo "u_time_diff=\`expr \$l_time_diff + $BOUNDARY_DATA_PERTURBATION_FREQ \`      " >> $local_script

   echo "if [ ! -e $PERTMETEMDIR/\$MEM/\$CFILE ] ; then                              " >> $local_script
#   echo "ln -sf $METEMDIR/\${MEM}/\$CFILE \$WORKDIR                               " >> $local_script

   #Original data will be perturbed only at the initial cycle or if the Perturb_boundary option is enabled.
    echo " Boundary data is going to be perturbed"
    #Get the dates that we will use to create the perturbation and link the corresponding met_em files
    echo "DATEP1A=\`date_edit2 \$DATEP1 \$l_time_diff \`                             " >> $local_script
    echo "DATEP2A=\`date_edit2 \$DATEP2 \$l_time_diff \`                             " >> $local_script
    echo "   TMPFILE1A=\`met_em_file_name \$DATEP1A \$MAX_DOM \`                     " >> $local_script
    echo "   TMPFILE2A=\`met_em_file_name \$DATEP2A \$MAX_DOM \`                     " >> $local_script

    #IF perturbed met_ems are not present generate them                            
    echo "if [ ! -e  $PERTMETEMDB/\$TMPFILE1A ] ; then                               " >> $local_script
    echo "   ln -sf  $TMPDIR/WPS/*             ./                                    " >> $local_script
    echo "   ln -sf  $TMPDIR/domain/geo_em.d*  ./                                    " >> $local_script
    echo "   rm ./namelist.wps                                                       " >> $local_script
    echo "   cp $TMPDIR/NAMELIST/namelist.wps.template ./namelist.wps                " >> $local_script
    echo "   edit_namelist_wps ./namelist.wps \$DATEP1A \$DATEP1A  $BOUNDARY_DATA_PERTURBATION_FREQ   " >> $local_script
    echo "   ./link_grib.csh  $PERTGRIBDIR/\${DATEP1A}.grb                           " >> $local_script
    echo "   rm ./Vtable ; ln -sf ./ungrib/Variable_Tables/$PERTGRIBTABLE  ./Vtable  " >> $local_script
    echo "   ./ungrib.exe > ./ungrib.log                                             " >> $local_script
    echo "   ./metgrid.exe > ./metgrid.log                                           " >> $local_script
    echo "   mv met_em*.nc       $PERTMETEMDB                                        " >> $local_script
    echo "fi                                                                         " >> $local_script

    echo "if [ ! -e  $PERTMETEMDB/\$TMPFILE2A ] ; then                               " >> $local_script
    echo "   ln -sf  $TMPDIR/WPS/*             ./                                    " >> $local_script
    echo "   ln -sf  $TMPDIR/domain/geo_em.d*  ./                                    " >> $local_script
    echo "   rm ./namelist.wps                                                       " >> $local_script
    echo "   cp $TMPDIR/NAMELIST/namelist.wps.template ./namelist.wps                " >> $local_script
    echo "   edit_namelist_wps ./namelist.wps \$DATEP2A \$DATEP2A  $BOUNDARY_DATA_PERTURBATION_FREQ   " >> $local_script
    echo "   ./link_grib.csh  $PERTGRIBDIR/\${DATEP2A}.grb                           " >> $local_script
    echo "   rm ./Vtable ; ln -sf ./ungrib/Variable_Tables/$PERTGRIBTABLE  ./Vtable  " >> $local_script
    echo "   ./ungrib.exe > ./ungrib.log                                             " >> $local_script
    echo "   ./metgrid.exe > ./metgrid.log                                           " >> $local_script
    echo "   mv met_em*.nc     $PERTMETEMDB                                          " >> $local_script
    echo "fi                                                                         " >> $local_script

    #Repeat for the upper date.
    echo "DATEP1B=\`date_edit2 \$DATEP1 \$u_time_diff \`                             " >> $local_script
    echo "DATEP2B=\`date_edit2 \$DATEP2 \$u_time_diff \`                             " >> $local_script

    echo "   TMPFILE1B=\`met_em_file_name \$DATEP1B \$MAX_DOM \`                     " >> $local_script
    echo "   TMPFILE2B=\`met_em_file_name \$DATEP2B \$MAX_DOM \`                     " >> $local_script

    echo "if [ ! -e  $PERTMETEMDB/\$TMPFILE1B ] ; then                               " >> $local_script
    echo "   ln -sf  $TMPDIR/WPS/*             ./                                    " >> $local_script
    echo "   ln -sf  $TMPDIR/domain/geo_em.d*  ./                                    " >> $local_script
    echo "   rm ./namelist.wps                                                       " >> $local_script
    echo "   cp $TMPDIR/NAMELIST/namelist.wps.template ./namelist.wps                " >> $local_script
    echo "   edit_namelist_wps ./namelist.wps \$DATEP1B \$DATEP1B  $BOUNDARY_DATA_PERTURBATION_FREQ   " >> $local_script
    echo "   ./link_grib.csh $PERTGRIBDIR/\${DATEP1B}.grb                            " >> $local_script
    echo "   rm ./Vtable ; ln -sf ./ungrib/Variable_Tables/$PERTGRIBTABLE  ./Vtable  " >> $local_script
    echo "   ./ungrib.exe > ./ungrib.log                                             " >> $local_script
    echo "   ./metgrid.exe > ./metgrid.log                                           " >> $local_script
    echo "   mv met_em*.nc       $PERTMETEMDB                                        " >> $local_script
    echo "fi                                                                         " >> $local_script

    echo "if [ ! -e  $PERTMETEMDB/\$TMPFILE2B ] ; then                               " >> $local_script
    echo "   ln -sf  $TMPDIR/WPS/*             ./                                    " >> $local_script
    echo "   ln -sf  $TMPDIR/domain/geo_em.d*  ./                                    " >> $local_script
    echo "   rm ./namelist.wps                                                       " >> $local_script
    echo "   cp $TMPDIR/NAMELIST/namelist.wps.template ./namelist.wps                " >> $local_script
    echo "   edit_namelist_wps ./namelist.wps \$DATEP2B \$DATEP2B  $BOUNDARY_DATA_PERTURBATION_FREQ   " >> $local_script
    echo "   ./link_grib.csh  $PERTGRIBDIR/\${DATEP2B}.grb                           " >> $local_script
    echo "   rm ./Vtable ; ln -sf ./ungrib/Variable_Tables/$PERTGRIBTABLE  ./Vtable  " >> $local_script
    echo "   ./ungrib.exe > ./ungrib.log                                             " >> $local_script
    echo "   ./metgrid.exe > ./metgrid.log                                           " >> $local_script
    echo "   mv met_em*.nc     $PERTMETEMDB                                          " >> $local_script
    echo "fi                                                                         " >> $local_script

    echo "  rm -fr FILE*                                                             " >> $local_script


    local my_domain=1

    while [ $my_domain -le $PMAX_DOM ] ; do
      my_domain=` add_zeros $my_domain 2 `
      echo "   CFILE=\`met_em_file_name $THEDATE $my_domain \`                         " >> $local_script
      echo "   TMPFILE1A=\`met_em_file_name \$DATEP1A $my_domain \`                    " >> $local_script
      echo "   TMPFILE2A=\`met_em_file_name \$DATEP2A $my_domain \`                    " >> $local_script
      echo "   TMPFILE1B=\`met_em_file_name \$DATEP1B $my_domain \`                    " >> $local_script
      echo "   TMPFILE2B=\`met_em_file_name \$DATEP2B $my_domain \`                    " >> $local_script
      echo "   ln -sf $PERTMETEMDB/\$TMPFILE1A ./input_filea1.nc                       " >> $local_script
      echo "   ln -sf $PERTMETEMDB/\$TMPFILE2A ./input_filea2.nc                       " >> $local_script
      echo "   ln -sf $PERTMETEMDB/\$TMPFILE1B ./input_fileb1.nc                       " >> $local_script
      echo "   ln -sf $PERTMETEMDB/\$TMPFILE2B ./input_fileb2.nc                       " >> $local_script
      echo "   cp $METEMDIR/\${MEM}/\${CFILE} ./ctrl_met_em.nc                         " >> $local_script
      #Get the time dinstance in seconds between the current time and LDATE
      echo "   TIMEDISTANCE=\`date_diff $THEDATE \$LDATE \`                            " >> $local_script
      #Run the program 
      # ctrl_met_em.nc = ctrl_met_em.nc + scale_factor *[ ( input_file1.nc - input_file2.nc ) ]
      # the [] indicates a time interpolation between LDATE and UDATE.
      echo "   cp ../../pertmetem.namelist.template ./pertmetem.namelist                          " >> $local_script
      echo "   sed -i 's/@MAX_TIME@/'${BOUNDARY_DATA_PERTURBATION_FREQ}'/g' ./pertmetem.namelist  " >> $local_script
      echo "   sed -i 's/@CURRENT_TIME@/'\${TIMEDISTANCE}'/g'            ./pertmetem.namelist     " >> $local_script
      echo "   sed -i 's/@RANDOM_AMP_FACTOR@/'\${RANDOM_AMP_FACTOR}'/g'  ./pertmetem.namelist     " >> $local_script
      echo "   sed -i 's/@AMP_FACTOR@/'\${AMP_FACTOR}'/g'                ./pertmetem.namelist     " >> $local_script
      echo "   $EXEC                                                                              " >> $local_script
      echo "   mv ./ctrl_met_em.nc $PERTMETEMDIR/\${MEM}/\${CFILE}                                " >> $local_script

      my_domain=`expr $my_domain + 1 `

    done
   echo  "fi                                                                          " >> $local_script

  else #Else  over perturbation of met_ems.
   local my_domain=1
   while [ $my_domain -le $PMAX_DOM ] ; do
    my_domain=` add_zeros $my_domain 2 `
    echo "CFILE=\`met_em_file_name $THEDATE $my_domain \`                             " >> $local_script
    echo "ln -sf $METEMDIR/\$CFILE ./$PERTMETEMDIR/\${MEM}/\${CFILE}                  " >> $local_script
    my_domain=`expr $my_domain + 1  `
   done

  fi #Fi over perturbation of met_ems.

  THEDATE=`date_edit2 $THEDATE $METEM_DATA_FREQ `
done

#We are done!
chmod 766 $local_script


M=$INIMEMBER
while [ $M -le $ENDMEMBER ] ; do
  RUNNING=0
  while [ $RUNNING -le $MAX_RUNNING -a $M -le $ENDMEMBER ] ; do
    sleep  0.3

    MEM=`ens_member $M `

    DATE1=${INI_RANDOM_DATE1[$M]}
    DATE2=${INI_RANDOM_DATE2[$M]}
   
    ssh $PPSSERVER "$local_script $MEM $DATE1 $DATE2 > $PERTMETEMDIR/perturb_met_em${MEM}.log 2>&1 " &

  
    M=`expr $M + 1`
    RUNNING=`expr $RUNNING + 1`

  done 

  time wait

done

}


get_wrfinput_from_met_em () {

#This function generates a wrfinputfile from each perturbed met_em file.
#This will be used to provide boundary conditions to a scale-letkf experiment.

if [ $RUN_ONLY_MEAN -eq 1 ] ; then
   local INIMEMBER=$MEANMEMBER  #Run only the last member.
   local ENDMEMBER=$MEANMEMBER
else
   local INIMEMBER=1
   local ENDMEMBER=$MEMBER
fi

#Define in which cases perturbation will be applied.
local perturb_met_em=0
if [ $PERTURB_BOUNDARY -eq 1 ] ; then
   perturb_met_em=1
   echo "[Warning]: Only MOAD will be perturbed"
fi
if [ $ANALYSIS -eq 1 -a $ITER -eq 1 ] ; then
   perturb_met_em=1
fi

#Only the outermost domain will be processed.

PERTMETEMDIR=$TMPDIR/BOUNDARY/INPUT/

local local_script=$PERTMETEMDIR/get_wrfinput_from_met_em.sh

#Fill some of the variables of the namelist.
#cp $TMPDIR/NAMELIST/namelist.inpu.template $TMPDIR/ENSINPUT/namelist.input.template
#edit_namelist_pertmetem $TMPDIR/ENSINPUT/pertmetem.namelist.template

#GENERATE THE SCRIPT TO GET PERTURBED MET_EM FILE FOR THE CURRENT TIME.
echo "#!/bin/bash                                                               "  > $local_script
echo "set -x                                                                    " >> $local_script
#This script perturbs met_em files.
#To avoid perturbing again the same met_em file for the same ensemble member
#First the script checks wether the perturbed met_em file exists and if it do not
#exist the script creates the file.
echo "MEM=\$1                          #Ensemble member                                                                     " >> $local_script
echo "WORKDIR=$TMPDIR/BOUNDARY/INPUT/\$MEM/WORK/  #Temporary work directory                                                 " >> $local_script
echo "ln -sf  $TMPDIR/WRF/*    \$WORKDIR/                                                                                   " >> $local_script
echo "ln -sf  $TMPDIR/BOUNDARY/INPUT/\$MEM/met_em*    \$WORKDIR/                                                            " >> $local_script
echo "source $TMPDIR/SCRIPTS/util.sh                                                                                        " >> $local_script

echo "ulimit -s unlimited                                                                                                   " >> $local_script
echo "export LD_LIBRARY_PATH=$LD_LIBRARY_PATH_ADD:\$LD_LIBRARY_PATH                                                         " >> $local_script
echo "export PATH=$LD_PATH_ADD:$PATH                                                                                        " >> $local_script
echo "mkdir -p \$WORKDIR                                                                                                    " >> $local_script
echo "cd \$WORKDIR                                                                                                          " >> $local_script

#################################################
#   CYCLE TO CREATE THE PERTURBATIONS
#################################################

THEDATE=$CDATE
   #Scales uses a naming convention for the bdy conditions that goes from 0 - 9999
   echo "MEM2=\`expr \${MEM} + 0 \`                                                                                         " >> $local_script
   echo "MEM2=\`add_zeros \${MEM2}  4 \`                                                                                    " >> $local_script
   echo "mkdir -p $TMPDIR/scale_bdy/\${MEM2}                                                                                " >> $local_script

while [ $THEDATE -le $FDATE  ] ; do

   echo "if [ ! -e $TMPDIR/scale_bdy/\${MEM2}/wrfout_${THEDATE}  ] ; then                                                   " >> $local_script
   echo "CFILE=\`met_em_file_name $THEDATE 01 \`                                                                            " >> $local_script
   echo "MAX_DOM=1  #Only the outermost domain will be processed                                                            " >> $local_script
   echo "NVERTEXP=${NVERTEXP}                                                                                               " >> $local_script
   echo "cp $TMPDIR/NAMELIST/namelist.input.template \$WORKDIR/namelist.input                                               " >> $local_script
   echo "edit_namelist_input \$WORKDIR/namelist.input  $THEDATE $THEDATE $WINDOW_FREC $BOUNDARY_DATA_FREQ                   " >> $local_script
   echo "./realpps.exe > ./real.log                                                                                         " >> $local_script
   #Scale model requires EMISS and ALBEDO fields. These are only included in the wrfout format (not in the wrfinput file)
   #Perform a fake run with the wrf model to generate the wrfout file corresponding to the initial time.
   echo "cp $TMPDIR/NAMELIST/namelist.input.template \$WORKDIR/namelist.input                                               " >> $local_script
   echo "THEDATE2=\`date_edit2 $THEDATE 60 \`                                                                               " >> $local_script
   echo "edit_namelist_input \$WORKDIR/namelist.input  $THEDATE \$THEDATE2 $WINDOW_FREC $BOUNDARY_DATA_FREQ                 " >> $local_script
   echo "./wrfpps.exe > ./wrf.log                                                                                           " >> $local_script
   echo "local_file=\`wrfout_file_name $THEDATE 01 \`                                                                       " >> $local_script
   echo "mv \$local_file  $TMPDIR/scale_bdy/\$MEM2/wrfout_${THEDATE}                                                        " >> $local_script
   #The scale model requires longitudes in the range 0-360, but WRF works in the range -180 180 this tool solves this problem.
   echo "ln -sf $TMPDIR/scale_bdy/\$MEM2/wrfout_${THEDATE} ./input_file.nc                                                  " >> $local_script
   echo "./change_wrf_longitudes.exe                                                                                        " >> $local_script
   echo "INPUT_ROOT_NAME=tmpin                                                                                              " >> $local_script
   echo "OUTPUT_ROOT_NAME=tmpout                                                                                            " >> $local_script
   echo "OUTLEVS=\"$OUTLEVS\"                                                                                               " >> $local_script
   echo "OUTVARS=\"$OUTVARS\"                                                                                               " >> $local_script
   echo "INTERP_METHOD=$INTERP_METHOD                                                                                       " >> $local_script
   echo "cp ${TMPDIR}/NAMELIST/namelist.ARWpost.template ./namelist.ARWpost                                                 " >> $local_script
   echo "edit_namelist_arwpost \${WORKDIR}/namelist.ARWpost $THEDATE $THEDATE $ARWPOST_FREC                                 " >> $local_script
   echo "ln -sf $TMPDIR/scale_bdy/\$MEM2/wrfout_${THEDATE} ./\${INPUT_ROOT_NAME}                                            " >> $local_script
   echo "ln -sf $TMPDIR/scale_bdy/\$MEM2/wrfout_${THEDATE}.dat ./\${OUTPUT_ROOT_NAME}.dat                                   " >> $local_script
   echo "ln -sf $TMPDIR/scale_bdy/\$MEM2/wrfout_${THEDATE}.ctl ./\${OUTPUT_ROOT_NAME}.ctl                                   " >> $local_script
   echo "ln -sf $TMPDIR/WRF/src .                                                                                           " >> $local_script
   echo "$TMPDIR/WRF/ARWpost.exe > \${WORKDIR}/arwpostd_${THEDATE}.log                                                      " >> $local_script
   echo "sed -i 's/tmpout/wrfout_${THEDATE}/g' $TMPDIR/scale_bdy/\$MEM2/wrfout_${THEDATE}.ctl                               " >> $local_script
   echo "fi                                                                                                                 " >> $local_script

  THEDATE=`date_edit2 $THEDATE $METEM_DATA_FREQ `

done

#We are done!
chmod 766 $local_script

M=$INIMEMBER
while [ $M -le $ENDMEMBER ] ; do

  RUNNING=0
  while [ $RUNNING -le $MAX_RUNNING -a $M -le $ENDMEMBER ] ; do
    sleep  0.3
    MEM=`ens_member $M `
    ssh $PPSSERVER " $local_script $MEM > $TMPDIR/BOUNDARY/INPUT/get_wrfinput_from_met_em_${MEM}.log  2>&1 " &
    RUNNING=`expr $RUNNING + 1 `
    M=`expr $M + 1 `
  done
  time wait
done

}



arw_postproc_noqueue () {


# FOR THE ANALYSIS CASE
  local CDATE=$ADATE                     #INITIAL DATE
  local WORKDIR=$TMPDIR/POSTPROC/        #Temporary work directory
  local ANALDIR=$OUTPUTDIR/anal/$CDATE/
  local GUESDIR=$OUTPUTDIR/gues/$CDATE/

  local INIMEMBER=1
  local ENDMEMBER=$MEANMEMBER
                                         
  ARWPOST_FREC=$WINDOW_FREC

  INPUT_ROOT_NAME=tmpin
  OUTPUT_ROOT_NAME=tmpout
  rm -fr $WORKDIR/namelist.ARWpost

  cp $TMPDIR/NAMELIST/namelist.ARWpost.template $WORKDIR/namelist.ARWpost
  edit_namelist_arwpost $WORKDIR/namelist.ARWpost $CDATE $CDATE $ARWPOST_FREC

  echo "export LD_LIBRARY_PATH=$RUNTIMELIBS:\$LD_LIBRARY_PATH         " >  ${WORKDIR}/tmp.sh
  if [ $SYSTEM -eq  1 ] ; then
     echo " ulimit -s unlimited                                       " >> ${WORKDIR}/tmp.sh
  fi
  if [ $SYSTEM -eq  0 ] ; then
     echo " $TMPDIR/SPAWN/dummy-mpi                                   " >> ${WORKDIR}/tmp.sh
  fi

  echo "MEM=\$1                                                       " >> ${WORKDIR}/tmp.sh
  echo "mkdir -p ${WORKDIR}/\${MEM}                                   " >> ${WORKDIR}/tmp.sh
  echo "cd ${WORKDIR}/\${MEM}                                         " >> ${WORKDIR}/tmp.sh
  echo "DATADIR=${ANALDIR}                                            " >> ${WORKDIR}/tmp.sh
  echo "PREFIX=anal                                                   " >> ${WORKDIR}/tmp.sh
  echo "ln -sf \${DATADIR}/\${PREFIX}\${MEM} ./tmpin                  " >> ${WORKDIR}/tmp.sh
  echo "ln -sf \${DATADIR}/plev\${MEM}.dat ./tmpout.dat               " >> ${WORKDIR}/tmp.sh
  echo "ln -sf \${DATADIR}/plev\${MEM}.ctl ./tmpout.ctl               " >> ${WORKDIR}/tmp.sh
  echo "ln -sf $TMPDIR/WRF/src .                                      " >> ${WORKDIR}/tmp.sh
  echo "ln -sf $WORKDIR/namelist.ARWpost ./namelist.ARWpost           " >> ${WORKDIR}/tmp.sh
  echo "$TMPDIR/WRF/ARWpost.exe > \${DATADIR}/arwpostd01_\${MEM}.log  " >> ${WORKDIR}/tmp.sh
  echo "sed -i 's/tmpout/plev'\${MEM}'/g' \${DATADIR}/plev\${MEM}.ctl " >> ${WORKDIR}/tmp.sh

  echo "DATADIR=${GUESDIR}                                            " >> ${WORKDIR}/tmp.sh
  echo "PREFIX=gues                                                   " >> ${WORKDIR}/tmp.sh
  echo "ln -sf \${DATADIR}/\${PREFIX}\${MEM} ./tmpin                  " >> ${WORKDIR}/tmp.sh
  echo "ln -sf \${DATADIR}/plev\${MEM}.dat ./tmpout.dat               " >> ${WORKDIR}/tmp.sh
  echo "ln -sf \${DATADIR}/plev\${MEM}.ctl ./tmpout.ctl               " >> ${WORKDIR}/tmp.sh
  echo "ln -sf $TMPDIR/WRF/src .                                      " >> ${WORKDIR}/tmp.sh
  echo "ln -sf $WORKDIR/namelist.ARWpost ./namelist.ARWpost           " >> ${WORKDIR}/tmp.sh
  echo "$TMPDIR/WRF/ARWpost.exe > \${DATADIR}/arwpostd01_\${MEM}.log  " >> ${WORKDIR}/tmp.sh
  echo "sed -i 's/tmpout/plev'\${MEM}'/g' \${DATADIR}/plev\${MEM}.ctl " >> ${WORKDIR}/tmp.sh


  chmod 766 ${WORKDIR}/tmp.sh


 M=$INIMEMBER
 while [ $M -le $ENDMEMBER ] ; do
  MYNODE=1
  while [ $MYNODE -le $NNODES -a $M -le $ENDMEMBER ] ; do
    MEM=`ens_member $M `

    sleep 0.3
#    ssh ${NODELIST[$MYNODE]} "${WORKDIR}/tmp.sh ${MEM} 2>&1 " & 


      if [ $SYSTEM -eq 2 ] ; then

        ssh ${PPSSERVER} "${WORKDIR}/tmp.sh ${MEM} 2>&1  " &

      fi
      if [ $SYSTEM -eq 1 ] ; then

        ssh ${NODELIST[$MYNODE]} "${WORKDIR}/tmp.sh ${MEM} 2>&1  " &

      fi
      if [ $SYSTEM -eq 0 ] ; then

        echo ${NODELIST[$MYNODE]} > ./tmp_machinefile

        mpiexec -np 1 -vcoordfile ./tmp_machinefile ${WORKDIR}/tmp.sh ${MEM} 2>&1  &

      fi
    
    M=`expr $M + 1`
    MYNODE=`expr $MYNODE + 1`

  done 

  time wait

 done

}

arw_postproc_forecast_noqueue () {

# FOR THE FORECAST CASE
  ARWPOST_FREC=$WINDOW_FREC
  INPUT_ROOT_NAME=tmpin
  OUTPUT_ROOT_NAME=tmpout
#For the forecast case.
  local IDATE=$CDATE                   #INITIAL DATE
  local EDATE=$FDATE                   #FINAL DATE
  local WORKDIR=$TMPDIR/POSTPROC/      #Temporary work directory
  local GUESDIR=$RESULTDIRG

  if [ $RUN_ONLY_MEAN -eq 1 ] ; then
     local INIMEMBER=$MEANMEMBER  #Run only the last member.
     local ENDMEMBER=$MEANMEMBER
  else
     local INIMEMBER=1
     local ENDMEMBER=$MEMBER
  fi

  ARWPOST_FREC=$WINDOW_FREC

  echo "export LD_LIBRARY_PATH=$RUNTIMELIBS:\$LD_LIBRARY_PATH         " >  ${WORKDIR}/tmp.sh
  echo "source $TMPDIR/SCRIPTS/util.sh                                " >> ${WORKDIR}/tmp.sh
  if [ $SYSTEM -eq  1 ] ; then
     echo " ulimit -s unlimited                                       " >> ${WORKDIR}/tmp.sh
  fi
  if [ $SYSTEM -eq 0  ] ; then
     echo "$TMPDIR/SPAWN/dummy-mpi                                    " >> ${WORKDIR}/tmp.sh
  fi
  echo "MEM=\$1                                                       " >> ${WORKDIR}/tmp.sh
  echo "mkdir -p ${WORKDIR}/\${MEM}                                   " >> ${WORKDIR}/tmp.sh
  echo "cd ${WORKDIR}/\${MEM}                                         " >> ${WORKDIR}/tmp.sh
  echo "INPUT_ROOT_NAME=tmpin                                         " >> ${WORKDIR}/tmp.sh
  echo "OUTPUT_ROOT_NAME=tmpout                                       " >> ${WORKDIR}/tmp.sh
  echo "OUTVARS=\"${OUTVARS}\"                                        " >> ${WORKDIR}/tmp.sh
  echo "OUTLEVS=${OUTLEVS}                                            " >> ${WORKDIR}/tmp.sh
  echo "INTERP_METHOD=${INTERP_METHOD}                                " >> ${WORKDIR}/tmp.sh

 local my_domain=1
 while [ $my_domain -le $MAX_DOM ] ; do
  my_domain=`add_zeros $my_domain 2 `
  local TMPDATE=$IDATE
  while [ $TMPDATE -le $EDATE  ] ; do
   local input_file=`wrfout_file_name $TMPDATE $my_domain `
   #echo "rm ./namelist.ARWpost                                                                                  " >> ${WORKDIR}/tmp.sh
   echo "cp ${TMPDIR}/NAMELIST/namelist.ARWpost.template ./namelist.ARWpost                                     " >> ${WORKDIR}/tmp.sh
   echo "edit_namelist_arwpost ${WORKDIR}/\${MEM}/namelist.ARWpost $TMPDATE $TMPDATE $ARWPOST_FREC              " >> ${WORKDIR}/tmp.sh
   echo "ln -sf ${GUESDIR}/\${MEM}/${input_file} ./${INPUT_ROOT_NAME}                                           " >> ${WORKDIR}/tmp.sh
   echo "ln -sf ${GUESDIR}/plevd${my_domain}_${TMPDATE}_\${MEM}.dat ./${OUTPUT_ROOT_NAME}.dat                   " >> ${WORKDIR}/tmp.sh
   echo "ln -sf ${GUESDIR}/plevd${my_domain}_${TMPDATE}_\${MEM}.ctl ./${OUTPUT_ROOT_NAME}.ctl                   " >> ${WORKDIR}/tmp.sh
   echo "ln -sf $TMPDIR/WRF/src .                                                                               " >> ${WORKDIR}/tmp.sh
   echo "$TMPDIR/WRF/ARWpost.exe > ${GUESDIR}/arwpostd${my_domain}_\${MEM}.log                                  " >> ${WORKDIR}/tmp.sh
   echo "sed -i 's/${OUTPUT_ROOT_NAME}/plevd${my_domain}_${TMPDATE}_'\${MEM}'/g' ${GUESDIR}/plevd${my_domain}_${TMPDATE}_\${MEM}.ctl  " >> ${WORKDIR}/tmp.sh

   TMPDATE=`date_edit2 $TMPDATE $WINDOW_FREC `
  done

  my_domain=`expr $my_domain + 1 `
 done

 chmod 766 ${WORKDIR}/tmp.sh

  M=$INIMEMBER
  while [ $M -le $ENDMEMBER ] ; do
    RUNNING=0
    while [ $RUNNING -le $MAX_RUNNING -a $M -le $ENDMEMBER ] ; do
      MEM=`ens_member $M`

        if [ $SYSTEM -eq 1 ] ; then

          ssh ${NODELIST[$MYNODE]} "${WORKDIR}/tmp.sh ${MEM} 2>&1  " &

        fi
        if [ $SYSTEM -eq 0 ] ; then

          echo ${NODELIST[$MYNODE]} > ./tmp_machinefile
 
          mpiexec -np 1 -vcoordfile ./tmp_machinefile ${WORKDIR}/tmp.sh ${MEM} 2>&1  &

        fi

      RUNNING=`expr $RUNNING + 1 `
      M=`expr $M + 1 `
    done
    time wait
  done


}


upp_postproc_noqueue () {


if [  $ENABLE_UPP -eq 1 ];then

  local MODEL=NCAR
  local FORMAT=netcdf

# FOR THE ANALYSIS CASE
  local CDATE=$ADATE                     #THE CURRENT DATE
  local WORKDIR=$TMPDIR/POSTPROC/        #Temporary work directory
  local ANALDIR=$OUTPUTDIR/anal/$CDATE/
  local GUESDIR=$OUTPUTDIR/gues/$CDATE/

  local INIMEMBER=1
  local ENDMEMBER=$MEANMEMBER
                                         
  local CDATEWRF=`date_in_wrf_format $CDATE `

  echo "export LD_LIBRARY_PATH=$RUNTIMELIBS:\$LD_LIBRARY_PATH         " >  ${WORKDIR}/tmp.sh
  if [ $SYSTEM -eq  1 ] ; then
     echo " ulimit -s unlimited                                       " >> ${WORKDIR}/tmp.sh
  fi
  if [ $SYSTEM -eq 0 ] ; then
     echo "$TMPDIR/SPAWN/dummy-mpi                                    " >> ${WORKDIR}/tmp.sh
  fi
  echo "MEM=\$1                                                       " >> ${WORKDIR}/tmp.sh
  echo "mkdir -p ${WORKDIR}/\${MEM}                                   " >> ${WORKDIR}/tmp.sh
  echo "cd ${WORKDIR}/\${MEM}                                         " >> ${WORKDIR}/tmp.sh
  echo "DATADIR=${ANALDIR}                                            " >> ${WORKDIR}/tmp.sh
  echo "PREFIX=anal                                                   " >> ${WORKDIR}/tmp.sh
  echo "ln -sf \${DATADIR}/\${PREFIX}\${MEM} ./tmpin                  " >> ${WORKDIR}/tmp.sh
  echo "ln -sf \${DATADIR}/slev\${MEM}.grib  ./WRFPRS.GrbF00          " >> ${WORKDIR}/tmp.sh
  echo "ln -sf $TMPDIR/UPP/* .                                        " >> ${WORKDIR}/tmp.sh
  echo "ln -sf wrf_cntrl.parm   ./fort.14                             " >> ${WORKDIR}/tmp.sh
  #Create UPP namelist.
#  echo "cat > itag <<EOF                                             " >> ${WORKDIR}/tmp.sh
  echo "echo \"tmpin     \" > itag                                    " >> ${WORKDIR}/tmp.sh
  echo "echo \"$FORMAT   \" >> itag                                   " >> ${WORKDIR}/tmp.sh
  echo "echo \"$CDATEWRF \" >> itag                                   " >> ${WORKDIR}/tmp.sh
  echo "echo \"$MODEL    \" >> itag                                   " >> ${WORKDIR}/tmp.sh
#  echo "EOF                                                          " >> ${WORKDIR}/tmp.sh
  echo "./unipost.exe > \${DATADIR}/uppd01_\${MEM}.log                " >> ${WORKDIR}/tmp.sh

  echo "DATADIR=${GUESDIR}                                            " >> ${WORKDIR}/tmp.sh
  echo "PREFIX=gues                                                   " >> ${WORKDIR}/tmp.sh
  echo "ln -sf \${DATADIR}/\${PREFIX}\${MEM} ./tmpin                  " >> ${WORKDIR}/tmp.sh
  echo "ln -sf \${DATADIR}/slev\${MEM}.grib  ./WRFPRS.GrbF00          " >> ${WORKDIR}/tmp.sh
  echo "ln -sf $TMPDIR/UPP/* .                                        " >> ${WORKDIR}/tmp.sh
  echo "ln -sf wrf_cntrl.parm   ./fort.14                             " >> ${WORKDIR}/tmp.sh
  #Create UPP namelist.
#  echo "cat > itag <<EOF                                             " >> ${WORKDIR}/tmp.sh
  echo "echo \"tmpin     \" > itag                                    " >> ${WORKDIR}/tmp.sh
  echo "echo \"$FORMAT   \" >> itag                                   " >> ${WORKDIR}/tmp.sh
  echo "echo \"$CDATEWRF \" >> itag                                   " >> ${WORKDIR}/tmp.sh
  echo "echo \"$MODEL    \" >> itag                                   " >> ${WORKDIR}/tmp.sh
#  echo "EOF                                                          " >> ${WORKDIR}/tmp.sh
  echo "unipost.exe             > \${DATADIR}/uppd01_\${MEM}.log      " >> ${WORKDIR}/tmp.sh



  chmod 766 ${WORKDIR}/tmp.sh


 M=$INIMEMBER
 while [ $M -le $ENDMEMBER ] ; do
  MYNODE=1
  while [ $MYNODE -le $NNODES -a $M -le $ENDMEMBER ] ; do
    MEM=`ens_member $M `

    sleep 0.3

    if [ $SYSTEM -eq 1 ] ; then

     ssh ${NODELIST[$MYNODE]} "${WORKDIR}/tmp.sh ${MEM} 2>&1  " &

    fi
    if [ $SYSTEM -eq 0 ] ; then

     echo ${NODELIST[$MYNODE]} > ./tmp_machinefile

     mpiexec -np 1 -vcoordfile ./tmp_machinefile ${WORKDIR}/tmp.sh ${MEM} 2>&1  &

    fi
    
    M=`expr $M + 1`
    MYNODE=`expr $MYNODE + 1`

  done 

  time wait

 done

fi

}

upp_postproc_forecast_noqueue () {

if [ $ENABLE_UPP -eq 1 ] ; then

# FOR THE FORECAST CASE
  UPP_FREC=$WINDOW_FREC
  local IDATE=$CDATE                   #INITIAL DATE
  local EDATE=$FDATE                   #FINAL DATE
  local WORKDIR=$TMPDIR/POSTPROC/      #Temporary work directory
  local GUESDIR=$RESULTDIRG

  if [ $RUN_ONLY_MEAN -eq 1 ] ; then
     local INIMEMBER=$MEANMEMBER  #Run only the last member.
     local ENDMEMBER=$MEANMEMBER
  else
     local INIMEMBER=1
     local ENDMEMBER=$MEMBER
  fi

  echo "export LD_LIBRARY_PATH=$RUNTIMELIBS:\$LD_LIBRARY_PATH         " >  ${WORKDIR}/tmp.sh
  echo "source $TMPDIR/SCRIPTS/util.sh                                " >> ${WORKDIR}/tmp.sh
  if [ $SYSTEM -eq  1 ] ; then
     echo " ulimit -s unlimited                                       " >> ${WORKDIR}/tmp.sh
  fi
  echo "MEM=\$1                                                       " >> ${WORKDIR}/tmp.sh
  echo "mkdir -p ${WORKDIR}/\${MEM}                                   " >> ${WORKDIR}/tmp.sh
  echo "cd ${WORKDIR}/\${MEM}                                         " >> ${WORKDIR}/tmp.sh

  local my_domain=1
     while [ $my_domain -le $MAX_DOM ] ; do
      my_domain=` add_zeros $my_domain 2 `
      local TMPDATE=$IDATE
      local TMPDATEWRF=`date_in_wrf_format $TMPDATE `
      
      while [ $TMPDATE -le $EDATE  ] ; do
           local input_file=`wrfout_file_name $TMPDATE $my_domain `
           echo "DATADIR=${GUESDIR}                                                                   " >> ${WORKDIR}/tmp.sh
           echo "PREFIX=gues                                                                          " >> ${WORKDIR}/tmp.sh
           echo "ln -sf ${GUESDIR}/\${MEM}/${input_file} ./tmpin                                      " >> ${WORKDIR}/tmp.sh
           echo "ln -sf ${GUESDIR}/slevd${my_domain}_${TMPDATE}_\${MEM}.grib ./WRFPRS.GrbF00          " >> ${WORKDIR}/tmp.sh
           echo "ln -sf $TMPDIR/UPP/* .                                                               " >> ${WORKDIR}/tmp.sh
           echo "ln -sf wrf_cntrl.parm   ./fort.14                                                    " >> ${WORKDIR}/tmp.sh
           #Create UPP namelist.
           #  echo "cat > itag <<EOF                                                                  " >> ${WORKDIR}/tmp.sh
           echo "echo \"tmpin > itag \"                                                               " >> ${WORKDIR}/tmp.sh
           echo "echo \"netcdf > itag \"                                                              " >> ${WORKDIR}/tmp.sh
           echo "echo \"$CDATEWRF > itag \"                                                           " >> ${WORKDIR}/tmp.sh
           echo "echo \"NCAR > itag \"                                                                " >> ${WORKDIR}/tmp.sh
	   #  echo "EOF                                                                               " >> ${WORKDIR}/tmp.sh
           echo "unipost.exe             > \${GUESDIR}/uppd01_\${MEM}.log                             " >> ${WORKDIR}/tmp.sh

           TMPDATE=`date_edit2 $TMPDATE $WINDOW_FREC `
       done

       my_domain=`expr $my_domain + 1 `
     done

  chmod 766 ${WORKDIR}/tmp.sh


  M=$INIMEMBER
  while [ $M -le $ENDMEMBER ] ; do
   MYNODE=1
   while [ $MYNODE -le $NNODES -a $M -le $ENDMEMBER ] ; do
     MEM=`ens_member $M `

     sleep 0.3

     if [ $SYSTEM -eq 1 ] ; then

      ssh ${NODELIST[$MYNODE]} "${WORKDIR}/tmp.sh ${MEM} 2>&1  " &

     fi
     if [ $SYSTEM -eq 0 ] ; then

      echo ${NODELIST[$MYNODE]} > ./tmp_machinefile

      mpiexec -np 1 -vcoordfile ./tmp_machinefile ${WORKDIR}/tmp.sh ${MEM} 2>&1  &

     fi

     #ssh ${NODELIST[$MYNODE]} "${WORKDIR}/tmp.sh ${MEM}  2>&1 " &

     M=`expr $M + 1`
     MYNODE=`expr $MYNODE + 1`

   done

   time wait

  done



fi

}


#Get arw post file of global analysis.
postproc_global_analysis () {

local CDATEL=$1
local EDATEL=$2
local LARWPOSTFREC=3600
local INPUT_ROOT_NAME=tmpin
local OUTPUT_ROOT_NAME=tmpout


if [ $ANALYSIS -eq 1  ] ; then
   EDATEL=$CDATEL
   local output_data=$RESULTDIRA
fi
if [ $FORECAST -eq 1 ] ; then
   local output_data=$RESULTDIRG
fi

local WORKDIR=$TMPDIR/verification

NVERTEXP=$NVERTDB #Set the input number of vertical levels according to db data.


 local my_date=$CDATEL
 while [ $my_date -le $EDATEL  ] ; do
  #Link metgrid for all the domains.
  local my_domain=1
  while [ $my_domain -le $MAX_DOM  ] ; do
    my_domain=` add_zeros $my_domain 2 `
    local met_em_file=` met_em_file_name $my_date $my_domain ` #[We assume that input data is only available for domain 1]
    met_em_file=$INPUTDIR/db_met_em/$met_em_file
    ln -sf $met_em_file $WORKDIR/
    my_domain=`expr $my_domain + 1 `
  done

  
  #Force input from file == true for all the domains.
  tmplinenumber=`grep -n "input_from_file" $TMPDIR/WRF/namelist.input.template | grep -Eo '^[^:]+' `
  awk '{ if (NR == '$tmplinenumber') print "input_from_file=.true.,.true.,.true.,"; else print $0}' $TMPDIR/NAMELIST/namelist.input.template > $WORKDIR/namelist.input

  #Edit namelist.input
  edit_namelist_input $WORKDIR/namelist.input $my_date $my_date $WINDOW_FREC $BOUNDARY_DATA_FREQ  #For real

  ln -sf $TMPDIR/WRF/* $WORKDIR/

  #Run real an wrf. By running wrf we guarantee that all fields are available.
  #(ie precipitation, condensates, etc), even if they are 0.
  echo "cd $WORKDIR                                  " >  $WORKDIR/tmp.sh
#  echo "cp namelist.input.real namelist.input        " >> $WORKDIR/tmp.sh
  echo "$MPIBIN -np $MAX_RUNNING ./realpps.exe > null.log    " >> $WORKDIR/tmp.sh
  local my_domain=1
  while [ $my_domain -le $MAX_DOM ] ; do
   my_domain=` add_zeros $my_domain 2 `
  
   echo "mv wrfinput_d${my_domain} ${output_data}/ganald${my_domain}_$my_date    " >> $WORKDIR/tmp.sh
   my_domain=`expr $my_domain + 1 `
  done
  chmod 766 $WORKDIR/tmp.sh

  #Run real to generate wrfinput_d01.
  echo "  Running real ..."
  time ssh $PPSSERVER $WORKDIR/tmp.sh

  #Post process input file
  cp ${TMPDIR}/NAMELIST/namelist.ARWpost.template $WORKDIR/namelist.ARWpost
  ln -sf $TMPDIR/WRF/ARWpost.exe $WORKDIR/
  ln -sf $TMPDIR/WRF/src         $WORKDIR/
  edit_namelist_arwpost ${WORKDIR}/namelist.ARWpost $my_date $my_date $LARWPOSTFREC

  my_domain=1
  while [ $my_domain -le $MAX_DOM ] ; do
   my_domain=` add_zeros $my_domain 2 `
   ln -sf ${output_data}/ganald${my_domain}_$my_date  $WORKDIR/${INPUT_ROOT_NAME}
   ln -sf ${output_data}/plevganald${my_domain}_${my_date}.ctl $WORKDIR/${OUTPUT_ROOT_NAME}.ctl
   ln -sf ${output_data}/plevganald${my_domain}_${my_date}.dat $WORKDIR/${OUTPUT_ROOT_NAME}.dat


   echo "cd $WORKDIR             " >   $WORKDIR/tmp.sh
   echo "./ARWpost.exe > tmp.log " >>  $WORKDIR/tmp.sh
   chmod 766 $WORKDIR/tmp.sh

   echo "   Running ARWpost "
   time ssh $PPSSERVER $WORKDIR/tmp.sh

   #To correct the ctl generated by ARWPOST
   tmpstring=plevganald${my_domain}_${my_date}
   sed -i 's/'${OUTPUT_ROOT_NAME}'/'${tmpstring}'/g' ${WORKDIR}/${OUTPUT_ROOT_NAME}.ctl

   mv $WORKDIR/tmp.log ${output_data}/arwpost_global_d${my_domain}.log

   my_domain=`expr $my_domain + 1 `

  done

 my_date=`date_edit2 $my_date $GLOBALANALYSIS_DATA_VERIFICATION_FREQ `
 done #[End do over my_date ]


}

verification_against_global_analysis () {


local CDATEL=$1
local EDATEL=$2
local WORKDIR=$TMPDIR/verification/

#if [ $RUN_ONLY_MEAN -eq 1 -a $FORECAST -eq 1 ] ; then
#  INIMEMBER=$MEANMEMBER
#  ENDMEMBER=$MEANMEMBER
#else
  INIMEMBER=1
  ENDMEMBER=$MEMBER
#fi

#Create namelist for verify module

#Check if we will perform accmulation statistics or not
#Usually these are performed serveral cycles after the 
#start of the assimilation cycle.

local namelist=$WORKDIR/verify.namelist

echo "&general                           " > $namelist
if [ $RUN_ONLY_MEAN -eq 1 -a $FORECAST -eq 1 ] ; then
  echo "nbv=1                            " >>$namelist
else
  echo "nbv=${MEMBER}                    " >>$namelist
fi
echo "regrid_output=${REGRID_OUTPUT}     " >>$namelist
echo "regrid_res=${REGRID_RES}           " >>$namelist
echo "regrid_vert_res=${REGRID_VERT_RES} " >>$namelist
echo "narea=${NAREA}                     " >>$namelist
echo "vlon1=${VLON1}                     " >>$namelist
echo "vlon2=${VLON2}                     " >>$namelist
echo "vlat1=${VLAT1}                     " >>$namelist
echo "vlat2=${VLAT2}                     " >>$namelist
echo "/                                  " >>$namelist
#Link ensemble members

if [ $ANALYSIS -eq 1 ] ; then
  #First perform the verification for the analysis data in the ARWpost output grid
  echo "my_date=\$1                                                                "  > ${WORKDIR}/tmp.sh
  echo "my_dir=\$2                                                                 " >> ${WORKDIR}/tmp.sh
  echo "my_lead=\$3                                                                " >> ${WORKDIR}/tmp.sh
  echo "my_domain=\$4                                                              " >> ${WORKDIR}/tmp.sh
  echo "ln -sf ${namelist}  \${my_dir}                                             " >> ${WORKDIR}/tmp.sh
  local M=$INIMEMBER
  while [ $M -le $ENDMEMBER ] ; do
   local MEM=`ens_member $M `
   echo "ln -sf ${RESULTDIRA}/plev${MEM}.dat         \${my_dir}/fcst${MEM}.grd    " >> ${WORKDIR}/tmp.sh
   M=`expr $M + 1 `
  done
   echo "ln -sf ${RESULTDIRA}/plev00001.ctl                            \${my_dir}/inputfor.ctl " >> ${WORKDIR}/tmp.sh  #Link forecast ctl
   echo "ln -sf ${RESULTDIRA}/plevganald\${my_domain}_\${my_date}.ctl  \${my_dir}/inputanl.ctl " >> ${WORKDIR}/tmp.sh  #Link analysis ctl
   echo "ln -sf ${RESULTDIRA}/plevganald\${my_domain}_\${my_date}.dat  \${my_dir}/anal.grd     " >> ${WORKDIR}/tmp.sh
   echo "ln -sf ${RESULTDIRA}/plevmean.dat                 \${my_dir}/mean.grd    " >> ${WORKDIR}/tmp.sh
   echo "ln -sf ${RESULTDIRA}/plevsprd.dat                 \${my_dir}/sprd.grd    " >> ${WORKDIR}/tmp.sh
   echo "ln -sf ${RESULTDIRA}/plevmerr.dat                 \${my_dir}/merr.grd    " >> ${WORKDIR}/tmp.sh
   echo "ln -sf ${RESULTDIRA}/areal_error.txt              \${my_dir}/area.txt    " >> ${WORKDIR}/tmp.sh
   if [ "${REGRID_OUTPUT}" == ".TRUE." -o "${REGRID_OUTPUT}" == ".true." ] ; then
     echo "ln -sf ${RESULTDIRA}/plevmeanreg.dat              \${my_dir}/meanreg.grd    " >> ${WORKDIR}/tmp.sh
     echo "ln -sf ${RESULTDIRA}/plevsprdreg.dat              \${my_dir}/sprdreg.grd    " >> ${WORKDIR}/tmp.sh
     echo "ln -sf ${RESULTDIRA}/plevmerrreg.dat              \${my_dir}/merrreg.grd    " >> ${WORKDIR}/tmp.sh
     echo "ln -sf ${RESULTDIRA}/arealreg_error.txt           \${my_dir}/areareg.txt " >> ${WORKDIR}/tmp.sh
   fi
   echo "ln -sf  ${TMPDIR}/verification/verify.exe         \${my_dir}/verify.exe  " >> ${WORKDIR}/tmp.sh
   echo "cd \${my_dir}/                                                           " >> ${WORKDIR}/tmp.sh
   echo "./verify.exe                                                             " >> ${WORKDIR}/tmp.sh
  #Perfom the verification of the first guess in the ARWpost output grid.
  local M=$INIMEMBER
  while [ $M -le $ENDMEMBER ] ; do
   local MEM=`ens_member $M `
   echo "ln -sf ${RESULTDIRG}/plev${MEM}.dat           \${my_dir}/fcst${MEM}.grd   " >> ${WORKDIR}/tmp.sh
   M=`expr $M + 1 `
  done
   echo "ln -sf ${RESULTDIRG}/plev00001.ctl                \${my_dir}/inputfor.ctl " >> ${WORKDIR}/tmp.sh
   echo "ln -sf ${RESULTDIRA}/plevganald\${my_domain}_\${my_date}.ctl  \${my_dir}/inputanl.ctl " >> ${WORKDIR}/tmp.sh
   echo "ln -sf ${RESULTDIRA}/plevganald\${my_domain}_\${my_date}.dat  \${my_dir}/anal.grd     " >> ${WORKDIR}/tmp.sh   
   echo "ln -sf ${RESULTDIRG}/plevmean.dat                 \${my_dir}/mean.grd    " >> ${WORKDIR}/tmp.sh
   echo "ln -sf ${RESULTDIRG}/plevsprd.dat                 \${my_dir}/sprd.grd    " >> ${WORKDIR}/tmp.sh
   echo "ln -sf ${RESULTDIRG}/plevmerr.dat                 \${my_dir}/merr.grd    " >> ${WORKDIR}/tmp.sh
   echo "ln -sf ${RESULTDIRG}/areal_error.txt              \${my_dir}/area.txt    " >> ${WORKDIR}/tmp.sh

   if [ "${REGRID_OUTPUT}" == ".TRUE." -o "${REGRID_OUTPUT}" == ".true." ] ; then
     echo "ln -sf ${RESULTDIRG}/plevmeanreg.dat              \${my_dir}/meanreg.grd    " >> ${WORKDIR}/tmp.sh
     echo "ln -sf ${RESULTDIRG}/plevsprdreg.dat              \${my_dir}/sprdreg.grd    " >> ${WORKDIR}/tmp.sh
     echo "ln -sf ${RESULTDIRG}/plevmerrreg.dat              \${my_dir}/merrreg.grd    " >> ${WORKDIR}/tmp.sh
     echo "ln -sf ${RESULTDIRG}/arealreg_error.txt           \${my_dir}/areareg.txt " >> ${WORKDIR}/tmp.sh
   fi

   echo "ln -sf  ${TMPDIR}/verification/verify.exe         \${my_dir}/verify.exe  " >> ${WORKDIR}/tmp.sh
   echo "cd \${my_dir}/                                                           " >> ${WORKDIR}/tmp.sh
   echo "./verify.exe                                                             " >> ${WORKDIR}/tmp.sh

fi #[ Analysis case  ]

#FORECAST CASE
if [ $FORECAST -eq 1  ] ; then

  #First perform the verification for the analysis data in the ARWpost output grid
  echo "my_date=\$1                                                                "  > ${WORKDIR}/tmp.sh
  echo "my_dir=\$2                                                                 " >> ${WORKDIR}/tmp.sh
  echo "my_lead=\$3                                                                " >> ${WORKDIR}/tmp.sh
  echo "my_domain=\$4                                                              " >> ${WORKDIR}/tmp.sh
  echo "ln -sf ${namelist}  \${my_dir}                                             " >> ${WORKDIR}/tmp.sh

  echo "ln -sf ${RESULTDIRG}/plevganald\${my_domain}_\${my_date}.ctl  \${my_dir}/inputanl.ctl " >> ${WORKDIR}/tmp.sh
  echo "ln -sf ${RESULTDIRG}/plevganald\${my_domain}_\${my_date}.dat  \${my_dir}/anal.grd     " >> ${WORKDIR}/tmp.sh

  if [ $RUN_ONLY_MEAN -eq 1 ] ; then
    local MEM=`ens_member $MEANMEMBER `
    local MEM1=`ens_member 1 `
    echo "ln -sf ${RESULTDIRG}/plevd\${my_domain}_\${my_date}_${MEM}.dat   \${my_dir}/fcst${MEM1}.grd " >> ${WORKDIR}/tmp.sh
    echo "ln -sf ${RESULTDIRG}/plevd\${my_domain}_\${my_date}_${MEM}.ctl   \${my_dir}/inputfor.ctl    " >> ${WORKDIR}/tmp.sh
  else
   local M=$INIMEMBER
   while [ $M -le $ENDMEMBER ] ; do
    local MEM=`ens_member $M `
    echo "ln -sf ${RESULTDIRG}/plevd\${my_domain}_\${my_date}_${MEM}.dat   \${my_dir}/fcst${MEM}.grd " >> ${WORKDIR}/tmp.sh
    echo "ln -sf ${RESULTDIRG}/plevd\${my_domain}_\${my_date}_00001.ctl    \${my_dir}/inputfor.ctl   " >> ${WORKDIR}/tmp.sh
    M=`expr $M + 1 `
   done
  fi
   echo "ln -sf ${RESULTDIRG}/plevmean\${my_domain}_\${my_lead}.dat       \${my_dir}/mean.grd    " >> ${WORKDIR}/tmp.sh
   echo "ln -sf ${RESULTDIRG}/plevsprd\${my_domain}_\${my_lead}.dat       \${my_dir}/sprd.grd    " >> ${WORKDIR}/tmp.sh
   echo "ln -sf ${RESULTDIRG}/plevmerr\${my_domain}_\${my_lead}.dat       \${my_dir}/merr.grd    " >> ${WORKDIR}/tmp.sh
   echo "ln -sf ${RESULTDIRG}/areal_error_d\${my_domain}_\${my_lead}.txt    \${my_dir}/area.txt    " >> ${WORKDIR}/tmp.sh
   if [ "${REGRID_OUTPUT}" == ".TRUE." -o "${REGRID_OUTPUT}" == ".true." ] ; then
     echo "ln -sf ${RESULTDIRG}/plevmeanreg\${my_domain}_\${my_lead}.dat  \${my_dir}/meanreg.grd    " >> ${WORKDIR}/tmp.sh
     echo "ln -sf ${RESULTDIRG}/plevsprdreg\${my_domain}_\${my_lead}.dat  \${my_dir}/sprdreg.grd    " >> ${WORKDIR}/tmp.sh
     echo "ln -sf ${RESULTDIRG}/plevmerrreg\${my_domain}_\${my_lead}.dat  \${my_dir}/merrreg.grd    " >> ${WORKDIR}/tmp.sh
     echo "ln -sf ${RESULTDIRG}/arealreg_errord\${my_domain}_\${my_lead}.txt           \${my_dir}/areareg.txt " >> ${WORKDIR}/tmp.sh
   fi
   echo "ln -sf  ${TMPDIR}/verification/verify.exe         \${my_dir}/verify.exe  " >> ${WORKDIR}/tmp.sh
   echo "cd \${my_dir}/                                                           " >> ${WORKDIR}/tmp.sh
   echo "./verify.exe                                                             " >> ${WORKDIR}/tmp.sh


fi


 chmod 766 ${WORKDIR}/tmp.sh

 forecast_domain=1
 while [ $forecast_domain -le $MAX_DOM  ] ; do
   if [ $forecast_domain -lt 10 ] ; then
    forecast_domain=0$forecast_domain
   fi
   CDATEL=$1
   #RUN THE SCRIPT IN PPS NODE.
   local forecast_lead_time=0
   while [ $CDATEL -le $EDATEL  ] ; do
     RUNNING=0
     while [ $RUNNING -le $MAX_RUNNING -a $CDATEL -le $EDATEL ] ; do
      forecast_lead_time=`forecast_lead $forecast_lead_time `
      mkdir -p $WORKDIR/$RUNNING
      echo " Verifying domain $forecast_domain at $CDATEL which  $forecast_lead_time lead time. "
      ssh $PPSSERVER " ${WORKDIR}/tmp.sh $CDATEL $WORKDIR/$RUNNING $forecast_lead_time $forecast_domain > $WORKDIR/$RUNNING/verif.log " &
      CDATEL=`date_edit2 $CDATEL $GLOBALANALYSIS_DATA_VERIFICATION_FREQ `
      forecast_lead_time=`expr $forecast_lead_time + $GLOBALANALYSIS_DATA_VERIFICATION_FREQ `
      RUNNING=`expr $RUNNING + 1 `
     done
    time wait 
   done

 forecast_domain=`expr $forecast_domain + 1 `
 done #[Loop over model domains.]


}

verification_against_obs () {

#This function uses the offline observation operator to 
#generate verfication files for the forecast.

local CDATEL=$1    #Forecast start date
local EDATEL=$2    #Forecast end date  (if analysis or gues then should be equal)
local WORKDIR=$TMPDIR/verification/


rm -fr $TMPDIR/*.txt
rm -fr $TMPDIR/*.grd

#Prepare namelist for observation operator
cp $NAMELISTOBSOPE $TMPDIR/verification/obsope.namelist

if [ $RUN_ONLY_MEAN -eq 1 ] ; then
  #In this case we force the ensemble size to be 1.
  sed -i 's/@NBV@/'1'/g' $TMPDIR/verification/obsope.namelist
fi

edit_namelist_obsope $TMPDIR/verification/obsope.namelist

if [ $RUN_ONLY_MEAN -eq 1 ] ; then
   INIMEMBER=$MEANMEMBER
   ENDMEMBER=$MEANMEMBER
else
   INIMEMBER=1
   ENDMEMBER=$MEMBER
fi


if [ $FORECAST -eq 1  ] ; then

my_domain=1
while [ $my_domain -le $MAX_DOM ] ; do

 my_domain=` add_zeros $my_domain 2 `
 

 local output_dir=${RESULTDIRG}/obsver_d$my_domain
 mkdir -p $output_dir

 local my_date=$CDATEL
 local S=1
 while [ $my_date -le $EDATEL ] ; do

  local my_file_name=`wrfout_file_name ${my_date} $my_domain `
  local SLOT=`add_zeros $S 2 `

  if [ $RUN_ONLY_MEAN -eq 1 ] ; then
    local MEM=`ens_member $MEANMEMBER `
    local MEM1=`ens_member 1 `
    ln -sf ${RESULTDIRG}/${MEM}/${my_file_name}         ${WORKDIR}/gs${SLOT}${MEM1}
  else
    local M=$INIMEMBER
    while [ $M -le $ENDMEMBER ] ; do
      local MEM=`ens_member $M `
      ln -sf ${RESULTDIRG}/${MEM}/${my_file_name}       ${WORKDIR}/gs${SLOT}${MEM}              
      M=`expr $M + 1 `
    done
  fi

  #TODO: Add radar observations here.
  ln -sf ${OBSDIR}/${my_date}.dat                       ${WORKDIR}/obs${SLOT}.dat      

  my_date=`date_edit2 $my_date $WINDOW_FREC `
  S=`expr $S + 1 `
 done

  #Create run script
  echo "#!/bin/bash                                                                         " >  ${WORKDIR}/tmp.sh
  echo "export LD_LIBRARY_PATH=$RUNTIMELIBS:\$LD_LIBRARY_PATH                               " >> ${WORKDIR}/tmp.sh
  if [ $SYSTEM -eq  1 ] ; then
     echo " ulimit -s unlimited                                                             " >> ${WORKDIR}/tmp.sh
  fi
  echo "cd ${WORKDIR}/                                                                      " >> ${WORKDIR}/tmp.sh
  echo "$MPIBIN -np ${MAX_RUNNING} ./obsope.exe   > obsop.log                               " >> ${WORKDIR}/tmp.sh
  echo "mv ${WORKDIR}/*.grd       ${output_dir}                                             " >> ${WORKDIR}/tmp.sh
  echo "mv ${WORKDIR}/*.txt       ${output_dir}                                             " >> ${WORKDIR}/tmp.sh
  echo "mv ${WORKDIR}/obsope????? ${output_dir}                                             " >> ${WORKDIR}/tmp.sh
  echo "mv ${WORKDIR}/OBSO-???    ${output_dir}                                             " >> ${WORKDIR}/tmp.sh
  chmod 755 ${WORKDIR}/tmp.sh

  ssh $PPSSERVER ${WORKDIR}/tmp.sh

  my_domain=`expr $my_domain + 1 `
done


fi #[Script for forecast verification (supports muliple nests)]

if [ $ANALYSIS -eq 1  ] ; then


 #Run for the first guess
 local my_date=$CDATEL
 local S=1

  local SLOT=`add_zeros $S 2`

  local M=$INIMEMBER
  while [ $M -le $ENDMEMBER ] ; do
   local MEM=`ens_member $M `
   ln -sf ${RESULTDIRG}/gues${MEM}                  ${WORKDIR}/gs${SLOT}${MEM}
   M=`expr $M + 1 `
  done
  ln -sf ${OBSDIR}/${my_date}.dat                   ${WORKDIR}/obs${SLOT}.dat

  #Create run script
  echo "#!/bin/bash                                                                         " >  ${WORKDIR}/tmp.sh
  echo "export LD_LIBRARY_PATH=$RUNTIMELIBS:\$LD_LIBRARY_PATH                               " >> ${WORKDIR}/tmp.sh
  if [ $SYSTEM -eq  1 ] ; then
     echo " ulimit -s unlimited                                                             " >> ${WORKDIR}/tmp.sh
  fi
  echo "cd ${WORKDIR}/                                                                      " >> ${WORKDIR}/tmp.sh
  echo "$MPIBIN -np ${MAX_RUNNING} ./obsope.exe           > obsop.log                       " >> ${WORKDIR}/tmp.sh
  echo "mv ${WORKDIR}/obsmean01_01.grd    ${RESULTDIRG}/obsmeangues.grd                     " >> ${WORKDIR}/tmp.sh
  echo "mv ${WORKDIR}/obsmerr01_01.grd    ${RESULTDIRG}/obsmerrgues.grd                     " >> ${WORKDIR}/tmp.sh
  echo "mv ${WORKDIR}/obssprd01_01.grd    ${RESULTDIRG}/obssprdgues.grd                     " >> ${WORKDIR}/tmp.sh
  echo "mv ${WORKDIR}/obsonum01_01.grd    ${RESULTDIRG}/obsnumgues.grd                      " >> ${WORKDIR}/tmp.sh
  echo "mv ${WORKDIR}/oarea01_01.txt      ${RESULTDIRG}/oareagues.txt                       " >> ${WORKDIR}/tmp.sh
  
  echo "mv ${WORKDIR}/obsope????? ${RESULTDIRG}                                             " >> ${WORKDIR}/tmp.sh
  echo "mv ${WORKDIR}/OBSO-???    ${RESULTDIRG}                                             " >> ${WORKDIR}/tmp.sh
  chmod 755 ${WORKDIR}/tmp.sh

  ssh $PPSSERVER ${WORKDIR}/tmp.sh

 #Run for the analysis
 local my_date=$CDATEL
 local S=1

  local SLOT=`add_zeros $S 2`

  local M=$INIMEMBER
  while [ $M -le $ENDMEMBER ] ; do
   local MEM=`ens_member $M `
   ln -sf ${RESULTDIRA}/anal${MEM}                  ${WORKDIR}/gs${SLOT}${MEM}
   M=`expr $M + 1 `
  done
  ln -sf ${OBSDIR}/${my_date}.dat                   ${WORKDIR}/obs${SLOT}.dat

  #Create run script
  echo "#!/bin/bash                                                                         " >  ${WORKDIR}/tmp.sh
  echo "export LD_LIBRARY_PATH=$RUNTIMELIBS:\$LD_LIBRARY_PATH                               " >> ${WORKDIR}/tmp.sh
  if [ $SYSTEM -eq  1 ] ; then
     echo " ulimit -s unlimited                                                             " >> ${WORKDIR}/tmp.sh
  fi
  echo "cd ${WORKDIR}/                                                                      " >> ${WORKDIR}/tmp.sh
  echo "$MPIBIN -np ${MAX_RUNNING} ./obsope.exe         > obsop.log                         " >> ${WORKDIR}/tmp.sh
  echo "mv ${WORKDIR}/obsmean01_01.grd    ${RESULTDIRA}/obsmeananal.grd                     " >> ${WORKDIR}/tmp.sh
  echo "mv ${WORKDIR}/obsmerr01_01.grd    ${RESULTDIRA}/obsmerranal.grd                     " >> ${WORKDIR}/tmp.sh
  echo "mv ${WORKDIR}/obssprd01_01.grd    ${RESULTDIRA}/obssprdanal.grd                     " >> ${WORKDIR}/tmp.sh
  echo "mv ${WORKDIR}/obsonum01_01.grd    ${RESULTDIRA}/obsnumanal.grd                      " >> ${WORKDIR}/tmp.sh
  echo "mv ${WORKDIR}/oarea01_01.txt    ${RESULTDIRA}/oareaanal.txt                        " >> ${WORKDIR}/tmp.sh
  echo "mv ${WORKDIR}/obsope????? ${RESULTDIRA}                                             " >> ${WORKDIR}/tmp.sh
  echo "mv ${WORKDIR}/OBSO-???    ${RESULTDIRA}                                             " >> ${WORKDIR}/tmp.sh
  chmod 755 ${WORKDIR}/tmp.sh

  ssh $PPSSERVER ${WORKDIR}/tmp.sh

fi #[Script for analysis and gues verification ]


}

# ------------------------------------
#   FUNCTION : sub_and_wait
# ------------------------------------
sub_and_wait() {
input_shell=$1
n=$2
if [ $# -eq 1 ]; then
        n=$RANDOM
fi

local my_dir=$(dirname "${input_shell}")
local shell_name=$(basename "${input_shell}")

cd ${my_dir}

if [ $SYSTEM -eq 0 ] ; then  #K-computer
        request_log=$1
        id=`pjsub -z jid ${input_shell}`
        echo "${input_shell} SUMBITTED, ID= $id"


        echo "WAITING FOR THE JOB..."
        qsub_end=0
        while [ ${qsub_end} -eq 0 ]
        do
                pjstat > ${my_dir}/qstat.log${id}

               
                grep ${id} ${my_dir}/qstat.log${id} > ${my_dir}/grep.log${id}

                if [ ! -s ${my_dir}/grep.log${id} ]; then
                        qsub_end=1
                        echo "JOB FINISHED"
                        mv ${my_dir}/${shell_name}.* $OUTPUTDIR/joblogs/
                else
                        sleep 60
                fi
        done
fi

if [ $SYSTEM -eq 1 ] ; then  #Torque-cluster
        request_log=$1
        id=`qsub  ${input_shell}`
        echo "${input_shell} SUMBITTED, ID= $id"


        echo "WAITING FOR THE JOB..."
        qsub_end=0
        while [ ${qsub_end} -eq 0 ]
        do
                qstat > ${my_dir}/qstat.log${id}

                grep ${id} ${my_dir}/qstat.log${id} > ${my_dir}/grep.log${id}

                if [ ! -s ${my_dir}/grep.log${id} ]; then
                        qsub_end=1
                        echo "JOB FINISHED"
                        mv ${my_dir}/${shell_name}.* $OUTPUTDIR/joblogs/
                else
                        sleep 60
                fi
        done
fi

}

#################################################################################
#  CHECK POSTPROCESING FOR FORECAST AND ANALYSIS EXPERIMENTS.
#################################################################################

check_postproc () {
#TO DO, add checks over forecasts.
local cycle_error=0
local my_domain=1

if [ $RUN_ONLY_MEAN -eq 1 ] ; then
   INIMEMBER=$MEANMEMBER
   ENDMEMBER=$MEANMEMBER
else
   INIMEMBER=1
   ENDMEMBER=$MEMBER
fi

local M=$INIMEMBER

while [ $my_domain -le $MAX_DOM ] ; do
 my_domain=` add_zeros $my_domain 2 `
 while [ $M -le $ENDMEMBER ] ; do
  local MEM=`ens_member $M `
  if [ $FORECAST -eq 1 -o $ANALYSIS -eq 1 ] ; then
   grep  "Successful completion of ARWpost" ${RESULTDIRG}/arwpostd${my_domain}_${MEM}.log > null
   if [ $? -ne 0 ] ; then
     echo "[Error]: ARWPOST for gues ensemble member $MEM"
     echo "====================================="
     echo "SHOWING LAST PART OF arwpost${MEM}.log     "
     tail ${RESULTDIRG}/arwpostd${my_domain}_${MEM}.log
     cycle_error=1
   fi
  fi

  if [ $ANALYSIS -eq 1 ] ; then
   grep  "Successful completion of ARWpost" ${RESULTDIRA}/arwpostd${my_domain}_${MEM}.log > null
   if [ $? -ne 0 ] ; then
     echo "[Error]: ARWPOST for anal ensemble member $MEM"
     echo "====================================="
     echo "SHOWING LAST PART OF arwpost${MEM}.log     "
     tail ${RESULTDIRA}/arwpostd${my_domain}_${MEM}.log
     cycle_error=1
   fi
  fi

  M=`expr $M + 1 `
 done
 my_domain=`expr $my_domain + 1 `
done

}


#################################################################################
#  CHECK LETKF OUTPUT
#################################################################################

check_analysis () {

local cycle_error=0

local MMS=`ens_member $MEANMEMBER`
if [ ! -e ${RESULTDIRA}/anal$MMS ] ; then
  echo "[Error]: Cannot find analysis ensemble mean."
  cycle_error=1
fi

grep  "PARTIAL OBSERVATIONAL DEPARTURE" ${RESULTDIRA}/NOUT-000 > null
if [ $? -ne 0  ] ; then
 echo "[Error]: LETKF do not finish properly."
 tail ${RESULTDIRA}/NOUT-000
 cycle_error=1
fi

if [ $cycle_error -eq 1 ] ; then
   echo "LETKF ABNORMAL END -> STOP EXECUTION "
   exit 1
fi

}

#################################################################################
#  CHECK ENSEMBLE FORECAST OUPUT
#################################################################################

check_forecast () {

  local WORKDIR=$1     #Directory where the job scripts are
  local INIMEMBER=$2   #Initial ensemble member (optional), default 1
  local ENDMEMBER=$3   #End ensemble member (optional), default $MM


  #Default ensemble range is the full ensemble
   if [ ! -n "$INIMEMBER" ] ; then
    INIMEMBER=1
   fi
   if [ ! -n "$ENDMEMBER" ] ; then
    ENDMEMBER=$MEMBER
   fi
   if [ $RUN_ONLY_MEAN -eq 1 ] ; then
    INIMEMBER=$MEANMEMBER
    ENDMEMBER=$MEANMEMBER
   fi
   if [ ! -n "$USE_ANALYSIS_IC" ] ; then
     USE_ANALYSIS_IC=0
   fi

local M=$INIMEMBER
local cycle_error=0
while [ $M -le $ENDMEMBER ] ; do
 local MEM=`ens_member $M `
 grep "SUCCESS COMPLETE WRF" ${WORKDIR}/WRF${MEM}/rsl.error.0000 > /dev/null 2>&1 
 if [ $? -ne 0 ] ; then
   echo "[Error]: WRF for ensemble member $MEM"          
   echo "====================================="
   echo "SHOWING LAST PART OF wrf${MEM}.log     "
   tail ${WORKDIR}/WRF${MEM}/rsl.error.0000
   cycle_error=1
 fi
 
 if [ $ITER -ne 1 -a $USE_ANALYSIS_IC -ne 1 ] ; then
  grep  "Update_bc completed successfully" ${WORKDIR}/WRF${MEM}/daupdatebc${MEM}.log > /dev/null  2>&1 
  if [ $? -ne 0 ] ; then
   echo "[Error]: WRF da update bc for ensemble member $MEM"
   echo "====================================="
   echo "SHOWING LAST PART OF dapudatebc${MEM}.log     "
   tail ${WORKDIR}/WRF${MEM}/daupdatebc${MEM}.log
   cycle_error=1
  fi
 fi

 M=`expr $M + 1 `
done

if [ $cycle_error -eq 1 ] ; then
   echo "FORECAST ABNORMAL END -> REDO FORECAST FOR MEMBERS $INIMEMBER $ENDMEMBER "
   #exit 1
   echo 1
else
   echo 0
fi


}

#################################################################################
#  DOWNLOAD CFSR DATA
#################################################################################

download_cfsr () {
local LITIME=$1   #Start Time
local LETIME=$2   #End Time

local LINT=$3     #Frequency
local LDESTDIR=$4 #Destination dir

PROXY="proxy.fcen.uba.ar:8080"

local LCTIME=$LITIME
mkdir -p $LDESTDIR

while [ $LCTIME -le $LETIME ]
do
echo "Downloading the following file: $LCTIME"
local LFECHA=`echo $LCTIME | cut -c1-8`
local LANIO=`echo $LCTIME | cut -c1-4`
local LMES=`echo $LCTIME | cut -c5-6`
local LDIA=`echo $LCTIME | cut -c7-8`
local LHORA=`echo $LCTIME | cut -c9-10`

curl --proxy ${PROXY}  http://nomads.ncdc.noaa.gov/modeldata/cmd_grblow/$LANIO/${LANIO}${LMES}/${LANIO}${LMES}${LDIA}/pgbl00.gdas.${LANIO}${LMES}${LDIA}${LHORA}.grb2 -o $LDESTDIR/pgbl00.gdas.${LANIO}${LMES}${LDIA}${LHORA}.grb2

LCTIME=`date_edit2  $LCTIME $LINT `
echo $LCTIME

done

}

#################################################################################
#  GENERATE RANDOM DATES FOR BOUNDARY PERTURBATION
#################################################################################

get_random_dates () {

#This function generates (or reads from a file) a set of random generated dates.
#There are two dates for each ensemble member. These two dates are used in the computation of the random 
#perturbations that are used to generate the boundary and initial ensemble perturbations.

if [ $RESTART -eq 0 ] ; then
  
  if [ $INPUT_PERT_DATES_FROM_FILE -eq 0 ] ; then

     echo "Generating a new set of random dates"

     local MAX_TIMES=`date_diff $ENDPERTDATE $INIPERTDATE `

     local MAX_TIMES=`expr $MAX_TIMES \/ $BOUNDARY_DATA_PERTURBATION_FREQ ` #In days

     local EXP_LENGTH=`date_diff $EDATE $IDATE `
     local EXP_LENGTH=`expr $MAX_TIMES \/ $BOUNDARY_DATA_PERTURBATION_FREQ ` #In days


     local M=1

     while [ $M -le $MEMBER ] ; do

       local MEM=`ens_member $M `
       local PROCEED=0
       while [ $PROCEED -eq 0  ] ; do

         #Generate random numbers to pick random dates.
         #First date is totally random. Second date is within 5-25 days from the previous date. 
         local MAXINCREMENT=25 
         local MININCREMENT=5
         local TMPINCREMENT=20
         local TMPMAXINCREMENT=`expr $MAXINCREMENT \* 86400 \/ $BOUNDARY_DATA_PERTURBATION_FREQ `
          
         local TMPTIME=`expr $MAX_TIMES - $EXP_LENGTH - $TMPMAXINCREMENT `
         local number1=$RANDOM
         let "number1 %=$TMPTIME "
         local INCREMENT=$RANDOM
         let "INCREMENT %=$TMPINCREMENT"
         local INCREMENT=`expr $INCREMENT + $MININCREMENT `
         local INCREMENT=`expr $INCREMENT \* 86400 \/ $BOUNDARY_DATA_PERTURBATION_FREQ ` #Convert 

 
         local number2=`expr $number1 + $INCREMENT `

         local PROCEED=1
         #Test to see if number1 and number2 has been chosen before.
         if [ $M -gt 1 ] ; then
            for element in $(seq 1 `expr $M - 1 `  ) ; do
              if [ ${hist_number1[$element]} -eq $number1 ] && [ ${hist_number2[$element]} -eq $number2  ] ; then
                 PROCEED=0
                 echo "Number 1 and number 2 has been chosen before, let's chose another combination"
                 echo "If this happens a lot, increase the size of the analysis data base "
              fi
            done
         fi
         if [ $PROCEED -eq 1 ] ; then
            hist_number1[$M]=$number1
            hist_number2[$M]=$number2
         fi
       done

       #Get dates corresponding to these random numbers
       #2009 has been used for the generation of the perturbations.
       local INTERVAL=`expr $number1 \* $BOUNDARY_DATA_PERTURBATION_FREQ `
       INI_RANDOM_DATE1[${M}]=`date_edit2 $INIPERTDATE $INTERVAL `
  
       local INTERVAL=`expr $number2 \* $BOUNDARY_DATA_PERTURBATION_FREQ `
       INI_RANDOM_DATE2[${M}]=`date_edit2 $INIPERTDATE $INTERVAL `


       M=`expr $M + 1 `
     done


  else

    echo "Reading a set of random dates from file: $TMPDIR/NAMELIST/ini_pert_date_file "
    M=1
    while read line; do 
      echo $line  > $TMPDIR/tmp_file
      read TMPINDATE1 TMPINDATE2 < $TMPDIR/tmp_file
      INI_RANDOM_DATE1[${M}]=$TMPINDATE1
      INI_RANDOM_DATE2[${M}]=$TMPINDATE2  
      M=`expr $M + 1 `
    done < $TMPDIR/NAMELIST/ini_pert_date_file

  fi

  #Generate random date file
  if [  ! -e  $OUTPUTDIR/initial_random_dates ] ; then
    local M=1
    while [ $M -le $MEMBER ] ; do
      echo ${INI_RANDOM_DATE1[${M}]} " " ${INI_RANDOM_DATE2[${M}]}  >> $OUTPUTDIR/initial_random_dates
      M=`expr $M + 1 `
    done

  fi


else #RESTART = 1 

    #This is a restart run read the initial random dates from the OUTPUTDIR.
    echo "Reading a set of random dates from file: $OUTPUTDIR/initial_perturbation_dates "
    M=1
    while read line; do 
      echo $line  > $TMPDIR/tmp_file
      read TMPINDATE1 TMPINDATE2 < $TMPDIR/tmp_file
      INI_RANDOM_DATE1[${M}]=$TMPINDATE1
      INI_RANDOM_DATE2[${M}]=$TMPINDATE2
      M=`expr $M + 1 `
    done < $OUTPUTDIR/initial_random_dates

fi #FI over the restart = 0 contion.


}


