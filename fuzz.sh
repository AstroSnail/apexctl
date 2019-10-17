#!/bin/bash

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
		echo 'OK, now try to reduce the command to its smallest while still doing something interesting'
		echo 'You'\''ll have to do this manually'
		echo 'Post your findings on GitHub if you think you'\''re onto something'
		exit 0
	fi
done
