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
		echo "::set-env name=$key::$value"
	fi

done < $1


exit $?