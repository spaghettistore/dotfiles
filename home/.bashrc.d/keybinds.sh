# Vim Keybinds
#set -o vi  # Use 'set editing-mode vi' in '~/.inputrc' instead, so that all readline() based apps use vi keybinds
#bind -x '"\C-L": "clear"'  # Vim mode clear (is setup inside '~/.inputrc' now)
## Arrow keys up/down use what is in prompt to search history (is setup inside '~/.inputrc' now)
#bind '"\e[A": history-search-backward'
#bind '"\e[B": history-search-forward'

# Script keybinds (with vim mode this only works in insert mode)
bind -x '"\C-F": "~/.config/tmux/tmux_fzf_file_picker.sh -o current"'
bind -x '"\C-G": ". ~/.config/tmux/tmux_fzf_directory_picker.sh"'
bind -x '"\C-O": ". ~/.config/tmux/tmux_files_and_directory_picker.sh"'
