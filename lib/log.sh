#! /usr/bin/env bash
! $DIX && >&2 echo "DIX404" && exit 1

log.error(){
	echo "DIX» $@" 1>&2
}

log.info(){
	echo "DIX» $@"
}