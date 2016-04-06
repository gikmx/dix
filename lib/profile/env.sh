#! /bin/usr/env bash

[[ -z $DOTFILES ]] && source $HOME/.dotfiles

if sys.is_linux; then
	export LC_ALL=en_US.UTF-8
	export LANG=en_US.UTF-8
fi

if sys.is_mac; then

	! sys.has_brew && return

	prefix=$(brew --prefix)

	export PATH=$prefix/bin:$prefix/sbin:$PATH

	if sys.has_brew 'fzf'; then
		prefix=$(brew --prefix coreutils)
		export PATH=$prefix/bin:$PATH
	 	export MANPATH=$prefix/share/man:$MANPATH
		export FZF_TMUX=0                                # don't use a split in tmyx for FZF
		export FZF_DEFAULT_COMMAND='ag -g ""'            # make FZF parse .gitignore .hgignore and svn:ignore
		export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND" # Same as above but for CtrlT
	fi

	if sys.has_brew 'coreutils'; then
		prefix=$(brew --prefix coreutils)
		export PATH=$prefix/libexec/gnubin:$PATH
		export MANPATH=$prefix/libexec/gnuman:$MANPATH
	fi

	unset prefix
fi

if sys.has 'git'; then
	# GIT_AUTHOR_* should be declared on $DOTFILES_PATH_SRV
	export GIT_COMMITTER_NAME="$GIT_AUTHOR_NAME"
	export GIT_COMMITTER_EMAIL="$GIT_AUTHOR_EMAIL"
fi

export NVM_DIR=$HOME/.nvm
export PATH=$DOTFILES_PATH_BIN:$PATH

