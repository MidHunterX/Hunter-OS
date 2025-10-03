#!/usr/bin/env bash

BLU='\033[0;34m'
YLO='\033[0;33m'
RESET='\033[0;0m'

# Switch to alternate screen + hide cursor
tput smcup
tput civis

draw_ui() {
  local VOLUME BAR
  VOLUME=$(pamixer --get-volume-human)
  BAR=$(printf '─%.0s' $(seq 1 $((${VOLUME%?}/4))))

  tput cup 0 0
  echo ""
  echo -e "${BLU} Hunter Volume Script (u/d/m/x) ${RESET}"
  echo " ------------------------------ "
  echo -e "   ${YLO}${BAR:0:99} ${RESET}"
  echo -e " Current Volume: ${YLO}${VOLUME}${RESET}"
  tput ed
}

draw_ui

while true; do
  read -rsn1 junk
  case $junk in
    u) pamixer -i 1 ;;
    d) pamixer -d 1 ;;
    m) pamixer -t ;;
    x) break ;;
    q) break ;;
  esac
  draw_ui
done

# Restore normal screen + cursor
tput rmcup
tput cnorm
