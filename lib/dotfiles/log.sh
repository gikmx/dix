#! /usr/bin/env bash
[ -z "$DOTFILES" ] && echo "Invalid environment" && exit 1

log.error(){
	echo "DOTFILES» $@" 1>&2
}

log.info(){
	echo "DOTFILES» $@"
}