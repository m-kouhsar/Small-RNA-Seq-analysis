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

result_dir=/lustre/projects/Research_Project-191391/Morteza/miRNA/Results/Project.11008.V0304.NorCog/mirdeep2.FLASH
fastq_dir=/lustre/projects/Research_Project-191391/Morteza/miRNA/Results/Project.11008.V0304.NorCog/flash
genome_file=/lustre/projects/Research_Project-191391/Morteza/mirdeep2/hg38.fa
bowtie_index_pref=/lustre/projects/Research_Project-191391/Morteza/mirdeep2/bowtie-index/hg38.fa
hairpin_file=/lustre/projects/Research_Project-191391/Morteza/mirdeep2/hairpin1.fa.fix
mature_file=/lustre/projects/Research_Project-191391/Morteza/mirdeep2/mature1.fa.fix

#######################################################################################
#######################################################################################

fastq_files=(${fastq_dir}/*R1*.fastq)

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
echo Genome file for mirdeep2: $genome_file
echo Number of samples: $Num_samp
echo Start array index: $SLURM_ARRAY_TASK_MIN
echo End array index : $SLURM_ARRAY_TASK_MAX
echo numer of arrays: $SLURM_ARRAY_TASK_COUNT
echo current array index: $SLURM_ARRAY_TASK_ID
echo Number of samples in current array: ${#fastq_files1[@]}

echo "##########################################################################"
echo -e '\n'
if [ ${#fastq_files1[@]} != 0 ]
then
    mkdir -p $result_dir
    cd $result_dir
    #step 2: generating config file
    echo Saving config file to ${result_dir}/config.${SLURM_ARRAY_TASK_ID}.txt
    j=0
    for i in ${fastq_files1[@]}
    do
        j_code=$(printf "%03d\n" "$((j+1))")
        echo -e "${i}\t${j_code}" >> config.${SLURM_ARRAY_TASK_ID}.txt
        j=$(( j + 1 ))
    done

    config_file=config.${SLURM_ARRAY_TASK_ID}.txt

    #step 3: mapping on the ref genome using mapper module
    echo -e '\n'
    echo "Running mapper.pl..."

    mapper.pl ${config_file} \
        -d -e -h -i -j  -l 18 -m -p $bowtie_index_pref \
        -s mapper.${SLURM_ARRAY_TASK_ID}.fa \
        -t mapper.${SLURM_ARRAY_TASK_ID}.arf -v -o 16\

    #step 4: extracting miRNA count with miRdeep2 module
    echo -e '\n'
    echo "Running miRDeep2.pl..."

    miRDeep2.pl mapper.${SLURM_ARRAY_TASK_ID}.fa \
        ${genome_file} \
        mapper.${SLURM_ARRAY_TASK_ID}.arf \
        ${mature_file} none ${hairpin_file} \
        -t hsa 2>mirdeep2.${SLURM_ARRAY_TASK_ID}.log \

    echo "all processes have been done!"
else
    echo "There is no sample in this array!"
fi
