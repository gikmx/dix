#! /usr/bin/env bash
! $DIX && >&2 echo "DIX404" && exit 1

number.ceil(){
	perl -we "use POSIX; print ceil($1), qq{\n}"
}

number.floor(){
	perl -we "use POSIX; print floor($1), qq{\n}"
}

number.math(){
	perl -E "say ($1)"
}