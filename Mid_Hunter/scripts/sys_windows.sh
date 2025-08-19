# Print Center of Terminal
center_text() {
  text="$1"
  columns="$(tput cols)"
  printf "%*s\n" $(((${#text} + columns) / 2)) "$text"
}

center_color() {
  text="$1"
  columns="$(tput cols)"
  echo -e "$(printf "%*s" $(((${#text} + columns) / 2 + 10)) "$text")"
}

# Specificly spaced for Sudo Prompt
center_space() {
  columns="$(tput cols)"
  printf "%*s" $(((${#text} + columns) / 2 - 23))
}

RED='\033[1;31m'
GRN='\033[1;32m'
YLO='\033[1;33m'
BLU='\033[1;34m'
CYN='\033[1;36m'
RESET='\033[0;0m'

echo -e '\n\n\n\n'
center_text 'REBOOT TO WINDOWS'
center_text '==================='
echo -e '\n'

logo=(
  "${GRN}"
  "        .oodMMMM"
  ".oodMMMMMMMMMMMM"
  "${RED}       ..oodMMM${GRN}  MMMMMMMMMMMMMMMMMMM"
  "${RED} oodMMMMMMMMMMM${GRN}  MMMMMMMMMMMMMMMMMMM"
  "${RED} MMMMMMMMMMMMMM${GRN}  MMMMMMMMMMMMMMMMMMM"
  "${RED} MMMMMMMMMMMMMM${GRN}  MMMMMMMMMMMMMMMMMMM"
  "${RED} MMMMMMMMMMMMMM${GRN}  MMMMMMMMMMMMMMMMMMM"
  "${RED} MMMMMMMMMMMMMM${GRN}  MMMMMMMMMMMMMMMMMMM"
  "${RED} MMMMMMMMMMMMMM${GRN}  MMMMMMMMMMMMMMMMMMM"
  ""
  "${CYN} MMMMMMMMMMMMMM${YLO}  MMMMMMMMMMMMMMMMMMM"
  "${CYN} MMMMMMMMMMMMMM${YLO}  MMMMMMMMMMMMMMMMMMM"
  "${CYN} MMMMMMMMMMMMMM${YLO}  MMMMMMMMMMMMMMMMMMM"
  "${CYN} MMMMMMMMMMMMMM${YLO}  MMMMMMMMMMMMMMMMMMM"
  "${CYN} MMMMMMMMMMMMMM${YLO}  MMMMMMMMMMMMMMMMMMM"
  "${CYN} \`^^^^^^MMMMMMM${YLO}  MMMMMMMMMMMMMMMMMMM"
  "${CYN}       \`\`\`\`^^^^${YLO}  ^^MMMMMMMMMMMMMMMMM"
  "  \`\`\`\`^^^^^^MMMM"
  "${RESET}"
)

for line in "${logo[@]}"; do
  center_color "$line"
done

# Activate sudo if not root
if ! sudo -n true 2>/dev/null; then
  echo -e "\n\n"
  center_text "Enter sudo password to continue, or Ctrl+C to cancel"
  echo -e -n "${GRN}"
  read -p "$(center_text 'PASSWORD: ')" SUDO_PASSWORD

  if ! echo "$SUDO_PASSWORD" | sudo -S -v >/dev/null 2>&1; then
    exit 1
  fi
fi

# eg: 'Windows Boot Manager (on /dev/nvme0n1p1)'
windows_title=$(sudo grep -i windows /boot/grub/grub.cfg | cut -d "'" -f 2)
sudo grub-reboot "$windows_title"
sudo reboot
