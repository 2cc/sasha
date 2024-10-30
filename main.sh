#!/bin/bash

# Colors
RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
CYAN='\033[1;36m'
NC='\033[0m' # No Color

CONFIG_FILE="$HOME/.ssh/config"
selected=0
hosts=()
filtered_hosts=()
search_query=""

# Load hosts from SSH config file
load_hosts() {
    if [[ ! -f $CONFIG_FILE ]]; then
        printf "${RED}Error: SSH config file not found at $CONFIG_FILE${NC}\n" >&2
        exit 1
    fi

    # Extract hostnames from config
    mapfile -t hosts < <(grep -i '^Host ' "$CONFIG_FILE" | awk '{print $2}' | grep -v '[*?]')
    filtered_hosts=("${hosts[@]}")
}

# Filter hosts based on search query
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
    # Reset selection if filtered list is shorter
    ((selected >= ${#filtered_hosts[@]})) && selected=0
}

# Function to calculate padding based on terminal width, text length and label length
calculate_padding() {
    local term_width=$1
    local text_length=$2
    local label_length=$3
    echo $((term_width - 4 - text_length - label_length))  # -4 для учета рамки
}

# Draw the menu with highlighted selection and search query
draw_menu() {
    clear
    printf "${CYAN}==== SSH Host Menu ====${NC}\n"

    # Получаем ширину терминала
    local term_width=$(tput cols)

    # Создаем рамку для поля поиска
    local border_line=$(printf "%-$((term_width - 2))s" "" | sed 's/ /─/g')  # Уменьшаем на 2 для двух символов рамки по бокам
    printf "${CYAN}┌%s┐${NC}\n" "$border_line"  # Верхняя граница с символами

    # Заполняем пробелы между "Search:" и правой рамкой
    local search_label="Search: "
    local search_padding=$(calculate_padding $term_width ${#search_query} ${#search_label})
    printf "${CYAN}│ %s${YELLOW}%s%*s${CYAN} │\n" "$search_label" "$search_query" "$search_padding" ""  # Выводим строку поиска с рамкой
    printf "${CYAN}└%s┘${NC}\n" "$border_line"  # Нижняя граница с символами

    # Создаем рамку для списка хостов
    printf "${CYAN}┌%s┐${NC}\n" "$border_line"  # Верхняя граница списка хостов

    # Выводим список хостов
    for i in "${!filtered_hosts[@]}"; do
        local host_padding=$(calculate_padding $term_width ${#filtered_hosts[$i]} 3)  # Для хостов длина метки равна 0
        
        # Подсветка выбранного элемента
        if [[ $i -eq $selected ]]; then
            printf "${YELLOW}│--> ${filtered_hosts[$i]}%*s${NC}${CYAN} │\n" "$host_padding" ""  # Выводим выбранный хост
        else
            printf "${CYAN}│    %s%*s${CYAN} │\n" "${filtered_hosts[$i]}" "$host_padding" ""  # Выводим строку хоста с рамкой
        fi
    done

    printf "${CYAN}└%s┘${NC}\n" "$border_line"  # Нижняя граница с символами

    printf "${CYAN}Use arrow keys to navigate, type to search, Enter to select, Ctrl+C to exit.${NC}\n"
    
    # Move cursor to the end of the search query
    local search_line_length=${#search_query}
    tput cup 2 $((10 + search_line_length)) # Позиционируем курсор за текстом поиска
}

# Connect to selected host
connect_to_host() {
    local host=${filtered_hosts[$selected]}
    printf "${GREEN}Connecting to $host...${NC}\n"
    ssh "$host"
}

# Main loop
main() {
    load_hosts
    while true; do
        filter_hosts
        draw_menu

        # Capture user key presses
        read -rsn1 key
        case $key in
            $'\x1b') # Handle arrow keys
                read -rsn2 -t 0.1 key
                if [[ $key == "[A" ]]; then # Up arrow
                    ((selected--))
                    ((selected < 0)) && selected=$((${#filtered_hosts[@]} - 1))
                elif [[ $key == "[B" ]]; then # Down arrow
                    ((selected++))
                    ((selected >= ${#filtered_hosts[@]})) && selected=0
                fi
                ;;
            "") # Enter key
                clear
                connect_to_host
                read -rp "Press Enter to return to menu."
                clear
                ;;
            [[:print:]]) # Capture printable characters for search
                search_query+="$key"
                selected=0
                ;;
            $'\177') # Handle backspace
                search_query="${search_query:0:-1}"
                selected=0
                ;;
        esac
    done
}

main
