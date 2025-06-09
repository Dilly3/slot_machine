#!/usr/bin/env bash

set -e
set -o pipefail
set -u

declare WORK_DIR="$(dirname "$(readlink -f $0)")"
declare FOOD_OPTIONS_BASENAME="food_options.txt"
declare FOOD_STOCK_BASENAME="food_stock.txt"
declare FOOD_OPTIONS_FILE="${WORK_DIR}/${FOOD_OPTIONS_BASENAME}"
declare FOOD_STOCK_FILE="${WORK_DIR}/${FOOD_STOCK_BASENAME}"
declare -a FOOD_ARRAY=()
declare -A FOOD_STOCK_ARRAY=()

printColor() {
    text=${1}
    local -r color="${2^^}"
    case $color in "RED")
        echo -e "\n\e[1;31m${text}\e[0m\n"
        ;;
    "BLUE")
        echo -e "\n\e[1;34m${text}\e[0m\n"
        ;;
    "YELLOW")
        echo -e "\n\e[1;33m${text}\e[0m\n"
        ;;
    "GREEN")
        echo -e "\n\e[1;32m${text}\e[0m\n"
        ;;
    "CYAN")
        echo -e "\n\e[1;36m${text}\e[0m\n"
        ;;
    "ORANGE")
        echo -e "\n\e[1;33m${text}\e[0m\n"
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

}
checkUserType() {
    case ${1^^} in "ADMIN" | "CUSTOMER")
        :
        ;;
    *)
        help
        terminate "invalid user type" "127"
        ;;
    esac
}

adminMessage() {
    printColor "\n\tEnter Food And Quantity. eg 'Amala 2'\n\tEnter 'end' To Exit" "Yellow"
}

checkFiles() {
    [[ -f $FOOD_OPTIONS_FILE ]] || (
        touch "$WORK_DIR/$FOOD_OPTIONS_BASENAME"
        chmod 755 "$WORK_DIR/$FOOD_OPTIONS_BASENAME"
    )
    [[ -f $FOOD_STOCK_FILE ]] || (
        touch "$WORK_DIR/$FOOD_STOCK_BASENAME"
        chmod 755 "$WORK_DIR/$FOOD_STOCK_BASENAME"
    )
}
addItems() {
    while true; do
        read -p "Enter Food: " food qty

        if [[ "${food^^}" == "END" ]]; then
            break
        fi
        [[ ! -z ${qty} ]] || (terminate "Quantity Is Missing" "127")
        for ((i = 0; i < qty; i++)); do
            FOOD_ARRAY[${#FOOD_ARRAY[@]}]="${food^^}"
            if [[ -v FOOD_STOCK_ARRAY["${food^^}"] ]]; then
                ((FOOD_STOCK_ARRAY["${food^^}"]++))
            else
                FOOD_STOCK_ARRAY["${food^^}"]=1
            fi
        done

    done
    printf "%s\n" "${FOOD_ARRAY[@]}" >>${FOOD_OPTIONS_FILE}

    # update stock
    : >"${FOOD_STOCK_FILE}"
    for key in "${!FOOD_STOCK_ARRAY[@]}"; do
        printf "%s:%s\n" "${key}" "${FOOD_STOCK_ARRAY["${key}"]}" >>${FOOD_STOCK_FILE}
    done
}
loadFoodFile() {
    while read food; do
        # Skip empty lines
        # [[ -z "$food" ]] && continue
        if [[ -v FOOD_STOCK_ARRAY["${food^^}"] ]]; then
            ((FOOD_STOCK_ARRAY["${food^^}"]++))
        else
            FOOD_STOCK_ARRAY["${food^^}"]=1
        fi
    done <"$FOOD_OPTIONS_FILE"

}

loadFoodStock() {
    while IFS=':' read key value || [[ -n "${key}" ]]; do
        [[ -z "$key" || "$key" =~ ^[[:space:]]*# ]] && continue
        printf "%s:%s\n" "$key" "$value"
    done <"${FOOD_STOCK_FILE}"
}

# Run Program
declare user="${1^^}"
verifyArguments $#
checkUserType $1
welcome

if [[ $user == "ADMIN" ]]; then
    adminMessage
    checkFiles
    loadFoodFile
    addItems
fi
exit 0
