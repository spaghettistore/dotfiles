#!/bin/bash

# This script will symlink the following:
# '~/dotfiles/.config/*' -> '~/.config/'
# '~/dotfiles/home/*' -> '~/'

dry_run="false"
dotfiles_directory="$HOME"/dotfiles

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
    local config_dir dir_name new_config_dir_path file file_name new_home_dir_path

    case "$1" in
        "--dry" | "--dry-run")
            dry_run="true"
            ;;
    esac

    confirm_start_or_exit

    local -a dotfiles_config_directories
    mapfile -t dotfiles_config_directories < <(\
        find "$dotfiles_directory"/.config -mindepth 1 -maxdepth 1 -type d)

    for config_dir in "${dotfiles_config_directories[@]}"; do
        dir_name="$(basename -- "$config_dir")"
        new_config_dir_path="$HOME/.config/$dir_name"
        attempt_create_symlink "$config_dir" "$new_config_dir_path"
    done

    local -a dotfiles_home_directories
    mapfile -t dotfiles_home_directories < <(\
        find "$dotfiles_directory"/home -maxdepth 1 -mindepth 1)

    for file in "${dotfiles_home_directories[@]}"; do
        file_name="$(basename -- "$file")"
        new_home_dir_path="$HOME/$file_name"
        attempt_create_symlink "$file" "$new_home_dir_path"
    done
}


main "$@"
