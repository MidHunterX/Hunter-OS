#!/usr/bin/bash

BLU='\033[0;34m'
YLO='\033[0;33m'
RESET='\033[0;0m'

while true
do
  # Get le Brightness Value
  CURRENT_BRIGHTNESS=$(brillo)
  # BAR=$(seq -s "─" 0 ${CURRENT_BRIGHTNESS:0:-3} | sed 's/[0-9]//g')
  BAR=$(echo "$(printf '─%.0s' $(seq 1 ${CURRENT_BRIGHTNESS:0:-3}))")

  clear
  echo ""
  echo -e ${BLU}" Hunter Brightness Script (u/d/x)"${RESET}
  echo          " --------------------------------"
  # Looong stikk sequenze
  echo -e -n " 󰃟 " ${YLO}${BAR:0:27} ${RESET}"\n"
  echo -e -n " Current Brightness:" ${YLO}${CURRENT_BRIGHTNESS}"%"${RESET}
  read -n1 junk

  case $junk in
    "u") brillo -q -A 1 ;;
    "d") brillo -q -U 1 ;;
    "x") break ;;
    *) echo -n "Invalid Input! Try: u/d/x" ;;
  esac
done
clear

# ========================================================================== #
#                               STORING VALUES                               #
# ========================================================================== #

# Sourcing Config file
CONFIG_FILE=~/Mid_Hunter/scripts/set_brightness.conf
source ${CONFIG_FILE}

# Getting Values
INTERVALS=15
HOUR=$(date +"%H")
MINUTE=$(date +"%M")
MINUTE=$(( (INTERVALS - (10#$MINUTE % INTERVALS) + 10#$MINUTE) ))
# Jump to next hour if 60
if [[ $MINUTE_CEIL == 60 ]]; then
  HOUR=$((10#$HOUR + 1))
  printf -v HOUR "%02d" $HOUR
  MINUTE_CEIL=00
fi

STORED_VARIABLE="BR_${HOUR}_${MINUTE}"
STORED_BRIGHTNESS=${!STORED_VARIABLE}
AVERAGE_BRIGHTNESS=$(awk "BEGIN { printf \"%.2f\", ($STORED_BRIGHTNESS + $CURRENT_BRIGHTNESS) / 2 }")

# Set value in config for next time
sed -i "s/\($STORED_VARIABLE *= *\).*/\1$AVERAGE_BRIGHTNESS/" $CONFIG_FILE
