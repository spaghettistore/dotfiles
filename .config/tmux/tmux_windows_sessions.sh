#!/bin/bash

# This script is intended to be used as a tmux keybind bind. It will provide a
# fzf list of all windows, excluding the empty terminals that are there to keep
# the tmux session alive for use with tmux_fzcd.sh
# Use case is for when you have a lot of sessions and want to jump between the open windows

if [[ ! "$TMUX" ]]; then
    #tmux a -t "$selected"
    echo "Seems to acts strange when used outside tmux. Disabled for now."
    exit 1
fi

list_of_sessions="$(tmux list-sessions | awk '{print $1}' | tr -d ":")"
#echo "Sessions: '$list_of_sessions'"

[[ -z "$list_of_sessions" ]] && exit

clean_list=()
for session in $list_of_sessions; do
    #echo "Session: '$session'"
    list_of_windows="$(tmux list-windows -t "$session" | awk '{print $2}')"
    #echo "Windows: '$list_of_windows'"

    for window in $list_of_windows; do

        # Remove suffix '-' and '*'
        clean_window="${window%-}"
        clean_window="${clean_window%\*}"

        # Filter out windows named 'bash' to only show active windows
        if ! echo "$clean_window" | grep -q "bash$"; then
            [[ "${clean_list[*]}" ]] &&
                clean_list+="
"
            clean_list+="$session:$clean_window"
        fi
    done
done

selected="$(echo "$clean_list" | fzf)"
[[ -z "$selected" ]] && exit 1

if [[ "$TMUX" ]]; then
    tmux switch-client -t "$selected"
fi
