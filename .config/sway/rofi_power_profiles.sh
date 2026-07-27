#!/bin/bash

SCRIPT_NAME="$(basename -- "$0")"
readonly SCRIPT_NAME
DEFAULT_MODE="fzf"
readonly DEFAULT_MODE
declare -A ICONS=([performance]="" [balanced]="" [power-saver]="")
readonly ICONS

show_help() {
    echo "USAGE: $SCRIPT_NAME [-h] [-m <fzf|rofi>] [PROFILE]

ARGUMENTS
  PROFILE
    Set powerprofilesctl to PROFILE.
    Available profiles: performance, balanced, power-saver.

FLAGS
  -h
    Show this help message and exit.
  -m MODE
    Set displaly mode to either 'fzf' or 'rofi' (default=$DEFAULT_MODE).
    This flag will be ignored if an argument is used."
}


main() {
    local mode="$DEFAULT_MODE"

    local opt
    while getopts ":hm:" opt; do
        case "$opt" in
            "h") show_help ; exit 0 ;;
            "m") mode="$OPTARG" ;;
            *) echo "$SCRIPT_NAME: Invalid option -- '${OPTARG}'" >&2 ; exit 1 ;;
        esac
    done
    shift $((OPTIND - 1))

    local selected_profile
    if [[ $# -eq 0 ]]; then
        declare -a options=(
            "${ICONS["performance"]}  performance"
            "${ICONS["balanced"]}  balanced"
            "${ICONS["power-saver"]}  power-saver"
        )
        local current_profile
        current_profile="$(powerprofilesctl | grep "^\*" | tr -d "* :")"
        local capacity
        capacity="$(cat /sys/class/power_supply/BAT0/capacity)"
        local charging_status
        charging_status="$(cat /sys/class/power_supply/BAT0/status)"
        local prompt="${capacity}% ${charging_status} (${current_profile})"

        case "$mode" in
            "fzf")
                selected_profile="$(printf -- '%s\n' "${options[@]}" \
                    | fzf --prompt "$prompt ")"
                ;;
            "rofi")
                selected_profile="$(printf -- '%s\n' "${options[@]}" \
                    | rofi -matching "fuzzy" -p "$prompt" -dmenu -i)"
                ;;
            *)
                echo "'$mode': Invalid mode. See '$SCRIPT_NAME -h' for more information" >&2
                exit 1
                ;;
        esac
    else
        selected_profile="$1"
    fi

    local profile
    case "$selected_profile" in
        "${ICONS["performance"]}  performance" | "performance")
            profile="performance"
            ;;
        "${ICONS["balanced"]}  balanced" | "balanced")
            profile="balanced"
            ;;
        "${ICONS["power-saver"]}  power-saver" | "power-saver")
            profile="power-saver"
            ;;
        "") exit 0 ;;
        *)
            echo "'$selected_profile': Invalid profile. See '$SCRIPT_NAME -h' for more information" >&2
            exit 1
            ;;
    esac

    powerprofilesctl set "$profile"
    case "$mode" in
        "fzf")
            echo "Power Profile: $profile"
            ;;
        "rofi")
            notify-send \
                "Power Profile" "$profile" \
                --urgency=low \
                --app-name="current_power_profile_notification" \
                --hint=string:x-canonical-private-synchronous:"current_power_profile_notification"
            ;;
        *)
            echo "'$mode': Invalid mode. See '$SCRIPT_NAME -h' for more information" >&2
            exit 1
            ;;
    esac

}

main "$@"
