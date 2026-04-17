#!/bin/bash

case "$1" in
    "$HOME/.config/tmux/tmux_fzf_editor_new_pane.sh")
        script_name="$1"
        title_mode="split-pane"
        ;;
    "$HOME/.config/tmux/tmux_fzed.sh")
        script_name="$1"
        title_mode="new-window"
        ;;
    *) exit 0 ;;
esac

tmux display-menu -T "Find Files ($title_mode)" \
    "Current Directory" "." "display-popup -w 80% -h 80% -E \"$script_name\"" \
    "Home" h "display-popup -w 80% -h 80% -E \"$script_name ~\"" \
    "Inbox" i "display-popup -w 80% -h 80% -E \"$script_name ~/inbox\"" \
    "Projects" p "display-popup -w 80% -h 80% -E \"$script_name ~/projects\"" \
    "Resources" r "display-popup -w 80% -h 80% -E \"$script_name ~/resources\"" \
    "Code" c "display-popup -w 80% -h 80% -E \"$script_name ~/resources/code\"" \
    "Dotfiles" d "display-popup -w 80% -h 80% -E \"$script_name ~/resources/dotfiles\""
