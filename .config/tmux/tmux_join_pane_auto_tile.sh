#!/bin/bash

[[ "$TMUX" ]] || exit 0

num_panes="$(tmux list-panes | wc --lines)"
current_pane="$(tmux display -p "#{pane_index}")"
tmux_pane_base_index="$(tmux show-options -g pane-base-index)"  # Default is 0, but you can change it to 1

if (( num_panes <= 1 )); then
    if ! tmux join-pane -h; then
        tmux select-pane -t "$current_pane"
        exit 0
    fi
else
    # Select (focus) final pane to auto tile from that position
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

    if ! tmux join-pane "-$direction"; then
        tmux select-pane -t "$current_pane"
        exit 0
    fi

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
