#!/bin/bash

# Open a tmux new pane that is auto tiled.
# Optionally can provide a directory path as argmument 1 open in that directory.

directory="$1"

if [[ "$TMUX" ]]; then
    num_panes="$(tmux list-panes | wc --lines)"

    if [[ "$num_panes" -le 1 ]]; then
        if [[ -d "$directory" ]]; then
            tmux split-pane -h -c "$directory"
        else
            tmux split-pane -h
        fi
    else
        current_pane="$(tmux list-panes | grep "(active)$" | awk -F ":" '{print $1}')"

        # Select final pane to auto tile (panes start at index 0 so we -1)
        final_pane="$(( num_panes - 1))"
        tmux select-pane -t "$final_pane"

        # Create new pane from final pane so the way it spawns is consistent
        if [[ $(( num_panes %2 )) -eq 0 ]]; then
            direction="v"
        else
            direction="h"
        fi

        if [[ -d "$directory" ]]; then
            tmux split-pane -$direction -c "$directory"
        else
            tmux split-pane -$direction
        fi

        # Return to original pane, and then back to newly created pane.
        # We do this to keep tmux's last pane the same (as otherwise the last
        # pane will be replaced when temporarily swapping to the final pane)
        tmux select-pane -t "$current_pane"
        tmux select-pane -t "$num_panes"  # As we have just created another pane, we can reuse this variable, as last time we needed to -1 and we have just added another
    fi
fi
