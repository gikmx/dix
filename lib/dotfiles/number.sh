#! /usr/bin/env bash
[ -z "$DOTFILES" ] && echo "Invalid environment" && exit 1

number.ceil(){
	perl -we "use POSIX; print ceil($1), qq{\n}"
}

number.floor(){
	perl -we "use POSIX; print floor($1), qq{\n}"
}

number.math(){
	perl -E "say ($1)"
}