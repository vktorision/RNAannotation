#Script to split a fasta file in to smaller sekvenses and creatig a bash file 
#with the correct information. After that it is sent with sbatch to be executed
FILE=$1
mkdir "temporary_split"
mkdir "temporary_script"
mkdir "output"
	awk 'BEGIN {n_seq=0;} /^>/ {if(n_seq%10==0){file=sprintf("temporary_split/myseq%d.fa",n_seq);} print >> file; n_seq++; next;} { print >> file; }' $FILE
FILES="temporary_split/*"
for f in $FILES
do
  echo "Processing $f file..."
  name=$(basename "$f")
  name="${name%.*}"
  echo "#!/bin/bash -l" >> temporary_script/$name
  echo "#SBATCH -A b2011098" >> temporary_script/$name
  echo "#SBATCH -p core" >> temporary_script/$name
  echo "#SBATCH -n 4" >> temporary_script/$name
  echo "#SBATCH -t 00:50:00" >> temporary_script/$name
  echo "#SBATCH -J $name" >> temporary_script/$name
  echo "./interproscan.sh -t n -dp -appl Coils, Gene3D, PfamA, PRINTS, ProDom, SMART, SUPERFAMILY, TIGRFAM -i $f -b output/$name" >> temporary_script/$name
  sbatch temporary_script/$name
  echo "Done"
done
