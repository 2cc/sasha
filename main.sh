#!/bin/bash

source themes/base_theme

COLOR_RESET='\033[0m'
CONFIG_FILE="$HOME/.ssh/config"

selected=0
hosts=()
filtered_hosts=()
search_query=""

cleanup() {
    tput clear
    exit 0
}

trap cleanup SIGINT

load_hosts() {
    if [[ ! -f $CONFIG_FILE ]]; then
        printf "${ERROR_COLOR}Error: SSH config file not found at $CONFIG_FILE${COLOR_RESET}\n" >&2
        exit 1
    fi

    mapfile -t hosts < <(grep -i '^Host ' "$CONFIG_FILE" | awk '{print $2}' | grep -v '[*?]')
    filtered_hosts=("${hosts[@]}")
}

filter_hosts() {
    if [[ -z $search_query ]]; then
        filtered_hosts=("${hosts[@]}")
    else
        filtered_hosts=()
        for host in "${hosts[@]}"; do
            if [[ ${host,,} == *${search_query,,}* ]]; then
                filtered_hosts+=("$host")
            fi
        done
    fi
    ((selected >= ${#filtered_hosts[@]})) && selected=0
}

calculate_padding() {
    local term_width=$1
    local text_length=$2
    local label_length=$3
    echo $((term_width - 4 - text_length - label_length))
}

draw_menu() {
    clear
    local term_width=$(tput cols)
    local border_line=$(printf "%-$((term_width - 2))s" "" | sed 's/ /─/g')
    printf "${BORDER_COLOR}┌%s┐${COLOR_RESET}\n" "$border_line"

    local search_label="Search: "
    local search_padding=$(calculate_padding $term_width ${#search_query} ${#search_label})
    printf "${BORDER_COLOR}│ %s${SEARCH_FG}%s%*s ${BORDER_COLOR}│\n" "$search_label" "$search_query" "$search_padding" ""
    printf "${BORDER_COLOR}└%s┘${COLOR_RESET}\n" "$border_line"

    printf "${BORDER_COLOR}┌%s┐${COLOR_RESET}\n" "$border_line"

    for i in "${!filtered_hosts[@]}"; do
        local host_padding=$(calculate_padding $term_width ${#filtered_hosts[$i]} 3)
        if [[ $i -eq $selected ]]; then
            printf "${COLOR_RESET}${BORDER_COLOR}│${SELECTED_FG}${SELECTED_BG}    %s%*s ${COLOR_RESET}${BORDER_COLOR}│\n" "${filtered_hosts[$i]}" "$host_padding" ""
        else
            printf "${COLOR_RESET}${BORDER_COLOR}│    %s%*s${BORDER_COLOR} │\n" "${filtered_hosts[$i]}" "$host_padding" ""
        fi
    done

    printf "${BORDER_COLOR}└%s┘${COLOR_RESET}\n" "$border_line"
    printf "${BORDER_COLOR}Use arrow keys to navigate, type to search, Enter to select, Ctrl+C to exit.${COLOR_RESET}\n"
    local search_line_length=${#search_query}
    tput cup 1 $((10 + search_line_length))
}

connect_to_host() {
    local host=${filtered_hosts[$selected]}
    printf "${SUCCESS_COLOR}Connecting to $host...${COLOR_RESET}\n"
    ssh "$host"
}

main() {
    load_hosts
    while true; do
        filter_hosts
        draw_menu

        read -rsn1 key
        case $key in
            $'\x1b')
                read -rsn2 -t 0.1 key
                if [[ $key == "[A" || $key == "OA" ]]; then
                    ((selected--))
                    ((selected < 0)) && selected=$((${#filtered_hosts[@]} - 1))
                elif [[ $key == "[B" || $key == "OB" ]]; then
                    ((selected++))
                    ((selected >= ${#filtered_hosts[@]})) && selected=0
                fi
                ;;
            "")
                clear
                connect_to_host
                clear
                ;;
            [[:print:]])
                search_query+="$key"
                selected=0
                ;;
            $'\177')
                search_query="${search_query:0:-1}"
                selected=0
                ;;
        esac
    done
}

main
