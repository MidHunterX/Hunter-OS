# Reboot directly to Windows
set_GRUB_default_entry (){
  # eg: 'Windows Boot Manager (on /dev/nvme0n1p1)'
  windows_title=$(sudo grep -i windows /boot/grub/grub.cfg | cut -d "'" -f 2)
  sudo grub-reboot "$windows_title"
}


# Print Center of Terminal
display_center(){
    text="$1"
    columns="$(tput cols)"
    printf "%*s\n" $(( (${#text} + columns) / 2)) "$text"
}

display_center_colors() {
    text="$1"
    columns="$(tput cols)"
    echo -e "$(printf "%*s" $(( (${#text} + columns) / 2 + 10)) "$text")"
}

# Specificly spaced for Sudo Prompt
space_center(){
    columns="$(tput cols)"
    printf "%*s" $(( (${#text} + columns) / 2 - 23))
}

RED='\033[1;31m'
GRN='\033[1;32m'
YLO='\033[1;33m'
BLU='\033[1;34m'
CYN='\033[1;36m'
RESET='\033[0;0m'


echo -e '\n\n\n\n'
display_center 'REBOOT TO WINDOWS'
display_center '==================='
echo -e '\n'
display_center_colors "${GRN}"
display_center "                             .oodMMMM"
display_center "                    .oodMMMMMMMMMMMMM"
display_center_colors "${RED}       ..oodMMM${GRN}  MMMMMMMMMMMMMMMMMMM"
display_center_colors "${RED} oodMMMMMMMMMMM${GRN}  MMMMMMMMMMMMMMMMMMM"
display_center_colors "${RED} MMMMMMMMMMMMMM${GRN}  MMMMMMMMMMMMMMMMMMM"
display_center_colors "${RED} MMMMMMMMMMMMMM${GRN}  MMMMMMMMMMMMMMMMMMM"
display_center_colors "${RED} MMMMMMMMMMMMMM${GRN}  MMMMMMMMMMMMMMMMMMM"
display_center_colors "${RED} MMMMMMMMMMMMMM${GRN}  MMMMMMMMMMMMMMMMMMM"
display_center_colors "${RED} MMMMMMMMMMMMMM${GRN}  MMMMMMMMMMMMMMMMMMM"
display_center_colors ""
display_center_colors "${CYN} MMMMMMMMMMMMMM${YLO}  MMMMMMMMMMMMMMMMMMM"
display_center_colors "${CYN} MMMMMMMMMMMMMM${YLO}  MMMMMMMMMMMMMMMMMMM"
display_center_colors "${CYN} MMMMMMMMMMMMMM${YLO}  MMMMMMMMMMMMMMMMMMM"
display_center_colors "${CYN} MMMMMMMMMMMMMM${YLO}  MMMMMMMMMMMMMMMMMMM"
display_center_colors "${CYN} MMMMMMMMMMMMMM${YLO}  MMMMMMMMMMMMMMMMMMM"
display_center_colors "${CYN} \`^^^^^^MMMMMMM${YLO}  MMMMMMMMMMMMMMMMMMM"
display_center_colors "${CYN}       \`\`\`\`^^^^${YLO}  ^^MMMMMMMMMMMMMMMMM"
display_center "                      \`\`\`\`^^^^^^MMMM"
display_center_colors "${RESET}"

echo -e "\n\n${GRN}"
space_center
set_GRUB_default_entry
sudo reboot
