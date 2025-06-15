#!/bin/bash

# If arg provided, use that path, else fzf for it
if [[ "$#" -eq 1 ]]; then
    selected="$1"
else
    # If we are in ~, only search specific directories to reduce clutter
    if [[ "$(pwd)" == "$HOME" ]]; then
        files="$(find "$HOME"/inbox "$HOME"/projects "$HOME"/refs "$HOME"/bin \
            "$HOME"/git_repos "$HOME"/dotfiles "$HOME"/archive -type f,l)
$(find "$HOME" -maxdepth 1 -type f,l)"
    else
        # Search recursively
        files="$(find ./ -type f,l)"
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

[[ -z "$selected" ]] &&
    exit 1

[[ -z "$EDITOR" ]] &&
    EDITOR="nvim"

#tmux_running="$(prep tmux)"

file_name=$(basename "$selected")
clean_name=$(echo "$file_name" | tr "./" "__")

dir_path="$(echo "$selected" | sed "s/\/$file_name$//")"
dir_name="$(echo "$dir_path" | awk -F/ '{print $NF}')"
clean_dir="$(echo "$dir_name" | tr "./" "__")"
target="${clean_dir}:${clean_name}"

# If exact target exists, attach to that
if tmux has-session -t="$target" 2>/dev/null; then
    if [[ "$TMUX" ]]; then
        tmux switch-client -t "$target"
    else
        tmux a -t "$target"
    fi

    exit 0
fi

# If no matches, create a new session
if [[ "$TMUX" ]]; then
    session_name=$(tmux display-message -p "#S")
    target="$session_name:$clean_name"

    # If target does not exist within current session, create it
    if ! tmux has-session -t "$target" 2>/dev/null; then
        tmux neww -dn "$clean_name" "$EDITOR" "$selected"
    fi

    # Attach to existing (or newly created)
    tmux select-window -t "$clean_name"
else
    $EDITOR "$selected"
    #tmux new-session -s "$clean_dir" -c "$dir_path" tmux neww -dn "$clean_name" "$EDITOR" "$selected"
fi
