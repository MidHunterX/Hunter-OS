#!/usr/bin/env bash

BLU='\033[0;34m'
YLO='\033[0;33m'
RESET='\033[0;0m'

while true
do
  # Get le Brightness Value
  CURRENT_BRIGHTNESS=$(brillo -r)
  # BAR=$(seq -s "─" 0 ${CURRENT_BRIGHTNESS:0:-3} | sed 's/[0-9]//g')
  BAR=$(echo "$(printf '─%.0s' $(seq 1 ${CURRENT_BRIGHTNESS:0:-3}))")

  clear
  echo ""
  echo -e ${BLU}" Hunter Brightness Script (u/d/x)"${RESET}
  echo          " --------------------------------"
  # Looong stikk sequenze
  echo -e -n " 󰃟 " ${YLO}${BAR:0:27} ${RESET}"\n"
  echo -e -n " Current Brightness:" ${YLO}${CURRENT_BRIGHTNESS}${RESET}
  read -n1 junk

  case $junk in
    "u") brillo -r -A 1 ;;
    "d") brillo -r -U 1 ;;
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
INTERVALS=15

# CURRENT, PREVIOUS AND NEXT HOUR VARIABLES
THIS_HOUR=$(date +"%H")
THIS_MIN=$(date +"%M")
# Jump to Next datapoint if Min > 30
if [[ $THIS_MIN > 30 ]]; then
  THIS_HOUR=$((10#$THIS_HOUR+1))
  printf -v THIS_HOUR "%02d" $THIS_HOUR
fi
NEXT_HOUR=$((10#$THIS_HOUR+1))
PREV_HOUR=$((10#$THIS_HOUR-1))
printf -v NEXT_HOUR "%02d" $NEXT_HOUR
printf -v PREV_HOUR "%02d" $PREV_HOUR
# Boundary handling for the current hour
if [[ $THIS_HOUR == 00 ]]; then PREV_HOUR=23; fi
if [[ $THIS_HOUR == 23 ]]; then NEXT_HOUR=00; fi
PREV_VAR="BR_${PREV_HOUR}_00"
THIS_VAR="BR_${THIS_HOUR}_00"
NEXT_VAR="BR_${NEXT_HOUR}_00"
PREV_VAL="${!PREV_VAR}"
THIS_VAL="${!THIS_VAR}"
NEXT_VAL="${!NEXT_VAR}"


# Update Average Brightness
AVG_BR=$(awk "BEGIN {printf \"%.2f\", ($THIS_VAL + $CURRENT_BRIGHTNESS) / 2}")
# Roundoff into integer
AVG_BR=$(printf "%.0f" $AVG_BR)
# Set value in config for next time
sed -i "s/\($THIS_VAR *= *\).*/\1$AVG_BR/" $CONFIG_FILE
# Update New value for generating gradient
THIS_VAL="${AVG_BR}"


DIVISIONS=$((60/$INTERVALS))


# UPDATE Linear Gradient - from PREV to THIS
# ------------------------------------------
# BRIGHTNESS DIFFERENCE (Floating Point Arithmetic)
BR_DIFF=$(echo | awk "{print $THIS_VAL - $PREV_VAL}")
DIV_INC=$(echo | awk "{print $BR_DIFF / $DIVISIONS}")
printf -v DIV_INC "%.2f" $DIV_INC

# LOG: PREV VARIABLE
echo "${PREV_VAR} = ${PREV_VAL}"

# Generate Interval Values
DIV_POINT=00
for ((i = 1; i < $DIVISIONS; i++)); do
  DIV_POINT=$((10#$DIV_POINT+$INTERVALS))
  printf -v DIV_POINT "%02d" $DIV_POINT
  # Interval Variable Names
  DIV_VAR="BR_${PREV_HOUR}_${DIV_POINT}"
  # Generated Values in float
  GEN_VAL=$(echo | awk "{print $PREV_VAL + ($DIV_INC * $i)}")
  # Roundoff into integer
  GEN_VAL=$(printf "%.0f" $GEN_VAL)
  # Update linear gradient in config
  echo "${DIV_VAR} = ${GEN_VAL}"
  sed -i "s/\($DIV_VAR *= *\).*/\1$GEN_VAL/" $CONFIG_FILE
done

# LOG: THIS VARIABLE
echo -e "\033[1;32m${THIS_VAR} = ${THIS_VAL}\033[0;0m"

# UPDATE Linear Gradient - from THIS to NEXT
# ------------------------------------------
# BRIGHTNESS DIFFERENCE (Floating Point Arithmetic)
BR_DIFF=$(echo | awk "{print $NEXT_VAL - $THIS_VAL}")
DIV_INC=$(echo | awk "{print $BR_DIFF / $DIVISIONS}")
printf -v DIV_INC "%.2f" $DIV_INC

# Generate Interval Values
DIV_POINT=00
for ((i = 1; i < $DIVISIONS; i++)); do
  DIV_POINT=$((10#$DIV_POINT+$INTERVALS))
  printf -v DIV_POINT "%02d" $DIV_POINT
  # Interval Variable Names
  DIV_VAR="BR_${THIS_HOUR}_${DIV_POINT}"
  # Generated Values in float
  GEN_VAL=$(echo | awk "{print $THIS_VAL + ($DIV_INC * $i)}")
  # Roundoff into integer
  GEN_VAL=$(printf "%.0f" $GEN_VAL)
  # Update linear gradient in config
  echo "${DIV_VAR} = ${GEN_VAL}"
  sed -i "s/\($DIV_VAR *= *\).*/\1$GEN_VAL/" $CONFIG_FILE
done

# LOG: NEXT VARIABLE
echo "${NEXT_VAR} = ${NEXT_VAL}"
