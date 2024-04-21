#!/usr/bin/env bash

# Power Status
flag=$(cat /sys/class/net/wl*/flags)
if [ "$flag" = "0x1003" ]; then
  power="On"
else
  power="Off"
fi

# Connection Status
state=$(cat /sys/class/net/wl*/operstate)
if [ "$state" = "up" ]; then
  status=$(nmcli | grep "^wlp" | sed 's/\ connected\ to/Connected to/' | cut -d ':' -f2)
else
  status="Disconnected"
fi

# Power Toggle Switch
powertoggle=$( [ "$flag" = "0x1003" ] && echo "Power Off" || echo "Power On" )
powerswitch() {
  if [ "$powertoggle" = "Power Off" ]; then
    nmcli radio wifi off
  elif [ "$powertoggle" = "Power On" ]; then
    nmcli radio wifi on
  fi
}



# █▀▀ █▀█ █▄░█ █▄░█ █▀▀ █▀▀ ▀█▀
# █▄▄ █▄█ █░▀█ █░▀█ ██▄ █▄▄ ░█░

connections() {
  list=$(nmcli --fields "SECURITY,SSID" device wifi list \
    | tail -n +2 | sed "s/  */ /g" \
    | sed -E "s/WPA*.?//g" | sed "s/^--//g" | sed "s/ //g")
  networks=$(printf "$list" | fuzzel --dmenu -p "Select Wifi Network: ")
  ssid=$( echo "$networks" | sed "s/ //g" | sed "s/ //g" | xargs)
  echo "Log: SSID=$ssid"
  [ -z "$networks" ] && exit
  nopass="No Password"
  pass=$(printf "$nopass\nCancel" | fuzzel --dmenu -p "Wifi Password: ")

  if [ "$pass" = "" ]; then
    exit
  elif [ "$pass" = "$nopass" ]; then
    nmcli device wifi connect "$ssid" && printf "exit" | fuzzel --dmenu -p "Connected to $ssid" && exit
  elif [ "$pass" = "Cancel" ]; then
    exit
  else
    nmcli device wifi connect "$ssid" password "$pass" &&  printf "exit" | fuzzel --dmenu -p "Connected to $ssid" && exit
  fi

  printf "exit" | fuzzel --dmenu -p "Failed to Connect $ssid" && exit
}


# █▀▀ █▀█ █▄░█ █▄░█ █▀▀ █▀▀ ▀█▀   █▀█ █▀█ ▀█▀ █ █▀█ █▄░█ █▀
# █▄▄ █▄█ █░▀█ █░▀█ ██▄ █▄▄ ░█░   █▄█ █▀▀ ░█░ █ █▄█ █░▀█ ▄█

options="SSID List\n$powertoggle"
if [[ $power == 'On' ]]; then
  selection=$(printf "$options" | fuzzel --dmenu -p "Wifi: $status")
else
  selection=$(printf "$options" | fuzzel --dmenu -p "Wifi is $power")
fi

case $selection in
  $powertoggle)
    powerswitch
    ;;
  "SSID List")
    notify-send "Scanning" -t 5000
    connections
esac 2>/dev/null

