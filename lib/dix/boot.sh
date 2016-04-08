#! /usr/bin/env bash
! $DIX && >&2 echo "DIX404" && exit 1

boot.motd(){
	cat $DIX_PATH_LIB/dix/motd
	echo
}

boot.head(){
	[ ! -z ]
	local title=$1
	local fillr="–"
	local width=80
	local space=`number.ceil $(number.math "($width-$(string.length "$title"))/2")`
	string.repeat "–" $width && printf "\n"
	string.repeat " " $space && printf "$(string.upper "$title")\n"
	string.repeat "–" $width && printf "\n"
}

boot.reload(){
	reset
	hash -r # reload the hashtable so the paths are updated
}

boot.profile(){
	pkgs="`cat $DIX_PATH_SRV/DIX_PKGS`"

	export PATH=$DIX_PATH_BIN:$DIX_PATH_SBIN:$PATH

	for pkg in ${pkgs[@]}; do
		dir=$DIX_PATH_BOOT/$pkg
		[ ! -d $dir ] && log.error "PKG404:$pkg" && exit 1
		[ ! -f "$dir/profile" ] && continue
		source "$dir/profile"
		[ ! -f "$dir/profile.$(sys.name)" ] && continue
		source "$dir/profile.$(sys.name)"
		if type.is_func DIX_ON_AFTER; then
			DIX_ON_AFTER $DIX_PKG
			unset DIX_ON_AFTER
		fi
	done
}

boot.pkg_exists(){
	[ -z "$1" ] && log.error "PKG_EXISTS_406" && return 1
	! test -z "`grep "$1" "$DIX_PATH_SRV/DIX_PKGS"`"
}

boot.pkg_enable(){
	[ -z "$1" ] && log.error "PKG_ENABLE_406" && exit 1
	local filename="$DIX_PATH_SRV/DIX_PKGS"
	[ ! -f "$filename" ] && touch "$filename"
	# Append the current package and remove duplicates
	echo "$1" >> "$filename"
	echo "`sort -u "$filename"`" > $filename
	log.info "Enabled Package $1"
}

boot.pkg_disable(){
	local filename="$DIX_PATH_SRV/DIX_PKGS"
	[ ! -f "$filename" ] && touch "$filename"
	[ -z "$1" ] && log.error "PKG_DISABLE_406" && exit 1
	# Outputs the inverse of the matched file
	echo "$(sed  -n "/$1/!p" "$filename")" > "$filename"
	log.info "Disabled Package $1"
}

boot.menu(){

	# Capture cancellation signals so the user MUST input.
	# trap '' SIGINT
	# trap '' SIGQUIT
	# trap '' SIGTSTP

	while true; do
		# show menu
		clear
		boot.motd
		boot.head "Main Menu"
		echo

		paths=(true)
		infos=(true)
		echo "0. Exit"

		i=1
		for file in `find $DIX_PATH_BOOT -type f -name "boot.conf"`; do
			paths+=("${file%/*}")
			infos+=("`source $file && echo $title`")
			echo "$i. ${infos[$i]}"
			((i++))
		done

		printf "\n$(string.repeat "–" 80)\n\n"
		read -r -n $(string.length $i) -p "Select an item {0..$((i-1))} » " val

		# match the regex and be a valid index to continue
		[[ ! $val =~ ^[0-9]+ || $val -gt $((i-1)) ]] && continue

		# if 0, break the loop
		[[ $val == 0 ]] && break
		clear

		# A boot.img must exist.
		[ ! -f "${paths[$val]}/boot.img" ] && log.error "IMG404" && exit 1

		# Let the package know its name
		DIX_PKG="`basename ${paths[$val]}`"

		# Load the common boot first, and then (if available) the system-specific one.
		source ${paths[$val]}/boot.img || exit 1
		if [ -f "${paths[$val]}/boot.img.$(sys.name)" ]; then
			source ${paths[$val]}/boot.img.$(sys.name) || exit 1
		fi

		if type.is_func DIX_ON_AFTER; then
			DIX_ON_AFTER $DIX_PKG
			unset DIX_ON_AFTER
		fi

		unset DIX_PKG
		boot.profile

		read -p "Done. Press [Enter] to continue ..."

	done
}