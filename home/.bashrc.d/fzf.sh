# Set up fzf key bindings and shell integration

# Disable 'ALT+c' as pressing 'Esc' then 'c' will trigger it, which sucks in vim mode
FZF_ALT_C_COMMAND=""

# CTRL-Y to copy the command into clipboard using wl-copy
FZF_CTRL_R_OPTS="
  --bind 'ctrl-y:execute-silent(echo -n {2..} | wl-copy)+abort'
  --color header:italic
  --header 'Press CTRL-Y to copy command into clipboard'"

# Default fzf options, changing vanity
export FZF_DEFAULT_OPTS="--color=16 --style=minimal --ansi --layout=reverse"

eval "$(fzf --bash)"
