#!/bin/bash

# This script should work in these conditions:
    # In nvim inside tmux
    # In term outside tmux
    # In term inside tmux

if [[ "$#" -eq 1 ]]; then
    selected="$1"
else
    dirs=(
        "$HOME"
        "$HOME/inbox"
        "$HOME/projects"
        "$HOME/refs"
        "$HOME/archive"
        "$HOME/scripts"
        "$HOME/media"
    )

    files="$(find -L "${dirs[@]}" -mindepth 1 -maxdepth 1 -type d)"

    # Remove '/home/$USER' prefix during fzf
    files="$(echo "$files" | sed "s|^$HOME/||")"
    files="$files
~"

    selected="$(echo "$files" \
        | sort \
        | fzf)"

    # Re-add '/home/$USER' prefix
    case "$selected" in
        "~") selected="$HOME" ;;
        "") exit 1 ;;
        *) selected="$HOME/${selected}" ;;
    esac
fi

[[ -z "$selected" ]] \
    && exit 1

# Create/Attach to tmux session in that directory
selected_name="$(basename -- "$selected" | tr "." "_")"

if [[ "$TMUX" ]]; then
    # Inside tmux
    # Make new session (unless duplicate)
    if ! tmux has-session -t="$selected_name" 2>/dev/null; then
        tmux new-session -ds "$selected_name" -c "$selected"
    fi
    # Attach/Swap Focus to existing (or newly created)
    tmux switch-client -t "$selected_name"
else
    # Outside tmux
    # Make new session and attach to it (unless duplicate)
    if ! tmux has-session -t="$selected_name" 2>/dev/null; then
        tmux new-session -s "$selected_name" -c "$selected"
    else
        # Attach to existing
        tmux a -t "$selected_name"
    fi
fi
