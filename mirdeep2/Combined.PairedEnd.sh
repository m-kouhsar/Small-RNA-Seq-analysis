InputDir=./
OutDir=./

for i1 in ${InputDir}/*R1*.fastq.gz
do
	i2=${i1/R1/R2}
	name=${i1/R1/R12}
  name=$(basename -- "$name")
	echo $name
	cat $i1 $i2  > ${OutDir}/$name
done
