#!/usr/bin/env bash

# usage: switch_now.sh <workspace>
hyprctl keyword animations:enabled false
hyprctl dispatch workspace "$1"
sleep 0.2  # adjust based on your animation speed
hyprctl keyword animations:enabled true
