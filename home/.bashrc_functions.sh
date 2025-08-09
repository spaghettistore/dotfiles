#!/bin/bash

fzcd() {
    local selected
    selected="$(find . -mindepth 1 -type d | fzf --preview 'ls {}')" \
        && cd "$selected" \
        || return 1
}


fzed() {
    local selected=""
    local files

    files=$(find . -mindepth 1 -type f)

    # Filter out non-text files
    selected="$(echo "$files" | grep -v -e "/\.steam/" -e "/GIMP/2\.10/" -e "/\.config/libreoffice/" -e "\.mp3$" -e "\.wma$" -e "\.m4a$" -e "\.png$" -e "\.jpg$" -e "\.jpeg$" -e "\.svg$" -e "\.kra$" -e "\.pdf$" -e "\.epub$" -e "\.djvu$" -e "\.docx$" -e "\.mp4$" -e "\.wav$" -e "\.mmpz" -e "\.tdb$" -e "\.zip$" -e "\.7z$" -e "\.bin$" -e "\.cue$" -e "\.chd$" -e "\.iso$" -e "\.gba$" -e "\.nes$" -e "\.nds$" -e "\.srm$" -e "\.tar$" -e "\.nvmem$" -e "\.eeprom$" -e "\.ps2$" -e "/\.git/" -e "/__pycache__/" -e "a\.out" -e "\.gitignore" \
        | sort \
        | fzf --preview 'cat {}')"

    [[ -z "$selected" ]] \
        || $EDITOR "$selected"
}


fzls() {
    local selected
    selected="$(ls -Ap1 \
        | fzf --preview "if [[ -f {} ]]; then cat {}; else ls {}; fi")"

    [[ -z "$selected" ]] \
        && return 1

    if [[ -d "$selected" ]]; then
        cd "$selected" \
            || return 1
    elif [[ -f "$selected" ]]; then
        [[ -e "$HOME/bin/open_thing.sh" ]] \
            && "$HOME"/bin/open_thing.sh "$selected"
    fi
}


goto() {
    local target
    target="$(find . -mindepth 1 \
        | fzf)"

    [[ -z "$target" ]] \
        && return 1

    target="$(realpath "$target")"

    local directory
    if [[ -f "$target" ]]; then
        directory="$(dirname "$target")"
    elif [[ -d "$target" ]]; then
        directory="$target"
    else
        return 1
    fi

    cd "$directory" \
        || return 1
}


#func_git_status() {
#    [[ ! "$(which git)" == "/usr/bin/git" ]] \
#    && return
#
#    local git_status
#    git_status="$(git status -s 2>/dev/null | wc -l)"
#
#    [[ "$git_status" -ne 0 ]] \
#    && echo " [$git_status] "
#}
