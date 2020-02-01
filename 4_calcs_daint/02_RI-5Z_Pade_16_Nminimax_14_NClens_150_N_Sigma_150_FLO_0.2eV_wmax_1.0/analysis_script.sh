#!/bin/bash

result_file='results.out'
xyzdir='/scratch/snx3000/jwilhelm/23_GW100_git/1_struc/'
calcdir='/scratch/snx3000/jwilhelm/23_GW100_git/4_calcs_daint/02_RI-5Z_Pade_16_Nminimax_14_NClens_150_N_Sigma_150_FLO_0.2eV_wmax_1.0'
GWfile='GW.inp'
reffile='GW_reference.dat'
outfile='cp2k.out'
exclhomofile='excluded_HOMOs.dat'
excllumofile='excluded_LUMOs.dat'
absresultfile=$calcdir'/'$result_file
absreffile=$calcdir'/'$reffile
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
  cd $dirname

  homo=$(grep "( occ )" $outfile | tail -1 | awk '{ print $10 }')
  lumo=$(grep "( vir )" $outfile | head -1 | awk '{ print $10 }')

  homo_ref=$(grep $dirname $absreffile |  awk '{ print $2 }')
  lumo_ref=$(grep $dirname $absreffile |  awk '{ print $3 }')

  homo=$(printf '%.*f\n' 2 $homo)
  lumo=$(printf '%.*f\n' 2 $lumo)

  if grep -q "$dirname" "$calcdir/$exclhomofile"; then
    echo $dirname' skipped for averaging HOMO'
  else
    homodiffsum=$(echo "$homodiffsum+($homo-($homo_ref))*($homo > $homo_ref)"| bc -l)
    homodiffsum=$(echo "$homodiffsum+($homo_ref-($homo))*($homo < $homo_ref)"| bc -l)
    n_molecules_homo=$(echo "$n_molecules_homo+1"| bc -l)
  fi

  if grep -q "$dirname" "$calcdir/$excllumofile"; then
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
  runavgerror_homo=$runavgerror_homo"____________________________"
  runavgerror_homo=${runavgerror_homo:0:10}
  runavgerror_lumo=$runavgerror_lumo"____________________________"
  runavgerror_lumo=${runavgerror_lumo:0:10}

  echo " "$dirname $homo $homo_ref $lumo $lumo_ref  \
          $runavgerror_homo$runavgerror_lumo >> $absresultfile

  sed -i 's/_/ /g' $absresultfile

  cd ..
done
