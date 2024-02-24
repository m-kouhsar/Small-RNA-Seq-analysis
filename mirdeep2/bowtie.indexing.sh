#!/bin/bash
#SBATCH -A Research_Project1 # research project to submit under.
#SBATCH --export=ALL # export all environment variables to the batch job.
#SBATCH -D . # set working directory to .
#SBATCH -p mrcq
#SBATCH --time=5:00:00 # Maximum wall time for the job
#SBATCH --nodes=1 # specify number of nodes.
#SBATCH --ntasks-per-node=16 # specify number of processors.
#SBATCH --mail-type=END # send email at job completion
#SBATCH --mail-user=m.kouhsar@exeter.ac.uk # email address

out_dir=./mirdeep2/bowtie-index
genome_file=./mirdeep2/hg38.fa


if [ ! -d "${out_dir}/bowtie-index" ]
then
  echo "Generating bowtie index..." 
  module load Bowtie
  mkdir -p ${out_dir}
  bowtie-build ${genome_file}  ${out_dir}
fi

