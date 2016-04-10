#! /usr/bin/env bash
[ ! $DIX ] && >&2 echo "${BASH_SOURCE[0]}:DIX404" && exit 1

log.error(){
	echo "DIX» $@" 1>&2
}

log.info(){
	echo "DIX» $@"
}