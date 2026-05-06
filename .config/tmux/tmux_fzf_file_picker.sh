#!/bin/bash

# Tmux fzf file picker script
#
# Package Dependencies: tmux, fzf, nvim/vim/vi
# Optional Dependencies: batcat, wl-copy

SCRIPT_CONFIG_DIRECTORY="$HOME/.config/tmux_fzf_file_picker"
readonly SCRIPT_CONFIG_DIRECTORY
FAVOURITES_FILE="$SCRIPT_CONFIG_DIRECTORY/favourites.txt"
readonly FAVOURITES_FILE
HISTORY_FILE="$SCRIPT_CONFIG_DIRECTORY/history.txt"
readonly HISTORY_FILE
HISTORY_MAX_LINE_SIZE=1000
readonly HISTORY_MAX_LINE_SIZE
DESIRED_HOME_DIRECTORIES=(
    "$HOME/inbox"
    "$HOME/projects"
    "$HOME/resources"
)
readonly DESIRED_HOME_DIRECTORIES

SCRIPT_NAME="$(basename -- "$0")"
readonly SCRIPT_NAME
SCRIPT_PATH="$(realpath -- "$0")"
readonly SCRIPT_PATH

# Globals:
#   SCRIPT_NAME HISTORY_FILE FAVOURITES_FILE
show_help() {
    echo "NAME
  ${SCRIPT_NAME} - Tmux fzf file picker script

USAGE:
  ${SCRIPT_NAME} [-h] [-s <PATH>] [-x <PATH>] [-m] [-l] [-f] [-r] [-o <window|pane|current|goto>] [PATH]

DESCRIPTION:
  A fzf find files script that can open the selected file in a new tmux window,
  a new auto tiled tmux pane, or the current pane.
  Can also go to the directory of a file in a new window or pane.

  If a window exists that has the same name as the selected file, and the
  window is inside of a session with the dirname of the selected file, focus
  the existing window instead (when using <window|pane|current> options).

  Recently opened files are saved to the history file. There is a flag,
  keybind, and display-menu option to open the last opened file, or search the
  history file.

  Files can be saved to the favourites file, with a flag, keybind and
  display-menu option to search the favourites file.

  Recently opened files are appened to the top of this file:
    $HISTORY_FILE
  Favourited files are appended to the bottom of this file:
    $FAVOURITES_FILE

POSITIONAL ARGUMENTS:
  [PATH]
    Can optionally provide a path:
    - If any of the flags within 'sxmlfr' are used (everything except '-o'),
      the path will be ignored.
    - If no path is provided, use the current working directory.
    - If path is a file, skip fzf and open it.
    - If path is a directory, start the file search from that directory.

OPTIONS:
  -o=<window|pane|current|goto>
    window
      Open selected file with editor in a tmux new window.
    pane
      Open selected file with editor in a tmux new pane that is auto tiled.
    current
      Open selected file in the current terminal that this script was ran from.
    goto
      Open a new window in the directory of the file.
  -m
    Open a tmux display-menu containing specific directories to start search
    from. Provided path will be ignored.
    Will open in new window by default.
    '-o <window|pane|current|goto>' option will be respected as the default
    open option.
    If this flag is used, the '-l', '-f', and '-r' flags will be ignored, and
    menu result will be used instead.
    The '-s' and '-x' flags take priority over this flag.
  -l
    Open last opened file.
    Using this flag will mean if a path is provied, that will be ignored, and
    replaced with the path to the last opened file.
    Will open in new window by default.
    If '-o pane' was used, the 'window' and 'pane' options will be respected.
    If '-s', '-x', or '-m' flag was used, this flag will be ignored.
    If this flag is used, the '-r', and '-f' flags will be ignored.
  -f
    Search a list of favourited files.
    '-o <window|pane|current|goto>' option will be respected as the default
    open option.
    If '-s', '-x', '-m', or '-l' flag was used, this flag will be ignored.
    This will take priority over '-r'.
  -r
    Search a list of files from history, sorted by most recently opened.
    If '-s', '-x', '-m', or '-l' flag was used, this flag will be ignored.
  -s <PATH>
    Save file currently highlighted file to the favourites file.
    Using this flag will ignore all other flags.
    Only one of either '-s' or '-x' can be used, it is first come first serve.
  -x <PATH>
    Remove file path from both history and favourites files and exit.
    If this flag is used, all other flags will be ignored.
    Using this flag will ignore all other flags.
    Only one of either '-s' or '-x' can be used, it is first come first serve.
  -h
    Show this help message and exit.

FZF KEYBINDS:
  Enter
    The default action of the enter key will be defined based on what
    argument was given to the script (window, pane, current, goto).
  ctrl+v
    Open file in a new pane, as if the flag '-o pane' was given.
  ctrl+t
    Open file in a new window, as if the flag '-o window' was given.
  ctrl+o
    Open file in current pane, as if the flag '-o current' was given.
  ctrl+g
    Open a new window in the directory of the file.
    If '-o pane' was used, this keybind will respect that and open in a new
    pane.
  ctrl+l
    Open last opened file.
    If '-o pane' was used, this keybind will respect that and open in a new
    pane.
  ctrl+f
    Search a list of favourited files.
  ctrl+r
    Search a list of files from history, sorted by most recently opened.
  ctrl+s
    Save file currently highlighted file to the favourites file (fzf --multi
    selection does not work).
  ctrl+x
    Remove file path from both history and favourites files (fzf --multi
    selection does not work).
  ctrl+y
    Copy the currently highlighted file (fzf --multi selection does not work).
  ctrl+i
    Toggle preview."
}


# Globals:
#   SCRIPT_NAME
show_usage() {
    echo "USAGE: ${SCRIPT_NAME} [-h] [-s <PATH>] [-x <PATH>] [-m] [-l] [-f] [-r] [-o <window|pane|current|goto>] [PATH]
See '${SCRIPT_NAME} -h' for help."
}


# Outputs message to STDERR and STDOUT.
#
# Globals:
#   SCRIPT_NAME
# Arguments:
#   1: Error message to be printed.
# Outputs:
#   Error message to STDERR and STDOUT.
echo_error() {
    echo "${SCRIPT_NAME}: $*" >&2
}


# Return the name of the editor to use, prioritising $EDITOR>nvim>vim>vi.
#
# Globals:
#   EDITOR
get_editor() {
    if command -v "$EDITOR"; then
        echo "$EDITOR"
    elif command -v nvim; then
        echo "nvim"
    elif command -v vim; then
        echo "vim"
    else
        echo "vi"
    fi
}


# Return the fzf preview command for viewing content of files, to be used with:
# fzf --preview="$(get_fzf_file_preview_command)"
get_fzf_file_preview_command() {
    if command -v batcat; then
        echo "batcat -n --theme=gruvbox-dark --color=always -- {}"
    else
        echo "cat -- {}"
    fi
}


# If a window exists that has the same name as the selected file, and the
# window is inside of a session with the dirname of the selected file, focus
# the existing window instead.
#
# Globals:
#   TMUX
# Arguments:
#   1: File path
# Returns:
#   0 if successfully attached, 1 if not.
tmux_attach_to_existing() {
    local file="$1"
    local file_realpath file_basename clean_window_name dir_realpath
    local dir_basename clean_session_name target

    file_realpath="$(realpath -- "$file")"
    file_basename=$(basename -- "$file_realpath")
    clean_window_name=$(echo "$file_basename" | tr "./" "__")
    dir_realpath="$(dirname -- "$file_realpath")"
    dir_basename="$(basename -- "$dir_realpath")"
    clean_session_name="$(echo "$dir_basename" | tr "./" "__")"
    target="${clean_session_name}:${clean_window_name}"

    # If exact target exists, attach to that
    if tmux has-session -t="$target" 2>/dev/null; then
        if [[ "$TMUX" ]]; then
            tmux switch-client -t "$target"
        else
            tmux a -t "$target"
        fi
        return 0
    fi

    return 1
}


# Open selected file with editor in a tmux new window.
#
# Globals:
#   TMUX EDITOR
# Arguments:
#   1: File path
tmux_open_file_in_new_window() {
    local file="$1"
    local file_realpath file_basename clean_window_name dir_realpath
    local dir_basename clean_session_name target

    file_realpath="$(realpath -- "$file")"
    file_basename=$(basename -- "$file_realpath")
    clean_window_name=$(echo "$file_basename" | tr "./" "__")
    dir_realpath="$(dirname -- "$file_realpath")"
    dir_basename="$(basename -- "$dir_realpath")"
    clean_session_name="$(echo "$dir_basename" | tr "./" "__")"
    target="${clean_session_name}:${clean_window_name}"

    if [[ "$TMUX" ]]; then
        session_name=$(tmux display-message -p "#S")
        target="$session_name:$clean_window_name"

        # If target does not exist within current session, create it
        if ! tmux has-session -t "$target" 2>/dev/null; then
            tmux neww -dn "$clean_window_name" "$EDITOR" "$file"
        fi

        # Attach to existing (or newly created)
        tmux select-window -t "$clean_window_name"
    else
        "$EDITOR" "$file"
        # This commented out code is for if you want to make a new session and
        # window for the file if this script was started from outside tmux.
        #tmux new-session -s "$clean_session_name" -c "$dir_realpath" tmux neww -dn "$clean_window_name" "$EDITOR" "$file"
    fi
}


# Open selected file with editor in a tmux new pane that is auto tiled.
#
# Globals:
#   TMUX EDITOR
# Arguments:
#   1: File path
tmux_open_file_in_new_pane() {
    local file="$1"
    local number_of_panes current_pane_index final_pane_index

    if [[ "$TMUX" ]]; then
        number_of_panes="$(tmux list-panes | wc --lines)"

        if (( number_of_panes <= 1 )); then
            tmux split-pane -h "$EDITOR" "$file"
        else
            current_pane_index="$(tmux display -p "#{pane_index}")"

            # Select (focus) final pane so that the newly created pane is
            # created from that position to allow consistent auto tiling.
            # Panes start at index 0 so we -1.
            final_pane_index="$(( number_of_panes - 1))"
            tmux select-pane -t "$final_pane_index"

            if (( $(( number_of_panes %2 )) == 0 )); then
                tmux split-pane -v "$EDITOR" "$file"
            else
                tmux split-pane -h "$EDITOR" "$file"
            fi

            # Return to original pane, and then back to newly created pane.
            # We do this to keep tmux's last-pane the same (as otherwise the
            # last-pane will be replaced when temporarily swapping to the final
            # pane).
            tmux select-pane -t "$current_pane_index"
            tmux select-pane -t "$number_of_panes"  # We can reuse this variable, as last time we needed to -1 and we have just added another
        fi
    else
        "$EDITOR" "$file"
    fi
}


# Open a tmux new pane that is auto tiled.
#
# Globals:
#   TMUX
# Arguments:
#   1: optional directory path to open pane in
tmux_auto_tile_new_pane() {
    local directory="$1"
    local number_of_panes current_pane_index final_pane_index directory direction

    [[ "$TMUX" ]] || exit 1
    number_of_panes="$(tmux list-panes | wc --lines)"

    if (( number_of_panes <= 1 )); then
        if [[ -d "$directory" ]]; then
            tmux split-pane -h -c "$directory"
        else
            tmux split-pane -h
        fi
    else
        current_pane_index="$(tmux display -p "#{pane_index}")"

        # Select final pane to auto tile (panes start at index 0 so we -1)
        final_pane_index="$(( number_of_panes - 1))"
        tmux select-pane -t "$final_pane_index"

        # Create new pane from final pane so the way it spawns is consistent
        if (( $(( number_of_panes %2 )) == 0 )); then
            direction="v"
        else
            direction="h"
        fi

        if [[ -d "$directory" ]]; then
            tmux split-pane "-$direction" -c "$directory"
        else
            tmux split-pane "-$direction"
        fi

        # Return to original pane, and then back to newly created pane.
        # We do this to keep tmux's last pane the same (as otherwise the last
        # pane will be replaced when temporarily swapping to the final pane)
        tmux select-pane -t "$current_pane_index"
        tmux select-pane -t "$number_of_panes"  # As we have just created another pane, we can reuse this variable, as last time we needed to -1 and we have just added another
    fi
}


# Open a new tmux window or pane in the directory of the file.
#
# Globals:
#   TMUX
# Arguments:
#   1: path to file or directory
#   2: optional argument for what to open in (window, pane)
#      default=window
goto_file() {
    local path="$1"
    local open_in="${2:-window}"
    local real_path
    real_path="$(realpath -- "$path")"
    local directory

    if [[ -f "$real_path" ]]; then
        directory="$(dirname -- "$real_path")"
    elif [[ -d "$real_path" ]]; then
        directory="$real_path"
    else
        echo_error "'$path': Is not a file or directory"
        show_usage
        exit 1
    fi

    if [[ "$TMUX" ]]; then
        case "$open_in" in
            "window")
                local dir_basename clean_window_name
                dir_basename=$(basename -- "$directory")
                clean_window_name=$(echo "$dir_basename" | tr "./" "__")
                tmux neww -c "$directory" -n "$clean_window_name"
                ;;
            "pane")
                tmux_auto_tile_new_pane "$directory"
                ;;
            *)
                echo_error "'$open_in': Invalid goto open option, expects: window or pane"
                show_usage
                exit 1
        esac
    fi
}


# Globals:
#   SCRIPT_PATH
# Arguments:
#   1: optional argument for what to open in (window, pane, current, goto)
#      default=window
tmux_display_menu() {
    local open_in="${1:-window}"
    local command title

    case "$open_in" in
        "window" | "pane" | "current" |"goto") title="$open_in" ;;
        *)
            echo_error "'$open_in': Invalid menu open option, expects: window, pane, current or goto"
            show_usage
            exit 1
            ;;
    esac
    command="$SCRIPT_PATH -o $open_in"

    tmux display-menu -T "Find Files ($title)" \
        "Current Directory" "." "display-popup -w 80% -h 80% -E \"$command\"" \
        "Last" l "display-popup -w 80% -h 80% -E \"$SCRIPT_PATH -l -o $open_in\"" \
        "Recent" R "display-popup -w 80% -h 80% -E \"$SCRIPT_PATH -r -o $open_in\"" \
        "Favourites" f "display-popup -w 80% -h 80% -E \"$SCRIPT_PATH -f -o $open_in\"" \
        "Home" h "display-popup -w 80% -h 80% -E \"$command ~\"" \
        "Inbox" i "display-popup -w 80% -h 80% -E \"$command ~/inbox\"" \
        "Projects" p "display-popup -w 80% -h 80% -E \"$command ~/projects\"" \
        "Resources" r "display-popup -w 80% -h 80% -E \"$command ~/resources\"" \
        "Code" c "display-popup -w 80% -h 80% -E \"$command ~/resources/code\"" \
        "Dotfiles" d "display-popup -w 80% -h 80% -E \"$command ~/resources/dotfiles\""
}


# Append line to the top of the HISTORY_FILE
#
# Globals:
#   SCRIPT_CONFIG_DIRECTORY HISTORY_FILE
# Arguments:
#   1: file path to append to history
append_file_to_history() {
    local file_to_add="$1"
    local updated_file
    mkdir -p "$SCRIPT_CONFIG_DIRECTORY"
    # Append to top of file so we can remove duplicates without sorting later
    updated_file="$({ realpath -- "$file_to_add"; cat -- "$HISTORY_FILE"; })"
    echo "$updated_file" >"$HISTORY_FILE"
}


# Append line to the bottom of the FAVOURITES_FILE
#
# Globals:
#   SCRIPT_CONFIG_DIRECTORY FAVOURITES_FILE
# Arguments:
#   1: file path to append to favourites
save_file_to_favourites() {
    local file_to_add="$1"
    mkdir -p "$SCRIPT_CONFIG_DIRECTORY"
    echo "$file_to_add" >>"$FAVOURITES_FILE"
}


# Remove duplicate lines without sorting the file (as 'uniq' only removes
# dupes that are adjacent and requires sorting).
# This will keep the duplicate line closest to the top, which is why we
# append new entries to the top, to keep that as the most recent
# We pipe into head at the end to limit the file line count.
#
# Globals:
#   HISTORY_FILE HISTORY_MAX_LINE_SIZE
remove_duplicate_lines_from_history() {
    local duplicateless_history_file
    duplicateless_history_file="$(cat -n -- "$HISTORY_FILE" \
        | sort -uk2 \
        | sort -n \
        | cut -f2 \
        | head -n "$HISTORY_MAX_LINE_SIZE")"
    echo "$duplicateless_history_file" >"$HISTORY_FILE"
}


# Remove non-existent files from history. Also remove directories.
#
# Globals:
#   HISTORY_FILE
remove_non_existent_files_from_history_and_reduce_max_size() {
    local file_content_without_non_existent_files line
    file_content_without_non_existent_files="$(
        while read -r line; do
            [[ -f "$line" ]] && echo "$line"
        done <"$HISTORY_FILE"
    )"
    echo "$file_content_without_non_existent_files" >"$HISTORY_FILE"
}


# Globals:
#   HISTORY_FILE FAVOURITES_FILE
# Arguments:
#   1: file path to remove from history and favourites file.
remove_file_from_history_and_favourites() {
    local path="$1"
    local real_path
    real_path="$(realpath -- "$path")"

    local history_without_removed_file favourites_without_removed_file
    history_without_removed_file="$(grep -v ^"$real_path"$ "$HISTORY_FILE")"
    favourites_without_removed_file="$(grep -v ^"$real_path"$ "$FAVOURITES_FILE")"

    echo "$history_without_removed_file" >"$HISTORY_FILE"
    echo "$favourites_without_removed_file" >"$FAVOURITES_FILE"
}


main() {
    # Set default options, assuming nothing will be set by flags
    local open_in="window"
    local fzf_enter_key_default_value="window"
    local default_goto_open_in="window"
    local use_menu="False"
    local jump_last="False"
    local show_recent="False"
    local show_favourites="False"

    local opt
    while getopts ":ho:mlfrs:x:" opt; do
        case $opt in
            "h")
                show_help
                exit 0
                ;;
            "o")
                case "$OPTARG" in
                    "window" | "pane") default_goto_open_in="$OPTARG" ;;
                    "current" | "goto") default_goto_open_in="window" ;;
                    *)
                        echo_error "'$OPTARG': Invalid optarg for '-o', expects: window, pane, current or goto"
                        show_usage
                        exit 1
                        ;;
                esac
                open_in="$OPTARG"
                fzf_enter_key_default_value="$OPTARG"
                ;;
            "m") use_menu="True" ;;
            "l") jump_last="True" ;;
            "f") show_favourites="True" ;;
            "r") show_recent="True" ;;
            "s")
                if [[ -e "$OPTARG" ]]; then
                    save_file_to_favourites "$(realpath -- "$OPTARG")"
                    exit 0
                else
                    echo_error "'$OPTARG': Invalid optarg for '-s', Path does not exist."
                    show_usage
                    exit 1
                fi
                ;;
            "x")
                if [[ -n "$OPTARG" ]]; then
                    remove_file_from_history_and_favourites "$OPTARG"
                    exit 0
                else
                    echo_error "'$OPTARG': Empty optarg, '-x' expects a file path."
                    show_usage
                    exit 1
                fi
                ;;
            *)
                echo_error "'-${OPTARG}': Invalid flag usage"
                show_usage
                exit 1
                ;;
        esac
    done
    shift $((OPTIND - 1))

    EDITOR="$(get_editor)"

    if [[ "$use_menu" == "True" ]]; then
        tmux_display_menu "$open_in"
        exit 0
    fi

    local path
    if [[ "$jump_last" == "True" ]]; then
        path="$(head -n1 -- "$HISTORY_FILE")"
        if [[ -z "$path" ]]; then
            echo_error "'$HISTORY_FILE' is empty or does not exist"
            exit 1
        fi
    elif [[ "$show_recent" == "True" ]] || [[ "$show_favourites" == "True" ]]; then
        path=""
    else
        path="$1"
    fi

    local selected_file
    if [[ "$path" ]]; then
        # If provided argument is a file, use that and skip fzf
        # If provided argument is a directory, open fzf using that directory
        if [[ -f "$path" ]]; then
            selected_file="$path"
        elif [[ -d "$path" ]]; then
            cd "$path" || exit 1
        else
            if [[ -e "$path" ]]; then
                echo_error "'$path': Invalid file."
            else
                echo_error "'$path': File does not exist."
            fi
            show_usage
            exit 1
        fi
    fi

    if [[ -z "$selected_file" ]]; then
        local fzf_input_stream fzf_strip_home_delimiter fzf_prompt
        if [[ "$show_favourites" == "True" ]]; then
            fzf_input_stream="$(cat -- "$FAVOURITES_FILE")"
            if [[ -z "$fzf_input_stream" ]]; then
                echo_error "'$FAVOURITES_FILE' does not exist or is empty"
                exit 1
            fi
            fzf_prompt="(f) > "
        elif [[ "$show_recent" == "True" ]]; then
            fzf_input_stream="$(cat -- "$HISTORY_FILE")"
            if [[ -z "$fzf_input_stream" ]]; then
                echo_error "'$HISTORY_FILE' does not exist or is empty"
                exit 1
            fi
            fzf_prompt="(r) > "
        else
            local files
            fzf_prompt="(${open_in:0:1}) > "  # Use first character of open method
            
            if [[ "$(pwd)" == "$HOME" ]]; then
                # If in ~ only search specific directories to reduce clutter
                files="$({ find -L "${DESIRED_HOME_DIRECTORIES[@]}" -type f
                    find -L "$HOME" -maxdepth 1 -type f
                })"

                # Strip the '/home/$USER/' prefix for cleaner fzf results from ~
                fzf_strip_home_delimiter=( "--delimiter" "/" "--with-nth" "4.." )
            else
                files="$(find -L ./ -type f)"
            fi

            # Filter out non-text files and sort
            fzf_input_stream="$(printf "%s\n" "${files[@]}" \
                | grep -v \
                -e "/\.steam/" \
                -e "/GIMP/2\.10/" \
                -e "/\.config/libreoffice/" \
                -e "\.mp3$" \
                -e "\.wma$" \
                -e "\.m4a$" \
                -e "\.png$" \
                -e "\.jpg$" \
                -e "\.jpeg$" \
                -e "\.svg$" \
                -e "\.kra$" \
                -e "\.pdf$" \
                -e "\.epub$" \
                -e "\.djvu$" \
                -e "\.docx$" \
                -e "\.mp4$" \
                -e "\.wav$" \
                -e "\.mmpz" \
                -e "\.tdb$" \
                -e "\.zip$" \
                -e "\.7z$" \
                -e "\.bin$" \
                -e "\.cue$" \
                -e "\.chd$" \
                -e "\.iso$" \
                -e "\.gba$" \
                -e "\.nes$" \
                -e "\.nds$" \
                -e "\.srm$" \
                -e "\.tar$" \
                -e "\.nvmem$" \
                -e "\.eeprom$" \
                -e "\.ps2$" \
                -e "/\.git/" \
                -e "/__pycache__/" \
                -e "a\.out" \
                -e "\.gitignore" \
                | sort
            )"
        fi
        local fzf_full_response
        # Optional fzf header to use:
        #--header "C-t window C-v pane C-o current C-g goto C-l last C-f favs C-r recent C-i toggle-preview C-y yank C-s save C-x rm" \
        fzf_full_response="$(echo "$fzf_input_stream" \
            | fzf \
                --prompt="$fzf_prompt" \
                --preview="$(get_fzf_file_preview_command)" \
                --bind "enter:print($fzf_enter_key_default_value)+accept,ctrl-t:print(window)+accept,ctrl-v:print(pane)+accept,ctrl-o:print(current)+accept,ctrl-g:print(goto)+accept,ctrl-l:print(last)+accept,ctrl-f:print(favourites)+accept,ctrl-r:print(recent)+accept,ctrl-y:execute(wl-copy {}),ctrl-s:execute($SCRIPT_PATH -s {}),ctrl-x:execute($SCRIPT_PATH -x {}),ctrl-i:toggle-preview" \
                "${fzf_strip_home_delimiter[@]}"
        )"

        # Extract fzf returned response (due to the extra keybind stuff):
        # Line 1 is from fzf's bind key 'print()' and is set up to be either:
        # (window, pane, current, goto, last, favourites, recent) depending on
        # what keybind was pressed.
        # Line 2 is regular fzf selection response.
        local fzf_keybind_response fzf_selection
        fzf_keybind_response="$(echo "$fzf_full_response" | head -n1)"
        fzf_selection="$(echo "$fzf_full_response" | tail -n+2)"

        if [[ "$fzf_keybind_response" == "last" ]]; then
            selected_file="$(head -n1 -- "$HISTORY_FILE")"
            if [[ -z "$selected_file" ]]; then
                echo_error "'$HISTORY_FILE' is empty or does not exist"
                exit 1
            fi
        elif [[ "$fzf_keybind_response" == "favourites" ]]; then
            "$SCRIPT_PATH" -f -o "$open_in"
            exit 0
        elif [[ "$fzf_keybind_response" == "recent" ]]; then
            "$SCRIPT_PATH" -r -o "$open_in"
            exit 0
        else
            # Override variable set by external flags if keybind is used
            open_in="$fzf_keybind_response"

            selected_file="$fzf_selection"
            [[ -z "$selected_file" ]] && exit 1
        fi
    fi

    append_file_to_history "$selected_file"

    case "$open_in" in
        "window")
            tmux_attach_to_existing "$selected_file" && exit 0
            tmux_open_file_in_new_window "$selected_file"
            ;;
        "pane")
            tmux_attach_to_existing "$selected_file" && exit 0
            tmux_open_file_in_new_pane "$selected_file"
            ;;
        "current")
            tmux_attach_to_existing "$selected_file" && exit 0
            "$EDITOR" "$selected_file"
            ;;
        "goto")
            goto_file "$selected_file" "$default_goto_open_in"
            ;;
        *)
            echo_error "'$open_in': Invalid open option, expects: window, pane, current or goto"
            show_usage
            exit 1
            ;;
    esac

    remove_duplicate_lines_from_history
    remove_non_existent_files_from_history_and_reduce_max_size
}


main "$@"
