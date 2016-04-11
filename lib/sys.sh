#! /usr/bin/env bash
[ ! $DIX ] && >&2 echo "${BASH_SOURCE[0]}:DIX404" && exit 1

# Get the current system name
sys.name(){
	echo $(string.lower "`uname -s`")
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

# Test if current system is a mac
sys.is_darwin() {
	sys.is 'Darwin'
}

# Test if current system is linux
sys.is_linux() {
    sys.is 'Linux'
}

# Test if current system is archlinux
sys.is_arch() {
    sys.is_linux && test -f '/etc/arch-release'
}
