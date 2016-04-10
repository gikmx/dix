#! /usr/bin/env bash
! $DIX && >&2 echo "DIX404" && exit 1

show.dix(){
	local line wide char dist text
	[ $1 ] && wide=$1 || wide=`tput cols`
	[ $2 ] && char=$2 || char='–'
	while read line; do
		[ ! $dist ] &&\
			dist=`number.ceil $(number.math "($wide-$(string.length "$line"))/2")`
		string.repeat " " $dist && printf "$(string.upper "$line")\n"
	done < $DIX_PATH_LIB/dix.ascii
}

show.box(){
	local line wide dist text
	[[ ! $1 ]] && log.error "MissingTitle" && exit 1
	[ $2 ] && wide=$2 || wide=`tput cols`
	thetxt=$(string.upper "$1")
	lentxt=`number.math $(string.length "$thetxt")`
	lenbox=`number.math "$lentxt + 4"`
	spaces=`number.ceil $(number.math "($wide-$lenbox)/2")`
	string.repeat " " $spaces && printf "┌─" && string.repeat "─" $lentxt && printf "─┐\n"
	string.repeat " " $spaces && printf "│ " && printf "$thetxt"          && printf " │\n"
	string.repeat " " $spaces && printf "└─" && string.repeat "─" $lentxt && printf "─┘\n"
}

show.title(){
	[[ ! $1 ]] && log.error "MissingTitle" && exit 1
	local wide=`tput cols`
	local lent=$(number.math $wide-`string.length "$1"`)
	string.repeat " " $lent && echo $1
	string.repeat "─" $wide && echo
}