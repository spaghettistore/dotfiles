#!/bin/bash

get_confirmation() {
    local message="$1"
    local confirmation
    read -rp "$message [y/N] " confirmation
    case "$confirmation" in
        [yY]*) return 0 ;;
        *) return 1 ;;
    esac
}


get_git_branch() {
    local current_branch
    current_branch="$(git branch --list | grep "^\* ")"
    echo "${current_branch:2}"  # Strip the '* ' prefix
}


display_with_less() {
    [[ "$*" ]] && echo "$*" | less -R
}


get_title() {
    local branch
    branch="$(git branch --list | grep "^\*")"
    if [[ -z "$branch" ]]; then
        echo "Git"
        exit 0
    fi
    branch="${branch:2}"  # Remove '* ' prefix
    local status_num
    status_num="$(git status -s | wc --lines)"
    echo "Git (${branch}) (${status_num})"
}


tmux_git_display_menu() {
    local title
    title="$(get_title)"

    tmux display-menu -T "$title" \
        "Status (Short)" s "display-popup -w 80% -h 80% -E \"~/.config/tmux/git_script.sh status -s\"" \
        "Status (Full)" S "display-popup -w 80% -h 80% -E \"~/.config/tmux/git_script.sh status\"" \
        "Difftool" D "new-window -n difftool \"~/.config/tmux/git_script.sh difftool\"" \
        "Diff Menu" d "display-menu -T \"Diff Menu\" \
            \"Diff\" d \"display-popup -w 80% -h 80% -E '~/.config/tmux/git_script.sh diff'\" \
            \"Diff (Staged)\" D \"display-popup -w 80% -h 80% -E '~/.config/tmux/git_script.sh diff --staged'\" \
            \"Difftool\" t \"new-window -n difftool '~/.config/tmux/git_script.sh difftool'\" \
            \"Difftool (Staged)\" T \"new-window -n difftool '~/.config/tmux/git_script.sh difftool --staged'\" \
        " \
        "Log (fzf)" l "display-popup -w 80% -h 80% -E \"~/.config/tmux/git_script.sh log fzf\"" \
        "Log (Full)" L "display-popup -w 80% -h 80% -E \"~/.config/tmux/git_script.sh log\"" \
        "Branch" b "display-popup -w 80% -h 80% -E \"~/.config/tmux/git_script.sh branch\"" \
        "Add" a "display-popup -w 80% -h 80% -E \"~/.config/tmux/git_script.sh add\"" \
        "Commit" c "display-popup -w 80% -h 80% -E \"~/.config/tmux/git_script.sh commit\""

        #"Log" l "display-popup -w 80% -h 80% -E \"~/.config/tmux/git_script.sh log --oneline\"" \
}


git_add() {
    if git diff 2>/dev/null; then
        git status -s 2>/dev/null
        if get_confirmation "Confirm 'git add .'"; then
            git add .
        fi
    fi
}


git_commit() {
    if git diff --staged 2>/dev/null; then
        git status -s 2>/dev/null
        if get_confirmation "Confirm 'git commit'"; then
            git commit
        fi
    fi
}


git_log_fzf() {
    if git status -s 2>/dev/null >/dev/null; then
        # Get ID from: git log --oneline | awk '{print $1}'
        # Preview ID with: git show ID
        git log --oneline | fzf --preview="git show --color \$(echo {} | awk '{print \$1}')"
    fi
}


main() {
    case "$*" in
        "display-menu") tmux_git_display_menu ;;
        "getbranch") get_git_branch ;;
        "status -s") display_with_less "$(git status -s 2>/dev/null)" ;;
        "status") display_with_less "$(git status 2>/dev/null)" ;;
        "diff") display_with_less "$(git diff --color 2>/dev/null)" ;;
        "diff --staged") display_with_less "$(git diff --staged --color 2>/dev/null)" ;;
        "difftool") git difftool 2>/dev/null ;;
        "difftool --staged") git difftool --staged 2>/dev/null ;;
        "log --oneline") display_with_less "$(git log --oneline --color 2>/dev/null)" ;;
        "log") display_with_less "$(git log --oneline -p --color 2>/dev/null)" ;;
        "log fzf") git_log_fzf ;;
        "branch") display_with_less "$(git branch --list --color 2>/dev/null)" ;;
        "add") git_add ;;
        "commit") git_commit ;;
        *) exit 0 ;;
    esac
}


main "$@"
