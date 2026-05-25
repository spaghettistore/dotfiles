#!/bin/bash

# Open a tmux new pane that is auto tiled.
# Optionally can provide a directory path as argmument 1 open in that directory.

[[ "$TMUX" ]] || exit 0

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

    # Select final pane to auto tile (panes start at index 0 so we -1)
    final_pane="$(( num_panes - 1))"
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
    tmux select-pane -t "$num_panes"  # As we have just created another pane, we can reuse this variable, as last time we needed to -1 and we have just added another
fi
