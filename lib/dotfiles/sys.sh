#! /usr/bin/env bash
[ -z "$DOTFILES" ] && echo "Invalid enviromnent." && exit

# Get the current system name
sys.name(){
	echo $(string.lower "`uname -s`")
}

# Test if the command ($1) is available on the system
sys.has(){
	[ -z "$1" ] && return 1
	! test -z "`command -v $1`"
}

sys.has_brew(){
	! sys.has 'brew' && return 1               # no brew available
	sys.has 'brew' && [ -z "$1" ] && return 0  # has brew, and no argument
	test -d $(brew --prefix $1)                # do the actual test using brew
}

# Test current system
sys.is(){
	test $(sys.name) = $(string.lower "$1")
}

# Test if current system is a mac
sys.is_mac() {
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
