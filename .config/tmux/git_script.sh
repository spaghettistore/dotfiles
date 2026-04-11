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
        "add")
            if git status -s; then
                if get_confirmation "Confirm 'git add .'"; then
                    git add .
                fi
            fi
            ;;
        "commit")
            if git status -s; then
                if get_confirmation "Confirm 'git commit'"; then
                    git commit
                fi
            fi
            ;;
        *) exit 0 ;;
    esac
}


main "$@"
