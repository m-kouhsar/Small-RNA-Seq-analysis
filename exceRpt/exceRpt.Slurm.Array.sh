#!/bin/bash
#SBATCH -A Research_Project-MRC164847 # research project to submit under.
#SBATCH --job-name=LDpred2  # job name
#SBATCH --output=exceRpt.%j.log  # output
#SBATCH --export=ALL # export all environment variables to the batch job.
#SBATCH -D . # set working directory to .
#SBATCH -p mrcq # submit to the parallel test queue
#SBATCH --time=5:00:00 # Maximum wall time for the job
#SBATCH --nodes=1 # specify number of nodes.
#SBATCH --ntasks-per-node=16 # specify number of processors.
#SBATCH --mail-type=END # send email at job completion
#SBATCH --mail-user=m.kouhsar@exeter.ac.uk # email address
#SBATCH --array=0-9

echo Job started on:
date -u
echo -e '\n'

InputDir=/lustre/projects/Research_Project-191391/Project_10398/V0182/14.2_4bp_trimmed
OutDir=/lustre/projects/Research_Project-191391/Morteza/exceRpt/Project.10398
RefDir=/lustre/projects/Research_Project-191391/Morteza/exceRpt/hg19
is_paired_end=no #no or yes

###################################################################################################
mkdir -p $OutDir

samples=($(ls ${InputDir}/*R1*.gz))
Num_samp=${#samples[@]}
window_size=$(( Num_samp / SLURM_ARRAY_TASK_COUNT + 1 ))

lower=$(( SLURM_ARRAY_TASK_ID * window_size ))

samples_batch=(${samples[@]:${lower}:${window_size}})

if [ "$SLURM_ARRAY_TASK_ID" -eq "$SLURM_ARRAY_TASK_MAX" ]
then
    samples_batch=(${samples[@]:$lower})
fi

#echo "number of samples $Num_samp"
#echo "Window $window_size"
#echo "lower $lower"
#echo "$is_paired_end"

if [ "$is_paired_end" = "yes" ] 
then
	echo "Merging paired end data..."
	echo -e '\n'
	mkdir -p ${OutDir}/merged.fastq
	for i1 in "${samples_batch[@]}"
	do
		i2=${i1/R1/R2}
		name=$(basename $i1)
		name=${name/R1/R12}
		
		if [ ! -f ${OutDir}/merged.fastq/$name ]
		then
			echo Merging $(basename $i1) and $(basename $i2) files and saving the result in ${OutDir}/merged.fastq/$name
			cat $i1 $i2  > ${OutDir}/merged.fastq/$name
		else
			echo ${OutDir}/merged.fastq/$name is already exist
		fi
		echo -e '\n'
	done
	samples_batch=(${OutDir}/merged.fastq/*R12*.fastq)
fi

for i in ${samples_batch[@]}
do

    InputFileName=$(basename $i)
    
    #echo $i
    echo "Working on $InputFileName ..."

    udocker run -v ${InputDir}:/exceRptInput -v ${OutDir}:/exceRptOutput -v ${RefDir}:/exceRpt_DB/hg19 -t rkitchen/excerpt INPUT_FILE_PATH=/exceRptInput/${InputFileName} MAIN_ORGANISM_GENOME_ID=hg19 ADAPTER_SEQ=none N_THREADS=15 REMOVE_LARGE_INTERMEDIATE_FILES=true 

    #rm ${OutDir}/${InputFileName%".gz"}/*.gz
    #rm ${OutDir}/${InputFileName%".gz"}/*.bam
    echo -e '\n'
done

echo Job finished on:
date -u
