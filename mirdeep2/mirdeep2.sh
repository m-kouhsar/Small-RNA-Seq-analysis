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

### miRDeep2.pl inputs
result_dir=/lustre/projects/Research_Project-191391/Morteza/miRNA/Results/Project.11008.V0304.NorCog/mirdeep2.R1
genome_file=/lustre/projects/Research_Project-191391/Morteza/mirdeep2/hg38.fa
hairpin_file=/lustre/projects/Research_Project-191391/Morteza/mirdeep2/hairpin1.fa.fix
mature_file=/lustre/projects/Research_Project-191391/Morteza/mirdeep2/mature1.fa.fix

### mapper.pl inputs
skip_mapper=no
### The following two arguments are mendatory if you set skip_mapper to "yes"
mapper_fa=/lustre/projects/Research_Project-191391/Morteza/miRNA/Results/Project.11008.V0304.NorCog/mirdeep2.R1/mapper.16.fa
mapper_arf=/lustre/projects/Research_Project-191391/Morteza/miRNA/Results/Project.11008.V0304.NorCog/mirdeep2.R1/mapper.16.arf
### The following three arguments are mendatory if you set skip_mapper to "no"
fastq_dir=/lustre/projects/Research_Project-191391/Morteza/miRNA/Results/Project.11008.V0304.NorCog/R1
bowtie_index_pref=/lustre/projects/Research_Project-191391/Morteza/mirdeep2/bowtie-index/hg38.fa


#######################################################################################
#######################################################################################
fastq_files=(${fastq_dir}/*R1*.fastq)

mkdir -p $result_dir
cd $result_dir
#step 1: generating config file
echo Saving config file to ${result_dir}/config.txt
j=0
for i in ${fastq_files[@]}
do
    j_code=$(printf "%03d\n" "$((j+1))")
    echo -e "${i}\t${j_code}" >> config.txt
    j=$(( j + 1 ))
done

config_file=config.txt

#step 2: mapping on the ref genome using mapper module

if [ $skip_mapper != "yes" ]
then
    echo -e '\n'
    echo "Running mapper.pl..."
    mapper.pl ${config_file} \
        -d -e -h -i -j  -l 18 -m -p $bowtie_index_pref \
        -s mapper.fa \
        -t mapper.arf -v -o 16\
    
    mapper_fa=mapper.fa
    mapper_arf=mapper.arf
fi

#step 3: extracting miRNA count with miRdeep2 module
echo -e '\n'
echo "Running miRDeep2.pl..."

miRDeep2.pl $mapper_fa \
    ${genome_file} \
    $mapper_arf \
    ${mature_file} none ${hairpin_file} \
    -t hsa 2>mirdeep2.log \

echo "all processes have been done!"

