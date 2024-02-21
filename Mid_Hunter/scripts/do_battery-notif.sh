#!/bin/bash
minutes(){ echo $(($1*60));}

check_interval=$(minutes 10)
bat_interval=5
bat_prev=0
bat_next=0

while :; do
  battery=$(cat /sys/class/power_supply/BAT0/capacity)

  if [[ $((battery % bat_interval)) -eq 0 && $battery -ne $bat_prev ]]; then
    notify-send "Battery: ${battery}%"
    bat_prev=$battery
    bat_next=$((bat_prev - bat_interval))
  fi

  if [[ $battery -le $bat_next ]]; then
    notify-send "Battery: ${battery}%"
    bat_next=$(( battery - (battery % bat_interval) ))
  fi

  sleep $check_interval
done
