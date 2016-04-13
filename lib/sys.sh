#! /usr/bin/env bash
[ ! $DIX ] && >&2 echo "${BASH_SOURCE[0]}:DIX404" && exit 1

# Get the current system name
sys.name(){
	name=$(string.lower "`uname -s`")
	[[ $name == 'linux' && -f '/etc/arch-release' ]] && name='arch'
	echo $name
}

sys.supported(){
	echo 'darwin linux arch'
}

# Test if the command ($1) is available on the system
sys.has(){
	[ -z "$1" ] && return 1
	! test -z "`command -v $1`"
}

# Test current system
sys.is(){
	test $(sys.name) = $(string.lower "$1")
}