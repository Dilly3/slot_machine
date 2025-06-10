#!/usr/bin/env bash

# This script is a program for a food dispencer (Food Truck)
# Run the script either as an admin or a customer
# Admin:
#   Admin user takes inventory and update stock of food availabe
# Customer:
#   Customer User makes order according to what is available in the menu.
#   If the desired meal and the required quatity is available in stock
#   Then customer order is taken and processed.

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
        echo -e "\e[1;38m${text}\e[0m\n"
        ;;
    "WHITE")
        echo -e "\e[1;91m${text}\e[0m\n"
        ;;
    *) ;;
    esac
}
help() {
    local -r message="
INFO: Script expects one argument, user-type.
user-type ( eg. customer or admin )
eg ./food_truck.sh customer.
"
    printColor "$message" "Yellow"
}
terminate() {
    msg="error: ${1}"
    code=${2:-130}
    printColor "${msg}" "red"
    exit $code

}

welcome() {
    message1="==============================================="
    message2="=========Welcome to Food Truck ================
==============================================="
    printColor "${message1}" "Orange"
    printColor "${message2}" "Cyan"
}

goodbyeCustomer() {
    local message="Thanks for your Patronage!!
Hope to see you again
=================================="
    local footnote="
========== Food Truck ============
"
    printColor "$message" "Green"
    printColor "$footnote" "Cyan"

}

goodbyeAdmin() {
    local message="GoodBye!!"
    local footnote="
========== Food Truck ============"
    printColor "$message" "Green"
    printColor "$footnote" "Cyan"
}

verifyArguments() {
    declare -i MIN_ARGS=1
    if [[ $1 -lt $MIN_ARGS ]]; then
        (
            help
            terminate "user-type missing" "127"
        )
    fi

}
checkUserType() {
    case ${1^^} in "ADMIN" | "CUSTOMER")
        :
        ;;
    *)
        help
        terminate "invalid user-type" "127"
        ;;
    esac
}

adminMessage() {
    message="
Enter Food And Quantity.
eg 'Amala 2'.
Enter 'end' To Exit"
    printColor "${message}" "Yellow"
}

customerMessage() {
    message="
What would you love to eat?,
Select from the menu. eg. egusi , fufu.
type 'end' to quit."
    printColor "$message" "Yellow"
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

updateStock() {
    : >"${FOOD_STOCK_FILE}"
    for key in "${!FOOD_STOCK_ARRAY[@]}"; do
        if [[ ${FOOD_STOCK_ARRAY["${key}"]} -eq 0 ]]; then
            continue
        fi
        printf "%s:%s\n" "${key}" "${FOOD_STOCK_ARRAY["${key}"]}" >>${FOOD_STOCK_FILE}
    done
    : >"${FOOD_OPTIONS_FILE}"
    for item in "${FOOD_ARRAY[@]}"; do
        printf "%s\n" "${item^^}" >>${FOOD_OPTIONS_FILE}
    done

}

updateFoodArray() {
    local choice=${1}
    local qty=${2}
    for i in "${!FOOD_ARRAY[@]}"; do
        if [[ $qty -lt 1 ]]; then
            break
        fi
        if [[ "${FOOD_ARRAY[i]}" == "${choice^^}" ]]; then
            unset FOOD_ARRAY[i]
            ((qty--))
        fi
    done
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
    updateStock
}
loadFoodFile() {
    while read food; do
        # Skip empty lines
        [[ -z "$food" ]] && continue
        if [[ -v FOOD_STOCK_ARRAY["${food^^}"] ]]; then
            ((FOOD_STOCK_ARRAY["${food^^}"]++))
        else
            FOOD_STOCK_ARRAY["${food^^}"]=1
        fi
        FOOD_ARRAY[${#FOOD_ARRAY[@]}]="$food"
    done <"$FOOD_OPTIONS_FILE"

}

loadFoodStock() {
    while IFS="$IFS:" read key value || [[ -n "${key}" ]]; do
        [[ -z "$key" || "$key" =~ ^[[:space:]]*# ]] && continue
        printf "%s:%s\n" "$key" "$value"
    done <"${FOOD_STOCK_FILE}"
}

printMenu() {
    printColor "MENU: " "Green"
    for key in "${!FOOD_STOCK_ARRAY[@]}"; do
        printColor "${key^^}" "Orange"
    done
}

collectOrder() {
    msg="
Make food choice and Quantity. eg 'Semo 2'
Press 'end' to Quit
"
    orderProcessing="
Thank you , We Are Processing Order.
Will be served in 15Mins.
"
    foodNotInMenu="
Sorry, The food You Ordered is not in Menu
"
    orderCollected="
Thank You.
Your Order has been collected"
    notEnoughInStock="
Sorry we dont Have enough in stock to carry out your order
"

    printColor "${msg}" "Blue"
    orderMade="false"

    while true; do
        read -p "Food choice and Qty:" choice qty
        if [[ "${choice^^}" == "END" ]]; then
            break
        fi
        [[ ! -z ${qty} ]] || (terminate "Quantity Is Missing" "127")
        if [[ ! -v FOOD_STOCK_ARRAY["${choice^^}"] ]]; then
            printColor "INFO: ${foodNotInMenu}" "Yellow"
            continue
        elif [[ $qty -gt ${FOOD_STOCK_ARRAY["${choice^^}"]} ]]; then
            printColor "INFO: ${notEnoughInStock}" "Yellow"
            continue
        elif [[ $qty == "1" && ${FOOD_STOCK_ARRAY["${choice^^}"]} == "1" ]]; then
            ((FOOD_STOCK_ARRAY["${choice^^}"]--))
            printColor "${orderCollected}" "Green"
            orderMade="true"
        else
            ((FOOD_STOCK_ARRAY["${choice^^}"] -= qty))
            printColor "${orderCollected}" "Green"
            orderMade="true"
        fi
        # Update food array
        updateFoodArray "$choice" "$qty"

    done
    #update stock
    updateStock
    if [[ "$orderMade" == "true" ]]; then
        printColor "${orderProcessing}" "Green"
    fi

}

# Run Program
verifyArguments $#
declare user="${1^^}"
checkUserType $1
welcome

if [[ $user == "ADMIN" ]]; then
    adminMessage
    checkFiles
    loadFoodFile
    addItems
    goodbyeAdmin
fi

if [[ $user == "CUSTOMER" ]]; then
    customerMessage
    checkFiles
    loadFoodFile
    printMenu
    collectOrder
    goodbyeCustomer
fi
exit 0
