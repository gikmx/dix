#! /usr/bin/env bash
[ -z "$DOTFILES" ] && echo "Invalid enviromnent." && exit

# Test current system
sys(){
	test $(str.lower `uname -s`) = $(str.lower $1)
}

# Test if current system is a mac
sys.mac() {
	sys 'Darwin'
}

# Test if current system is linux
sys.linux() {
    sys 'Linux'
}

# Test if current system is archlinux
sys.arch() {
    sys.linux && test -f '/etc/arch-release'
}
