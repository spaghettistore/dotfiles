#!/bin/bash

fzcd() {
    local selected
    selected="$(find . -mindepth 1 -type d \
        | grep -v -e "/\.steam/" -e "/\.git/" \
        | fzf --preview 'ls {}')"
    cd "$selected" || return 1
}


fzed() {
    local selected=""

    if [[ "$#" -eq 1 ]]; then
        if [[ -f "$1" ]]; then
            # If provided argument is a file, use that and skip fzf
            selected="$1"
        elif [[ -d "$1" ]]; then
            # If provided argument is a directory, open fzf using that directory
            cd "$1" || return 1
        fi
    fi

    if [[ -z "$selected" ]]; then
        # If we are in ~, only search specific directories to reduce clutter
        if [[ "$(pwd)" == "$HOME" ]]; then
            local dirs
            dirs=(
                "$HOME/inbox"
                "$HOME/projects"
                "$HOME/resources"
            )
            local files
            files="$({ find -L "${dirs[@]}" -type f
                find -L "$HOME" -maxdepth 1 -type f
            })"
        else
            # Search recursively
            files="$(find -L ./ -type f)"
        fi

        local batcat_flags=(
            "--number"
            "--theme=gruvbox-dark"
            "--color=always"
        )

        # Some distros call it 'batcat' or 'bat'
        local cat_cmd
        if command -v "batcat" &>/dev/null; then
            cat_cmd="batcat ${batcat_flags[*]}"
        elif command -v "bat" &>/dev/null; then
            cat_cmd="bat ${batcat_flags[*]}"
        else
            cat_cmd="cat"
        fi

        # Filter out non-text files
        selected="$(echo "$files" \
            | grep -v \
            -e "/\.steam/" \
            -e "/GIMP/2\.10/" \
            -e "/\.config/libreoffice/" \
            -e "\.mp3$" \
            -e "\.wma$" \
            -e "\.m4a$" \
            -e "\.png$" \
            -e "\.jpg$" \
            -e "\.jpeg$" \
            -e "\.svg$" \
            -e "\.kra$" \
            -e "\.pdf$" \
            -e "\.epub$" \
            -e "\.djvu$" \
            -e "\.docx$" \
            -e "\.mp4$" \
            -e "\.mkv$" \
            -e "\.wav$" \
            -e "\.mmpz" \
            -e "\.tdb$" \
            -e "\.zip$" \
            -e "\.7z$" \
            -e "\.bin$" \
            -e "\.cue$" \
            -e "\.chd$" \
            -e "\.iso$" \
            -e "\.gba$" \
            -e "\.nes$" \
            -e "\.nds$" \
            -e "\.srm$" \
            -e "\.tar$" \
            -e "\.nvmem$" \
            -e "\.eeprom$" \
            -e "\.ps2$" \
            -e "/\.git/" \
            -e "/__pycache__/" \
            -e "a\.out" \
            -e "\.gitignore" \
            | sort \
            | fzf --preview="$cat_cmd {}")"
    fi

    [[ -z "$selected" ]] && return 1
    [[ -z "$EDITOR" ]] && EDITOR="nvim"

    $EDITOR "$selected"
}


fzls() {
    local selected
    selected="$(find . -maxdepth 1 \
        | fzf --preview "if [[ -f {} ]]; then cat {}; else ls {}; fi")"

    [[ -z "$selected" ]] && return 1

    if [[ -d "$selected" ]]; then
        cd "$selected" || return 1
    elif [[ -f "$selected" ]]; then
        [[ -e "$HOME/.local/bin/open_thing.sh" ]] \
            && "$HOME"/.local/bin/open_thing.sh "$selected"
    fi
}


goto() {
    local target

    if [[ "$1" ]]; then
        target="$1"
    else
        target="$(find . -mindepth 1 | fzf)"
    fi

    [[ -z "$target" ]] && return 1

    target="$(realpath -- "$target")"

    local directory
    if [[ -f "$target" ]]; then
        directory="$(dirname -- "$target")"
    elif [[ -d "$target" ]]; then
        directory="$target"
    else
        return 1
    fi

    cd "$directory" || return 1
}


cu() {
    local number="$1"

    case "$number" in
        "") number=1 ;;
        *[!0-9]*) echo "cu: '$number': Not a number" >&2 ; return 1 ;;
    esac

    if (( number < 1 )); then
        return 1
    else
        local cd_string=''
        for _ in $(seq 1 "$number"); do
            cd_string+='../'
        done
        cd "$cd_string" || return 1
    fi
}
