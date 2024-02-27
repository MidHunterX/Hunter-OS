#!/usr/bin/env bash

BLU='\033[0;34m'
YLO='\033[0;33m'
RESET='\033[0;0m'

while true
do
  # tput bel
  VOLUME=$(pamixer --get-volume-human)
  BAR=$(echo "$(printf '─%.0s' $(seq 1 $((${VOLUME:0:-1}/4))))")

  clear
  echo ""
  echo -e ${BLU}" Hunter Volume Script (u/d/m/x) "${RESET}
  echo          " ------------------------------ "
  # Looong stikk sequenze
  echo -e -n "  " ${YLO}${BAR:0:99} ${RESET}"\n"
  echo -e -n " Current Volume:" ${YLO}${VOLUME}${RESET}
  read -n1 junk

  case $junk in

    "u")
      pamixer -i 1
      ;;

    "d")
      pamixer -d 1
      ;;

    "m")
      pamixer -t
      ;;

    "x")
      echo -n "Bye Bye"
      break
      ;;

    *)
      echo -n "Invalid Input! Try: u/d/x"
      ;;
  esac

done
clear
