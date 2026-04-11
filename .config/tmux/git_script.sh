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


main() {
    case "$*" in
        "status -s") git status -s | less ;;
        "status") git status | less ;;
        "difftool") git difftool ;;
        "difftool --staged") git difftool --staged ;;
        "log --oneline") git log --oneline | less ;;
        "log") git log | less ;;
        "log full") git log --oneline -p ;;
        "add")
            git status -s
            git diff
            if get_confirmation "Confirm 'git add .'"; then
                git add .
            fi
            ;;
        "commit")
            git status -s
            git diff --staged
            if get_confirmation "Confirm 'git commit'"; then
                git commit
            fi
            ;;
        *) exit 0 ;;
    esac
}


main "$@"
