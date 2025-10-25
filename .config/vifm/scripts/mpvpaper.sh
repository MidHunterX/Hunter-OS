#!/bin/sh

if command -v swww >/dev/null 2>&1; then
  # Installed
  if pgrep swww >/dev/null 2>&1; then
    # Running
    swww kill
  fi
fi

pkill expression

mpvpaper -o "no-audio loop" eDP-1 "$1"
