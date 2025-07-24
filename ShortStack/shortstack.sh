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
# Installing MINTmap: 'conda install bioconda::mintmap'
# To see the parameters description run 'MINTmap.pl -h'

result_dir=./ShortStack.Results
fastq_dir=./sRNA_Seq_trimmed
genome_fasta="/lustre/projects/Research_Project-191391/Morteza/Small_nonCoding_RNAs/miRNA/mirdeep2/Ref/hg38.fa"
threads=16

#######################################################################################
#######################################################################################
fastq_files=(${fastq_dir}/*.fastq.gz)

mkdir -p $result_dir

j=0

for i in ${fastq_files[@]}
do
    sample_name=$(basename $i)
    echo "working on sample $((j+1)): $sample_name"
    
    ShortStack --genomefile $genome_fasta --readfile $i --outdir ${result_dir}/${sample_name%.fastq.gz} --threads $threads
    
    j=$(( j + 1 ))
done

echo "all processes have been done!"
