#!/usr/bin/env bash

# Check if Hyprland is still running
if pgrep -x Hyprland >/dev/null; then
  # Hyprland is alive, kill it gracefully
  hyprctl dispatch exit 0
  sleep 2
  # If Hyprland didn't exit gracefully, kill it forcefully
  if pgrep -x Hyprland >/dev/null; then
    killall -9 Hyprland
  fi
fi
