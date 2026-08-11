#!/bin/bash

# This script will symlink the following:
# '$dotfiles_directory/.config/*' -> '~/.config/'
# '$dotfiles_directory/home/*' -> '~/'
# If a file exists, it will be overwritten.
# If a directory exists, it will be deleted with 'rm -r' to prevent adding to
# that directory instead of overrwriting it.

dry_run="false"
dotfiles_directory="$HOME/resources/dotfiles"

# Echo, but prefixed with '[DRY_RUN]: ' if global variable 'dry_run' is 'true'.
#
# Globals:
#   dry_run
# Arguments:
#   1: Text to be echoed.
log() {
    local message="$1"
    [[ "$dry_run" == "true" ]] && message="[DRY_RUN]: $message"
    echo "$message"
}


# Get [y/N] user confirmation (defaults to no)
#
# Arguments:
#   1: prompt message for 'read -p'
# Returns:
#   0 if yes, else 1
get_user_confirmation() {
    local user_confirmation
    read -rp "$* [y/N] " user_confirmation
    case "$user_confirmation" in
        [yY]*) return 0 ;;
        *) return 1 ;;
    esac
}


# Create a symlink, but first recursively remove destination directory (if
# existing) to prevent adding to the directory instead of overwriting it.
#
# Globals:
#   dry_run
# Arguments:
#   1: Path to source file or directory.
#   2: Path to destination file or directory.
attempt_create_symlink() {
    local src="$1"
    local dest="$2"

    if [[ -e "$dest" ]]; then
        if [[ -d "$dest" ]]; then
            # Remove old directory '$dest' to prevent adding to that directory
            # instead of overwriting it.
            log "removing: $dest"
            if [[ "$dry_run" == "false" ]]; then
                rm -rv "$dest"
            fi
        fi
    fi

    log "symlinking: '$src' -> '$dest'"
    if [[ "$dry_run" == "false" ]]; then
        ln -sf "$src" "$dest"
    fi
}


# Symlinks all files and directories:
# '$dotfiles_directory/.config/*' -> '~/.config/'
# '$dotfiles_directory/home/*' -> '~/'
#
# Globals:
#   dotfiles_directory
# Arguments:
#   none
symlink_dotfiles() {
    # Symlink '~/.config/'
    local -a dotfiles_config_directories
    mapfile -t dotfiles_config_directories < <(\
        find "$dotfiles_directory"/.config -mindepth 1 -maxdepth 1 -type d)

    local config_dir dir_name new_config_dir_path
    for config_dir in "${dotfiles_config_directories[@]}"; do
        dir_name="$(basename -- "$config_dir")"
        new_config_dir_path="$HOME/.config/$dir_name"
        attempt_create_symlink "$config_dir" "$new_config_dir_path"
    done

    # Symlink '~'
    local -a dotfiles_home_directories
    mapfile -t dotfiles_home_directories < <(\
        find "$dotfiles_directory"/home -maxdepth 1 -mindepth 1)

    local file file_name new_home_dir_path
    for file in "${dotfiles_home_directories[@]}"; do
        file_name="$(basename -- "$file")"
        new_home_dir_path="$HOME/$file_name"
        attempt_create_symlink "$file" "$new_home_dir_path"
    done
}


# Globals:
#   dry_run dotfiles_directory
main() {
    case "$1" in
        "--dry" | "--dry-run") dry_run="true" ;;
    esac

    [[ ! -d "$dotfiles_directory" ]] && echo "'$dotfiles_directory': No such directory" >&2 && exit 1

    echo "This script will symlink the following:
'$dotfiles_directory/.config/*' -> '~/.config/'
'$dotfiles_directory/home/*' -> '~/'

If a file exists, it will be overwritten.
If a directory exists, it will be deleted with 'rm -r' to prevent adding to that directory instead of overrwriting it."

    get_user_confirmation "Would you like to begin?" || exit 1

    symlink_dotfiles
}


[[ "${BASH_SOURCE[0]}" == "$0" ]] && main "$@"
