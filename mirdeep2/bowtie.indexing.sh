#!/bin/bash
#SBATCH -A Research_Project-MRC164847 # research project to submit under.
#SBATCH --export=ALL # export all environment variables to the batch job.
#SBATCH -D . # set working directory to .
#SBATCH -p mrcq
#SBATCH --time=50:00:00 # Maximum wall time for the job
#SBATCH --nodes=1 # specify number of nodes.
#SBATCH --ntasks-per-node=16 # specify number of processors.
#SBATCH --mail-type=END # send email at job completion
#SBATCH --mail-user=m.kouhsar@exeter.ac.uk # email address

out_dir=/lustre/projects/Research_Project-191391/Morteza/mirdeep2
genome_file=/lustre/projects/Research_Project-191391/Morteza/mirdeep2/hg38.fa


if [ ! -d "${out_dir}/bowtie-index" ]
then
  echo "Generating bowtie index..." 
  module load Bowtie
  mkdir ${out_dir}/bowtie-index
  bowtie-build ${out_dir}/${genome_file}  ${out_dir}/bowtie-index/${genome_file}
fi

