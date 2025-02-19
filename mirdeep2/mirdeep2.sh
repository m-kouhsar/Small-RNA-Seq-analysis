#!/bin/bash
#SBATCH -A Research_Project-MRC164847 # research project to submit under.
#SBATCH --export=ALL # export all environment variables to the batch job.
#SBATCH -D . # set working directory to .
#SBATCH -p mrcq
#SBATCH --time=30:00:00 # Maximum wall time for the job
#SBATCH --nodes=1 # specify number of nodes.
#SBATCH --ntasks-per-node=16 # specify number of processors.
#SBATCH --mail-type=END # send email at job completion
#SBATCH --mail-user=m.kouhsar@exeter.ac.uk # email address

#########################################################################################
#########################################################################################

result_dir=/lustre/projects/Research_Project-191391/Morteza/miRNA/Results/Project.11008.V0304.NorCog/mirdeep2.R1
fastq_dir=/lustre/projects/Research_Project-191391/Morteza/miRNA/Results/Project.11008.V0304.NorCog/R1
genome_file=/lustre/projects/Research_Project-191391/Morteza/mirdeep2/hg38.fa
bowtie_index_pref=/lustre/projects/Research_Project-191391/Morteza/mirdeep2/bowtie-index/hg38.fa
hairpin_file=/lustre/projects/Research_Project-191391/Morteza/mirdeep2/hairpin1.fa.fix
mature_file=/lustre/projects/Research_Project-191391/Morteza/mirdeep2/mature1.fa.fix
config_file=/lustre/projects/Research_Project-191391/Morteza/miRNA/Results/Project.11008.V0304.NorCog/mirdeep2.R1/config.txt

#######################################################################################
#######################################################################################


mkdir -p $result_dir
cd $result_dir

#step 1: mapping on the ref genome using mapper module
echo -e '\n'
echo "Running mapper.pl..."

mapper.pl ${config_file} \
    -d -e -h -i -j  -l 18 -m -p $bowtie_index_pref \
    -s mapper.fa \
    -t mapper.arf -v -o 16\

#step 2: extracting miRNA count with miRdeep2 module
echo -e '\n'
echo "Running miRDeep2.pl..."

miRDeep2.pl mapper.fa \
    ${genome_file} \
    mapper.arf \
    ${mature_file} none ${hairpin_file} \
    -t hsa 2>mirdeep2.log \

echo "all processes have been done!"

