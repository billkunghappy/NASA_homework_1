#!/usr/bin/env bash
#b06902012龔柏年
#discuss with 呂侑承
username="$1"
keyfile="$2"
shift 2
#remove arg1 and 2
command="$*"
server_list=()
#create empty server list
for i in {1..15}
do
	server_list[$(($i-1))]="$username@linux$i.csie.ntu.edu.tw" 
done
#for linux server
for i in {1..3}
do
	server_list[$(($i+14))]="$username@oasis$i.csie.ntu.edu.tw" 
done
#for oasis server
server_list[18]="$username@bsd1.csie.ntu.edu.tw"
#for bsd1 server
eval "`ssh-agent -s`" #> /dev/null
ssh-add "$keyfile" #> /dev/null
for i in {0..18} #total 19 servers
do
	server_name=${server_list[$i]}
	echo "======== $(echo $server_name | cut -d'@' -f2 |cut -d'.' -f1) ========"
	ssh "$server_name" -o StrictHostKeyChecking=no "$command"
	echo "========================"
	#-o StrictHostKeyChecking=no will disable some warnings
done
