#! /usr/bin/env bash
[ -z "$DOTFILES" ] && echo "Invalid enviromnent." && exit

# Test if the command ($1) is available
bin(){
	if `command -v $1 > /dev/null 2>&1`; then return 0; else return 1; fi
}