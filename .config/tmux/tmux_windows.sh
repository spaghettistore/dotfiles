#!/bin/bash

# Dependencies:
#   tmux
#   fzf

[[ ! "$TMUX" ]] && exit 1

mapfile -t sessions < <(tmux list-sessions | awk '{print $1}' | tr -d ":")
[[ -z "$sessions" ]] && exit 1

all_windows=()
for session in "${sessions[@]}"; do
    mapfile -t windows < <(tmux list-windows -t "$session" | awk '{print $1$2}')
    for window in "${windows[@]}"; do
        # window is: 'index:window name'
        # Final format will look like: 'session:index:window name'
        all_windows+=("$session:$window")
    done
done

selected="$(printf -- '%s\n' "${all_windows[@]}" | fzf)"
[[ -z "$selected" ]] && exit 1

# Strip window name and use only 'session:index'
selected="$(printf -- '%s\n' "$selected" | awk -F ":" '{print $1":"$2}')"

tmux switch-client -t "$selected"
