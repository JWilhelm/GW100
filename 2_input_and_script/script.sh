#!/bin/bash

result_file='results.out'
xyzdir='/data/wilhelm/2_job_test/11_GW100/1_struc/'
inpdir='/data/wilhelm/2_job_test/11_GW100/2_input_and_script'
calcdir='/data/wilhelm/2_job_test/11_GW100/3_calcs'
GWfile='GW.inp'
reffile='GW_reference.dat'
outfile='cp2k.out'
absresultfile=$inpdir'/'$result_file
absreffile=$inpdir'/'$reffile
cd $calcdir
length=${#xyzdir}

echo ' #  Name   HOMO      ref HOMO  LUMO      ref LUMO  chiomegatau   runavg. error HOMO/LUMO' > $absresultfile

homodiffsum='0.0'
lumodiffsum='0.0'
n_molecules='0'

for xyzfile in $xyzdir*
do
  xyzname=${xyzfile:$length}
  dirname=${xyzname::-4}
  if [ ! -d "$calcdir/$dirname" ]; then
    mkdir $dirname
  fi
  cd $dirname
  cp $inpdir'/'$GWfile .
  sed -i -e 's/<geo>/'$xyzname'/g' $GWfile
  cp $xyzfile .
  if grep -q "PROGRAM STOPPED IN" "$outfile"; then
    echo $dirname' already done'
  else
    echo $dirname' running'
    mpirun -np 4 /data/wilhelm/1_git_repository/cp2k/exe/local_valgrind_March_2019/cp2k.pdbg \
    $GWfile &> $outfile
  fi

  chiomegatau=$(grep -m 1 "Maximum deviation of the imag. time fit:" $outfile | awk '{ print $9 }')
  homo=$(grep "( occ )" $outfile | tail -1 | awk '{ print $10 }')
  lumo=$(grep "( vir )" $outfile | head -1 | awk '{ print $10 }')

  homo_ref=$(grep $dirname $absreffile |  awk '{ print $2 }')
  lumo_ref=$(grep $dirname $absreffile |  awk '{ print $3 }')

  homo=$(printf '%.*f\n' 2 $homo)
  lumo=$(printf '%.*f\n' 2 $lumo)

  homodiffsum=$(echo "$homodiffsum+($homo-($homo_ref))*($homo > $homo_ref)"| bc -l)
  homodiffsum=$(echo "$homodiffsum+($homo_ref-($homo))*($homo < $homo_ref)"| bc -l)

  lumodiffsum=$(echo "$lumodiffsum+($lumo-($lumo_ref))*($lumo > $lumo_ref)"| bc -l)
  lumodiffsum=$(echo "$lumodiffsum+($lumo_ref-($lumo))*($lumo < $lumo_ref)"| bc -l)

  n_molecules=$(echo "$n_molecules+1"| bc -l)
  runavgerror_homo=$(printf '%.*f\n' 3 $(echo "$homodiffsum / $n_molecules"| bc -l))
  runavgerror_lumo=$(printf '%.*f\n' 3 $(echo "$lumodiffsum / $n_molecules"| bc -l))

  dirname=$dirname"______________________"
  dirname=${dirname:0:10}
  homo=$homo"______________________"
  homo=${homo:0:10}
  homo_ref=$homo_ref"______________________"
  homo_ref=${homo_ref:0:10}
  lumo=$lumo"______________________"
  lumo=${lumo:0:10}
  lumo_ref=$lumo_ref"______________________"
  lumo_ref=${lumo_ref:0:10}
  chiomegatau=$chiomegatau"___________________________"
  chiomegatau=${chiomegatau:0:14}
  runavgerror_homo=$runavgerror_homo"____________________________"
  runavgerror_homo=${runavgerror_homo:0:10}
  runavgerror_lumo=$runavgerror_lumo"____________________________"
  runavgerror_lumo=${runavgerror_lumo:0:10}

  echo " "$dirname$homo$homo_ref$lumo$lumo_ref$chiomegatau$runavgerror_homo$runavgerror_lumo \
        >> $absresultfile

  sed -i 's/_/ /g' $absresultfile

  cd ..
done
