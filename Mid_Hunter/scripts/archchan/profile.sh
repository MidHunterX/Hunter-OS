source ./memory.sh


profile.arch() {
  NAME="Arch Chan"
  IMG=~/Mid_Hunter/scripts/archchan/assets/arch_chan.jpg
  HINTS="-h string:frcolor:#5cc0ff "
  HINTS+="-h string:bgcolor:#1f3847 "
}


# =========================== [ ADMIN FUNCTIONS ] =========================== #


reportBattery() {
  archchan.batteryStatus
  if [[ $BATTERY_STATUS == 'Not charging' ]]; then
    BAT_COLOR=#ffffff
  elif [[ $BATTERY -ge 80 ]]; then
    BAT_COLOR=#8aee9f
  elif [[ $BATTERY -ge 60 ]]; then
    BAT_COLOR=#def564
  elif [[ $BATTERY -ge 40 ]]; then
    BAT_COLOR=#fbd173
  elif [[ $BATTERY -ge 20 ]]; then
    BAT_COLOR=#ff9797
  elif [[ $BATTERY -ge 0 ]]; then
    BAT_COLOR=#fd0000
  fi
  archchan.batteryCapacity
  HINTS2="-h string:hlcolor:$BAT_COLOR "
  HINTS2+="-h int:value:$BATTERY "

  notify-send $HINTS $HINTS2 -i $IMG "$NAME" "Battery: $BATTERY% ($(cat /sys/class/power_supply/BAT0/power_now | awk '{ printf "%.1f\n", $1 / 1000000 }')W)"
}


message() {
  notify-send $HINTS -i $IMG "$NAME" "$1"
}
