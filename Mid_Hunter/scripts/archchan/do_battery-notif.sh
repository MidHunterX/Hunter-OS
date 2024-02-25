#!/bin/bash
minutes(){ echo $(($1*60));}

source $(dirname "$0")/archchan.sh
profile.arch
arch.updateBatteryPercent

check_interval=$(minutes 5)
bat_interval=5
bat_prev=$BATTERY
bat_next=0
turnaround=1

while :; do
  arch.updateBatteryPercent
  battery=$BATTERY


  # ▀█▀ █░█ █▀█ █▄░█ ▄▀█ █▀█ █▀█ █░█ █▄░█ █▀▄
  # ░█░ █▄█ █▀▄ █░▀█ █▀█ █▀▄ █▄█ █▄█ █░▀█ █▄▀

  if [[ $battery -eq $bat_prev && turnaround -eq 1 ]]; then
    turnaround=0
    arch.updateBatteryStatus
    arch.reportBattery
    bat_prev=$battery
    if [[ $BATTERY_STATUS == 'Discharging' ]]; then
      bat_next=$(( battery - (battery % bat_interval) ))
    else
      bat_next=$(( battery + (battery % bat_interval) ))
    fi
  fi


  # █▀▄ █ █▀ █▀▀ █░█ ▄▀█ █▀█ █▀▀ █▀▀   ▀▄▀ █▀▄
  # █▄▀ █ ▄█ █▄▄ █▀█ █▀█ █▀▄ █▄█ ██▄   █░█ █▄▀

  if [[ $battery -lt bat_prev ]]; then
    echo "Disacharge Script"
    # Send Notification at exact measurement
    if [[ $((battery % bat_interval)) -eq 0 && $battery -ne $bat_prev ]]; then
      turnaround=1
      arch.reportBattery 'Discharging'
      bat_prev=$battery
      bat_next=$((bat_prev - bat_interval))
    fi
    # Send Notification if exact measurement is missed
    if [[ $battery -le $bat_next ]]; then
      turnaround=1
      arch.reportBattery 'Discharging'
      bat_next=$(( battery - (battery % bat_interval) ))
    fi
  fi


  # █▀▀ █░█ ▄▀█ █▀█ █▀▀ █ █▄░█ █▀▀
  # █▄▄ █▀█ █▀█ █▀▄ █▄█ █ █░▀█ █▄█

  if [[ $battery -gt bat_prev ]]; then
    echo "Charging Script"
    # Send Notification at exact measurement
    if [[ $((battery % bat_interval)) -eq 0 && $battery -ne $bat_prev ]]; then
      turnaround=1
      arch.reportBattery 'Charging'
      bat_prev=$battery
      bat_next=$((bat_prev + bat_interval))
    fi
    # Send Notification if exact measurement is missed
    if [[ $battery -ge $bat_next ]]; then
      turnaround=1
      arch.reportBattery 'Charging'
      bat_next=$(( battery + (battery % bat_interval) ))
    fi
  fi


  sleep $check_interval
done
