#! /usr/bin/env bash
[ ! $DIX ] && >&2 echo "${BASH_SOURCE[0]}:DIX404" && exit 1

pkg.__parts(){
    [[ ! $1 ]] && log.error "Missing package name" && exit 1
    local parts
    # Split string into an array separated by ":" so we can validate format
    IFS=':' read -r -a parts <<< "$1"
    [[ ${#parts[@]} != 2 ]] && log.error "Invalid package name $1" && exit 1
    echo "${1//:/ }"
}

pkg.__names(){
    [[ -z "$@" ]] && log.error "Expected package name(s)" && exit 1
    local names=()
    local parts
    for pkg in $@; do names+=("$(pkg.__parts $pkg)"); done
    # echoes the variable declaration, so it can be evaulated on calling func.
    # This is the only way I've found to return an array
    declare -p names
}

pkg.__repo(){
    [[ ! $1 || ! $2 ]] && log.error "Expected package array" && exit 1
    echo "git://github.com/$1/dix-$2.git"
}

pkg.__path(){
    [[ ! $1 || ! $2 ]] && log.error "Expected package array" && exit 1
    echo "$DIX_PATH_OPT/$1-$2"
}

pkg.fetch(){
    # Make sure git is available before doing anything
    ! sys.has "git" && log.error "Git could not be found" && exit 1
    # Populate and validate package names
    local names pack repo path
    eval $(pkg.__names $@)
    # Iterate into sent packages and fetch the repo
    for pack in "${names[@]}"; do
        pack=($pack) # convert it to array
        repo="`pkg.__repo ${pack[0]} ${pack[1]}`"
        path="`pkg.__path ${pack[0]} ${pack[1]}`"
        [[ -d $path ]] && rm -Rf $path
        git clone $repo $path ||\
            log.error "Could not install: ${pack[@]}" && exit 1
    done
}
