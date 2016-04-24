#! /usr/bin/env bash
[ ! $DIX ] && >&2 echo "${BASH_SOURCE[0]}:DIX404" && exit 1

pkg.parse(){
    [[ -z "$@" ]] && dix.throw "Expected package name(s)"
    local pkgs=()
    for pkg in $@; do
        if [[ -f "$pkg/boot.conf" ]]; then
            pkg=("local" "$pkg" "$(basename $pkg)")
        else
            eval "$(string.split "$pkg" '-' 'pkg')"
            [[ ${#pkg[@]} < 2 ]] && dix.throw "Invalid package format: $pkg"
            pkg=("git" "${pkg[0]}" "${pkg[1]}")
        fi
        # Appends an array declaration to the pkgs array
        pkgs+=("$(declare -p pkg)")
    done
    # Return the array of arrays declaration so it can be evaluated
    echo $(declare -p pkgs)
}

pkg.info.name(){
    [[ ! $1 ]] && dix.throw "Invalid package parts"
    local pkg && eval $1
    if [[ "${pkg[0]}" == 'local' ]]; then
        echo "${pkg[2]}"
    else
        echo "${pkg[1]}-${pkg[2]}"
    fi
}

pkg.info.repo(){
    [[ ! $1 ]] && dix.throw "Invalid package parts"
    local pkg && eval $1
    if [[ "${pkg[0]}" == 'local' ]]; then
        echo "${pkg[1]}"
    else
        echo "git://github.com/${pkg[1]}/dix-${pkg[2]}.git"
    fi
}

pkg.info.root(){
    local name=$(pkg.info.name "$1")
    echo "$DIX_PATH_OPT/$name"
}

pkg.info.path(){
    local name=$(pkg.info.name "$1")
    echo "$DIX_PATH_BOOT/$name"
}

pkg.boot.check(){
    local DIX_PKG_TYPE=$2
    local DIX_PKG_PATH=$1
    local DIX_PKG=$(echo ${DIX_PKG_PATH/$DIX_DIX_PKG_PATH_BOOT\/} | perl -pe 's/^\d+\-//')
    local DIX_ERR="$DIX_PKG/$DIX_PKG_TYPE.conf"

    [[ ! -f "$DIX_PKG_PATH/$DIX_PKG_TYPE" ]] && dix.log "$DIX_ERR:404" && return 1
    [[ ! -f "$DIX_PKG_PATH/$DIX_PKG_TYPE.conf" ]] && dix.throw "$DIX_ERR.conf:404"

    source "$DIX_PKG_PATH/$DIX_PKG_TYPE.conf" || dix.throw "$DIX_ERR.conf:500"
    [[ -z "$priority" ]] && dix.throw "$DIX_ERR.conf:500 Invalid priority"
    ! type.is_array requires && dix.throw "$DIX_ERR.conf:500 Invalid requires"
    local result=()
}

pkg.boot.run(){
    local names pkg cmd DIX_PKG DIX_PKG_REPO DIX_PKG_ROOT DIX_PKG_PATH
    local DIX_PKG_TYPE=$1 && shift
    pkgs=$(pkg.parse $@) && eval $pkgs || exit 1
    # run each boot script in a sub shell.
    for pkg in "${pkgs[@]}"; do (
        DIX_PKG="$(pkg.info.name "$pkg")"
        DIX_PKG_REPO="$(pkg.info.repo "$pkg")"
        DIX_PKG_ROOT="$(pkg.info.root "$pkg")"
        DIX_PKG_PATH="$(pkg.info.path "$pkg")"

        ! pkg.boot.check "$DIX_PKG_PATH" "$DIX_PKG_TYPE" && continue

        # handle subdependencies first
        [[ "$DIX_PKG_TYPE" == 'boot' ]] && cmd='install' || cmd='uninstall'

        # Install subdependencies:
        # TODO: Handle uninstallation of dependencies
        [[ "$DIX_PKG_TYPE"  == 'boot' && ${#DIX_REQUIRE[@]} -gt 0 ]] &&\
            pkg.install ${DIX_REQUIRE[@]}
        # Everything ready, run the script
        source "$DIX_PKG_PATH/$DIX_PKG_TYPE"
        type.is_func DIX_ON_AFTER && DIX_ON_AFTER
    ); done
}
