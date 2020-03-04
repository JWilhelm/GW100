#!/bin/bash -l
#SBATCH --error=slurm.err
#SBATCH --output=slurm.out
#SBATCH --exclusive
#SBATCH --job-name="GW100-N3"
#SBATCH --time=00:40:00
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

srun   /users/jwilhelm/01_git_tcopt/cp2k/exe/daint-mc-regtest/cp2k.psmp_02_a4b1e46df3a186a02c3dbb6c3d09beeccc71116c_added_32_point_mesh   *.inp &> cp2k.out
