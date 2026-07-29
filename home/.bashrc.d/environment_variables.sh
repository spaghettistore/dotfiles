# Set EDITOR
if command -v "nvim" &>/dev/null; then
    export EDITOR="nvim"
elif command -v "vim" &>/dev/null; then
    export EDITOR="vim"
else
    export EDITOR="vi"
fi

export BROWSER="firefox"

# Open man pages with vim instead of less
#export MANPAGER="nvim +Man!"

# Add '~/.local/bin' to PATH
export PATH="$HOME/.local/bin:$PATH"

# New versions of Python replaced REPL, so it no longer reads GNU readline from
# ~/.inputrc, this env var allows you to use the old REPL that allows using
# ~/.inputrc for vim bindings
export PYTHON_BASIC_REPL=1
