#This scripts looks for ORFs that is not in the frame +1 or is on the negative strand
#It then calculates the amount of protein domains it finds in that ORF
#If it is the correct frame/strand then it's correct otherwise it's wrong

for FILE in $*
do
	while read line;do
		if [[ $line == \#\#FASTA* ]]; then
			break	
		elif [[ $line == \#* ]]; then 
			unset strand
		else 
			type=$(echo "$line" |awk 'BEGIN { FS = "\t" } ; { print $3}')
			if [ "$type" == "ORF" ]; then
				ORFstart=$(echo "$line" |awk 'BEGIN { FS = "\t" } ; { print $4}')
				if [ $((($ORFstart-1)%3)) != 0 ]; then
					strand="-"
				else
					strand=$(echo "$line" |awk 'BEGIN { FS = "\t" } ; { print $7}')
				fi
			elif [ "$type" == "protein_match" ]; then
				if [ "$strand" == "+" ];then
					((correct++))
				elif [ "$strand" == "-" ];then
					((wrong++))
				else
				echo "error!!!"
				echo "$strand"
				break
				fi
			fi
		fi
	done < "$FILE"
	echo "From file $FILE -> $correct is correct. $wrong is wrong" 
	allcorrect=$(($allcorrect+$correct))
	allwrong=$(($allwrong+$wrong))
	correct=0
	wrong=0
done
totala=$(($allcorrect+$allwrong))
echo "Number of correct:$allcorrect"
echo "Number of wrong:$allwrong"
echo $(awk "BEGIN {printf \"%.3f\",${allwrong}/${totala}*100}")%  