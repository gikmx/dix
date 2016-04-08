
path.readlink() {
    [ -z "$1" ] && return 1
    perl -le "print readlink '$1'"
}

path.relative(){
	[[ -z "$1" || -z "$2" ]] && return 1
	perl -le "use File::Spec; print File::Spec->abs2rel('$1', '$2')"
}