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
  center_text "Enter sudo password to continue, or Ctrl+C to cancel"
  echo -e -n "${G}"
  read -p "$(center_text 'PASSWORD: ')" SUDO_PASSWORD

  if [ -z "$SUDO_PASSWORD" ]; then exit 1; fi
  if ! echo "$SUDO_PASSWORD" | sudo -S -v >/dev/null 2>&1; then
    exit 1
  fi
fi

# eg: 'Windows Boot Manager (on /dev/nvme0n1p1)'
windows_title=$(sudo grep -i windows /boot/grub/grub.cfg | cut -d "'" -f 2)
sudo grub-reboot "$windows_title"
sudo reboot
