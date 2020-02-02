#!/bin/bash -l
#SBATCH --error=slurm.err
#SBATCH --output=slurm.out
#SBATCH --exclusive
#SBATCH --job-name="GW100-N3"
#SBATCH --time=08:10:00
#SBATCH --nodes=<nodes>
#SBATCH --ntasks-per-core=1
#SBATCH --ntasks-per-node=36
#SBATCH --cpus-per-task=1
#SBATCH --partition=normal
##SBATCH --mem=120GB
#SBATCH --constraint=mc
#SBATCH --account="uzh1"
#SBATCH --hint=nomultithread

module load "daint-mc"
export OMP_NUM_THREADS=$SLURM_CPUS_PER_TASK

srun /users/jwilhelm/03_GW_freq_trunc_Coul_for_GW100/GW_improved_freq_time/exe/daint-mc-regtest/cp2k.psmp *.inp &> cp2k.out
