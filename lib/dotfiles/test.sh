
# Test current system
test.sys(){
	test $(str.lower `uname -s`) = $(str.lower $1)
}

# Test if current system is a mac
test.sys_mac() {
	test.sys 'Darwin'
}

# Test if current system is linux
test.sys_linux() {
    test.sys 'Linux'
}

# Test if current system is archlinux
test.sys_arch() {
    test.sys_linux && test -f '/etc/arch-release'
}

# Test if current directory has git initialised
test.git(){
    git status > /dev/null 2> /dev/null
}

# Test if item ($2) is in array ($1)
test.array_item(){
  local e
  for e in "${@:1}"; do [[ "$e" == "$2" ]] && return 0; done
  return 1
}

# Test if the command ($1) is available
test.bin(){
	if `command -v $1 > /dev/null 2>&1`; then return 0; else return 1; fi
}