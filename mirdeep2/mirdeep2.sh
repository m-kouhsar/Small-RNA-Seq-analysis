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
#SBATCH --array=0-9
#########################################################################################
#########################################################################################

out_dir=/lustre/projects/Research_Project-191391/Morteza/mirdeep2/Project_10986.mirdeep2.results
fastq_dir=/lustre/projects/Research_Project-191391/Project_10986/V0327/14.1_fastp_adapter_trimmed
genome_file=/lustre/projects/Research_Project-191391/Morteza/mirdeep2/hg38.fa
bowtie_index_pref=/lustre/projects/Research_Project-191391/Morteza/mirdeep2/bowtie-index/hg38.fa
hairpin_file=/lustre/projects/Research_Project-191391/Morteza/mirdeep2/hairpin1.fa.fix
mature_file=/lustre/projects/Research_Project-191391/Morteza/mirdeep2/mature1.fa.fix

is_paired_end=true
out_prefix=Project_10986

#######################################################################################
#######################################################################################
out_prefix1=${out_dir}/${out_prefix}.${SLURM_ARRAY_TASK_ID}
fastq_files=(${fastq_dir}/*R1*.fastq.gz)

Num_samp=${#fastq_files[@]}
window_size=$(( Num_samp / SLURM_ARRAY_TASK_COUNT + 1 ))

lower=$(( SLURM_ARRAY_TASK_ID * window_size ))

fastq_files1=(${fastq_files[@]:${lower}:${window_size}})

if [ "$SLURM_ARRAY_TASK_ID" -eq "$SLURM_ARRAY_TASK_MAX" ]
then
    fastq_files1=(${fastq_files[@]:$lower})
fi

echo Output directory: $out_dir
echo Fastq files directory: $fastq_dir
echo Genome file for mirdeep2: $genome_file
echo Output file prefix: $out_prefix
echo Number of samples: $Num_samp
echo numer of arrays: $SLURM_ARRAY_TASK_COUNT

echo "##########################################################################"
echo -e '\n'

if [ "$is_paired_end" = true ] 
#step 1: merging paired end data
then
	mkdir -p ${out_prefix1}.merged.fastq
	for i1 in "${fastq_files1[@]}"
	do
		i2=${i1/R1/R2}
		name=$(basename $i1)
		name=${name/R1/R12}
		name1=${name%".gz"}
		if [ -f ${out_prefix1}.merged.fastq/$name1 ]
		then
			echo ${out_prefix1}.merged.fastq/$name1
		else
			echo Merging $(basename $i1) and $(basename $i2) files and saving the result in ${out_prefix}.${SLURM_ARRAY_TASK_ID}.merged.fastq/$name
			cat $i1 $i2  > ${out_prefix1}.merged.fastq/$name
			echo Unzipping ${out_prefix}.${SLURM_ARRAY_TASK_ID}.merged.fastq/$name
			gunzip ${out_prefix1}.merged.fastq/$name
		fi
		echo -e '\n'
	done
	fastq_files1=(${out_prefix1}.merged.fastq/*R12*.fastq)
fi

if [ "$is_paired_end" != true ] 
then
	mkdir -p ${out_prefix1}.fastq
	for i1 in "${fastq_files1[@]}"
	do
		name=$(basename $i1)
		name1=${name%".gz"}
		if [ -f ${out_prefix}.${SLURM_ARRAY_TASK_ID}.fastq/$name1 ]
		then
			echo ${out_prefix}.${SLURM_ARRAY_TASK_ID}.fastq/$name1
		else
			echo copy $name in ${out_prefix}.${SLURM_ARRAY_TASK_ID}.fastq/$name
			cp $i1 ${out_prefix1}.fastq/$name
			echo Unzipping ${out_prefix}.${SLURM_ARRAY_TASK_ID}.fastq/$name
			gunzip ${out_prefix1}.fastq/$name
		fi
		echo -e '\n'
	done
	fastq_files1=(${out_prefix1}.fastq/*.fastq)
fi

#step 2: generating config file
echo Saving config file to ${out_prefix}.${SLURM_ARRAY_TASK_ID}.config
j=100
for i in ${fastq_files1[@]}
do
	echo -e "${i}\t${j}" >> ${out_prefix1}.config
	j=$(( j + 1 ))
done

config_file=${out_prefix1}.config

#step 3: mapping on the ref genome using mapper module

#out_path=$(dirname -- "$out_prefix")
#out_name=$(basename -- "$out_prefix")
#mkdir -p $out_path

echo "Running mapper.pl..."

mapper.pl ${config_file} \
       -d -e -h -i -j  -l 18 -m -p $bowtie_index_pref \
       -s ${out_prefix1}.fa \
       -t ${out_prefix1}.arf -v -o 16\

#step 4: extracting miRNA count with miRdeep2 module

echo "Running miRDeep2.pl..."

miRDeep2.pl ${out_prefix1}.fa \
    ${genome_file} \
    ${out_prefix1}.arf \
    ${mature_file} none ${hairpin_file} \
    -t hsa 2>${out_prefix1}.log \

echo "all processes have been done!"
