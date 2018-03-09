#! /bin/bash

source ./hisi_common.sh
base_offset_dir "/home/zgm" "/home/zgm/linux/kernel/arch/hisi3531A" 
sub_dir "/home/zgm/linux/kernel/arch/hisi3531A" "/home/zgm"
#abs_path ./
#run_command_progress "cat ./hisi_common.sh"
#run_command_progress_float "cat ./hisi_common.sh" 0 "cat hisi_common.sh | wc -l"

TEST_ENV_L=4

#i=0
#find ./ | while read line
#do 
#	i=`expr $i + 1`
#	echo $i
#	echo $line
#done
#
#i=0
#for x in `find ./`;
#do
#	i=`expr $i + 1`
#	echo $i
#	echo $x
#done

#for cmd in $COMPREPLY;
#do
#	echo $cmd;
#done

#while read -r
#do
#	echo "$REPLY"
#done

#echo $REPLY
#echo '\t test1 $TEST_ENV_1'
#echo $'\t test1 $TEST_ENV_1'
#
#func () {
#	echo "$*"
#	for i in $*;
#	do
#		echo $i
#	done
#}
#
#case 1 in 
#	1)
#		func test1 test2 tes3;
#		echo "1";;
#	2)
#		echo "2";;
#	3)
#		echo "3";;
#esac

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
