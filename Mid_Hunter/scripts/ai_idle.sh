#!/bin/bash
minutes(){ echo $(($1*60));}

DISPLAY_OFF=$(minutes 5)
SUSPEND=$(minutes 15)

swayidle -w \
  timeout $DISPLAY_OFF 'hyprctl dispatch dpms off' \
  resume 'hyprctl dispatch dpms on' \
  timeout $SUSPEND 'systemctl suspend' \
  resume 'hyprctl dispatch dpms on'
