#!/bin/bash

# A fzf script to pick a file, or multiple to give to umpv.py to insert-next
# Use ctrl+y to copy currently highlighted

# Dependencies: fzf mpv wl-copy
# Script Dependencies: umpv.py

# Config options
MUSIC_DIRECTORY="$HOME/media/music"
readonly MUSIC_DIRECTORY

#UMPV_SCRIPT="$HOME/.config/mpv/scripts/umpv.py"
UMPV_SCRIPT="$HOME/projects/umpv_scripts/umpv.py"
readonly UMPV_SCRIPT
SCRIPT_NAME="$(basename -- "$0")"
readonly SCRIPT_NAME

# Outputs message to STDERR and STDOUT.
#
# Globals:
#   SCRIPT_NAME
# Arguments:
#   1: str: Error message to be printed.
# Outputs:
#   Error message to STDERR and STDOUT.
error() {
    echo "${SCRIPT_NAME}: $*" >&2
}


# Arguguments:
#   1: path to file
# Returns:
#   0 if path is a file, else 1
is_a_file() {
    local file="$1"

    if [[ -f "$file" ]]; then
        return 0
    elif [[ ! -e "$file" ]]; then
        error "'$file': File does not exist."
        return 1
    elif [[ -d "$file" ]]; then
        error "'$file': Is a directory, not a file."
        return 1
    else
        error "'$file': Invalid file."
        return 1
    fi
}


# Arguguments:
#   1: path to directory
# Returns:
#   0 if path is a directory, else 1
is_a_directory() {
    local directory="$1"

    if [[ -d "$directory" ]]; then
        return 0
    elif [[ ! -e "$directory" ]]; then
        error "'$directory': directory does not exist."
        return 1
    elif [[ -f "$directory" ]]; then
        error "'$directory': Is a file, not a directory."
        return 1
    else
        error "'$directory': Invalid directory."
        return 1
    fi
}


# Globals
#   UMPV_SCRIPT MUSIC_DIRECTORY
validity_checks() {
    is_a_file "$UMPV_SCRIPT" || exit 1
    is_a_directory "$MUSIC_DIRECTORY" || exit 1
}

# Return the NUMBER to use with 'fzf --delimiter / --with-nth NUMBER..'.
# Used to hide the provided path from fzf.
# Useful if directory would add a long prefix to a path when searching the
# directory recursively.
#
# e.g. if passing this function '/home/$USER', it will return 4.
# - if passing '/home/USER' then 'wc -l' returns 2, but we want +2 so delim
#   starts from 4
#   - +2
#     - +1 for additional / being added when used as path. e.g. '/home/USER'
#       becomes '/home/USER/dir'
#     - +1 as empty field before first character '/' is considered a field
#
# Arguments:
#   1: str: directory path
get_fzf_delimiter_number_for_directory() {
    local directory="$1"
    local wc_l
    wc_l="$(printf -- '%s\n' "$directory" | grep -o '/' | wc --lines)"
    local num
    num="$(( wc_l + 2 ))"
    printf -- '%s\n' "$num"
}


main() {
    validity_checks

    local delimiter_number
    delimiter_number="$(get_fzf_delimiter_number_for_directory "$MUSIC_DIRECTORY")"

    if (( $# == 0 )); then
        local fzf_multi_response
        mapfile -t fzf_multi_response < <(find "$MUSIC_DIRECTORY" -type f \
            | fzf \
                --multi \
                --bind "ctrl-y:execute(wl-copy {})" \
                --prompt "mpv insert-next: " \
                --delimiter '/' --with-nth "$delimiter_number"..
        )

        [[ -z "${fzf_multi_response[*]}" ]] && exit 1

        "$UMPV_SCRIPT" "${fzf_multi_response[@]}"
    else
        "$UMPV_SCRIPT" "$@"
    fi
}


[[ "${BASH_SOURCE[0]}" == "$0" ]] && main "$@"
