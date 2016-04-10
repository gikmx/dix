#! /usr/bin/env bash
[ ! $DIX ] && >&2 echo "${BASH_SOURCE[0]}:DIX404" && exit 1

pkg.exists(){
	[ -z "$1" ] && log.error "PKG_EXISTS_406" && return 1
	! test -z "`grep "$1" "$DIX_PATH_SRV/DIX_PKGS"`"
}

pkg.enable(){
	[ -z "$1" ] && log.error "PKG_ENABLE_406" && exit 1
	local filename="$DIX_PATH_SRV/DIX_PKGS"
	[ ! -f "$filename" ] && touch "$filename"
	# Append the current package and remove duplicates
	echo "$1" >> "$filename"
	echo "`sort -u "$filename"`" > $filename
	log.info "Enabled Package $1"
}

pkg.disable(){
	local filename="$DIX_PATH_SRV/DIX_PKGS"
	[ ! -f "$filename" ] && touch "$filename"
	[ -z "$1" ] && log.error "PKG_DISABLE_406" && exit 1
	# Outputs the inverse of the matched file
	echo "$(sed  -n "/$1/!p" "$filename")" > "$filename"
	log.info "Disabled Package $1"
}

