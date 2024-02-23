#!/bin/bash

NAME='Arch Chan'

BLK='\033[1;30m' RED='\033[1;31m' GRN='\033[1;32m' YLO='\033[1;33m'
BLU='\033[1;34m' PNK='\033[1;35m' CYN='\033[1;36m' WHT='\033[1;37m'
BLK='\033[1;30m' DEF='\033[0;39m' RST='\033[0;0m'

CMT=$YLO # Comment
CMD=$BLU # Command
STR=$GRN # Strings
INT=$PNK # Integer

# Define the list of keywords and corresponding commands
keywords=(
  'Oopsie.. Select nothing'
  '[wpctl] Show audio devices'
  '[tlp] Disable Conservation Mode - Set to fullcharge temporarily'
  '[tlp] Enable Conservation Mode - Set charging limit @60%'
  '[pacman] Remove unwanted depencies'
  '[pacman] Show unwanted depencies'
  '[aft-mtp-mount] Mount Android Device'
  '[curlftpfs] Mount FTP Device'
  '[umount] Unmount Device/Partition'
  '[nmcli] Wifi Disable'
  '[nmcli] Wifi Enable'
  '[nmcli] Network Disable'
  '[nmcli] Network Enable'
  '[ls] List installed themes'
  '[systemctl] Show running background services'
)
commands=(
  ''
  'wpctl status'
  'sudo tlp fullcharge'
  'sudo tlp setcharge'
  'sudo pacman -R $(pacman -Qdtq)'
  'pacman -Qdtq'
  'aft-mtp-mount ~/mnt'
  'curlftpfs ftphostname ~/mnt'
  'sudo umount ~/mnt'
  'nmcli radio wifi off'
  'nmcli radio wifi on'
  'nmcli networking off'
  'nmcli networking on'
  'ls /usr/share/themes/'
  'systemctl status'
)
comments=(
  'Go on... Have a nice day, master ;D'
  """ You can set default device using: ${CMD}wpctl set-default <${INT}number${CMD}>
  ${CMT}Just remember, Source == 🎙️Microphone and Sink == 🔈Sound
  """
  """You can set default charging mode at: /etc/tlp.conf
  STOP_CHARGE_THRESH_BAT0=1"""
  """You can set default charging mode at: /etc/tlp.conf
  STOP_CHARGE_THRESH_BAT0=1"""
  'Done'
  'These are the things you gotta yeet!'
  'Done'
  'Done'
  'Done'
  'Done'
  'Done'
  'Done'
  'Done'
  """You can set theme using:
  ${CMD}gsettings set org.gnome.desktop.interface gtk-theme '${STR}theme_name${CMD}'"""
  'Done'
)

# Prompt for input
usr_keyword=$(printf "%s\n" "${keywords[@]}" | fzf --prompt 'Select Command: ')
# usr_keyword=$(printf "%s\n" "${keywords[@]}" | fuzzel --dmenu)

# Find the index of the selected keyword
index=-1
for i in "${!keywords[@]}"; do
    if [[ "${keywords[$i]}" == "$usr_keyword" ]]; then
        index=$i
        break
    fi
done

if [[ index -ne -1 ]]; then
  echo -e "${GRN}${NAME}: ${RST}Executing ${CMD}${commands[$index]}${RST}"
  echo ''
  ${commands[$index]}
  echo ''
  echo -e "${GRN}${NAME}: ${CMT}${comments[$index]}${RST}"
fi
