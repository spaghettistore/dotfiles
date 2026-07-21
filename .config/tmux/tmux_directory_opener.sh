#!/bin/bash

SCRIPT_NAME="$(basename -- "$0")"
readonly SCRIPT_NAME

usage() {
    echo "$SCRIPT_NAME: open directory in tmux pane/session/window

USAGE
  $SCRIPT_NAME [-h] <-p|-s|-w> <DIRECTORY>

FLAGS
  -h
    show this help message and exit
  -p
    open directory in new auto tiled pane
  -s
    open directory in new session or attach to existing session
  -w
    open directory in new window in current session, or attach to existing
    window in current session"
}


error() {
    printf -- '%s\n' "${SCRIPT_NAME}: $*" >&2
}


tmux_open_directory_in_new_session_or_attach_to_existing_session() {
    local selected="$1"
    local selected_name
    selected_name="$(basename -- "$selected" | tr -- "." "_")"

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
}


# Open a tmux new pane that is auto tiled.
# Optionally can provide a directory path as argmument 1 open in that directory.
tmux_open_directory_in_new_auto_tiled_pane() {
    local directory="$1"

    [[ "$TMUX" ]] || exit 1

    local num_panes
    num_panes="$(tmux list-panes | wc --lines)"

    if [[ ! -d "$directory" ]]; then
        # If no directory provided by argument, use the current pane's directory
        directory='#{pane_current_path}'
    fi

    if (( num_panes <= 1 )); then
        tmux split-pane -h -c "$directory"
    else
        local current_pane
        current_pane="$(tmux display -p "#{pane_index}")"

        # Select final pane to auto tile (panes start at index 0 so we -1)
        local final_pane
        final_pane="$(( num_panes - 1))"
        tmux select-pane -t "$final_pane"

        # Create new pane from final pane so the way it spawns is consistent
        local direction
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
}


tmux_open_directory_in_new_window_in_current_session_or_attach_to_existing_window_in_current_session() {
    local dir="$1"
    local clean_window_name

    clean_window_name=$(basename -- "$dir" | tr "./" "__")

    if [[ "$TMUX" ]]; then
        local session_name
        session_name="$(tmux display-message -p "#S")"
        local target
        target="$session_name:$clean_window_name"

        # If target does not exist within current session, create it
        if ! tmux has-session -t "$target" 2>/dev/null; then
            tmux neww -dn "$clean_window_name" -c "$dir"
        fi

        # Attach to existing (or newly created)
        tmux select-window -t "$clean_window_name"
    fi
}


main() {
    local opt
    local mode
    while getopts ":hpsw" opt; do
        case "$opt" in
            "h") usage ; exit 0 ;;
            "p") mode="pane" ;;
            "s") mode="session" ;;
            "w") mode="window" ;;
            *) error "Invalid option -- '${OPTARG}'" ; exit 1 ;;
        esac
    done
    shift $((OPTIND - 1))

    local directory="$1"
    [[ ! -d "$directory" ]] && error "'$directory': No such directory" && exit 1

    case "$mode" in
        "pane")
            tmux_open_directory_in_new_auto_tiled_pane "$directory"
            ;;
        "session")
            tmux_open_directory_in_new_session_or_attach_to_existing_session "$directory"
            ;;
        "window")
            tmux_open_directory_in_new_window_in_current_session_or_attach_to_existing_window_in_current_session "$directory"
            ;;
        *)
            echo "Try '$SCRIPT_NAME -h' for more information."
            ;;
    esac
}


[[ "${BASH_SOURCE[0]}" == "$0" ]] && main "$@"
