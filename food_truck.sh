#!/usr/bin/env bash

set -e
set -o pipefail
set -u

printColor() {
    text=${1}
    local -r color="${2^^}"
    case $color in "RED")
        echo -e "\e[1;31m${text}\e[0m"
        ;;
    "BLUE")
        echo -e "\e[1;34m${text}\e[0m"
        ;;
    "YELLOW")
        echo -e "\e[1;33m${text}\e[0m"
        ;;
    "GREEN")
        echo -e "\e[1;32m${text}\e[0m"
        ;;
    "CYAN")
        echo -e "\e[1;36m${text}\e[0m"
        ;;
    "ORANGE")
        echo -e "\e[1;33m${text}\e[0m"
        ;;
    *) ;;
    esac
}

terminate() {
    msg=${1}
    code=${2:-130}
    printColor "${msg}" "red"
    exit $code

}

welcome() {
    printColor "$(printf "\n%s\n" "===============================================")" "Orange"
    printColor "$(printf "%s\n" "=========Welcome to Food Truck ================")" "Cyan"
}

welcome
exit 0
