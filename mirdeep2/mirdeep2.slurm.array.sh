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
#SBATCH --job-name=mirdeep2
#SBATCH --output=mirdeep2.%A_%a.out
#SBATCH --array=0-15
#########################################################################################
#########################################################################################

result_dir="./mirdeep2/BDR1"
fastq_dir="./Project.10230.BDR1"
genome_file="./Ref/hg38.fa"
bowtie_index_pref="./Ref/hg38"
hairpin_file="./Ref/hairpin1.fa.fix"
mature_file="./Ref/mature1.fa.fix"

#######################################################################################
#######################################################################################

fastq_files=(${fastq_dir}/*R1*.fastq*)

Num_samp=${#fastq_files[@]}

denom_2=$(( SLURM_ARRAY_TASK_COUNT / 2 ))
window_size=$(( ( Num_samp + denom_2 ) / SLURM_ARRAY_TASK_COUNT ))

lower=$(( SLURM_ARRAY_TASK_ID * window_size ))

fastq_files1=(${fastq_files[@]:${lower}:${window_size}})

if [ "$SLURM_ARRAY_TASK_ID" -eq "$SLURM_ARRAY_TASK_MAX" ]
then
    fastq_files1=(${fastq_files[@]:$lower})
fi

echo "##########################################################################"
echo "                    Running job array $SLURM_ARRAY_TASK_ID                "
echo "##########################################################################"

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
echo ""
result_dir=${result_dir}/mirdeep2.results.${SLURM_ARRAY_TASK_ID}
if [ ${#fastq_files1[@]} != 0 ]
then
    mkdir -p $result_dir
    cd $result_dir
    #step 1: creating config file
    echo ""
    echo "[STEP1] Creating config file: ${result_dir}/config.${SLURM_ARRAY_TASK_ID}.txt"
    echo ""
    j=0
    for i in ${fastq_files1[@]}
    do
        if [[ $i == *.gz ]]
        then
            echo "unzipping $(basename $i) ..."
            i1=${result_dir}/$(basename "$i")
            i1="${i1%.gz}"
            echo "Writing unzipped file to $(dirname $i1) ..."
            gunzip -c $i > $i1
            i=$i1
        fi
        j_code=$(printf "%03d\n" "$((j+1))")
        echo -e "${i}\t${j_code}" >> config.${SLURM_ARRAY_TASK_ID}.txt
        j=$(( j + 1 ))
    done

    config_file=config.${SLURM_ARRAY_TASK_ID}.txt

    #step 2: mapping on the ref genome using mapper module
    echo ""
    echo "[STEP2] Running mapper.pl..."
    echo ""
    mapper.pl ${config_file} \
        -d -e -h -i -j  -l 18 -m -p $bowtie_index_pref \
        -s mapper.${SLURM_ARRAY_TASK_ID}.fa \
        -t mapper.${SLURM_ARRAY_TASK_ID}.arf -v -o 16\

    #step 3: extracting miRNA count with miRdeep2 module
    echo ""
    echo "[STEP3] Running miRDeep2.pl..."
    echo ""
    miRDeep2.pl mapper.${SLURM_ARRAY_TASK_ID}.fa \
        ${genome_file} \
        mapper.${SLURM_ARRAY_TASK_ID}.arf \
        ${mature_file} none ${hairpin_file} \
        -t hsa 2>mirdeep2.${SLURM_ARRAY_TASK_ID}.log \

    echo ""
    echo "All done!"
    echo ""
else
    echo ""
    echo "There is no sample in this array!"
    echo ""
fi
