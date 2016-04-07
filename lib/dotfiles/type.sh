#! /usr/bin/env bash
! $DOTFILES && >&2 echo "DOTFILES404" && exit 1

type.is_func(){
	test "`type -t $1`" == 'function'
}

# Sadly, this wouldn't work for arrays sent as params.
type.is_array(){
	[[ "$(declare -p ${1} 2> /dev/null)" =~ "declare -a" ]]
}