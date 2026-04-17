#!/bin/bash

if [[ "$#" -eq 1 ]]; then
    if [[ -f "$1" ]]; then
        # If provided argument is a file, use that and skip fzf
        selected="$1"
    elif [[ -d "$1" ]]; then
        # If provided argument is a directory, open fzf using that directory
        cd "$1" || exit 1
    fi
fi

if [[ -z "$selected" ]]; then
    # If we are in ~, only search specific directories to reduce clutter
    if [[ "$(pwd)" == "$HOME" ]]; then
        dirs=(
            "$HOME/inbox"
            "$HOME/projects"
            "$HOME/resources"
            "$HOME/bin"
        )
        files="$(find -L "${dirs[@]}" -type f)
$(find -L "$HOME" -maxdepth 1 -type f)"
        # Remove '/home/$USER' prefix during fzf from ~
        files="$(echo "$files" | sed "s|^$HOME/||")"
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

[[ -z "$selected" ]] && exit 1

[[ -z "$EDITOR" ]] && EDITOR="nvim"

if [[ "$(pwd)" == "$HOME" ]]; then
    # Re-add '/home/$USER' prefix
    selected="$HOME/${selected}"
fi

if [[ "$TMUX" ]]; then
    num_panes="$(tmux list-panes | wc -l)"

    if [[ "$num_panes" -le 1 ]]; then
        tmux split-window -h "$EDITOR" "$selected"
    else
        current_pane="$(tmux display -p "#{pane_index}")"

        # Select final pane to auto tile (panes start at index 0 so we -1)
        final_pane="$(( num_panes - 1))"
        tmux select-pane -t "$final_pane"

        # Create new pane from final pane so the way it spawns is consistent
        if [[ $(( num_panes %2 )) -eq 0 ]]; then
            tmux split-window -v "$EDITOR" "$selected"
        else
            tmux split-window -h "$EDITOR" "$selected"
        fi

        # Return to original pane, and then back to newly created pane.
        # We do this to keep tmux's last pane the same (as otherwise the last
        # pane will be replaced when temporarily swapping to the final pane)
        tmux select-pane -t "$current_pane"
        tmux select-pane -t "$num_panes"  # As we have just created another pane, we can reuse this variable, as last time we needed to -1 and we have just added another
    fi
else
    "$EDITOR" "$selected"
fi
