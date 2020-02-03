#!/bin/bash

additional_16_pole_strucs='additional_128_poles.dat'
xyzdir='/scratch/snx3000/jwilhelm/23_GW100_git/1_struc/'
wfndir='/scratch/snx3000/jwilhelm/23_GW100_git/5_WFN'
calcdir=$(pwd)
GWfile='GW.inp'
submitfile='run.sh'
cp2koutfile='cp2k.out'

length=${#xyzdir}

while read struc; do
  echo  $struc
  cd    $struc
  mkdir "1_128_poles"
  cd    "1_128_poles"
  cp "../"$GWfile .
  cp "../"$submitfile .
  cp "../"$struc".xyz" .
  sed -i -e 's/NPARAM_PADE                                  16/NPARAM_PADE                                 128/g' $GWfile
  sbatch $submitfile
  cd ../..
done <$additional_16_pole_strucs

