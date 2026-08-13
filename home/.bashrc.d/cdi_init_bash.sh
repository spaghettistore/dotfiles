cdi() {
    local script="change_directory_interactively.py"
    local response

    response="$("$script" "$@")"
    [[ -z "$response" ]] && return 0

    # Only attempt to cd if the python script outputs one line that starts with 'cd'
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
