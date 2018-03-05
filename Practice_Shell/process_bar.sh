#!/bin/bash

counter=0
process_bar=

for (( i=0; i<50; i++ ));
do
	process_bar="$process_bar#"
	printf "      --------------------------------------------------\r[%03d%%]$process_bar\r" $i
	sleep 1
done
printf "[%03d%%]$process_bar Success!\n" $i
