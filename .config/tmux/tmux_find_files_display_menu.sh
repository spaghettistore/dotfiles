#!/bin/bash

# Dependencies: tmux_fzed.sh tmux_fzf_editor_new_pane.sh

case "$1" in
    "window")
        script_name="$HOME/.config/tmux/tmux_fzed.sh"
        title="new-window"
        ;;
    "pane")
        script_name="$HOME/.config/tmux/tmux_fzf_editor_new_pane.sh"
        title="split-pane"
        ;;
    *) exit 0 ;;
esac

tmux display-menu -T "Find Files ($title)" \
    "Current Directory" "." "display-popup -w 80% -h 80% -E \"$script_name\"" \
    "Home" h "display-popup -w 80% -h 80% -E \"$script_name ~\"" \
    "Inbox" i "display-popup -w 80% -h 80% -E \"$script_name ~/inbox\"" \
    "Projects" p "display-popup -w 80% -h 80% -E \"$script_name ~/projects\"" \
    "Resources" r "display-popup -w 80% -h 80% -E \"$script_name ~/resources\"" \
    "Code" c "display-popup -w 80% -h 80% -E \"$script_name ~/resources/code\"" \
    "Dotfiles" d "display-popup -w 80% -h 80% -E \"$script_name ~/resources/dotfiles\""
