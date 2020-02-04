#!/bin/bash

result_file='results.out'
xyzdir='/scratch/snx3000/jwilhelm/23_GW100_git/1_struc/'
wfndir='/scratch/snx3000/jwilhelm/23_GW100_git/5_WFN'
calcdir=$(pwd)
GWfile='GW.inp'
submitfile='run.sh'
cp2koutfile='cp2k.out'

length=${#xyzdir}

for xyzfile in $xyzdir*
do

  xyzname=${xyzfile:$length}
  dirname=${xyzname::-4}

  if [ ! -d "$calcdir/$dirname" ]; then
    mkdir $dirname
  fi
  cd $dirname
  cp $calcdir'/'$GWfile .
  sed -i -e 's/<geo>/'$xyzname'/g' $GWfile
  cp $xyzfile .

  cp $calcdir'/'$submitfile .
  if [ $dirname == '23_C4H10' ] || [$dirname == '27_C3H6'] || [ $dirname == '28_C6H6' ] || [ $dirname == '29_C8H8' ] || [ $dirname == '30_C5H6' ] || [ $dirname == '34_C2H3I' ] || [ $dirname == '37_CBr4' ] || [ $dirname == '42_Si5H12' ] || [ $dirname == '56_TiF4' ] || [ $dirname == '64_AlI3' ] || [ $dirname == '73_C4H10O4' ] || [ $dirname == '86_C7H8' ] || [ $dirname == '87_C8H10' ] || [ $dirname == '88_C6F6' ] || [ $dirname == '89_C6H5OH' ] || [ $dirname == '90_C6H5NH2' ] || [ $dirname == '91_C5H5N' ] || [ $dirname == '92_guanine' ] || [ $dirname == '93_adenine' ] || [ $dirname == '94_cytosine' ] || [ $dirname == '95_thymine' ] || [ $dirname == '96_uracil' ] ; then

    sed -i -e 's/<nodes>/3/g' $submitfile

  elif [ $dirname == '22_C3H8' ] ; then

    sed -i -e 's/<nodes>/1/g' $submitfile

  elif [ $dirname == '38_CI4' ] ; then

    sed -i -e 's/<nodes>/4/g' $submitfile

  else

    sed -i -e 's/<nodes>/1/g' $submitfile

  fi

  if [ $dirname == '65_BN' ] ; then
    sed -i -e 's/NUM_FREQ_POINTS_CLENSHAW_LOW_SCALING_GW     100/NUM_FREQ_POINTS_CLENSHAW_LOW_SCALING_GW     400/g' $GWfile
    sed -i -e 's/<time>/23/g' $submitfile
  else
    sed -i -e 's/<time>/03/g' $submitfile
  fi

  if [ $dirname == '56_TiF4' ] || [ $dirname == '65_BN' ] || [ $dirname == '67_PN' ] || [ $dirname == '81_CO' ] || [ $dirname == '84_BeO' ] || [ $dirname == '85_MgO' ] || [ $dirname == '100_CuCN' ] ; then
      cp $wfndir'/'$dirname'/ALL_ELEC-RESTART.wfn' .
      echo 'Copied WFN for   '$xyzname'.'
  fi

  if grep -Fq "( vir )" $cp2koutfile
  then
      echo 'Calculation for  '$xyzname' already terminated. -> Skip it.'
  else
      sbatch $submitfile
      echo 'Started calc for '$xyzname'.'
  fi

  cd ..

done
