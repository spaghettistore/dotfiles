#!/bin/bash

main() {
    local TMUX_DIRECTORY_OPENER_SCRIPT="$HOME/.config/tmux/tmux_directory_opener.sh"
    readonly TMUX_DIRECTORY_OPENER_SCRIPT
    local TMUX_FILE_PICKER_SCRIPT="$HOME/resources/dotfiles/.config/tmux/tmux_fzf_file_picker.sh"
    readonly TMUX_FILE_PICKER_SCRIPT
    local fzf_enter_key_default_value="current"

    local fzf_full_response
    fzf_full_response="$(find . \
        | fzf \
            --header "ENTER:$fzf_enter_key_default_value  C-t:window  C-v:pane  C-o:current  C-g:session/goto  C-x:xdg-open" \
            --bind "enter:print($fzf_enter_key_default_value)+accept,ctrl-t:print(window)+accept,ctrl-v:print(pane)+accept,ctrl-o:print(current)+accept,ctrl-g:print(goto)+accept,ctrl-x:print(xdg-open)+accept" \
    )"

    # We use return instead of exit as we plan to source script this with a
    # keybind
    [[ -z "$fzf_full_response" ]] && return 0

    # Extract fzf returned response (due to the extra keybind stuff):
    # Line 1 is from fzf's bind key 'print()'.
    # Line 2 is regular fzf selection response.
    local fzf_keybind_response
    fzf_keybind_response="$(echo "$fzf_full_response" | head -n1)"
    local fzf_selection
    fzf_selection="$(echo "$fzf_full_response" | tail -n+2)"

    local selected
    selected="$(realpath -- "$fzf_selection")"

    if [[ "$fzf_keybind_response" == "current" ]]; then
        if [[ -d "$selected" ]]; then
            cd "$selected" || return 1
        elif [[ -f "$selected" ]]; then
            $TMUX_FILE_PICKER_SCRIPT -o "$fzf_keybind_response" "$selected"
        else
            exit 1
        fi
    elif [[ "$fzf_keybind_response" == "xdg-open" ]]; then
        xdg-open "$selected"
    else
        if [[ -d "$selected" ]]; then
            if [[ "$fzf_keybind_response" == "goto" ]]; then
                fzf_keybind_response="session"
            fi
            local flag
            flag="-${fzf_keybind_response:0:1}"  # Prefix first character with hyphen, e.g. '-s'
            $TMUX_DIRECTORY_OPENER_SCRIPT "$flag" "$selected"
        elif [[ -f "$selected" ]]; then
            if [[ "$fzf_keybind_response" == "session" ]]; then
                fzf_keybind_response="current"
            fi
            $TMUX_FILE_PICKER_SCRIPT -o "$fzf_keybind_response" "$selected"
        else
            exit 1
        fi
    fi
}


# We want to be able to source this script
main "$@"
