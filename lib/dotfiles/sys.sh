#! /usr/bin/env bash
[ -z "$DOTFILES" ] && echo "Invalid enviromnent." && exit

sys.get(){
	echo $(string.lower `uname -s`)
}

# Test current system
sys.is(){
	test sys.get = $(str.lower $1)
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
