#!/bin/bash
# $1 == file

set -e


while read -r line
do
	if [[ "$line" == *"="* ]];
	then
		key=`echo $line | cut -d \= -f 1`
		value=`echo $line | cut -d \= -f 2`	

		echo "$key"
		echo "$value"
		echo "$key=$value" >> $GITHUB_ENV
	fi

done < $1


exit $?