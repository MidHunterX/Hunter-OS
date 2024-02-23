#!/bin/bash
minutes(){ echo $(($1*60));}

check_interval=$(minutes 5)
bat_interval=5
bat_prev=$(cat /sys/class/power_supply/BAT0/capacity)
bat_next=$((bat_prev - bat_interval))

while :; do
  battery=$(cat /sys/class/power_supply/BAT0/capacity)


  # █▀▄ █ █▀ █▀▀ █░█ ▄▀█ █▀█ █▀▀ █▀▀   ▀▄▀ █▀▄
  # █▄▀ █ ▄█ █▄▄ █▀█ █▀█ █▀▄ █▄█ ██▄   █░█ █▄▀

  if [[ $battery -lt bat_prev ]]; then
    echo "Disacharge Script"
    # Send Notification at exact measurement
    if [[ $((battery % bat_interval)) -eq 0 && $battery -ne $bat_prev ]]; then
      notify-send "Battery Level: ${battery}%" "Discharging at the rate of $(cat /sys/class/power_supply/BAT0/power_now | awk '{ printf "%.1f\n", $1 / 1000000 }') W"
      bat_prev=$battery
      bat_next=$((bat_prev - bat_interval))
    fi
    # Send Notification if exact measurement is missed
    if [[ $battery -le $bat_next ]]; then
      notify-send "Battery Level: ${battery}%" "Discharging at the rate of $(cat /sys/class/power_supply/BAT0/power_now | awk '{ printf "%.1f\n", $1 / 1000000 }') W"
      bat_next=$(( battery - (battery % bat_interval) ))
    fi
  fi


  # █▀▀ █░█ ▄▀█ █▀█ █▀▀ █ █▄░█ █▀▀
  # █▄▄ █▀█ █▀█ █▀▄ █▄█ █ █░▀█ █▄█

  if [[ $battery -gt bat_prev ]]; then
    echo "Charging Script"
    # Send Notification at exact measurement
    if [[ $((battery % bat_interval)) -eq 0 && $battery -ne $bat_prev ]]; then
      notify-send "Battery Level: ${battery}%" "Charging at the rate of $(cat /sys/class/power_supply/BAT0/power_now | awk '{ printf "%.1f\n", $1 / 1000000 }') W"
      bat_prev=$battery
      bat_next=$((bat_prev + bat_interval))
    fi
    # Send Notification if exact measurement is missed
    if [[ $battery -ge $bat_next ]]; then
      notify-send "Battery Level: ${battery}%" "Charging at the rate of $(cat /sys/class/power_supply/BAT0/power_now | awk '{ printf "%.1f\n", $1 / 1000000 }') W"
      bat_next=$(( battery + (battery % bat_interval) ))
    fi
  fi


  sleep $check_interval
done
