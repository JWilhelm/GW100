#!/bin/bash
#SBATCH -t 02:20:00
#SBATCH --exclusive
#SBATCH --ntasks-per-node=32
#SBATCH --cpus-per-task=4
#SBATCH -N 1
#SBATCH -J "GW100"

export OMP_NUM_THREADS=4
export OMP_PLACES=cores
export OMP_PROC_BIND=true

module reset
module load chem/CP2K/2023.1-foss-2022b-gcc-openmpi-openblas
srun  /pc2/groups/hpc-prf-eprop2d/eprop2d1_Jan/02_compile_CP2K/10*/cp2k/exe/local_fixed_hdf5/cp2k.psmp    *.inp &> cp2k.out
