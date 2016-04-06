#! /usr/bin/env bash
[ -z "$DOTFILES" ] && echo "Invalid enviromnent." && exit

boot.motd(){
	cat $DOTFILES_PATH_LIB/boot/motd
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

boot.menu(){

	# Capture cancellation signals so the user MUST input.
	trap '' SIGINT
	trap '' SIGQUIT
	trap '' SIGTSTP

	while true; do
		# show menu
		clear
		boot.motd
		boot.head "Main Menu"
		echo
		paths=(' ')
		infos=('Exit')
		i=0
		for file in `find $DOTFILES_PATH_BOOT -type f -name "boot.ini"`; do
			paths+=("dir${file%/*}")
			infos+=("`cat $file`")
			echo "${i}. ${infos[$i]}"
			((i++))
		done
		printf "\n$(string.repeat "–" 80)\n\n"
		read -r -n $(string.length $i) -p "Select an item {0..$((i-1))} » " val
		echo
		# match the regex and be a valid index to continue
		[[ ! $val =~ ^[0-9]+ || $val -gt $((i-1)) ]] && continue
		# if 0, break the loop
		[[ $val == 0 ]] && break

		echo ${paths[$val]}

	done
}