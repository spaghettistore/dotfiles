#!/bin/bash

main() {
    local TMUX_DIRECTORY_OPENER_SCRIPT="$HOME/.config/tmux/tmux_directory_opener.sh"
    readonly TMUX_DIRECTORY_OPENER_SCRIPT
    local selected_directory
    local fzf_enter_key_default_value="session"
    local fzf_keybind_response="session"  # Default to open directory in new session when providing an arg and not using fzf

    if (( $# == 1 )); then
        selected_directory="$1"
    else
        local dirs=(
            "$HOME/files"
            "$HOME/files/inbox"
            "$HOME/files/projects"
            "$HOME/files/resources"
            "$HOME/files/archive"
            "$HOME/files/resources/code"
            "$HOME/files/resources/code/scripts"
            "$HOME/media"
        )

        mapfile -t files < <(find -L "${dirs[@]}" -mindepth 1 -maxdepth 1 -type d)

        # Remove '/home/$USER' prefix during fzf
        files=("${files[@]#"$HOME"/}")

        # Add as final option (so it will be highlighted by default)
        files+=('files')

        local fzf_binds=(
            --bind "enter:print($fzf_enter_key_default_value)+accept"
            --bind "ctrl-t:print(window)+accept"
            --bind "ctrl-v:print(pane)+accept"
            --bind "ctrl-o:print(current)+accept"
        )
        local fzf_full_response
        fzf_full_response="$(printf -- '%s\n' "${files[@]}" | sort \
            | fzf \
                --header "ENTER:session  C-t:window  C-v:pane  C-o:current" \
                "${fzf_binds[@]}" \
                --preview="ls -Cp --color=always -- $HOME/{}" --preview-window=up,1%
        )"

        [[ -z "$fzf_full_response" ]] && return 0

        # Extract fzf returned response (due to the extra keybind stuff):
        # Line 1 is from fzf's bind key 'print()'.
        # Line 2 is regular fzf selection response.
        local fzf_keybind_response
        fzf_keybind_response="$(echo "$fzf_full_response" | head -n1)"
        local fzf_selection
        fzf_selection="$(echo "$fzf_full_response" | tail -n+2)"


        # Re-add '/home/$USER' prefix
        case "$fzf_selection" in
            "~") fzf_selection="$HOME" ;;
            "") return 1 ;;
            *) fzf_selection="$HOME/${fzf_selection}" ;;
        esac

        selected_directory="$(realpath -- "$fzf_selection")"
    fi

    [[ -z "$selected_directory" ]] && return 1

    if [[ "$fzf_keybind_response" == "current" ]]; then
        cd "$selected_directory" || return 1
    else
        local flag
        flag="-${fzf_keybind_response:0:1}"  # Prefix first character with hyphen, e.g. '-s'

        $TMUX_DIRECTORY_OPENER_SCRIPT "$flag" "$selected_directory"
    fi
}


# We want to be able to source this script
main "$@"
