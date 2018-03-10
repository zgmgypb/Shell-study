#!/bin/bash

select opt in "say hello world!" "say goodbye!" "say morning!" "say evening!" "Try" "Ignore" "Abort"
do
	case $opt in 
	*hello*)
		echo "hello world!" && break;
		;;
	*goodbye*)
		echo "good bye!" && break;
		;;
	*morning*)
		echo "morning!" && break;
		;;
	*evening*)
		echo "evening!" && break;
		;;
	Try)
		continue;
		;;
	Ignore)
		exit 0;
		;;
	Abort)
		exit 1;
		;;
	*)
		echo "Invalid Input! Please try again!" && continue;
		;;
	esac
done
	

