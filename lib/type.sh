#! /usr/bin/env bash
[ ! $DIX ] && >&2 echo "${BASH_SOURCE[0]}:DIX404" && exit 1

type.is_func(){
	test "`type -t $1`" == 'function'
}

# Sadly, this wouldn't work for arrays sent as params.
type.is_array(){
	[[ "$(declare -p ${1} 2> /dev/null)" =~ "declare -a" ]]
}