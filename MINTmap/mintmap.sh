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

result_dir=./MINTmap.Results
fastq_dir=./sRNA_Seq_trimmed
genome_assembly="GRCh38"
lookuptable="/lustre/projects/Research_Project-191391/Morteza/Small_nonCoding_RNAs/tRNA_Fragments/MINTmap/MINTmap_github/LookupTable.tRFs.MINTmap_v1.txt"
tRNAsequences="/lustre/projects/Research_Project-191391/Morteza/Small_nonCoding_RNAs/tRNA_Fragments/MINTmap/MINTmap_github/tRNAspace.Spliced.Sequences.MINTmap_v1.fa"
tRFtypes="/lustre/projects/Research_Project-191391/Morteza/Small_nonCoding_RNAs/tRNA_Fragments/MINTmap/MINTmap_github/OtherAnnotations.MINTmap_v1.txt"
MINTplatesPath=/lustre/projects/Research_Project-191391/Morteza/Small_nonCoding_RNAs/tRNA_Fragments/MINTmap/MINTmap_github/MINTplates/

#######################################################################################
#######################################################################################
fastq_files=(${fastq_dir}/*R1*.fastq.gz)

mkdir -p $result_dir

j=0

for i in ${fastq_files[@]}
do
    sample_name=$(basename $i)
    echo "*************************************************************************"
    echo "               working on sample $((j+1)): $sample_name"
    echo "*************************************************************************"
    
    MINTmap.pl -f $i -p ${result_dir}/${sample_name%.fastq.gz} -l $lookuptable -s $tRNAsequences -o $tRFtypes -a $genome_assembly -j $MINTplatesPath
    j=$(( j + 1 ))
done

echo "all processes have been done!"
