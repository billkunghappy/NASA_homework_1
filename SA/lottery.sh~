#! /usr/bin/env bash
winning_file=$1
receipt_file=$2
#make the code more readable
function check_valid(){
	receipt=$1
	if [[ $receipt = [A-Za-z][A-Za-z][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9] ]] ; then
    		echo $receipt
	elif [[ $receipt = [0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9] ]] ; then
    		echo $receipt
	elif [[ $receipt = [A-Za-z][A-Za-z]-[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9] ]] ; then
    		echo $receipt
	else
		echo 0
	fi
}

#function to create win number arrays
fp_num=()
asp_num=()
fp_prize=( 200000 40000 10000 4000 1000 200 )
function create_winnum(){
	for i in {0..2}
	do
		fp_num[$i]=$( cat $winning_file | sed "$((3+$i))!d" ) 
		asp_num[$i]=$( cat $winning_file | sed "$((6+$i))!d" ) 
	done
}
function check_win(){
	receipt=$1
	win_flag=0
	if [ $receipt == $( cat $winning_file | head -1 ) ];then
		win_flag=1
		echo 10000000
	elif [ $receipt == $( cat $winning_file | sed "2!d" ) ];then
		win_flag=1
		echo 2000000
	fi
	#for special prize and grand prize above
	for fp in ${fp_num[@]}
	do
		if [[ $win_flag -eq 1 ]];then
			break
		fi
		for i in {0..5}
		do
			if [ "$(echo $receipt | cut -c$(($i+1))-8)" == "$(echo $fp | cut -c$(($i+1))-8)" ];then
				win_flag=1
				echo ${fp_prize[$i]}
				break
			fi
		done
	done
	#for first prize above
	for asp in ${asp_num[@]}
	do
		if [ $(echo $receipt | cut -c6-8) == $(echo $asp | cut -c$6-8) ];then
			win_flag=1
			echo 200
			break
		fi
	done
	#for additional prize above
	if [[ $win_flag -eq 0 ]];then
		echo 0
	fi
	#if no win
}

#check_valid ac-80986819
total_count=0
valid_count=0
winning_count=0
prize=0

while read each_line; do
	total_count=$((total_count+1))
	if [[ 0 != $(check_valid $each_line) ]] ; then
		valid_ary[$valid_count]=$each_line
		valid_idx[$valid_count]=$total_count
		valid_count=$((valid_count+1))
	fi
done < $receipt_file

create_winnum
#create the ary of winning num

counter=0
for valid_num in ${valid_ary[@]}
do
	win_this=$( check_win $( echo  $valid_num | tail -c 9 )) 
	if [[ win_this != 0 ]];then
		let "prize += $win_this"
		win_ary[$winning_count]=$valid_num
		win_idx[$winning_count]=${valid_idx[$counter]}
		win_prz[$winning_count]=$win_this
		let "winning_count += 1"
	fi
	let "counter += 1"
done

echo "The number of receipts: $total_count"
echo "The number of valid receipts: $valid_count"
echo "The number of winning lotteries: $winning_count"
echo "The winning money: $prize"
echo "Winning Lotteries:"
for ((i=0;i<$winning_count;i++))
do
	echo "$(($i+1)). ${win_ary[$i]} (${win_idx[$i]}) \$${win_prz[$i]}"
done
