#!/usr/bin/env bash

# Print Center of Terminal
center_text() {
  text="$1"
  columns="$(tput cols)"
  printf "%*s\n" $(((${#text} + columns) / 2)) "$text"
}

center_color() {
  local text="$1"
  local columns
  local visible_len
  local offset

  columns=$(tput cols)
  visible_len=$(echo -e "$text" | sed 's/\x1B\[[0-9;]*[A-Za-z]//g' | wc -m)
  offset=$(((columns - visible_len) / 2))
  echo -e "$(printf "%*s%s\n" "$offset" "" "$text")"
}

# Specificly spaced for Sudo Prompt
center_space() {
  columns="$(tput cols)"
  printf "%*s" $(((${#text} + columns) / 2 - 23))
}

read_password() {
    local prompt="$1"
    local password=""
    local char

    # Print prompt without newline
    printf "%s" "$prompt"

    while IFS= read -r -s -n 1 char; do
        # Enter ends input
        if [[ $char == $'\0' || $char == $'\n' ]]; then
            break
        fi
        # Handle backspace (ASCII 127)
        if [[ $char == $'\177' ]]; then
            if [ -n "$password" ]; then
                password=${password%?}
                # Move cursor back, erase *, move back again
                printf '\b \b'
            fi
        else
            password+=$char
            printf '*'
        fi
    done
    echo
    REPLY="$password"   # store in REPLY like `read` does
}

R='\033[1;31m' # RED
G='\033[1;32m' # GREEN
Y='\033[1;33m' # YELLOW
B='\033[1;34m' # BLUE
C='\033[1;36m' # CYAN
RESET='\033[0;0m'

echo -e '\n\n\n\n'
center_text 'REBOOT TO WINDOWS'
center_text '==================='
echo -e '\n'

logo=(
  "${R}                ${G}            .oodMMMM"
  "${R}                ${G}    .oodMMMMMMMMMMMM"
  "${R}       ..oodMMM ${G} MMMMMMMMMMMMMMMMMMM"
  "${R} oodMMMMMMMMMMM ${G} MMMMMMMMMMMMMMMMMMM"
  "${R} MMMMMMMMMMMMMM ${G} MMMMMMMMMMMMMMMMMMM"
  "${R} MMMMMMMMMMMMMM ${G} MMMMMMMMMMMMMMMMMMM"
  "${R} MMMMMMMMMMMMMM ${G} MMMMMMMMMMMMMMMMMMM"
  "${R} MMMMMMMMMMMMMM ${G} MMMMMMMMMMMMMMMMMMM"
  "${R} MMMMMMMMMMMMMM ${G} MMMMMMMMMMMMMMMMMMM"
  ""
  "${C} MMMMMMMMMMMMMM ${Y} MMMMMMMMMMMMMMMMMMM"
  "${C} MMMMMMMMMMMMMM ${Y} MMMMMMMMMMMMMMMMMMM"
  "${C} MMMMMMMMMMMMMM ${Y} MMMMMMMMMMMMMMMMMMM"
  "${C} MMMMMMMMMMMMMM ${Y} MMMMMMMMMMMMMMMMMMM"
  "${C} MMMMMMMMMMMMMM ${Y} MMMMMMMMMMMMMMMMMMM"
  "${C} '^^^^^^MMMMMMM ${Y} MMMMMMMMMMMMMMMMMMM"
  "${C}        ''''^^^ ${Y} ^^MMMMMMMMMMMMMMMMM"
  "${C}                ${Y}       ''''^^^^^MMMM"
  "${RESET}"
)

for line in "${logo[@]}"; do
  center_color "$line"
done

# Activate sudo if not root
if ! sudo -n true 2>/dev/null; then
  echo -e "\n\n"
  center_color "[ Enter sudo password to continue, or ${R}Ctrl+C${RESET} to cancel ]"

  echo -e -n "${G}"
  # read -sp "$(center_text ' PASSWORD: ')" SUDO_PASSWORD
  read_password "$(center_space)   PASSWORD: "
  SUDO_PASSWORD="$REPLY"

  if [ -z "$SUDO_PASSWORD" ]; then exit 1; fi
  if ! echo "$SUDO_PASSWORD" | sudo -S -v >/dev/null 2>&1; then
    exit 1
  fi
fi

# eg: 'Windows Boot Manager (on /dev/nvme0n1p1)'
windows_title=$(sudo grep -i windows /boot/grub/grub.cfg | cut -d "'" -f 2)
sudo grub-reboot "$windows_title"
sudo reboot
