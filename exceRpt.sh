#!/bin/bash
#SBATCH -A Research_Project-MRC164847 # research project to submit under.
#SBATCH --export=ALL # export all environment variables to the batch job.
#SBATCH -D . # set working directory to .
#SBATCH -p mrcq # submit to the parallel test queue
#SBATCH --time=5:00:00 # Maximum wall time for the job
#SBATCH --nodes=1 # specify number of nodes.
#SBATCH --ntasks-per-node=16 # specify number of processors.
#SBATCH --mail-type=END # send email at job completion
#SBATCH --mail-user=m.kouhsar@exeter.ac.uk # email address

echo Job started on:
date -u

InputDir=/lustre/projects/Research_Project-191391/Morteza/exceRpt
OutDir=/lustre/projects/Research_Project-191391/Morteza/exceRpt
RefDir=/lustre/projects/Research_Project-191391/Morteza/exceRpt/hg19

char="/"
index=$(echo "${InputDir}" | awk -F"${char}" '{print NF-1}')
index=$(( index + 2 ))

for i in  ${InputDir}/*.fastq.gz
do

    
    InputFileName=$(echo $i| cut -d'/' -f $index)
    
    #echo $i
    echo $InputFileName

    udocker run -v ${InputDir}:/exceRptInput -v ${OutDir}:/exceRptOutput -v ${RefDir}:/exceRpt_DB/hg19 -t rkitchen/excerpt INPUT_FILE_PATH=/exceRptInput/${InputFileName} MAIN_ORGANISM_GENOME_ID=hg19 ADAPTER_SEQ=none N_THREADS=15 REMOVE_LARGE_INTERMEDIATE_FILES=true 

    #rm ${OutDir}/${InputFileName%".gz"}/*.gz
    #rm ${OutDir}/${InputFileName%".gz"}/*.bam
    
done

echo Job finished on:
date -u


