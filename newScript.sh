#Takes on file and get the lowest p-value from every sequence 
#Input file shulde be a tsv file from interproscan



FILE=$1
firstLine=$(head -1 "$FILE")
previous=$(echo "$firstLine" |awk 'BEGIN { FS = "\t" } ; { print $1}')
previousPvalue=$(echo "$firstLine" |awk 'BEGIN { FS = "\t" } ; { print $9}')
while read line;do
        currentPvalue=$(echo "$line" |awk 'BEGIN { FS = "\t" } ; { print $9}')
        re='^[0-9]+([.][0-9]+)?(E\-[0-9]+)?$'
        if ! [[ $currentPvalue =~ $re ]] ; then
                echo "error: Not a number"
                echo $currentPvalue
                continue
        fi
        currentPvalue=$(printf '%.10f' $currentPvalue)
		currentName=$(echo "$line" |awk 'BEGIN { FS = "\t" } ; { print $1}')
        if [ "$previous" == "$currentName" ]; then
                var=$(awk 'BEGIN{ print "'$previousPvalue'">="'$currentPvalue'" }')
                if [ "$var" -eq 1 ]; then
                        previousPvalue=$currentPvalue
                fi
        else
                echo "$previous $previousPvalue" >> test.txt
                previous=$(echo "$line" |awk 'BEGIN { FS = "\t" } ; { print $1}')
                previousPvalue=$currentPvalue
        fi
done < $FILE
echo "$previous $previousPvalue" >> test.txt
