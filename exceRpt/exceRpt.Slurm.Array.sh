#!/bin/bash
#SBATCH -A Research_Project1 # research project to submit under.
#SBATCH --job-name=exceRpt  # job name
#SBATCH --output=exceRpt.%j.log  # output
#SBATCH --export=ALL # export all environment variables to the batch job.
#SBATCH -D . # set working directory to .
#SBATCH -p mrcq # submit to the parallel test queue
#SBATCH --time=25:00:00 # Maximum wall time for the job
#SBATCH --nodes=1 # specify number of nodes.
#SBATCH --ntasks-per-node=16 # specify number of processors.
#SBATCH --mail-type=END # send email at job completion
#SBATCH --mail-user=m.kouhsar@exeter.ac.uk # email address
#SBATCH --output=exceRpt.%A_%a.out
#SBATCH --array=0-9

echo Job started on:
date -u
echo -e '\n'

InputDir=./miRNASeq_trimmed
OutDir=./exceRpt/results
RefDir=./exceRpt/hg38
Genome_Ver=hg38
Threads=15

###################################################################################################

samples=($(ls ${InputDir}/*R1*.fastq.gz))
Num_samp=${#samples[@]}

denom_2=$(( SLURM_ARRAY_TASK_COUNT / 2 ))
window_size=$(( ( Num_samp + denom_2 ) / SLURM_ARRAY_TASK_COUNT ))

lower=$(( SLURM_ARRAY_TASK_ID * window_size ))

samples_batch=(${samples[@]:${lower}:${window_size}})

if [ "$SLURM_ARRAY_TASK_ID" -eq "$SLURM_ARRAY_TASK_MAX" ]
then
    samples_batch=(${samples[@]:$lower})
fi

echo Output directory: $OutDir
echo Fastq files directory: $InputDir
echo "Reference genome file (downloaded from https://github.gersteinlab.org/exceRpt/):" $RefDir
echo Total Number of samples: $Num_samp
echo Start array index: $SLURM_ARRAY_TASK_MIN
echo End array index : $SLURM_ARRAY_TASK_MAX
echo numer of arrays: $SLURM_ARRAY_TASK_COUNT
echo current array index: $SLURM_ARRAY_TASK_ID
echo Number of samples in current array: ${#samples_batch[@]}

echo "##########################################################################"
echo -e '\n'

mkdir -p $OutDir

j=0

for i in ${samples_batch[@]}
do
	  j=$(( j + 1 ))

    InputFileName=$(basename $i)
    
    echo "*********************************************************************************"
    echo "                  Working on sample $j: $InputFileName ..."
	  echo "*********************************************************************************"

    udocker run -v ${InputDir}:/exceRptInput -v ${OutDir}:/exceRptOutput -v ${RefDir}:/exceRpt_DB/${Genome_Ver} -t rkitchen/excerpt INPUT_FILE_PATH=/exceRptInput/${InputFileName} MAIN_ORGANISM_GENOME_ID=$Genome_Ver ADAPTER_SEQ=none N_THREADS=$Threads REMOVE_LARGE_INTERMEDIATE_FILES=true 

    echo -e '\n'
done

echo Job finished on:
date -u
