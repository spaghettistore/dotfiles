#!/bin/bash

# Open a tmux new pane that is auto tiled.
# Optionally can provide a directory path as argmument 1 open in that directory.

[[ "$TMUX" ]] || exit 0

tmux_pane_base_index="$(tmux show-options -g pane-base-index)"  # Default is 0, but you can change it to 1

directory="$1"
num_panes="$(tmux list-panes | wc --lines)"

if [[ ! -d "$directory" ]]; then
    # If no directory provided by argument, use the current pane's directory
    directory='#{pane_current_path}'
fi

if (( num_panes <= 1 )); then
    tmux split-pane -h -c "$directory"
else
    current_pane="$(tmux display -p "#{pane_index}")"

    if [[ "$tmux_pane_base_index" == "pane-base-index 0" ]]; then
        final_pane="$(( num_panes - 1))"
    elif [[ "$tmux_pane_base_index" == "pane-base-index 1" ]]; then
        final_pane="$num_panes"
    else
        echo "'$tmux_pane_base_index': Invalid index, expects 0 or 1" >&2
        exit 1
    fi
    tmux select-pane -t "$final_pane"

    # Create new pane from final pane so the way it spawns is consistent
    if (( $(( num_panes %2 )) == 0 )); then
        direction="v"
    else
        direction="h"
    fi

    tmux split-pane "-$direction" -c "$directory"

    # Return to original pane, and then back to newly created pane.
    # We do this to keep tmux's last pane the same (as otherwise the last
    # pane will be replaced when temporarily swapping to the final pane)
    tmux select-pane -t "$current_pane"
    if [[ "$tmux_pane_base_index" == "pane-base-index 0" ]]; then
        tmux select-pane -t "$num_panes"
    elif [[ "$tmux_pane_base_index" == "pane-base-index 1" ]]; then
        tmux select-pane -t "$(( num_panes + 1 ))"
    else
        echo "'$tmux_pane_base_index': Invalid index, expects 0 or 1" >&2
        exit 1
    fi
fi
