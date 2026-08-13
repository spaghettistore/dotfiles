ofi() {
    local script="open_file_interactively.py"
    local response

    response="$("$script" "$@")"
    [[ -z "$response" ]] && return 0

    # We expect cdi to output a single line containing 'COMMAND SELECTION' e.g. 'cd ~'
    local cdi_command
    cdi_command="$(echo "$response" | awk '{print $1}')"
    local selection
    selection="$(echo "$response" | awk '{$1=""; $0=substr($0,2)}1')"  # Print all but $1

    case "$cdi_command" in
        "cd") cd "$selection" || return 1 ;;
        "edit") $EDITOR "$selection" ;;
        "xdg-open") xdg-open "$selection" ;;
        "all")
            if [[ -f "$selection" ]]; then
                xdg-open "$selection"
            elif [[ -d "$selection" ]]; then
                cd "$selection" || return 1
            else
                return 1
            fi
            ;;
        *) echo "$response" ;;
    esac
}


alias cdi="ofi -d"
alias edi="ofi -f"
alias xoi="ofi -x"
