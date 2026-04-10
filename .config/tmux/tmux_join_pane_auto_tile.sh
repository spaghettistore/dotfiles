#!/bin/bash

[[ "$TMUX" ]] || exit 0

num_panes="$(tmux list-panes | wc --lines)"
current_pane="$(tmux list-panes | grep "(active)$" | awk -F ":" '{print $1}')"

if [[ "$num_panes" -le 1 ]]; then
    if ! tmux join-pane -h; then
        tmux select-pane -t "$current_pane"
        exit 0
    fi
else
    # Select (focus) final pane to auto tile from that position
    # Panes start at index 0 so we -1
    final_pane="$(( num_panes - 1))"
    tmux select-pane -t "$final_pane"

    # Create new pane from final pane so the way it spawns is consistent
    if [[ $(( num_panes %2 )) -eq 0 ]]; then
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
    tmux select-pane -t "$num_panes"  # As we have just created another pane, we can reuse this variable, as last time we needed to -1 and we have just added another
fi
