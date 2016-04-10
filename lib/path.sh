#! /usr/bin/env bash
[ ! $DIX ] && >&2 echo "${BASH_SOURCE[0]}:DIX404" && exit 1

path.real() {
    [ -z "$1" ] && return 1
    perl -le "use Cwd qw(realpath); print realpath('$1')"
}

path.relative(){
	[[ -z "$1" || -z "$2" ]] && return 1
	perl -le "use File::Spec; print File::Spec->abs2rel('$1', '$2')"
}