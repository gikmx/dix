#! /usr/bin/env bash
! $DIX && >&2 echo "DIX404" && exit 1

# $1: Has to be an array in this form Packages[@] (no $)
# $2: Has to be a function.
brew.install(){
	# TODO: Haven't found a way to validate the 1sr param.

	declare -a pkgs=("${!1}")
	for pkg in "${pkgs[@]}"; do
		# convert to array so we can extract parts
		name=(${pkg// / })
		name=${name[0]}
		# Skip already-installed packages
		sys.has_brew "$name" && continue
		log.info "Installing $name"
		if type.is_func $2; then
			TERM=xterm-256color brew install ${pkg[@]} && $2 $name
		else
			TERM=xterm-256color brew install ${pkg[@]}
		fi

	done
}