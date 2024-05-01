#!/bin/bash
#SBATCH --partition=long
#SBATCH --job-name=hospital_price
#SBATCH --output=out/%x_%j.out
#SBATCH --error=err/%x_%j.err
#SBATCH --nodes=1
#SBATCH --cpus-per-task=16
#SBATCH --mem-per-cpu=2500
#SBATCH --array=0-2  

module load R/R-4.0.1 openmpi/mpi-4.0.0
srun  Rscript group2.R splitted_parts/part_${SLURM_ARRAY_TASK_ID}.csv