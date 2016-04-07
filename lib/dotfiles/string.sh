#! /usr/bin/env bash
! $DOTFILES && >&2 echo "DOTFILES404" && exit 1

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