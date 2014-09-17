#This scripts looks for ORFs that is not in the frame +1 or is on the negative strand
#It then calculates the amount of protein domains it finds in that ORF
#If it is the correct frame/strand then it's correct otherwise it's wrong

for FILE in $*
do
	while read line;do
		declare -A correctAnalysis
		declare -A wrongAnalysis
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
				analysis=$(echo "$line" |awk 'BEGIN { FS = "\t" } ; { print $2}')
				if [ "$strand" == "+" ];then
					((correct++))
					case "$analysis" in
						"ProDom") ((correctAnalysis[ProDom]++))
						;;
						"Hamap") ((correctAnalysis[Hamap]++))
						;;
						"TIGRFAM") ((correctAnalysis[TIGRFAM]++))
						;;
						"SUPERFAMILY") ((correctAnalysis[SUPERFAMILY]++))
						;;
						"PRINTS") ((correctAnalysis[PRINTS]++))
						;;
						"PIRSF") ((correctAnalysis[PIRSF]++))
						;;
						"Gene3D") ((correctAnalysis[Gene3D]++))
						;;
						"Coils") ((correctAnalysis[Coils]++))
						;;
						"ProSitePatterns") ((correctAnalysis[ProSitePatterns]++))
						;;
						"ProSiteProfiles") ((correctAnalysis[ProSiteProfiles]++))
						;;
						"Pfam") ((correctAnalysis[Pfam]++))
						;;
						"SMART") ((correctAnalysis[SMART]++))
						;;
						*) echo "Unknown analysis"
						;;
						esac
				elif [ "$strand" == "-" ];then
					((wrong++))
					case "$analysis" in
						"ProDom") ((wrongAnalysis[ProDom]++))
						;;
						"Hamap") ((wrongAnalysis[Hamap]++))
						;;
						"TIGRFAM") ((wrongAnalysis[TIGRFAM]++))
						;;
						"SUPERFAMILY") ((wrongAnalysis[SUPERFAMILY]++))
						;;
						"PRINTS") ((wrongAnalysis[PRINTS]++))
						;;
						"PIRSF") ((wrongAnalysis[PIRSF]++))
						;;
						"Gene3D") ((wrongAnalysis[Gene3D]++))
						;;
						"Coils") ((wrongAnalysis[Coils]++))
						;;
						"ProSitePatterns") ((wrongAnalysis[ProSitePatterns]++))
						;;
						"ProSiteProfiles") ((wrongAnalysis[ProSiteProfiles]++))
						;;
						"Pfam") ((wrongAnalysis[Pfam]++))
						;;
						"SMART") ((wrongAnalysis[SMART]++))
						;;
						esac
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
echo
echo "Number of correct:$allcorrect"
echo "Number of wrong:$allwrong"
echo $(awk "BEGIN {printf \"%.3f\",${allwrong}/${totala}*100}")"% was wrong"
echo
echo "Number of correct answers each analysis had"
for i in "${!correctAnalysis[@]}"
do
  echo "$i hade ${correctAnalysis[$i]} correct that is " $(awk "BEGIN {printf \"%.3f\",${correctAnalysis[$i]}/${allcorrect}*100}")"% of all correct ones"
done
echo
echo "Number of wrong answers each analysis had"
for i in "${!wrongAnalysis[@]}"
do
  echo "$i hade ${wrongAnalysis[$i]} wrong that is " $(awk "BEGIN {printf \"%.3f\",${wrongAnalysis[$i]}/${allwrong}*100}")"% of all wrongs"
done