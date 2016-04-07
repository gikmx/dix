#! /usr/bin/env bash
! $DOTFILES && >&2 echo "DOTFILES404" && exit 1

log.error(){
	echo "DOTFILES» $@" 1>&2
}

log.info(){
	echo "DOTFILES» $@"
}