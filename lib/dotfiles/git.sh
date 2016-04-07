#! /usr/bin/env bash
! $DOTFILES && >&2 echo "DOTFILES404" && exit 1

# Test if current directory has git initialised
git.enabled(){
    git status > /dev/null 2> /dev/null
}
