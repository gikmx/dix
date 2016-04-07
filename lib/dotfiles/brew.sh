#! /usr/bin/env bash
[ -z "$DOTFILES" ] && echo "Invalid environment" && exit 1

# $1: Has to be an array in this form Packages[@] (no $)
# $2: Has to be a function.
brew.install(){
	# TODO: Haven't found a way to validate the 1sr param.
	! type.is_func  $2 && log.error "Expecting a function" && return 1

	declare -a pkgs=("${!1}")
	for pkg in "${pkgs[@]}"; do
		# convert to array so we can extract parts
		name=(${pkg// / })
		name=${name[0]}
		# Skip already-installed packages
		sys.has_brew "$name" && continue
		log.info "Installing $name"
		TERM=xterm-256color brew install ${pkg[@]} && $2 $name
	done
}