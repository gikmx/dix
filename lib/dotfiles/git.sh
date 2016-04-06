#! /usr/bin/env bash
[ -z "$DOTFILES" ] && echo "Invalid environment" && exit 1

# Test if current directory has git initialised
git.enabled(){
    git status > /dev/null 2> /dev/null
}
