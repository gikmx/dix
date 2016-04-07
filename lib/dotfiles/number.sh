#! /usr/bin/env bash
! $DOTFILES && >&2 echo "DOTFILES404" && exit 1

number.ceil(){
	perl -we "use POSIX; print ceil($1), qq{\n}"
}

number.floor(){
	perl -we "use POSIX; print floor($1), qq{\n}"
}

number.math(){
	perl -E "say ($1)"
}