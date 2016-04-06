#! /usr/bin/env bash
[ -z "$DOTFILES" ] && echo "Invalid environment" && exit 1

# Take ownership of target ($1)
set.ownership() {
    sudo -k chown -R $(id -u):$(id -g) $1
    sudo -k chmod -R u+rw,g+u,o-rwx $1
}
