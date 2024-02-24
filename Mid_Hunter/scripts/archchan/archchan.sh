# source $(dirname "$0")/brain.sh
source ~/Mid_Hunter/scripts/archchan/brain.sh


profile.arch() {
  NAME="Arch Chan"
  IMG=~/Mid_Hunter/scripts/archchan/assets/arch_chan.jpg
  HINTS="-h string:frcolor:#5cc0ff "
  HINTS+="-h string:bgcolor:#1f3847 "
}


# =========================== [ ADMIN FUNCTIONS ] =========================== #


arch.reportBattery() {
  arch.updateBatteryStatus
  arch.updateBatteryPercent
  if [[ $BATTERY_STATUS == 'Not charging' ]]; then
    METER_COLOR=#ffffff
  elif [[ $BATTERY_STATUS == 'Charging' ]]; then
    METER_COLOR=#8aee9f
  elif [[ $BATTERY -ge 80 ]]; then
    METER_COLOR=#8aee9f
  elif [[ $BATTERY -ge 60 ]]; then
    METER_COLOR=#def564
  elif [[ $BATTERY -ge 40 ]]; then
    METER_COLOR=#fbd173
  elif [[ $BATTERY -ge 20 ]]; then
    METER_COLOR=#ff9797
  elif [[ $BATTERY -ge 0 ]]; then
    METER_COLOR=#fd0000
  fi
  HINTS2="-h string:hlcolor:$METER_COLOR "
  HINTS2+="-h int:value:$BATTERY "

  if [[ $1 ]]; then
    notify-send $HINTS $HINTS2 -i $IMG "$NAME" "Battery: $BATTERY%, is currently $1 at $(cat /sys/class/power_supply/BAT0/power_now | awk '{ printf "%.1f\n", $1 / 1000000 }')W"
  else
    notify-send $HINTS $HINTS2 -i $IMG "$NAME" "Battery is at $BATTERY%!"
  fi
}


arch.message() {
  notify-send $HINTS -t 5000 -i $IMG "$NAME" "$1"
}
