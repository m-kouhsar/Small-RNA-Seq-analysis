#!/bin/bash
#SBATCH -A Research_Project-MRC164847 # research project to submit under.
#SBATCH --export=ALL # export all environment variables to the batch job.
#SBATCH -D . # set working directory to .
#SBATCH -p mrcq
#SBATCH --time=10:00:00 # Maximum wall time for the job
#SBATCH --nodes=1 # specify number of nodes.
#SBATCH --ntasks-per-node=16 # specify number of processors.
#SBATCH --mail-type=END # send email at job completion
#SBATCH --mail-user=m.kouhsar@exeter.ac.uk # email address
#SBATCH --array=0-19
#########################################################################################
#########################################################################################

result_dir=./ShortStack.Results
fastq_dir=./sRNA_Seq_trimmed
genome_fasta="./Ref/hg38.fa"
genome_annot="./gencode.v48.annotation.shortstack.txt"
threads=16

#######################################################################################
#######################################################################################

fastq_files=(${fastq_dir}/*.fastq.gz)

Num_samp=${#fastq_files[@]}

denom_2=$(( SLURM_ARRAY_TASK_COUNT / 2 ))
window_size=$(( ( Num_samp + denom_2 ) / SLURM_ARRAY_TASK_COUNT ))

lower=$(( SLURM_ARRAY_TASK_ID * window_size ))

fastq_files1=(${fastq_files[@]:${lower}:${window_size}})

if [ "$SLURM_ARRAY_TASK_ID" -eq "$SLURM_ARRAY_TASK_MAX" ]
then
    fastq_files1=(${fastq_files[@]:$lower})
fi

echo Output directory: $result_dir
echo Fastq files directory: $fastq_dir
echo Genome version: $genome_fasta
echo Number of samples: $Num_samp
echo Start array index: $SLURM_ARRAY_TASK_MIN
echo End array index : $SLURM_ARRAY_TASK_MAX
echo numer of arrays: $SLURM_ARRAY_TASK_COUNT
echo current array index: $SLURM_ARRAY_TASK_ID
echo Number of samples in current array: ${#fastq_files1[@]}

echo "##########################################################################"
echo -e '\n'
mkdir -p $result_dir
if [ ${#fastq_files1[@]} != 0 ]
then
    j=0
    
    for i in ${fastq_files1[@]}
    do
        sample_name=$(basename $i)
        echo "working on sample $((j+1)): $sample_name"
    
        ShortStack --genomefile $genome_fasta --readfile $i --outdir ${result_dir}/${sample_name%.fastq.gz} --locifile $genome_annot --bowtie_cores $threads
        
        j=$(( j + 1 ))
    done

    echo "all processes have been done!"
else
    echo "There is no sample in this array!"
fi
