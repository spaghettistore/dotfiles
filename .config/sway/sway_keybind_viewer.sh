#!/bin/bash

show_help() {
    echo "USAGE
  $0 [-h] [-m MODE]

OPTIONS
  -h
    show this help message and exit
  -m MODE
    manual switch for changing display mode, expects: fzf, rofi (default: fzf)"
}


main() {
    local default_mode="fzf"
    local mode="$default_mode"
    local sway_config_file="$HOME/.config/sway/config"

    local opt
    while getopts "hm:" opt; do
        case "$opt" in
            "h") show_help; exit 0 ;;
            "m")
                case "$OPTARG" in
                    "fzf" | "rofi") mode="$OPTARG" ;;
                    *) echo "$0: '$OPTARG': Invalid mode, expects: fzf, rofi" >&2 ; exit 1 ;;
                esac
                ;;
            *) echo "See '$0 -h' for more information." >&2 ; exit 1 ;;
        esac
    done
    shift $((OPTIND - 1))


    if ! [[ -f "$sway_config_file" ]]; then
        echo "$0: '$sway_config_file': No such file" >&2
        exit 1
    fi

    # Get all keybinds from sway config (assumes all keybinds start at
    # beginning of line, so it should skip commented out lines, and indented
    # keybinds that are used within a sway mode)
    local data
    mapfile -t data < <(
        grep "^bindsym " "$sway_config_file" | sed "s/^bindsym //"
    )

    # Make a string that splits keybind and action with a separator that will
    # be used by the column command
    local separator="£"  # This can't be a character that is used within sway config
    local unformatted_output line key action
    unformatted_output="$(for line in "${data[@]}"; do
        key="$(echo "$line" | awk '{print $1}')"
        action="$(echo "$line" | awk '{$1=""; $0=substr($0,2)}1')"
        printf -- '%s\n' "$key $separator $action"
    done)"

    # Use column to format whitespace and add a '|' separator
    local column_flags=(
        --table
        --separator "$separator"
        --output-separator "|"
    )
    local clean_output
    clean_output="$(echo "$unformatted_output" | column "${column_flags[@]}")"

    # Fuzzy find will handle truncating long lines, while still printing the
    # whole line on selection

    case "$mode" in
        "fzf") echo "$clean_output" | fzf ;;
        "rofi") echo "$clean_output" | rofi -matching "fuzzy" -p "sway keybinds" -dmenu -i ;;
        *) echo "$0: '$mode': Invalid mode, expects: fzf, rofi" >&2
    esac
}


[[ "${BASH_SOURCE[0]}" == "$0" ]] && main "$@"
