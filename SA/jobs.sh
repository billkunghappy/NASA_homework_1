#! /usr/bin/env bash

#made by b06902012 龔柏年
#I have done the bonus to deal with the wrong op
#This program may take about ten seconds to run, thanks for your patience

#create flags to indicate if one option is called
flag_l=0 #list
flag_m=0 #mem,cpu
flag_c=0 #cpu
flag_h=0 #help
flag_w=0 #wrong 1 is extra arg, 2 is invalid op
#func to check op
function check_op(){
	op=$1
	if [ ${op:0:2} == "--" ];then
		#if --
		case ${op:2:${#op}} in
		"list" )
			flag_l=1;;
		"mem" )
			flag_m=1;;
		"cpu" )
			flag_c=1;;
		"help" )
			flag_h=1;;
		*)
			flag_w=1;;
		esac
	elif [ ${op:0:1} == "-" ];then
		#if -
		for char in $(echo ${op:1:${#op}} | fold -b1)
		do
			case $char in 
			'l' )
				flag_l=1;;
			'm' )
				flag_m=1;;
			'c' )
				flag_c=1;;
			'h' )
				flag_h=1;;
			*)
				flag_w=1;;
			esac
		done
	else
		#wrong!
		flag_w=2
	fi
}
function print_help(){
	echo "jobs.sh [OPTION...]"  
	echo "-l, --list           	listing all grades in descendant order of consuming resource (according to CPU usage first, then memory usage)"
	echo "-m, --mem            	print the usage of memory (in KB)"
	echo "-c, --cpu            	print the usage of CPU (in %)"
	echo "-h, --help           	print this help message"
}

################################## Main program below ##################################
#check input
wrong_arg=""
for op in $@
do
	check_op $op
	if [[ $flag_w != 0 ]];then
		wrong_arg=$op
		break
	fi
done
#echo "l is $flag_l m is $flag_m c is $flag_c h is $flag_h wrong is $flag_w"
if [[ $flag_h == 1 ]];then #no matter what other args are, if -h or --help is implement, print help message and exit
	print_help
	exit
fi
if [[ $flag_w == 1  ]];then #wrong type 1 --invalif option
	echo "invalid option -- '$(echo $wrong_arg | sed 's/'-'//g')'"
	print_help
	exit
fi

if [[ $flag_w == 2  ]];then #wrong type 2 --extra arg
	echo "jobs.sh: Extra arguments -- '$wrong_arg'"
	echo "Try 'jobs.sh -h' for more information."
	exit
fi

#if the program gets here, it means that there are no wrong arg, so let's do the stuff
temp_file=$(mktemp)
temp_file_group=$(mktemp)
#store the value of all group
ps aux | awk '$3!="0.0" || $5!="0" { print substr($1 ,0 , 3) " " $3 " " $5 }' | grep -v "^USE" | sort -s -k1,1 > $temp_file
others_cpu=0
others_mem=0
for group in $(cat $temp_file | awk '{ print $1 }' | uniq)
do
	total_cpu=0
	total_mem=0
	IFS=$'\n'
	for each in $( grep "^$group" $temp_file )
	do
		total_cpu=$(bc <<< "$total_cpu+$( echo $each | awk '{ print $2}' )" )
		total_mem=$(bc <<< "$total_mem+$( echo $each | awk '{ print $3}' )" )
	done
	unset IFS
	if [[ $group != [brd][0-9][0-9] ]];then
		others_cpu=$(bc <<< "$others_cpu+$total_cpu")
		others_mem=$(bc <<< "$others_mem+$total_mem")
	else
		echo "$group $(echo $total_cpu | sed 's/^\./0./g') $total_mem" >> $temp_file_group
	fi

done
echo "others $(echo $others_cpu | sed 's/^\./0./g') $others_mem" >> $temp_file_group
sort -k 2,2 -k 3,3 -nr $temp_file_group -o $temp_file_group

#now deal with the output format!
##################################### prepare for output ##################################### 
#deal with m_c_status below
m_c_status=0 #0 is none, 1 is m, 2 is c, 3 is both
case "$(( $flag_m + $flag_c ))" in
	0 )
		m_c_status=0;;
	1 )
		if [[ $flag_m == 1 ]];then
			m_c_status=1
		else
			m_c_status=2
		fi;;
	*) #2
		m_c_status=3;;
esac
#deal with mem and cpu output func
function print_line(){ #get $1 as the group info, and check m_c_status to know if output the cpu and mem
	group_info="$1"
	case $m_c_status in
	0) #no mem and cpu output
		echo $group_info | awk '{ printf "%-15s\n", $1 }';;
	1) #only mem output
		echo $group_info | awk '{ printf "%-15s%-15s\n", $1, $3 }';;
	2) #only cpu output
		echo $group_info | awk '{ printf "%-15s%-15s\n", $1, $2 }';;
	*) #3 both mem and cpu output
		echo $group_info | awk '{ printf "%-15s%-15s%-15s\n", $1, $2, $3 }';;
	esac
}
##################################### end prepare output #####################################
#deal with the table index
case $m_c_status in
0) #no mem and cpu output
	printf "%-15s\n" "GROUP";;
1) #only mem output
	printf "%-15s%-15s\n" "GROUP" "MEM(KB)";;
2) #only cpu output
	printf "%-15s%-15s\n" "GROUP" "CPU(%)";;
*) #3 both mem and cpu output
	printf "%-15s%-15s%-15s\n" "GROUP" "CPU(%)" "MEM(KB)";;
esac
#deal with --list
if [[ $flag_l == 0 ]];then #print one
	this_line="$( head -n1 $temp_file_group )"
	print_line "$this_line"
else #list
	while read each_line
	do
		print_line "$each_line"
	done < $temp_file_group
fi



##################################### end of the script  #####################################
rm $temp_file
rm $temp_file_group
#clear the temp file
