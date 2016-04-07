if sys.has_brew 'fzf'; then
	prefix=$(brew --prefix coreutils)
	export PATH=$prefix/bin:$PATH
 	export MANPATH=$prefix/share/man:$MANPATH
	export FZF_TMUX=0                                # don't use a split in tmyx for FZF
	export FZF_DEFAULT_COMMAND='ag -g ""'            # make FZF parse .gitignore .hgignore and svn:ignore
	export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND" # Same as above but for CtrlT
fi

    export TERM=256color-iterm


  # Enable Fuzzy Search
    if [ ! -z "$(brew --prefix fzf)" ]; then
       source "$(brew --prefix fzf)/shell/completion.bash" 2> /dev/null
       source "$(brew --prefix fzf)/shell/key-bindings.bash"
    fi

    # Enable iterm2's shell integration
    test -e "$HOME/.iterm/shell_integration.bash" && . "$HOME/.iterm/shell_integration.bash"


    # Enable keybindings for Fuzzy Search on Arch
    [ -f /etc/profile.d/fzf.bash ] && source /etc/profile.d/fzf.bash
