#!/bin/bash
filename="$HOME/.Todo.db"
finished=0
count=0
pad="  "

if [ ! -f "$filename" ]
then
	touch "$filename"
fi

PRINT_TODO_LIST () {
	file=$filename
	count=0

	while read item
	do
		count=$(($count + 1))
		bool=$(echo $item | cut -d '|' -f 2)
		printf "${pad}\e[37m   $count.\e[0m"
		if [ "$bool" = "True" ]
		then
			printf "\e[32m ✓  "
		else
			printf "\e[34m 〇 \e[0m\e[37m"
		fi
		printf "$item\e[0m" | cut -d '|' -f 1
	done < $file
}

COUNT () {
	for bool in `cat $filename | cut -d '|' -f 2`
	do
		count=$(($count + 1))
		if [ "$bool" = "True" ]
		then
			finished=$(($finished + 1))
		fi
	done
}

check () {
	if [ "$(uname)" == "Darwin" ]
	then
		sed -i '' "${1}s/False/True/" $filename
	else
		sed -i "${1}s/False/True/" $filename
	fi
}

uncheck () {
	if [ "$(uname)" == "Darwin" ]
	then
		sed -i '' "${1}s/True/False/" $filename
	else
		sed -i "${1}s/True/False/" $filename
	fi
}

add () {
	echo "$1|False" >> $filename
}

del () {
	if [ "$(uname)" == "Darwin" ]
	then
		sed -i '' "${1}d" $filename
	else
		sed -i "${1}d" $filename
	fi
}

COUNT
usage=0
while :
do
	clear
	echo
	printf "${pad}@TODO \e[0;37m[$finished/$count]\e[0m"
	echo
	PRINT_TODO_LIST
	echo
	if [ $count -ne 0 ]
	then
		printf "${pad}\e[37m$(( finished * 100 / count ))%% of all tasks complete.\e[0m"
		echo
	else
		printf "${pad}\e[37m0%% of all tasks complete.\e[0m"
		echo
	fi
	printf "${pad}\e[32m$finished\e[0m \e[37mdone\e[0m · \e[34m$(( count - finished ))\e[0m \e[37mpending\e[0m"
	echo
	echo
	if [ $usage = 1 ]
	then
		printf "${pad}\e[37musage: add:[task]               (Create note)\e[0m"
		echo
		printf "${pad}\e[37m       del:[number of task]     (Delete item)\e[0m"
		echo
		printf "${pad}\e[37m       check:[number of task]   (Check/uncheck task)\e[0m"
		echo
		printf "${pad}\e[37m       help                     (Display usage)\e[0m"
		echo
		printf "${pad}\e[37m       exit                     (Exit from program)\e[0m"
		echo
		usage=0
	else
		printf "${pad}\e[37mTry \`help\` for usage details.\e[0m"
		echo
	fi
	printf "${pad}\e[37m░ "
	read input
	printf "\e[0m"

	first=$(echo $input | cut -d ':' -f 1)
	second=$(echo $input | cut -d ':' -f 2)
	if [ $first = "exit" ]
	then
		echo
		exit
	elif [ $first = "check" ]
	then
		if [ $(sed "${second}q;d" $filename | cut -d '|' -f 2) = "False" ]
		then
			finished=$(($finished + 1))
			check $second
		else
			finished=$(($finished - 1))
			uncheck $second
		fi
	elif [ $first = "add" ]
	then
		add "$second"
		count=$(($count + 1))
	elif [ $first = "del" ]
	then
		count=$(($count - 1))
		echo $second
		if [ $(sed "${second}q;d" $filename | cut -d '|' -f 2) = "True" ]
		then
			finished=$(($finished - 1))
		fi
		del "$second"
	else
		usage=1
	fi
done
