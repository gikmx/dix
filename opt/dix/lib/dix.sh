#! /usr/bin/env bash

# DIX_PATH might be set if this is being sourced from /sbin/dix
# if not, then determine the real path of this file and set DIX_PATH
if [[ -z "$DIX_PATH" ]]; then
	PWD=$(dirname $(perl -le "use Cwd qw(realpath); print realpath('${BASH_SOURCE[0]}')"))
	pushd $PWD > /dev/null
		while true; do
			DIX_PATH=$(pwd -P)
			[ -d ".git" ] && break
			cd ..
		done
	popd > /dev/null
fi

# Centralise error handling
dix.error(){
	show.error $1
	exit 1
}

# Convert directories in $1 into files in $2
dix.env.save(){
	[[ ! $1 || ! $2 ]] && >&2 echo "ERR:dix.set_srv" && exit 1
	local path name
	# Set the path environment variables
	for path in $(find $1 -maxdepth 1 -type d ! -name ".*" ! -path $1); do
	    name="DIX_PATH_$(basename $path | tr '[:lower:]' '[:upper:]')"
	    echo "$path" > "$2/$name"
	done
	echo "$2" > "$2/DIX_PATH_ENV"
	echo "$1" > "$2/DIX_PATH"
}

# Populates the environment using files on $1
dix.env.load(){
	[ ! $1 ] && >&2 echo "dix.srv:404" && exit 1
	local name
	for path in $(find $1 -maxdepth 1 -type f ! -name "README.md"); do
		name="$(basename $path)"
		export $name="$(cat $path)"
	done
}

# load libraries on $1
dix.load.lib(){
	[ ! $1 ] && >&2 echo "dix.srv:404" && exit 1
	for DIX_LIB_PATH in $(find $1 -type f -name "*.sh" ! -name "dix.sh"); do
		DIX_LIB_NAME=$(basename $DIX_LIB_PATH)
		DIX_LIB_NAME=${DIX_LIB_NAME/.sh}
		DIX_LIB=$(dirname $DIX_LIB_PATH)
		DIX_LIB=${DIX_LIB/$1}
		source "$DIX_LIB_PATH"
		unset DIX_LIB_PATH DIX_LIB_NAME DIX_LIB
	done
}

dix.load(){
	dix.load.srv $DIX_PATH/srv
	dix.load.lib $DIX_PATH/lib
	# dix.etc $DIX_PATH/etc
}

# Let everyone know that dix is ready to work
DIX=true
