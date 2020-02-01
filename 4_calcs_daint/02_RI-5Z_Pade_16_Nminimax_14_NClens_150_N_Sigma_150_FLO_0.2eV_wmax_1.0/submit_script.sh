#!/bin/bash

result_file='results.out'
xyzdir='/scratch/snx3000/jwilhelm/23_GW100_git/1_struc/'
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
  if [ $dirname == '23_C4H10' ] || [ $dirname == '28_C6H6' ] || [ $dirname == '29_C8H8' ] || [ $dirname == '30_C5H6' ] || [ $dirname == '37_CBr4' ] || [ $dirname == '38_CI4' ] || [ $dirname == '42_Si5H12' ] || [ $dirname == '56_TiF4' ] || [ $dirname == '64_AlI3' ] || [ $dirname == '73_C4H10O4' ] || [ $dirname == '86_C7H8' ] || [ $dirname == '87_C8H10' ] || [ $dirname == '88_C6F6' ] || [ $dirname == '89_C6H5OH' ] || [ $dirname == '90_C6H5NH2' ] || [ $dirname == '91_C5H5N' ] || [ $dirname == '92_guanine' ] || [ $dirname == '93_adenine' ] || [ $dirname == '94_cytosine' ] || [ $dirname == '95_thymine' ] || [ $dirname == '96_uracil' ] ; then

    sed -i -e 's/<nodes>/8/g' $submitfile

  else

    sed -i -e 's/<nodes>/1/g' $submitfile

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
