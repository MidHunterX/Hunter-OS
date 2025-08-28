#!/usr/bin/env bash

# "Check if script is already running"; $0 == filename; $$ == PID
if [[ `pgrep -f $0` != "$$" ]]; then
  echo "Another instance of shell already exist!"
  exit
fi

INTERVALS=15

# Sourcing Config file
CONFIG_FILE=~/Mid_Hunter/scripts/set_brightness.conf
source ${CONFIG_FILE}

while [[ 1 ]]; do
  HOUR=$(date +"%H")
  MINUTE=$(date +"%M")
  MINUTE_CEIL=$(( (INTERVALS - (10#$MINUTE % INTERVALS) + 10#$MINUTE) ))
  # Jump to next hour if 60
  if [[ $MINUTE_CEIL == 60 ]]; then
    HOUR=$((10#$HOUR + 1))
    printf -v HOUR "%02d" $HOUR
    MINUTE_CEIL=00
  fi
  WAIT=$((($INTERVALS - (10#$MINUTE % $INTERVALS))*60))

  STORED_VARIABLE="BR_${HOUR}_${MINUTE_CEIL}"
  STORED_BRIGHTNESS=${!STORED_VARIABLE}

  echo "$STORED_VARIABLE = $STORED_BRIGHTNESS"

  # Set Brightness
  brillo -u 5000000 -S ${STORED_BRIGHTNESS}

  echo $WAIT
  sleep $WAIT
done
