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
#SBATCH --array=0-19
#########################################################################################
#########################################################################################
# Installing MINTmap: 'conda install bioconda::mintmap'
# To see the parameters description run 'MINTmap.pl -h'

result_dir=./MINTmap.results
fastq_dir=./trimmed_fastq_files
genome_assembly="GRCh38"
lookuptable="/lustre/projects/Research_Project-191391/Morteza/Small_nonCoding_RNAs/tRNA_Fragments/MINTmap/MINTmap_github/LookupTable.tRFs.MINTmap_v1.txt"
tRNAsequences="/lustre/projects/Research_Project-191391/Morteza/Small_nonCoding_RNAs/tRNA_Fragments/MINTmap/MINTmap_github/tRNAspace.Spliced.Sequences.MINTmap_v1.fa"
tRFtypes="/lustre/projects/Research_Project-191391/Morteza/Small_nonCoding_RNAs/tRNA_Fragments/MINTmap/MINTmap_github/OtherAnnotations.MINTmap_v1.txt"
MINTplatesPath=/lustre/projects/Research_Project-191391/Morteza/Small_nonCoding_RNAs/tRNA_Fragments/MINTmap/MINTmap_github/MINTplates/

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
echo Genome version: $genome_assembly
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
    cd $mintmap_git_dir
    for i in ${fastq_files1[@]}
    do
        sample_name=$(basename $i)
        echo "working on sample $((j+1)): $sample_name"
    
        MINTmap.pl -f $i -p ${result_dir}/${sample_name%.fastq.gz} -l $lookuptable -s $tRNAsequences -o $tRFtypes -a $genome_assembly -j $MINTplatesPath
        j=$(( j + 1 ))
    done

    echo "all processes have been done!"
else
    echo "There is no sample in this array!"
fi
