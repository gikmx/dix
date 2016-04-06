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

boot.pause(){
	local m="$@"
	echo "$m"
	read -p "Press [Enter] key to continue..." key
}

boot.menu(){

	# Capture cancellation signals so the user MUST input.
	trap '' SIGINT
	trap '' SIGQUIT
	trap '' SIGTSTP

	while :; do
		# show menu
		clear
		boot.motd
		boot.head "main meny"
		echo "1. Show current date/time"
		echo "2. Show what users are doing"
		echo "3. Show top memory & cpu eating process"
		echo "4. Show network stats"
		echo "5. Exit"
		echo "---------------------------------"
		read -r -p "Enter your choice [1-5] : " c
		# take action
		case $c in
			1) pause "$(date)";;
			2) w| less;;
			3) echo '*** Top 10 Memory eating process:'; ps -auxf | sort -nr -k 4 | head -10;
			   echo; echo '*** Top 10 CPU eating process:';ps -auxf | sort -nr -k 3 | head -10;
			   echo;  pause;;
			4) netstat -s | less;;
			5) break;;
			*) Pause "Select between 1 to 5 only"
		esac
	done
}