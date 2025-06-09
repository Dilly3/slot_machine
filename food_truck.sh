#!/usr/bin/env bash

set -e
set -o pipefail
set -u

printColor() {
    text=${1}
    local -r color="${2^^}"
    case $color in "RED")
        echo -e "\e[1;31m${text}\e[0m\n"
        ;;
    "BLUE")
        echo -e "\e[1;34m${text}\e[0m\n"
        ;;
    "YELLOW")
        echo -e "\e[1;33m${text}\e[0m\n"
        ;;
    "GREEN")
        echo -e "\e[1;32m${text}\e[0m\n"
        ;;
    "CYAN")
        echo -e "\e[1;36m${text}\e[0m\n"
        ;;
    "ORANGE")
        echo -e "\e[1;33m${text}\e[0m\n"
        ;;
    *) ;;
    esac
}
help() {
    printColor "Info: Run script with a user type , eg. customer or admin" "Yellow"
}
terminate() {
    msg="error: ${1}"
    code=${2:-130}
    printColor "${msg}" "red"
    exit $code

}

welcome() {
    printColor "$(printf "\n%s\n" "===============================================")" "Orange"
    printColor "$(printf "%s\n" "=========Welcome to Food Truck ================")" "Cyan"
}

verifyArguments() {
    declare -i MIN_ARGS=1
    if [[ $1 -lt $MIN_ARGS ]]; then
        (
            help
            terminate "user type missing" "127"
        )
    fi

    case ${2^^} in "ADMIN" | "CUSTOMER")
        :
        ;;
    *)
        help
        terminate "invalid user type" "127"
        ;;
    esac
}

verifyArguments $# $1
welcome
exit 0
