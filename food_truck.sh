#!/usr/bin/env bash

set -e
set -o pipefail
set -u


printColor() {
text=${1}
color=${2}
echo -e "\e[1;${color}m${text}\e[0m"
}

welcome() {
printColor "$(printf "\n%s\n" "===============================================")" "36"
printColor "$(printf "%s\n" "=========Welcome to Food Truck ================")" "35"
}

welcome
exit 0


