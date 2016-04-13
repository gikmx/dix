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

pkg.info(){
    [[ ! $1 ]] && log.error "Invalid package parts" && exit 1
    pack=($1) # converts it to array
    echo "${pack[0]}-${pack[1]}"
}

pkg.info.repo(){
    [[ ! $1 ]] && log.error "Invalid package parts" && exit 1
    pack=($1) # converts it to array
    echo "git://github.com/${pack[0]}/dix-${pack[1]}.git"
}

pkg.info.root(){
    local name=$(pkg.info "$1")
    echo "$DIX_PATH_OPT/$name"
}

pkg.info.path(){
    local name=$(pkg.info "$1")
    echo "$DIX_PATH_BOOT/$name"
}

pkg.fetch(){
    # Make sure git is available before doing anything
    ! sys.has "git" && log.error "Git could not be found" && exit 1
    # Populate and validate package names
    local names pack repo root
    eval $(pkg.__names $@)
    # Iterate into sent packages and fetch the repo
    for pack in "${names[@]}"; do
        repo="$(pkg.info.repo $pack)"
        root="$(pkg.info.root $pack)"
        [[ -d $root ]] && rm -Rf $root
        git clone $repo $root ||\
            log.error "Could not install: $(pkg.info $pack)" && exit 1
    done
}

pkg.enable(){
    local names DIX_PKG DIX_PKG_REPO DIX_PKG_ROOT DIX_PKG_PATH
    eval $(pkg.__names $@)
    for pack in "${names[@]}"; do
        DIX_PKG="$(pkg.info "$pack")"
        DIX_PKG_REPO="$(pkg.info.repo "$pack")"
        DIX_PKG_ROOT="$(pkg.info.root "$pack")"
        DIX_PKG_PATH="$(pkg.info.path "$pack")"

        [[ ! -d "$DIX_PKG_ROOT" ]] &&\
            log.error "Package not available: $DIX_PKG" && exit 1

        [[ -d "$DIX_PKG_PATH" ]] && rm -Rf "$DIX_PKG_PATH"

        # Find all files inside the folder, but omit platform specific
        # iterate over them and determine if a platform specific file exist
        # if it does, then append it to the end of line
        cmd=(find $DIX_PKG_ROOT -type f ! -name "README.md" ! -path "$DIX_PKG_ROOT/.*")
        for platform in $(sys.supported); do cmd+=(! -name "*.$platform"); done
        for origname in $("${cmd[@]}"); do
            bootname=${origname/$DIX_PKG_ROOT/$DIX_PKG_PATH}
            [[ ! -d $(dirname "$bootname") ]] && mkdir -p $(dirname "$bootname")
            cp "$origname" "$bootname"
            # does a platform specific file exist? append it to normal file.
            platname="$origname.$(sys.name)"
            [[ -f $platname ]] && echo -e "\n$(cat $platname)\n" >> $bootname
            log.info "Copied: $DIX_PKG${bootname/$DIX_PKG_PATH/}"
        done
        unset cmd platform origname bootname platname

        # With files in place, it's now time to symlink them into dix
        for path in $(find $DIX_PKG_PATH -maxdepth 1 -type d ! -path $DIX_PKG_PATH); do
            dest="DIX_PATH_$(string.upper ${path/$DIX_PKG_PATH\//})"
            [[ -z "${!dest}" ]] && continue
            dest=${!dest}
            rm -rf "$dest/$DIX_PKG"
            ln -s "$path" "$dest/$DIX_PKG"
            log.info "Linked: $DIX_PKG${path/$DIX_PKG_PATH/}"
        done
        unset path dest

        log.info "Enabled: $DIX_PKG"
    done
}

pkg.disable(){
    eval $(pkg.__names $@)
    local paths path did
    for pack in "${names[@]}"; do
        DIX_PKG="$(pkg.info "$pack")"
        paths=$(find "$DIX_PATH" ! -type f ! -path "$DIX_PATH_OPT/*" -name "$DIX_PKG")
        did=false
        for path in $paths; do
            rm -Rf "$path" && log.info "Removed ${path/$DIX_PATH\//}" && did=true
        done
        $did && log.info "Disabled: $DIX_PKG"
    done
}

pkg.install(){
    # TODO: Finish this
    # Read configuration file
    [[ ! -f "$DIX_PKG_ROOT/boot.conf" ]] &&\
        log.error "Invalid conf: $DIX_PKG" && exit 1
    (
        source "$DIX_PKG_ROOT/boot.conf"
        [[ $name != $DIX_PKG ]] &&\
            log.error "Invalid package name: $name" && exit 1

    )
}