#!/bin/bash

cu() {
    local number="$1"

    case "$number" in
        "") number=1 ;;
        *[!0-9]*) echo "cu: '$number': Not a number" >&2 ; return 1 ;;
    esac

    if (( number < 1 )); then
        return 1
    else
        local cd_string=''
        for _ in $(seq 1 "$number"); do
            cd_string+='../'
        done
        cd "$cd_string" || return 1
    fi
}


# li - passes args and flags to eza and pipes output to fzf
#
# Dependencies:
#   fzf
# Optional dependencies:
#   bat / batcat  (will use cat instead)
#   eza           (will use ls instead)
li() {
    # Due to different distros calling these commands differently, me must
    # check for bat/batcat
    local bat_command
    if command -v 'batcat' &>/dev/null; then
        bat_command='batcat'
    elif command -v 'bat' &>/dev/null; then
        bat_command='bat'
    else
        bat_command='cat'
    fi

    # Use `bat` if installed, else use `cat`
    local fzf_preview_file
    case "$bat_command" in
        'bat' | 'batcat') fzf_preview_file="$bat_command --number --theme=gruvbox-dark --color=always -- {}" ;;
        *) fzf_preview_file='cat --number -- {}' ;;
    esac

    # Use `eza` if installed, else use `ls`
    local fzf_preview_directory
    if command -v 'eza' &>/dev/null; then
        fzf_preview_directory='eza --all --icons always --color always --oneline -- {}'
    else
        fzf_preview_directory='ls --all --color=always -1 -- {}'
    fi

    local FZF_PREVIEW="
        if [[ -f {} ]]; then
            $fzf_preview_file
        elif [[ -d {} ]]; then
            $fzf_preview_directory
        fi"

    local response
    response="$(ls --all -1 --color=always "$@" \
        | fzf --ansi --preview "$FZF_PREVIEW"
    )"

    if [[ -f "$response" ]]; then
        $EDITOR "$response"
    elif [[ -d "$response" ]]; then
        cd "$response" || return 1
    else
        return 1
    fi
}


# fdi - passes args and flags to fdfind and pipes output into fzf
# Dependencies:
#   fzf
#   tmux
# Optional dependencies:
#   fd / fdfind   (will use find instead)
#   bat / batcat  (will use cat instead)
#   eza           (will use ls instead)
fdi() {
    # Due to different distros calling these commands differently, me must
    # check for bat/batcat and fd/fdfind
    local bat_command
    if command -v 'batcat' &>/dev/null; then
        bat_command='batcat'
    elif command -v 'bat' &>/dev/null; then
        bat_command='bat'
    else
        bat_command='cat'
    fi
    local fd_command
    if command -v 'fdfind' &>/dev/null; then
        fd_command='fdfind'
    elif command -v 'fd' &>/dev/null; then
        fd_command='fd'
    else
        fd_command='find'
    fi

    # Use `bat` if installed, else use `cat`
    local fzf_preview_file
    case "$bat_command" in
        'bat' | 'batcat') fzf_preview_file="$bat_command --number --theme=gruvbox-dark --color=always -- {}" ;;
        *) fzf_preview_file='cat --number -- {}' ;;
    esac

    # Use `eza` if installed, else use `ls`
    local fzf_preview_directory
    if command -v 'eza' &>/dev/null; then
        fzf_preview_directory='eza --all --icons always --color always --oneline -- {}'
    else
        fzf_preview_directory='ls --all --color=always -1 -- {}'
    fi

    local TMUX_DIR_SCRIPT="$HOME/files/resources/dotfiles/.config/tmux/tmux_directory_opener.sh"
    local TMUX_FILE_SCRIPT="$HOME/files/resources/dotfiles/.config/tmux/tmux_fzf_file_picker.sh"
    local FDFIND_FLAGS=(
        --color always
        --follow  # Follow symlinks
    )
    local FZF_KEYBINDS=(
        --bind "enter:execute([[ -f {} ]] && $EDITOR -- {})+accept"
        --bind "ctrl-e:execute([[ -f {} ]] && $EDITOR -- {})+abort"
        --bind "ctrl-g:execute(
            if [[ -f {} ]]; then
                $TMUX_FILE_SCRIPT -o goto -- {}
            elif [[ -d {} ]]; then
                $TMUX_DIR_SCRIPT -s -- $(realpath -- {})
            fi
        )+abort"
        # We can't use `read` when calling this function from a keybind, so we must read user input using fzf
        #--bind 'ctrl-o:execute(read -rp "Open with: " cmd; [[ -n "$cmd" ]] && $cmd {})+abort'  # This won't work when function is called from a keybind
        --bind 'ctrl-o:execute(cmd="$(: | fzf --disabled --print-query --prompt "Open with: " --header "{}")"; [[ -n "$cmd" ]] && $cmd {})+abort'
        --bind "ctrl-t:execute(
            if [[ -f {} ]]; then
                $TMUX_FILE_SCRIPT -o window -- {}
            elif [[ -d {} ]]; then
                $TMUX_DIR_SCRIPT -w -- $(realpath -- {})
            fi
        )+abort"
        --bind "ctrl-v:execute(
            if [[ -f {} ]]; then
                $TMUX_FILE_SCRIPT -o pane -- {}
            elif [[ -d {} ]]; then
                $TMUX_DIR_SCRIPT -p -- $(realpath -- {})
            fi
        )+abort"
        --bind "ctrl-x:execute(xdg-open {})+abort"
    )
    local FZF_HEADER=(
        "C-e EDITOR"
        "C-g session"
        "C-o open with"
        "C-t window"
        "C-v pane"
        "C-x xdg-open"
    )
    local FZF_PREVIEW="
        if [[ -f {} ]]; then
            $fzf_preview_file
        elif [[ -d {} ]]; then
            $fzf_preview_directory
        fi"
    local FZF_FLAGS=(
        --ansi
        --color dark
        "${FZF_KEYBINDS[@]}"
        --header "${FZF_HEADER[*]}"
        --preview "$FZF_PREVIEW"
    )

    # Use `fd`/`fdfind` if installed, else use `find`
    local directory
    case "$fd_command" in
        'fd' | 'fdfind') directory="$($fd_command "${FDFIND_FLAGS[@]}" "$@" | fzf "${FZF_FLAGS[@]}")" ;;
        *) directory="$(find -L -- "$@" | fzf "${FZF_FLAGS[@]}")" ;;
    esac

    [[ -d "$directory" ]] && cd "$directory" || return 1
}


# g - goto a directory / file's directory via fzf
#
# Dependencies:
#   fzf
# Optional dependencies:
#   fd / fdfind   (will use find instead)
#   bat / batcat  (will use cat instead)
#   eza           (will use ls instead)
g() {
    # Due to different distros calling these commands differently, me must
    # check for bat/batcat and fd/fdfind
    local bat_command
    if command -v 'batcat' &>/dev/null; then
        bat_command='batcat'
    elif command -v 'bat' &>/dev/null; then
        bat_command='bat'
    else
        bat_command='cat'
    fi
    local fd_command
    if command -v 'fdfind' &>/dev/null; then
        fd_command='fdfind'
    elif command -v 'fd' &>/dev/null; then
        fd_command='fd'
    else
        fd_command='find'
    fi

    # Use `bat` if installed, else use `cat`
    local fzf_preview_file
    case "$bat_command" in
        'bat' | 'batcat') fzf_preview_file="$bat_command --number --theme=gruvbox-dark --color=always -- {}" ;;
        *) fzf_preview_file='cat --number -- {}' ;;
    esac

    # Use `eza` if installed, else use `ls`
    local fzf_preview_directory
    if command -v 'eza' &>/dev/null; then
        fzf_preview_directory='eza --all --icons always --color always --oneline -- {}'
    else
        fzf_preview_directory='ls --all --color=always -1 -- {}'
    fi

    local FDFIND_FLAGS=(
        --color always
        --follow  # Follow symlinks
        --hidden
    )
    local FZF_PREVIEW="
        if [[ -f {} ]]; then
            $fzf_preview_file
        elif [[ -d {} ]]; then
            $fzf_preview_directory
        fi"
    local FZF_FLAGS=(
        --ansi
        --color dark
        --preview "$FZF_PREVIEW"
    )

    # Use `fd`/`fdfind` if installed, else use `find`
    local file
    case "$fd_command" in
        'fd' | 'fdfind') file="$($fd_command "${FDFIND_FLAGS[@]}" "$@" | fzf "${FZF_FLAGS[@]}")" ;;
        *) file="$(find -L -- "$@" | fzf "${FZF_FLAGS[@]}")" ;;
    esac

    local directory
    if [[ -d "$file" ]]; then
        directory="$file"
    elif [[ -f "$file" ]]; then
        directory="$(dirname -- "$(realpath -- "$file")")"
    else
        return 1
    fi

    cd "$directory" || return 1
}
