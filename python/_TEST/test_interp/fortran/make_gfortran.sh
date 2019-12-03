#This script compiles the fortran code and generates a python module
export PATH=~/anaconda3/bin/:$PATH
export LD_LIBRARY_PATH=~/anaconda3/lib/:$LD_LIBRARY_PATH

export FC=gfortran
export F77=gfortran
export F90=gfortran
export F2PY=f2py
#export F2PY=f2py3

export FFLAGS='-fopenmp -lgomp -O3 -fPIC '
#export FFLAGS='-g -fbacktrace -fPIC'

rm *.o *.mod *.so

$F2PY  -c common_superobbing.f90 -lgomp --f90flags="$FFLAGS" -m cs


#mv cs.cpython-37m-x86_64-linux-gnu.so cs.cpython-36m-x86_64-linux-gnu.so


