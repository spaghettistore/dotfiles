#!/bin/bash

# This script will symlink the following:
# '~/dotfiles/.config/*' -> '~/.config/'
# '~/dotfiles/home/*' -> '~/'

dry_run="false"

# Echo, but prefixed with '[DRY_RUN]: ' if global variable 'dry_run' is 'true'.
# Globals:
#   dry_run
# Arguments:
#   $1: Text to be echoed.
log() {
    if [[ $dry_run == "true" ]]; then
        echo "[DRY_RUN]: $1"
    else
        echo "$1"
    fi
}


# Interactive prompt before starting, defaults to no.
# Arguments:
#   None
confirm_start_or_exit() {
    local ans

    read -rp "Would you like to start? [y/N] " ans

    case "$ans" in
        [yY]*)
            echo "Starting..."
            ;;
        *)
            echo "Aborted."
            exit 1
            ;;
    esac
}


# Create a symlink, but first recursively remove destination directory (if
# existing) to prevent adding to the directory instead of overwriting it.
# Arguments:
#   $1: Path to source file or directory.
#   $2: Path to destination file or directory.
# Globals:
#   dry_run
attempt_create_symlink() {
    local src="$1"
    local dest="$2"

    if [[ -e "$dest" ]]; then
        if [[ -d "$dest" ]]; then
            # Remove old directory '$dest' to prevent adding to that directory
            # instead of overwriting it.
            log "removing: $dest"
            if [[ $dry_run == "false" ]]; then
                rm -rv "$dest"
            fi
        fi
    fi

    log "symlinking: '$src' -> '$dest'"
    if [[ $dry_run == "false" ]]; then
        ln -sf "$src" "$dest"
    fi
}


main() {
    case "$1" in
        "--dry" | "--dry-run")
            dry_run="true"
            ;;
    esac

    confirm_start_or_exit

    local -a config_directories
    mapfile -t config_directories < <(\
        find "$HOME"/dotfiles/.config -mindepth 1 -maxdepth 1 -type d)

    local config_dir
    for config_dir in "${config_directories[@]}"; do
        local dir_name
        dir_name="$(basename "$config_dir")"
        local new_path="$HOME/.config/$dir_name"
        attempt_create_symlink "$config_dir" "$new_path"
    done

    local -a dotfiles_home
    mapfile -t dotfiles_home < <(\
        find "$HOME"/dotfiles/home -maxdepth 1 -mindepth 1)

    local file
    for file in "${dotfiles_home[@]}"; do
        local file_name
        file_name="$(basename "$file")"
        local new_path="$HOME/$file_name"
        attempt_create_symlink "$file" "$new_path"
    done
}


main "$@"
