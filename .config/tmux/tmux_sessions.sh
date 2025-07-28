#!/bin/bash

main() {
    local ans
    ans="$(tmux list-sessions | awk -F":" '{print $1}' | fzf)"

    [[ -z "$ans" ]] &&
        exit 1

    if [[ "$TMUX" ]]; then
        tmux switch-client -t "$ans"
    else
        tmux attach -t "$ans"
    fi
}


main "$@"
