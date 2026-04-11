#!/bin/bash

case "$1" in
    "$HOME/.config/tmux/tmux_fzf_editor_new_pane.sh" | "$HOME/.config/tmux/tmux_fzed.sh") script_name="$1" ;;
    *) exit 0 ;;
esac

tmux display-menu -T "Find Files" \
    "Current Directory" "." "display-popup -w 80% -h 80% -E \"$script_name\"" \
    "Home" h "display-popup -w 80% -h 80% -E \"$script_name ~\"" \
    "Inbox" i "display-popup -w 80% -h 80% -E \"$script_name ~/inbox\"" \
    "Projects" p "display-popup -w 80% -h 80% -E \"$script_name ~/projects\"" \
    "Refs" r "display-popup -w 80% -h 80% -E \"$script_name ~/refs\"" \
    "Dotfiles" d "display-popup -w 80% -h 80% -E \"$script_name ~/dotfiles\""
