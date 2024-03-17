#!/usr/bin/env bash
minutes(){ echo $(($1*60));}

# "Check if script is already running"; $0 == filename; $$ == PID
if [[ `pgrep -f $0` != "$$" ]]; then
  echo "Another instance of shell already exist!"
  echo "Exiting"
  exit
fi

# Get the directory of the current script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# source ~/Mid_Hunter/scripts/archchan/profile/profile.sh # for LSP
source $SCRIPT_DIR/profile/profile.sh
profile.arch hot

check_interval=$(minutes 5)
WARM_TEMP=55

while :; do
  arch.updateCpuTemp
  if [[ $CPU_TEMP -gt $WARM_TEMP ]]; then
    arch.message "CPU TEMP @ ${CPU_TEMP}°C. Getting a little bit hot in here."
  fi
  sleep $check_interval
done
