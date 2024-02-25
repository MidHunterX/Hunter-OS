#!/usr/bin/bash

image_dir=~/Mid_Hunter/customization/wallpaper/24h_vibe/

# "Check if script is already running"; $0 == filename; $$ == PID
if [[ `pgrep -f $0` != "$$" ]]; then
  echo "Another instance of shell already exist!"
  echo "Updating Wallpaper . . ."
  swww img $image_dir/$(date +"%H").jpg
  echo "Exiting"
  exit
fi

# Grace period for Wallpaper Daemon to start
sleep 1

while [[ 1 ]]; do
  MINUTES_TO_WAIT=60

  HOUR=$(date +"%H")
  MINUTE=$(date +"%M")
  # 10# == "base 10"; because "0.*" == "octal"
  WAIT=$(((MINUTES_TO_WAIT - (10#$MINUTE % MINUTES_TO_WAIT))*60))
  image=$image_dir$HOUR

  if [[ -e "$image.jpg" ]]; then
    swww img "$image.jpg"
    notify-send "Tip: Replenish your health with water"
  else
    echo "Pic not exist: $image_dir"
  fi

  echo $WAIT
  sleep $WAIT
done
