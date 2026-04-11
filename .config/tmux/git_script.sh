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


main() {
    case "$*" in
        "getbranch") get_git_branch ;;
        "status -s") display_with_less "$(git status -s 2>/dev/null)" ;;
        "status") display_with_less "$(git status 2>/dev/null)" ;;
        "diff") display_with_less "$(git diff --color 2>/dev/null)" ;;
        "diff --staged") display_with_less "$(git diff --staged --color 2>/dev/null)" ;;
        "difftool") git difftool 2>/dev/null ;;
        "difftool --staged") git difftool --staged 2>/dev/null ;;
        "log --oneline") display_with_less "$(git log --oneline --color 2>/dev/null)" ;;
        "log") display_with_less "$(git log --oneline -p --color 2>/dev/null)" ;;
        "add")
            git status -s 2>/dev/null
            if git diff 2>/dev/null; then
                if get_confirmation "Confirm 'git add .'"; then
                    git add .
                fi
            fi
            ;;
        "commit")
            git status -s 2>/dev/null
            if git diff --staged 2>/dev/null; then
                if get_confirmation "Confirm 'git commit'"; then
                    git commit
                fi
            fi
            ;;
        *) exit 0 ;;
    esac
}


main "$@"
