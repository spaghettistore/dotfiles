#!/bin/bash

# Dependencies: fzf, rofi

SCRIPT_NAME="$(basename -- "$0")"
DEFAULT_MODE="fzf"
readonly DEFAULT_MODE
mode="$DEFAULT_MODE"
declare -A ICONS=(
    [suspend]=""
    [poweroff]=""
    [reboot]=""
    [logout]=""
    [lock]=""
)
readonly ICONS

show_help() {
    echo "USAGE: $SCRIPT_NAME [-h] [-m MODE] [OPTION]

ARGUMENTS
  OPTION
    suspend, poweroff, reboot, logout, lock

FLAGS
  -h
    show this help message and exit
  -m MODE
    Set displaly mode to either 'fzf' or 'rofi' (default=$DEFAULT_MODE).
    This flag will be ignored if an argument is used."
}


get_confirmation() {
    local prompt="$1"
    declare -a options=(
        "yes"
        "no"
    )
    local response
    case "$mode" in
        "rofi")
            response="$(printf -- '%s\n' "${options[@]}" \
                | rofi -matching "fuzzy" -p "$prompt" -dmenu -i)"
            ;;
        "fzf")
            response="$(printf -- '%s\n' "${options[@]}" \
                | fzf --prompt "$prompt ")"
            ;;
        *)
            echo "'$mode': Invalid mode" >&2
            exit 1
            ;;
    esac

    if [[ "$response" == "yes" ]]; then
        return 0
    else
        return 1
    fi
}


main() {
    local opt
    while getopts ":hm:" opt; do
        case "$opt" in
            "h") show_help ; exit 0 ;;
            "m") mode="$OPTARG" ;;
            *) echo "$SCRIPT_NAME: Invalid option -- '${OPTARG}'" >&2 ; exit 1 ;;
        esac
    done
    shift $((OPTIND - 1))

    local selected_option
    if [[ $# -eq 0 ]]; then
        declare -a options=(
            "${ICONS["suspend"]}  suspend"
            "${ICONS["poweroff"]}  poweroff"
            "${ICONS["reboot"]}  reboot"
            "${ICONS["logout"]}  logout"
            "${ICONS["lock"]}  lock"
        )
        local prompt="Select power option"
        case "$mode" in
            "rofi")
                selected_option="$(printf -- '%s\n' "${options[@]}" \
                    | rofi -matching "fuzzy" -p "$prompt" -dmenu -i)"
                ;;
            "fzf")
                selected_option="$(printf -- '%s\n' "${options[@]}" \
                    | fzf --prompt "$prompt ")"
                ;;
            *)
                echo "'$mode': Invalid mode. See '$SCRIPT_NAME -h' for more information." >&2
                exit 1
                ;;
    esac
    else
        selected_option="$1"
    fi

    # Clear icons if used by rofi, and make get_confirmation easier
    case "$selected_option" in
        "${ICONS["suspend"]}  suspend" | "suspend")
            selected_option="suspend"
            ;;
        "${ICONS["poweroff"]}  poweroff" | "poweroff")
            selected_option="poweroff"
            ;;
        "${ICONS["reboot"]}  reboot" | "reboot")
            selected_option="reboot"
            ;;
        "${ICONS["logout"]}  logout" | "logout")
            selected_option="logout"
            ;;
        "${ICONS["lock"]}  lock" | "lock")
            selected_option="lock"
            ;;
        *)
            exit 1
            ;;
    esac

    if ! get_confirmation "Would you like to ${selected_option}?"; then
        exit 1
    fi

    case "$selected_option" in
        "poweroff")
            systemctl poweroff
            ;;
        "reboot")
            systemctl reboot
            ;;
        "suspend")
            systemctl suspend
            swaylock
            ;;
        "logout")
            swaymsg exit
            ;;
        "lock")
            swaylock
            ;;
        *)
            exit 1
            ;;
    esac
}


main "$@"
