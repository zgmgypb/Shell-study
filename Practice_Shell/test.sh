#! /bin/bash

TEST_ENV_L=4

echo $REPLY
echo '\t test1 $TEST_ENV_1'
echo $'\t test1 $TEST_ENV_1'

func () {
	echo "$*"
	for i in $*;
	do
		echo $i
	done
}

case 1 in 
	1)
		func test1 test2 tes3;
		echo "1";;
	2)
		echo "2";;
	3)
		echo "3";;
esac

#for i;
#do
#	echo "arg-"$i;
#done
#
#select i; 
#do
#	echo $i
#done

#for (( i=0; i<10; i++ ));
#do
#	echo $i
#done

#export TEST_ENV=hahahahahh
#echo "test shell script!"
#((sum=1+2))
#echo $sum
#if ((1+2));then
#	printf "1 + 2 = d\n" 
#fi
