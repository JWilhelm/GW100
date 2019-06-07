#!/bin/bash

result_file='results.out'
xyzdir='/data/wilhelm/2_job_test/11_GW100/1_struc/'
inpdir='/data/wilhelm/2_job_test/11_GW100/2_input_and_script'
calcdir='/data/wilhelm/2_job_test/11_GW100/3_calcs'
GWfile='GW.inp'
reffile='GW_reference.dat'
skipfile='skip.dat'
outfile='cp2k.out'
exclhomofile='excluded_HOMOs.dat'
excllumofile='excluded_LUMOs.dat'
absresultfile=$inpdir'/'$result_file
absreffile=$inpdir'/'$reffile
cd $calcdir
length=${#xyzdir}

echo ' #  Name   HOMO      ref HOMO  LUMO      ref LUMO  chiomegatau   fit-points  Pade-param   runavg. error HOMO/LUMO' > $absresultfile

homodiffsum='0.0'
lumodiffsum='0.0'
n_molecules_homo='0'
n_molecules_lumo='0'

for xyzfile in $xyzdir*
do
  xyzname=${xyzfile:$length}
  dirname=${xyzname::-4}

  if grep -q "$dirname" "$inpdir/$skipfile"; then
    echo $dirname' skipped'
    echo " "$dirname >> $absresultfile
    continue
  fi

  if [ ! -d "$calcdir/$dirname" ]; then
    mkdir $dirname
  fi
  cd $dirname
  cp $inpdir'/'$GWfile .
  sed -i -e 's/<geo>/'$xyzname'/g' $GWfile
  cp $xyzfile .

  if test -f "$calcdir/$dirname/$outfile"; then
    if grep -q "PROGRAM STOPPED IN" "$outfile"; then
      echo $dirname' already done'
    else
      echo $dirname' running'
      mpirun -np 24 /data/wilhelm/1_git_repository/cp2k/exe/local_valgrind_March_2019/cp2k.pdbg \
      $GWfile &> $outfile
    fi
  else
    echo $dirname' running'
    mpirun -np 24 /data/wilhelm/1_git_repository/cp2k/exe/local_valgrind_March_2019/cp2k.pdbg \
    $GWfile &> $outfile
  fi

  chiomegatau=$(grep -m 1 "Maximum deviation of the imag. time fit:" $outfile | awk '{ print $9 }')
  numfitpoints=$(grep -m 1 "Number of fit points for analytic continuation:" $outfile | awk '{ print $8 }')
  numpadeparam=$(grep -m 1 "Number of pade parameters:" $outfile | awk '{ print $5 }')

  homo=$(grep "( occ )" $outfile | tail -1 | awk '{ print $10 }')
  lumo=$(grep "( vir )" $outfile | head -1 | awk '{ print $10 }')

  homo_ref=$(grep $dirname $absreffile |  awk '{ print $2 }')
  lumo_ref=$(grep $dirname $absreffile |  awk '{ print $3 }')

  homo=$(printf '%.*f\n' 2 $homo)
  lumo=$(printf '%.*f\n' 2 $lumo)

  if grep -q "$dirname" "$inpdir/$exclhomofile"; then
    echo $dirname' skipped for averaging HOMO'
  else
    homodiffsum=$(echo "$homodiffsum+($homo-($homo_ref))*($homo > $homo_ref)"| bc -l)
    homodiffsum=$(echo "$homodiffsum+($homo_ref-($homo))*($homo < $homo_ref)"| bc -l)
    n_molecules_homo=$(echo "$n_molecules_homo+1"| bc -l)
  fi

  if grep -q "$dirname" "$inpdir/$excllumofile"; then
    echo $dirname' skipped for averaging LUMO'
  else
    lumodiffsum=$(echo "$lumodiffsum+($lumo-($lumo_ref))*($lumo > $lumo_ref)"| bc -l)
    lumodiffsum=$(echo "$lumodiffsum+($lumo_ref-($lumo))*($lumo < $lumo_ref)"| bc -l)
    n_molecules_lumo=$(echo "$n_molecules_lumo+1"| bc -l)
  fi

  runavgerror_homo=$(printf '%.*f\n' 3 $(echo "$homodiffsum / $n_molecules_homo"| bc -l))
  runavgerror_lumo=$(printf '%.*f\n' 3 $(echo "$lumodiffsum / $n_molecules_lumo"| bc -l))

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
  numfitpoints=$numfitpoints"______________________"
  numfitpoints=${numfitpoints:0:8}
  numpadeparam=$numpadeparam"______________________"
  numpadeparam=${numpadeparam:0:8}
  runavgerror_homo=$runavgerror_homo"____________________________"
  runavgerror_homo=${runavgerror_homo:0:10}
  runavgerror_lumo=$runavgerror_lumo"____________________________"
  runavgerror_lumo=${runavgerror_lumo:0:10}

  echo " "$dirname $homo $homo_ref $lumo $lumo_ref $chiomegatau $numfitpoints $numpadeparam \
          $runavgerror_homo$runavgerror_lumo >> $absresultfile

  sed -i 's/_/ /g' $absresultfile

  cd ..
done
