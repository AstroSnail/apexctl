#!/bin/sh

interesting=0
declare -a args

while :
do
	for ((i=0; i<32; ++i))
	do
		args[$i]=$(printf %02x $(($RANDOM%256)))
	done
	echo 'Running `sudo ./apexctl probe '${args[*]}
	sudo ./apexctl probe ${args[*]}
	if (($?))
	then
		echo 'Something went wrong...'
		exit 1
	fi
	echo 'Did something interesting happen?'
	read yesno
	if [[ "$yesno" = y* ]]
	then
		echo 'Post on GitHub for further analysis!'
		exit 0
	fi
done
