
# Clones package(s) into /opt
cmd.fetch(){
    # Make sure git is available before doing anything
    ! sys.has "git" && dix.throw "Git could not be found"
    # Populate and validate package names
    local name pkg repo root
    local pkgs=$(pkg.parse $@) && eval $pkgs || exit 1
    # Iterate into sent packages and fetch the repo
    for pkg in "${pkgs[@]}"; do
        name="$(pkg.info.name "$pkg")"
        repo="$(pkg.info.repo "$pkg")"
        root="$(pkg.info.root "$pkg")"
        [[ -d $root ]] && dix.log "Already fetched: $name" && continue
        git clone $repo $root || dix.log.error "Could not fetch: $name" && continue
        dix.log "Fetched: $name"
    done
}

# Removes package(s) from /opt
cmd.drop(){
    local names pkg did name root
    pkgs=$(pkg.parse $@) && eval $pkgs || exit 1
    for pkg in "${pkgs[@]}"; do
        name="$(pkg.info.name "$pkg")"
        root="$(pkg.info.root "$pkg")"
        [[ ! -d $root ]] && dix.log.error "Not found: $name" && continue
        cmd.halt "$name" && cmd.deactivate "$name" &&\
            rm -Rf "$root" && dix.log "Lost: ${root/$DIX_PATH_OPT\//}"
    done
}

# Runs installation (boot) scripts for package(s)
cmd.boot(){
    pkg.boot.run boot $@
}

# Runs Uninstallation (halt) scripts for package(s)
cmd.halt(){
    pkg.boot.run halt $@
}

# Parses package(s) scripts by platform and copies them for booting
cmd.enable(){

}

# Removes package(s) scripts from boot
cmd.disable(){

}

# Activates package(s)' funcionality
cmd.activate(){
    local names pkg cmd DIX_PKG DIX_PKG_REPO DIX_PKG_ROOT DIX_PKG_PATH
    pkgs=$(pkg.parse $@) && eval $pkgs || exit 1
    for pkg in "${pkgs[@]}"; do
        DIX_PKG="$(pkg.info.name "$pkg")"
        DIX_PKG_REPO="$(pkg.info.repo "$pkg")"
        DIX_PKG_ROOT="$(pkg.info.root "$pkg")"
        DIX_PKG_PATH="$(pkg.info.path "$pkg")"

        [[ ! -d "$DIX_PKG_ROOT" ]] &&\
            dix.throw "Package not available: $DIX_PKG"

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
            dix.log "Copied: $DIX_PKG${bootname/$DIX_PKG_PATH/}"
        done
        unset cmd platform origname bootname platname

        # With files in place, it's now time to symlink them into dix
        for path in $(find $DIX_PKG_PATH -maxdepth 1 -type d ! -path $DIX_PKG_PATH); do
            dest="DIX_PATH_$(string.upper ${path/$DIX_PKG_PATH\//})"
            [[ -z "${!dest}" ]] && continue
            dest=${!dest}
            rm -rf "$dest/$DIX_PKG"
            ln -s "$path" "$dest/$DIX_PKG"
            dix.log "Linked: $DIX_PKG${path/$DIX_PKG_PATH/}"
        done
        unset path dest

        dix.log "Enabled: $DIX_PKG"
    done
}

# Activates package(s)' funcionality
cmd.deactivate(){
    local names pkg DIX_PKG
    pkgs=$(pkg.parse $@) && eval $pkgs || exit 1
    for pkg in "${pkgs[@]}"; do
        DIX_PKG="$(pkg.info.name "$pkg")"
        paths=$(find "$DIX_PATH" ! -type f ! -path "$DIX_PATH_OPT/*" -name "$DIX_PKG")
        did=false
        for path in $paths; do
            rm -Rf "$path" && dix.log "Removed ${path/$DIX_PATH\//}" && did=true
        done
        $did && dix.log "Disabled: $DIX_PKG" || dix.log "Not found: $DIX_PKG"
    done
}

cmd.install(){
    local names pkg name
    pkgs=$(pkg.parse $@) && eval $pkgs || exit 1
    for pkg in "${pkgs[@]}"; do
        name="$(pkg.info.name "$pkg")"
        cmd.fetch "$name" && cmd.activate "$name" && cmd.boot "$name"
    done
}

cmd.uninstall(){
    cmd.drop $@
}