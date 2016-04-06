#! /usr/bin/env bash
[ -z "$DOTFILES" ] && echo "Invalid enviromnent." && exit

# Take ownership of target ($1)
set.ownership() {
    sudo -k chown -R $(id -u):$(id -g) $1
    sudo -k chmod -R u+rw,g+u,o-rwx $1
}
