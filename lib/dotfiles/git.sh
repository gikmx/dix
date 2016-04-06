#! /usr/bin/env bash
[ -z "$DOTFILES" ] && echo "Invalid enviromnent." && exit

# Test if current directory has git initialised
test.git(){
    git status > /dev/null 2> /dev/null
}
