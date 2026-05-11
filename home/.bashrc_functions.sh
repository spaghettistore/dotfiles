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
    local files

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
            dirs=(
                "$HOME/inbox"
                "$HOME/projects"
                "$HOME/resources"
            )
            files="$(find -L "${dirs[@]}" -type f)
$(find -L "$HOME" -maxdepth 1 -type f)"
        else
            # Search recursively
            files="$(find -L ./ -type f)"
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
            | fzf --preview="batcat -n --theme=gruvbox-dark --color=always {}")"
            #| fzf --preview 'cat {}')"
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
