cdi() {
    local script="change_directory_interactively.py"
    local opt
    while getopts "h" opt; do
        case "$opt" in
            "h") "$script" -h ; return 0 ;;
            *) echo "See 'cdi -h' for more information." >&2 ; return 1 ;;
        esac
    done
    shift $((OPTIND - 1))

    local response
    response="$("$script" "$@")"
    [[ -z "$response" ]] && return 0

    # Only attempt to cd if the python script outputs one line: 'cd DIR'
    if [[ "$(echo "$response" | awk '{print $1}')" == "cd" ]]; then
        local dir
        # Print all but $1
        dir="$(echo "$response" | awk '{$1=""; $0=substr($0,2)}1')"
        cd "$dir" || return 1
    else
        # Write stdout and/or stderr
        echo "$response"
    fi
}
