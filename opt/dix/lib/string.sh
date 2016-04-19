#! /usr/bin/env bash
[ ! $DIX ] && >&2 echo "${BASH_SOURCE[0]}:DIX404" && exit 1

string.lower() {
	echo "$1" | tr '[:upper:]' '[:lower:]'
}

string.upper(){
	echo "$1" | tr '[:lower:]' '[:upper:]'
}

string.length(){
	echo ${#1}
}

# Repeat a string ($1) N ($2) times.
string.repeat(){
	printf "$1%.0s" $(seq 1 $2)
}

# Splits a string ($1) using separator ($2) to a variable name ($3)
string.split(){
	local __array name
	[[ -z "$3" ]] && name='__array' || name="$3"
	IFS="$2" read -r -a __array <<< "$1"
	declare -p __array | perl -pe "s/__array/$3/g"
}