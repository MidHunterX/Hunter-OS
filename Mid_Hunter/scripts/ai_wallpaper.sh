#!/usr/bin/env bash

# Get the directory of the current script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source $SCRIPT_DIR/ai_wallpaper.conf
# source ./ai_wallpaper.conf  # For LSP

normal_dir=$D_NORMAL
custom_dir=$D_CUSTOM


# █▀▀ █░█ █▀▀ █▀▀ █▄▀ █▀
# █▄▄ █▀█ ██▄ █▄▄ █░█ ▄█

# Check if Wallpaper Daemon is running
for ((i = 0; i < 5; i++)); do
  if ! swww query; then
    echo "checking..."
  else
    echo "info: 🔥 SWWW Daemon Found"
    break
  fi
  sleep 1
done

# "Check if script is already running"; $0 == filename; $$ == PID
if [[ `pgrep -f $0` != "$$" ]]; then
  echo "info:🔥 Another instance of shell already exist!"
  echo "log: Updating Wallpaper..."
  swww img $normal_dir/$(date +"%H").jpg
  echo "Exiting"
  exit
fi


while [[ 1 ]]; do
  MINUTES_TO_WAIT=60
  HOUR=$(date +"%H")
  MINUTE=$(date +"%M")
  # 10# == "base 10"; because "0.*" == "octal"
  WAIT=$(((MINUTES_TO_WAIT - (10#$MINUTE % MINUTES_TO_WAIT))*60))


  # █▀▄ █▀▀ █▀▀ █ █▀ █ █▀█ █▄░█
  # █▄▀ ██▄ █▄▄ █ ▄█ █ █▄█ █░▀█

  # Normal Wallpaper vs Custom Wallpaper
  CONTENT="T_${HOUR}00"
  if [[ ${!CONTENT} ]]; then
    echo 'log: 📝 Selecting Special Wallpaper'
    image=$custom_dir/${!CONTENT}

  else
    echo 'log: 📝 Selecting Normal Wallpaper'
    image=$normal_dir/$HOUR
  fi


  # █▀▀ ▀▄▀ █▀▀ █▀▀ █░█ ▀█▀ █ █▀█ █▄░█
  # ██▄ █░█ ██▄ █▄▄ █▄█ ░█░ █ █▄█ █░▀█

  if [[ -e "$image.jpg" ]]; then
    # Do Wallpaper
    echo 'log: ✅ Setting up Wallpaper'
    swww img "$image.jpg"
    notify-send "Tip: Replenish your health with water"

  elif [[ -e "$normal_dir/$HOUR.jpg" ]]; then
    # Fallback Wallpaper
    echo "log: ❌ Special Wallpaper does not exist"
    echo 'log: ✅ Falling back to Normal Wallpaper'
    swww img "$normal_dir/$HOUR.jpg"

  else
    # No Wallpaper :(
    echo "log: ❌ Cannot find any Wallpapers O_O"
  fi


  # █░█░█ ▄▀█ █ ▀█▀
  # ▀▄▀▄▀ █▀█ █ ░█░

  echo "log: ⏳ Waiting for $WAIT seconds..."
  sleep $WAIT
done
