#! /usr/bin/env bash
[ ! $DIX ] && >&2 echo "${BASH_SOURCE[0]}:DIX404" && exit 1

show.dix(){
	local line wide char dist text
	[ $1 ] && wide=$1 || wide=$(tput cols)
	[ $2 ] && char=$2 || char='–'
	while read line; do
		[ ! $dist ] &&\
			dist=$(number.ceil $(number.math "($wide-$(string.length "$line"))/2"))
		string.repeat " " $dist && printf "$(string.upper "$line")\n"
	done < $DIX_PATH_LIB/dix.ascii
}

show.error(){
    echo "DIX» $@" 1>&2
}

show.info(){
    echo "DIX» $@"
}

show.box(){
	local line wide dist text
	[[ ! $1 ]] && dix.error "MissingTitle"
	[ $2 ] && wide=$2 || wide=$(tput cols)
	thetxt=$(string.upper "$1")
	lentxt=$(number.math $(string.length "$thetxt"))
	lenbox=$(number.math "$lentxt + 4")
	spaces=$(number.ceil $(number.math "($wide-$lenbox)/2"))
	string.repeat " " $spaces && printf "┌─" && string.repeat "─" $lentxt && printf "─┐\n"
	string.repeat " " $spaces && printf "│ " && printf "$thetxt"          && printf " │\n"
	string.repeat " " $spaces && printf "└─" && string.repeat "─" $lentxt && printf "─┘\n"
}

show.title(){
	[[ ! $1 ]] && dix.error "MissingTitle"
	local wide=$(tput cols)
	local lent=$(number.math $wide-$(string.length "$1"))
	string.repeat " " $lent && echo $1
	string.repeat "─" $wide && echo
}

show.menu(){
    while true; do
        # show menu
        clear
        show.dix
        show.title "Select an option"
        echo

        paths=(true)
        infos=(true)

        i=1
        echo "0. Exit"
        for file in $(find $DIX_PATH_BOOT -type f -name "boot.conf"); do
            paths+=("${file%/*}")
            infos+=("$(source $file && echo $title)")
            echo "$i. ${infos[$i]}"
            ((i++))
        done

        show.title " "
        read -r -n $(string.length $i) -p " {0..$((i-1))} » " val

        # match the regex and be a valid index to continue
        [[ ! $val =~ ^[0-9]+ || $val -gt $((i-1)) ]] && continue

        # if 0, break the loop
        [[ $val == 0 ]] && break
        clear

        # A boot.img must exist.
        [ ! -f "${paths[$val]}/boot.img" ] && dix.error "IMG404"

        # Let the package know its name
        DIX_PKG="$(basename ${paths[$val]})"

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
    clear
}

